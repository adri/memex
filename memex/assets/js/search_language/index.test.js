import { describe, expect } from "@jest/globals";
import { Search, parseStateToFilters } from "./index";

const search = (query) =>
  parseStateToFilters(query, Search().language.parser.parse(query));

describe("Search parser", () => {
  test("parse field equals", () => {
    expect(search("person:Peter")).toEqual([
      { type: "Equals", key: "person", value: "Peter" },
    ]);
    expect(search("person=Peter")).toEqual([
      { type: "Equals", key: "person", value: "Peter" },
    ]);
  });

  test("prefix search", () => {
    expect(search("d")).toEqual([{ type: "prefix", value: "d" }]);
    expect(search("d e")).toEqual([
      { type: "prefix", value: "d" },
      { type: "prefix", value: "e" },
    ]);
  });

  test("comparison", () => {
    expect(search("d>1")).toEqual([
      { type: "GreaterThan", key: "d", value: 1 },
    ]);
    expect(search("d>=1")).toEqual([
      { type: "GreaterThanEquals", key: "d", value: 1 },
    ]);
    expect(search("d<1")).toEqual([{ type: "LessThan", key: "d", value: 1 }]);
    expect(search("d<=1")).toEqual([
      { type: "LessThanEquals", key: "d", value: 1 },
    ]);
    expect(search("d<1.4")).toEqual([
      { type: "LessThan", key: "d", value: 1.4 },
    ]);
  });

  test("mixed", () => {
    expect(search("d:1 e")).toEqual([
      { type: "Equals", key: "d", value: "1" },
      { type: "prefix", value: "e" },
    ]);
    expect(search("e d:1")).toEqual([
      { type: "prefix", value: "e" },
      { type: "Equals", key: "d", value: "1" },
    ]);
  });
});
