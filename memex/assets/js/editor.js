import { keymap, EditorView, placeholder } from "@codemirror/view";
import {
  defaultHighlightStyle,
  syntaxHighlighting,
  foldKeymap,
} from "@codemirror/language";
import { EditorState } from "@codemirror/state";
import {
  autocompletion,
  completionKeymap,
  closeBrackets,
  closeBracketsKeymap,
  completionStatus,
} from "@codemirror/autocomplete";
import { css } from "@codemirror/lang-css";

// Enforces that the input won't split over multiple lines (basically prevents
// Enter from inserting a new line)
const singleLine = EditorState.transactionFilter.of((transaction) =>
  transaction.newDoc.lines > 1 ? [] : transaction
);

function myCompletions(context) {
  let word = context.matchBefore(/\w*/);
  if (word.from == word.to && !context.explicit) return null;
  return {
    from: word.from,
    options: [
      { label: "match", type: "keyword" },
      { label: "hello", type: "variable", info: "(World)" },
      { label: "magic", type: "text", apply: "⠁⭒*.✩.*⭒⠁", detail: "macro" },
    ],
  };
}

export const Editor = {
  mounted() {
    const view = new EditorView({
      state: EditorState.create({
        doc: this.el.value ?? "",
        extensions: [
          closeBrackets(),
          autocompletion({ closeOnBlur: false, maxRenderedOptions: 3 }),
          syntaxHighlighting(defaultHighlightStyle, { fallback: true }),
          singleLine,
          placeholder("Search..."),
          keymap.of([
            ...closeBracketsKeymap,
            ...foldKeymap,
            ...completionKeymap,
          ]),
          css(),
        ],
      }),
      parent: document.getElementById("editor"),
    });
    this.view = view;

    // Synchronise the form's textarea with the editor on change
    this.el.form.addEventListener("keyup", (event) => {
      event.preventDefault();

      console.log(completionStatus(view.state));
      if (
        ["ArrowUp", "ArrowDown", "Enter"].includes(event.code) &&
        completionStatus(view.state) != "active"
      ) {
        console.log("key-pressed", { key: event.code });
        this.pushEvent("key-pressed", { key: event.code });
        return;
      }

      this.pushEvent("search", { query: view.state.doc.toString() });
    });

    view.focus();
  },
  unmounted() {
    this.view.destroy();
  },
};
