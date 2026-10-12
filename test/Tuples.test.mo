import Tuples "../src/Tuples";
import Array "../src/Array";
import Iter "../src/Iter";
import Map "../src/Map";
import Nat "../src/Nat";
import Order "../src/Order";
import Runtime "../src/Runtime";
import Text "../src/Text";
import { suite; test } "mo:test";

// `compare` and `equal` on `Bomb` trap, so a test passes only if they're never called
module Bomb {
  public type Bomb = { #bomb };
  public func compare(_ : Bomb, _ : Bomb) : Order.Order = Runtime.trap("element compared after the result was known");
  public func equal(_ : Bomb, _ : Bomb) : Bool = Runtime.trap("element compared after the result was known")
};
let bomb : Bomb.Bomb = #bomb;

func derivedCompare<T>(a : T, b : T, compare : (implicit : (T, T) -> Order.Order)) : Order.Order = compare(a, b);
func derivedEqual<T>(a : T, b : T, equal : (implicit : (T, T) -> Bool)) : Bool = equal(a, b);
func derivedToText<T>(value : T, toText : (implicit : T -> Text)) : Text = toText(value);

suite(
  "derived toText",
  func() {
    test(
      "pair",
      func() {
        assert derivedToText((1, "a")) == "(1, a)"
      }
    );
    test(
      "five elements",
      func() {
        assert derivedToText((1, "a", 2, "b", 3)) == "(1, a, 2, b, 3)"
      }
    );
    test(
      "nested",
      func() {
        assert derivedToText(((1, "a"), 2, 3, 4, (5, 6))) == "((1, a), 2, 3, 4, (5, 6))"
      }
    );
    test(
      "array of tuples",
      func() {
        assert [(1, "a", 2, "b", 3)].toText() == "[(1, a, 2, b, 3)]"
      }
    )
  }
);

suite(
  "derived equal",
  func() {
    test(
      "equal",
      func() {
        assert derivedEqual((1, "a", 2, "b", 3), (1, "a", 2, "b", 3))
      }
    );
    test(
      "last element differs",
      func() {
        assert not derivedEqual((1, "a", 2, "b", 3), (1, "a", 2, "b", 4))
      }
    );
    test(
      "stops at the first unequal element",
      func() {
        assert not derivedEqual((0, 2, 3, 4, bomb), (1, 2, 3, 4, bomb));
        assert not derivedEqual((0, bomb), (1, bomb))
      }
    )
  }
);

suite(
  "derived compare",
  func() {
    test(
      "lexicographic",
      func() {
        assert derivedCompare((1, "a", 2, "b", 3), (1, "a", 2, "b", 3)) == #equal;
        assert derivedCompare((1, "a", 2, "b", 3), (1, "a", 2, "b", 4)) == #less;
        assert derivedCompare((1, "b", 0, "a", 0), (1, "a", 9, "z", 9)) == #greater
      }
    );
    test(
      "stops at the first element that is not equal",
      func() {
        assert derivedCompare((1, 2, 3, 4, bomb), (0, 2, 3, 4, bomb)) == #greater;
        assert derivedCompare((0, bomb), (1, bomb)) == #less
      }
    );
    test(
      "sort",
      func() {
        let events = [(2026, 10, 12, 9, "standup"), (2026, 10, 12, 8, "coffee"), (2025, 1, 1, 0, "new year")];
        assert events.sort() == [(2025, 1, 1, 0, "new year"), (2026, 10, 12, 8, "coffee"), (2026, 10, 12, 9, "standup")]
      }
    );
    test(
      "map key",
      func() {
        let map = Map.empty<(Nat, Text, Nat, Text, Nat), Text>();
        map.add((1, "a", 2, "b", 3), "first");
        map.add((1, "a", 2, "b", 0), "second");
        assert map.get((1, "a", 2, "b", 0)) == ?"second";
        assert map.keys().toArray() == [(1, "a", 2, "b", 0), (1, "a", 2, "b", 3)]
      }
    )
  }
);
