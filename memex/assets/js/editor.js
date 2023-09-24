import {
  keymap,
  EditorView,
  placeholder,
  highlightSpecialChars,
} from "@codemirror/view";
import { CompletionContext } from "@codemirror/autocomplete";
import {
  defaultHighlightStyle,
  syntaxHighlighting,
  foldKeymap,
  HighlightStyle,
  syntaxTree,
} from "@codemirror/language";
import { EditorState } from "@codemirror/state";
import {
  autocompletion,
  completionKeymap,
  closeBrackets,
  closeBracketsKeymap,
  completionStatus,
  acceptCompletion,
} from "@codemirror/autocomplete";
import { Search, parseStateToFilters } from "./search_language";
import * as terms from "./search_language/syntax.terms.js";
import { tags } from "@lezer/highlight";
import { inlineSuggestion } from "codemirror-extension-inline-suggestion";

// Enforces that the input won't split over multiple lines (basically prevents
// Enter from inserting a new line)
const singleLine = EditorState.transactionFilter.of((transaction) =>
  transaction.newDoc.lines > 1 ? [] : transaction
);

// Nice query language:
// - https://www.meilisearch.com/docs/learn/fine_tuning_results/filtering
// - Qdrant: https://qdrant.tech/documentation/concepts/filtering/#geo
//   { filter: { must: [{ key: "", match: { value: "" } }] }, must_not: ..., should: ...}

// const query = [
//   { type: "provider", operator: "=", value: "Messages" }, // Auto convert "provider:Messages", "provider IN (Messages, Emails)"
//   { type: "provider", operator: "exists" }, // auto convert "provider exists"
//   { type: "provider", operator: "is_empty" }, // auto convert "provider is empty"
//   { type: "date", operator: ">=", value: "2022-03-01T00:00:00Z" }, // auto convert "date > 1 month ago"
//   { type: "_allSearchableFields", operator: "prefix", value: "Els" }, // auto convert "Els"
//   // auto convert '"Els Philipp" or "Els Remijnse"'
//   {
//     type: "or", operator: "", value: [ // ⚠️ no operator?
//       { type: "_allSearchableFields", operator: "=", value: "Els Philipp" },
//       { type: "_allSearchableFields", operator: "=", value: "Els Remijnse" },
//     ]
//   },
//   // auto convert "Els near Amsterdam" or "Els near Amsterdam within 20km". "near + [city] + within [distance]"
//   {
//     type: "_geoRadius",
//     operator: "radius",
//     value: {
//       type: "geopoint",
//       latitude: 32.1212312,
//       longitude: 4.0123123,
//       distance: "20km",
//     },
//   },
//   {
//     type: "_geoRadius",
//     operator: "radius",
//     value: {
//       type: "geopoint",
//       latitude: 32.1212312,
//       longitude: 4.0123123,
//       distance: "20km",
//     },
//   },
//   {
//     type: "",
//     operator: "",
//     value:,
//   },
// ];

const myHighlightStyle = HighlightStyle.define([
  {
    tag: tags.string,
    class: "bg-yellow-300/50 rounded-sm",
  },
  {
    tag: tags.propertyName,
    class: "dark:bg-gray-900 bg-gray-100 rounded-sm",
  },
  { tag: tags.invalid, class: "dark:bg-red-800 bg-red-200 rounded-sm" },
  { tag: tags.number, class: "dark:text-indigo-200 text-indigo-500" },
  { tag: tags.className, color: "red" },
  { tag: tags.arithmeticOperator, color: "blue" },
  { tag: tags.logicOperator, color: "#f5d", fontStyle: "italic" },
]);

export const Editor = {
  mounted() {
    const view = new EditorView({
      state: EditorState.create({
        doc: this.el.value ?? "",
        extensions: [
          closeBrackets(),
          syntaxHighlighting(defaultHighlightStyle, { fallback: true }),
          syntaxHighlighting(myHighlightStyle),
          highlightSpecialChars(),
          singleLine,
          placeholder("Search..."),
          keymap.of([
            ...closeBracketsKeymap,
            ...foldKeymap,
            ...completionKeymap,
          ]),
          Search(),
          autocompletion({
            icons: false,
            selectOnOpen: true,
            activateOnTyping: true,
            closeOnBlur: false,
            maxRenderedOptions: 3,
          }),
          keymap.of([{ key: "Tab", run: acceptCompletion }]), // needed because otherwise tab doesn't autocomplete
          Search().language.data.of({
            autocomplete: (context) => this.autocomplete(context),
          }),
          inlineSuggestion({
            fetchFn: async (state) => {
              console.log({ state });
              return "";
            },
            delay: 0,
          }),
        ],
      }),
      parent: document.getElementById("editor"),
    });
    this.view = view;

    // Synchronise the form's textarea with the editor on change
    this.el.form.addEventListener("keyup", (event) => {
      event.preventDefault();

      if (
        ["ArrowUp", "ArrowDown", "Enter"].includes(event.code) &&
        completionStatus(view.state) == null
      ) {
        console.log("key-pressed", { key: event.code });
        this.pushEvent("key-pressed", { key: event.code });
        return;
      }

      this.search();
    });

    this.el.form.addEventListener("addFilter", (event) =>
      this.addFilter(event)
    );
    this.el.form.addEventListener("removeFilter", (event) =>
      this.removeFilter(event)
    );
    this.el.form.addEventListener("resetFilters", (event) =>
      this.resetFilters(event)
    );
    this.el.form.addEventListener("search", (event) => this.search(event));

    view.focus();
  },
  addFilter(event) {
    const text = this.view.state.doc.toString();
    const filter = `${event.detail.key}:"${event.detail.value}"`;

    this.view.dispatch({
      changes: { from: 0, to: text.length, insert: `${text} ${filter}` },
    });
  },
  removeFilter(event) {
    const text = this.view.state.doc.toString();
    const pattern = new RegExp(`\\s*${event.detail.key}:".*"`);
    const match = pattern.exec(text);
    if (match == null) {
      return;
    }

    this.view.dispatch({
      changes: {
        from: match.index,
        to: match.index + match[0].length,
        insert: "",
      },
    });
  },
  resetFilters() {
    const text = this.view.state.doc.toString();
    this.view.dispatch({
      changes: { from: 0, to: text.length, insert: "" },
    });
  },
  search() {
    const query = this.view.state.doc.toString();
    const filters = parseStateToFilters(query, syntaxTree(this.view.state));
    console.log({ query, filters });

    this.pushEvent("search", { query, filters });
  },
  autocomplete(context) {
    const token = context.tokenBefore(["FilterExpression", "Identifier"]);
    if (!token || token.from == token.to) return null;

    const completion = {
      sources: ["keyword", "search", "field_keys", "field_values"],
      key: null,
      value: token?.text,
    };

    // Future to determine if this has been interrupted
    // const interruptedFuture = new Promise<'failed'>((resolve) => {
    //   context.addEventListener('abort', () => {
    //       resolve('failed')
    //   })
    // })

    // if (token.type.id == terms.FilterExpression) {
    //   completion.sources = ["field_values"];
    //   completion.key = token.firstChild;
    //   completion.value = token.firstChild?.nextSibling().nextSibling.value;
    // }

    console.log({ completion });

    return new Promise((resolve) => {
      this.pushEvent("completion", completion, (reply, ref) => {
        resolve({
          from: token.from,
          options: reply.options,
        });
      });
    });
  },
  unmounted() {
    this.view.destroy();
  },
};
