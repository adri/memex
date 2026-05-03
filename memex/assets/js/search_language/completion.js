// GitHub-style autocomplete engine. Reuses the Lezer parse tree (already
// produced by the search-language extension for syntax highlighting) to
// decide whether the cursor is on a key or a value, then matches against
// the catalog the LiveView pushed at mount.

import { syntaxTree } from "@codemirror/language";
import { startCompletion } from "@codemirror/autocomplete";
import * as terms from "./syntax.terms.js";
import { parseStateToFilters } from "./index.js";

function indexCatalog(catalog) {
  const byKey = Object.create(null);
  for (const entry of catalog.keys) byKey[entry.key] = entry;
  return byKey;
}

function classifyContext(state, pos) {
  const tree = syntaxTree(state);
  const node = tree.resolveInner(pos, -1);

  for (let n = node; n; n = n.parent) {
    if (n.type.id === terms.FilterValue) {
      const filterExpr = n.parent;
      const keyNode = filterExpr && filterExpr.firstChild;
      if (keyNode && keyNode.type.id === terms.FilterKey) {
        return {
          mode: "value",
          key: state.doc.sliceString(keyNode.from, keyNode.to),
          from: n.from,
          to: pos,
        };
      }
    }
    if (n.type.id === terms.FilterExpression) break;
  }

  const before = state.doc.sliceString(Math.max(0, pos - 64), pos);
  const valueAfterColon = before.match(/(?:^|[\s()])([a-zA-Z_]\w*)\s*[:=]\s*("?)([^"\s]*)$/);
  if (valueAfterColon) {
    const [, key, , partial] = valueAfterColon;
    return { mode: "value", key, from: pos - partial.length, to: pos };
  }

  const keyMatch = before.match(/(?:^|[\s()])([a-zA-Z_]\w*)?$/);
  const partial = (keyMatch && keyMatch[1]) || "";
  return { mode: "key", partial, from: pos - partial.length, to: pos };
}

function valueOptions(catalog, key, partial) {
  const byKey = indexCatalog(catalog);
  const entry = byKey[key];
  if (!entry || entry.values.length === 0) return [];

  const needle = partial.toLowerCase();
  return entry.values
    .filter((v) => !needle || v.value.toLowerCase().includes(needle))
    .map((v) => {
      const startsWith = v.value.toLowerCase().startsWith(needle);
      return {
        label: v.value,
        detail: v.description,
        type: "value",
        apply: maybeQuote(v.value),
        boost: startsWith ? 30 : 0,
      };
    });
}

function keyOptions(catalog, partial, usedKeys, hasChart) {
  const used = new Set(usedKeys);
  const needle = partial.toLowerCase();

  return catalog.keys
    .filter((entry) => !needle || entry.name.toLowerCase().includes(needle) || entry.key.toLowerCase().includes(needle))
    .map((entry) => {
      const matches =
        entry.key.toLowerCase().startsWith(needle) ||
        entry.name.toLowerCase().startsWith(needle);
      let boost = 0;
      if (matches) boost += 30;
      if (hasChart && entry.chart_followup) boost += 50;
      if (used.has(entry.key)) boost -= 99;

      return {
        // Readable, GitHub-style label.
        label: entry.name,
        // Small muted hint showing what gets inserted.
        detail: `${entry.key}:`,
        // Custom type drives a CSS class for the icon (cm-completionIcon-<type>).
        type: entry.icon || "field",
        apply: applyKey(entry.key),
        boost,
        info: entry.description ? () => infoElement(entry) : undefined,
      };
    });
}

// Build an `apply` function that inserts `key:` at the cursor and
// immediately re-triggers autocompletion so the user can pick a value.
function applyKey(key) {
  return (view, _completion, from, to) => {
    const insert = `${key}:`;
    view.dispatch({
      changes: { from, to, insert },
      selection: { anchor: from + insert.length },
    });
    // Defer past the current dispatch so the new tree is in place.
    Promise.resolve().then(() => startCompletion(view));
  };
}

function infoElement(entry) {
  const el = document.createElement("div");
  el.className = "cm-completionInfo-body";
  el.textContent = entry.description;
  return el;
}

function maybeQuote(value) {
  return /\s/.test(value) ? `"${value}"` : value;
}

export function buildCompletions(context, catalog) {
  if (!catalog || !catalog.keys) return null;

  const { state, pos, explicit } = context;
  const ctx = classifyContext(state, pos);

  if (ctx.mode === "value") {
    const partial = state.doc.sliceString(ctx.from, ctx.to);
    const options = valueOptions(catalog, ctx.key, partial);
    if (options.length === 0 && !explicit) return null;
    // No `validFor` on purpose: we recompute substring matches on every
    // keystroke so typing further into a key/value keeps narrowing the
    // results instead of being frozen on whatever matched first.
    return { from: ctx.from, options, filter: false };
  }

  const tree = syntaxTree(state);
  const filters = parseStateToFilters(state.doc.toString(), tree);
  const usedKeys = filters.filter((f) => f.key).map((f) => f.key);
  const hasChart = usedKeys.includes("chart");

  const options = keyOptions(catalog, ctx.partial, usedKeys, hasChart);
  if (options.length === 0 && !explicit) return null;
  return { from: ctx.from, options, filter: false };
}
