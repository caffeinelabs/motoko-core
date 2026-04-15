// @testmode wasi

import Map "../../src/pure/Map";
import Nat "../../src/Nat";
import Iter "../../src/Iter";
import Debug "../../src/Debug";
import Array "../../src/Array";
import Option "../../src/Option";

import Suite "mo:matchers/Suite";
import T "mo:matchers/Testable";
import M "mo:matchers/Matchers";

let { run; test; suite } = Suite;

let c = Nat.compare;

let entryTestable = T.tuple2Testable(T.natTestable, T.textTestable);

class MapMatcher(expected : Map.Map<Nat, Text>) : M.Matcher<Map.Map<Nat, Text>> {
  public func describeMismatch(actual : Map.Map<Nat, Text>, _description : M.Description) {
    Debug.print(debug_show ((Map.entries(actual)).toArray()) # " should be " # debug_show ((Map.entries(expected)).toArray()))
  };

  public func matches(actual : Map.Map<Nat, Text>) : Bool {
    (Map.entries(actual)).toArray() == (Map.entries(expected)).toArray()
  }
};

object Random {
  var number = 4711;
  public func next() : Nat {
    number := (15485863 * number + 5) % 15485867;
    number
  };

  public func nextNat(range : (Nat, Nat)) : Nat {
    let n = next();
    let v = n % (range.1 - range.0 + 1) : Nat + range.0;
    v
  };

  public func nextEntries(range : (Nat, Nat), size : Nat) : [(Nat, Text)] {
    Array.tabulate<(Nat, Text)>(
      size,
      func(_ix) {
        let key = nextNat(range);
        (key, debug_show (key))
      }
    )
  }
};

func mapGen(samples_number : Nat, size : Nat, range : (Nat, Nat)) : Iter.Iter<Map.Map<Nat, Text>> {
  object {
    var n = 0;
    public func next() : ?Map.Map<Nat, Text> {
      n += 1;
      if (n > samples_number) {
        null
      } else {
        ?Map.fromIter(Random.nextEntries(range, size).vals(), c)
      }
    }
  }
};

func run_all_props(range : (Nat, Nat), size : Nat, map_samples : Nat, query_samples : Nat) {
  func prop(name : Text, f : Map.Map<Nat, Text> -> Bool) : Suite.Suite {
    var error_msg : Text = "";
    test(
      name,
      do {
        var error = true;
        label stop for (map in mapGen(map_samples, size, range)) {
          if (not f(map)) {
            error_msg := "Property \"" # name # "\" failed\n";
            error_msg #= "\n m: " # debug_show ((Map.entries(map)).toArray());
            break stop
          }
        };
        error_msg
      },
      M.describedAs(error_msg, M.equals(T.text("")))
    )
  };
  func prop_with_key(name : Text, f : (Map.Map<Nat, Text>, Nat) -> Bool) : Suite.Suite {
    var error_msg : Text = "";
    test(
      name,
      do {
        label stop for (map in mapGen(map_samples, size, range)) {
          for (_query_ix in Nat.range(0, query_samples)) {
            let key = Random.nextNat(range);
            if (not f(map, key)) {
              error_msg #= "Property \"" # name # "\" failed";
              error_msg #= "\n m: " # debug_show ((Map.entries(map)).toArray());
              error_msg #= "\n k: " # debug_show (key);
              break stop
            }
          }
        };
        error_msg
      },
      M.describedAs(error_msg, M.equals(T.text("")))
    )
  };
  run(
    suite(
      "Property tests",
      [
        suite(
          "empty",
          [
            test(
              "get(empty(), c, k) == null",
              label res : Bool {
                for (_query_ix in Nat.range(0, query_samples)) {
                  let k = Random.nextNat(range);
                  if (Map.get(Map.empty<Nat, Text>(), c, k) != null) break res(false)
                };
                true
              },
              M.equals(T.bool(true))
            )
          ]
        ),

        suite(
          "get & add",
          [
            prop_with_key(
              "get(add(m, c, k, v), c,  k) == ?v",
              func(m, k) {
                Map.get(Map.add(m, c, k, "v"), c, k) == ?"v"
              }
            ),
            prop_with_key(
              "get(add(add(m, c, k, v1), c, k, v2), c, k) == ?v2",
              func(m, k) {
                let (v1, v2) = ("V1", "V2");
                Map.get(Map.add(Map.add(m, c, k, v1), c, k, v2), c, k) == ?v2
              }
            )
          ]
        ),

        suite(
          "swap",
          [
            prop_with_key(
              "swap(m, c, k, v).0 == add(m, c, k, v)",
              func(m, k) {
                Map.swap(m, c, k, "v").0 == Map.add(m, c, k, "v")
              }
            ),
            prop_with_key(
              "swap(add(m, c, k, v1), c,  k, v2).1 == ?v1",
              func(m, k) {
                Map.swap(Map.add(m, c, k, "v1"), c, k, "v2").1 == ?"v1"
              }
            ),
            prop_with_key(
              "get(m, c, k) == null ==> swap(m, c, k, v).1 == null",
              func(m, k) {
                if (Map.get(m, c, k) == null) {
                  Map.swap(m, c, k, "v").1 == null
                } else { true }
              }
            )
          ]
        ),

        suite(
          "remove",
          [
            prop_with_key(
              "get(m, c, k) == null ==> remove(m, c, k) == m",
              func(m, k) {
                if (Map.get(m, c, k) == null) {
                  MapMatcher(m).matches(Map.remove(m, c, k))
                } else { true }
              }
            ),
            prop_with_key(
              "remove(add(m, c, k, v), c, k) == m",
              func(m, k) {
                if (Map.get(m, c, k) == null) {
                  MapMatcher(m).matches(Map.remove(Map.add(m, c, k, "v"), c, k))
                } else { true }
              }
            ),
            prop_with_key(
              "remove(remove(m, c, k), c, k)) == remove(m, c, k)",
              func(m, k) {
                let m1 = Map.remove(Map.remove(m, c, k), c, k);
                let m2 = Map.remove(m, c, k);
                MapMatcher(m2).matches(m1)
              }
            )
          ]
        ),

        suite(
          "take",
          [
            prop_with_key(
              "take(m, c, k).0 == remove(m, c, k)",
              func(m, k) {
                let m1 = Map.take(m, c, k).0;
                let m2 = Map.remove(m, c, k);
                MapMatcher(m2).matches(m1)
              }
            ),
            prop_with_key(
              "take(add(m, c k, v), c, k).1 == ?v",
              func(m, k) {
                Map.take(Map.add(m, c, k, "v"), c, k).1 == ?"v"
              }
            ),
            prop_with_key(
              "take(take(m, c, k).0, c, k).1 == null",
              func(m, k) {
                Map.take(Map.take(m, c, k).0, c, k).1 == null
              }
            ),
            prop_with_key(
              "add(take(m, c, k).0, c, k, take(m, c, k).1) == m",
              func(m, k) {
                if (Map.get(m, c, k) != null) {
                  MapMatcher(m).matches(Map.add(Map.take(m, c, k).0, c, k, Option.get(Map.take(m, c, k).1, "")))
                } else { true }
              }
            )
          ]
        ),

        suite(
          "size",
          [
            prop_with_key(
              "size(add(m, c, k, v)) == size(m) + int(get(m, c, k) == null)",
              func(m, k) {
                Map.size(Map.add(m, c, k, "v")) == Map.size(m) + (if (Map.get(m, c, k) == null) { 1 } else { 0 })
              }
            ),
            prop_with_key(
              "size(remove(m, c, k)) + int(get(m, c, k) != null) == size(m)",
              func(m, k) {
                Map.size(Map.remove(m, c, k)) + (if (Map.get(m, c, k) != null) { 1 } else { 0 }) == Map.size(m)
              }
            )
          ]
        ),

        prop(
          "search tree invariant",
          func(m) {
            Map.assertValid(m, c);
            true
          }
        ),

        suite(
          "keys,valuef,entries,reverseEntries",
          [
            prop(
              "fromIter(entries(m), c) == m",
              func(m) {
                MapMatcher(m).matches(Map.fromIter(Map.entries(m), c))
              }
            ),
            prop(
              "fromIter(entriesRev(m)) == m",
              func(m) {
                MapMatcher(m).matches(Map.fromIter(Map.reverseEntries(m), c))
              }
            ),
            prop(
              "entries(m) = zip(key(m), values(m))",
              func(m) {
                let k = Map.keys(m);
                let v = Map.values(m);
                for (e in Map.entries(m)) {
                  if (?e.0 != k.next() or ?e.1 != v.next()) return false
                };
                return true
              }
            ),
            prop(
              "Array.fromIter(entries(m)) == Array.fromIter(reverseEntries(m)).reverse()",
              func(m) {
                let a = (Map.entries(m)).toArray();
                let b = Array.reverse((Map.reverseEntries(m)).toArray());
                M.equals(T.array<(Nat, Text)>(entryTestable, a)).matches(b)
              }
            )
          ]
        ),

        suite(
          "filterMap",
          [
            prop_with_key(
              "get(filterMap(m, c, (!=k)), c, k) == null",
              func(m, k) {
                Map.get(
                  Map.filterMap<Nat, Text, Text>(
                    m,
                    c,
                    func(ki, vi) { if (ki != k) { ?vi } else { null } }
                  ),
                  c,
                  k
                ) == null
              }
            ),
            prop_with_key(
              "get(filterMap(add(m, c, k, v), c, (==k)), c, k) == ?v",
              func(m, k) {
                Map.get(
                  Map.filterMap<Nat, Text, Text>(
                    Map.add(m, c, k, "v"),
                    c,
                    func(ki, vi) { if (ki == k) { ?vi } else { null } }
                  ),
                  c,
                  k
                ) == ?"v"
              }
            )
          ]
        ),

        suite(
          "map",
          [
            prop(
              "map(m, id) == m",
              func(m) {
                MapMatcher(m).matches(Map.map<Nat, Text, Text>(m, func(k, v) { v }))
              }
            )
          ]
        ),

        suite(
          "folds",
          [
            prop(
              "foldLeft as entries()",
              func(m) {
                let it = Map.entries(m);
                Map.foldLeft<Nat, Text, Bool>(m, true, func(acc, k, v) { acc and it.next() == ?(k, v) })
              }
            ),
            prop(
              "foldRight as reverseEntries()",
              func(m) {
                let it = Map.reverseEntries(m);
                Map.foldRight<Nat, Text, Bool>(m, true, func(k, v, acc) { acc and it.next() == ?(k, v) })
              }
            )
          ]
        ),

        suite(
          "all/any",
          [
            prop(
              "all through fold",
              func(m) {
                let pred = func(k : Nat, v : Text) : Bool = (k <= (range.1 - 2 : Nat) and range.0 + 2 <= k);
                Map.all(m, pred) == Map.foldLeft<Nat, Text, Bool>(m, true, func(acc, k, v) { acc and pred(k, v) })
              }
            ),
            prop(
              "any through fold",
              func(m) {
                let pred = func(k : Nat, v : Text) : Bool = (k >= (range.1 - 1 : Nat) or range.0 + 1 >= k);
                Map.any(m, pred) == Map.foldLeft<Nat, Text, Bool>(m, false, func(acc, k, v) { acc or pred(k, v) })
              }
            ),

            prop(
              "forall k, v in map, v == show_debug(k)",
              func(m) {
                Map.all(m, func(k : Nat, v : Text) : Bool = (v == debug_show (k)))
              }
            )
          ]
        ),

        suite(
          "containsKey",
          [
            prop_with_key(
              "containsKey(m, c,  k) == (get(m, c, k) != null)",
              func(m, k) {
                Map.containsKey(m, c, k) == (Option.isSome(Map.get(m, c, k)))
              }
            )
          ]
        ),

        suite(
          "minEntry/maxEntry",
          [
            prop(
              "max through fold",
              func(m) {
                let expected = Map.foldLeft<Nat, Text, ?(Nat, Text)>(m, null : ?(Nat, Text), func(_, k, v) = ?(k, v));
                M.equals(T.optional(entryTestable, expected)).matches(Map.maxEntry(m))
              }
            ),

            prop(
              "min through fold",
              func(m) {
                let expected = Map.foldRight<Nat, Text, ?(Nat, Text)>(m, null : ?(Nat, Text), func(k, v, _) = ?(k, v));
                M.equals(T.optional(entryTestable, expected)).matches(Map.minEntry(m))
              }
            )
          ]
        )
      ]
    )
  )
};

run_all_props((1, 3), 0, 1, 10);
run_all_props((1, 5), 5, 100, 100);
run_all_props((1, 10), 10, 100, 100);
run_all_props((1, 100), 20, 100, 100);
//run_all_props((1, 1000), 100, 100, 100)
