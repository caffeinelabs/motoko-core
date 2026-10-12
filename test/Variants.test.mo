import Variants "../src/Variants";
import Unit "../src/Unit";
import Array "../src/Array";
import Map "../src/Map";
import Nat "../src/Nat";
import Option "../src/Option";
import Text "../src/Text";
import { Tuple2 } "../src/Tuples";
import { suite; test } "mo:test";

func derivedToText<T>(value : T, toText : (implicit : T -> Text)) : Text = toText(value);

type Status = { #active; #suspended : Text; #banned : (Nat, Text) };
type Event = { #changed : Status; #deleted };
type Tree = { #leaf : Nat; #node : (Tree, Tree) };

let active : Status = #active;
let suspended : Status = #suspended "spam";
let banned : Status = #banned(3, "abuse");

suite(
  "derived toText",
  func() {
    test(
      "case without a payload",
      func() {
        assert derivedToText(active) == "#active"
      }
    );

    test(
      "payload",
      func() {
        assert derivedToText(suspended) == "#suspended(spam)"
      }
    );

    test(
      "tuple payload",
      func() {
        assert derivedToText(banned) == "#banned(3, abuse)"
      }
    );

    test(
      "variant payload",
      func() {
        let changed : Event = #changed banned;
        let deleted : Event = #deleted;
        assert derivedToText(changed) == "#changed(#banned(3, abuse))";
        assert derivedToText(deleted) == "#deleted"
      }
    );

    test(
      "recursive variant",
      func() {
        let tree : Tree = #node(#leaf 1, #node(#leaf 2, #leaf 3));
        assert derivedToText(tree) == "#node(#leaf(1), #node(#leaf(2), #leaf(3)))"
      }
    );

    test(
      "inside options, arrays, and maps",
      func() {
        let statuses : [?Status] = [?active, null];
        assert statuses.toText() == "[?#active, null]";
        let map = Map.empty<Nat, Status>();
        map.add(1, suspended);
        assert map.toText() == "Map{(1, #suspended(spam))}"
      }
    );

    test(
      "a payload that renders as `()` is dropped",
      func() {
        let note : { #note : Text } = #note "()";
        assert derivedToText(note) == "#note"
      }
    )
  }
)
