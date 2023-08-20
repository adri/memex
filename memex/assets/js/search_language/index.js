import { parser } from "./syntax.js";
import * as terms from "./syntax.terms.js";
import {
  LRLanguage,
  LanguageSupport,
  bracketMatching,
  syntaxTree,
} from "@codemirror/language";
import { styleTags, tags as t } from "@lezer/highlight";

export const parseStateToFilters = (query, state) => {
  const filters = [];
  const tree = state;

  console.log({ tree: tree.toString() });
  let cursor = tree.cursor();

  do {
    if (
      [terms.Prefix, terms.NotPrefix, terms.Exact, terms.NotExact].includes(
        cursor.node.type.id
      )
    ) {
      filters.push({
        type: cursor.node.type.name,
        value: getNodeContent(query, cursor.node.firstChild),
      });
    }

    if (cursor.node.type.id === terms.FilterExpression) {
      filters.push({
        type: cursor.node.firstChild.nextSibling.type.name,
        key: getNodeContent(query, cursor.node.firstChild),
        value: getNodeContent(
          query,
          cursor.node.firstChild.nextSibling.nextSibling
        ),
      });
    }
  } while (cursor.next());

  return filters;
};

function getNodeContent(query, node) {
  const content = query.slice(node.from, node.to).trim().replace(/\"/g, "");

  if (node.type.id === terms.Number) {
    return Number(content);
  }

  return content;
}

export const SearchLanguage = LRLanguage.define({
  name: "search",
  parser: parser.configure({
    props: [
      styleTags({
        FilterKey: t.propertyName,
        FilterValue: t.string,
        Identifier: t.string,
        QuotedString: t.string,
        Prefix: t.arithmeticOperator,
        Number: t.number,
        // FilterExpression: t.definition,
        "and or && ||": t.logicOperator,
        ": > >= < <= =": t.compareOperator,
        "⚠": t.invalid,
        // "( )": t.paren,
        // "[ ]": t.squareBracket,
        // "{ }": t.brace,
      }),
    ],
  }),
  languageData: {
    // commentTokens: { line: ";" },
  },
});

export function Search() {
  return new LanguageSupport(
    SearchLanguage,
    bracketMatching({ brackets: "()" })
  );
}
