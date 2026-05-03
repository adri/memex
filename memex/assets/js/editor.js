import {
  keymap,
  EditorView,
  placeholder,
  highlightSpecialChars,
  tooltips,
} from "@codemirror/view";
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
import { buildCompletions } from "./search_language/completion";
import { tags } from "@lezer/highlight";

// Enforces that the input won't split over multiple lines (basically prevents
// Enter from inserting a new line)
const singleLine = EditorState.transactionFilter.of((transaction) =>
  transaction.newDoc.lines > 1 ? [] : transaction
);

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
    this.catalog = null;

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
          // Render the autocomplete tooltip into <body> so it escapes the
          // search bar's fixed stacking context and reliably overlays any
          // in-page content below (chart card, timeline, etc.).
          tooltips({ parent: document.body }),
          autocompletion({
            icons: true,
            selectOnOpen: true,
            activateOnTyping: true,
            closeOnBlur: false,
            maxRenderedOptions: 8,
          }),
          keymap.of([{ key: "Tab", run: acceptCompletion }]),
          Search().language.data.of({
            autocomplete: (context) => buildCompletions(context, this.catalog),
          }),
        ],
      }),
      parent: document.getElementById("editor"),
    });
    this.view = view;

    this.handleEvent("search:catalog", (catalog) => {
      this.catalog = catalog;
    });

    this.el.form.addEventListener("keyup", (event) => {
      event.preventDefault();

      if (
        ["ArrowUp", "ArrowDown", "Enter"].includes(event.code) &&
        completionStatus(view.state) == null
      ) {
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

    this.pushEvent("search", { query, filters });
  },
  unmounted() {
    this.view.destroy();
  },
};
