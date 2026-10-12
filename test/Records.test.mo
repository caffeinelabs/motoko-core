import Records "../src/Records";
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
  public func compare(_ : Bomb, _ : Bomb) : Order.Order = Runtime.trap("field compared after the result was known");
  public func equal(_ : Bomb, _ : Bomb) : Bool = Runtime.trap("field compared after the result was known")
};
let bomb : Bomb.Bomb = #bomb;

func derivedCompare<T>(a : T, b : T, compare : (implicit : (T, T) -> Order.Order)) : Order.Order = compare(a, b);
func derivedEqual<T>(a : T, b : T, equal : (implicit : (T, T) -> Bool)) : Bool = equal(a, b);
func derivedToText<T>(value : T, toText : (implicit : T -> Text)) : Text = toText(value);

type Person = { name : Text; age : Nat };
type Team = { lead : Person; members : [Person]; tag : (Text, Nat) };

let alice : Person = { name = "Alice"; age = 30 };
let bob : Person = { name = "Bob"; age = 25 };

suite(
  "derived toText",
  func() {
    test(
      "fields in lexicographic order",
      func() {
        assert derivedToText(alice) == "{age = 30; name = Alice}"
      }
    );
    test(
      "empty record",
      func() {
        assert derivedToText({}) == "{}"
      }
    );
    test(
      "nested records, arrays, and tuples",
      func() {
        let team : Team = { lead = alice; members = [bob]; tag = ("core", 1) };
        assert derivedToText(team) == "{lead = {age = 30; name = Alice}; members = [{age = 25; name = Bob}]; tag = (core, 1)}"
      }
    );
    test(
      "var fields",
      func() {
        let counter = { var count = 1 };
        counter.count += 1;
        assert derivedToText(counter) == "{count = 2}"
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
        assert derivedEqual(alice, { name = "Alice"; age = 30 });
        assert derivedEqual({}, {})
      }
    );
    test(
      "one field differs",
      func() {
        assert not derivedEqual(alice, { alice with age = 31 });
        assert not derivedEqual(alice, { alice with name = "Alicia" })
      }
    );
    test(
      "stops at the first unequal field",
      func() {
        assert not derivedEqual({ a = 0; b = bomb }, { a = 1; b = bomb })
      }
    )
  }
);

suite(
  "derived compare",
  func() {
    test(
      "fields in lexicographic order",
      func() {
        // `age` comes before `name`, so the older person is greater despite the name
        assert derivedCompare(alice, bob) == #greater;
        assert derivedCompare(alice, { alice with name = "Bob" }) == #less;
        assert derivedCompare(alice, alice) == #equal;
        assert derivedCompare({}, {}) == #equal
      }
    );
    test(
      "nested records",
      func() {
        let team1 : Team = { lead = alice; members = []; tag = ("core", 1) };
        let team2 : Team = { lead = alice; members = [bob]; tag = ("core", 0) };
        assert derivedCompare(team1, team2) == #less
      }
    );
    test(
      "stops at the first field that is not equal",
      func() {
        assert derivedCompare({ a = 1; b = bomb }, { a = 0; b = bomb }) == #greater
      }
    );
    test(
      "sort",
      func() {
        assert [alice, bob].sort() == [bob, alice]
      }
    );
    test(
      "map key",
      func() {
        let emails = Map.empty<Person, Text>();
        emails.add(alice, "alice@example.com");
        emails.add(bob, "bob@example.com");
        assert emails.get({ name = "Bob"; age = 25 }) == ?"bob@example.com";
        assert emails.keys().toArray() == [bob, alice]
      }
    )
  }
);
