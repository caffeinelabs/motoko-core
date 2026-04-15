// @testmode wasi

import Set "../../src/pure/Set";
import Nat "../../src/Nat";
import Iter "../../src/Iter";
import Debug "../../src/Debug";
import Array "../../src/Array";

import Suite "mo:matchers/Suite";
import T "mo:matchers/Testable";
import M "mo:matchers/Matchers";

let { run; test; suite } = Suite;

// element comparison function
let c = Nat.compare;

class SetMatcher(expected : Set.Set<Nat>) : M.Matcher<Set.Set<Nat>> {
  public func describeMismatch(actual : Set.Set<Nat>, _description : M.Description) {
    Debug.print(debug_show ((actual.values()).toArray()) # " should be " # debug_show ((expected.values()).toArray()))
  };

  public func matches(actual : Set.Set<Nat>) : Bool {
    Set.equal(actual, expected, c)
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
    let v = n % (range.1 - range.0 + 1) + range.0;
    v
  };

  public func nextEntries(range : (Nat, Nat), size : Nat) : [Nat] {
    Array.tabulate<Nat>(
      size,
      func(_ix) {
        let key = nextNat(range);
        key
      }
    )
  }
};

func setGenN(samples_number : Nat, size : Nat, range : (Nat, Nat), chunkSize : Nat) : Iter.Iter<[Set.Set<Nat>]> {
  object {
    var n = 0;
    public func next() : ?([Set.Set<Nat>]) {
      n += 1;
      if (n > samples_number) {
        null
      } else {
        ?Array.tabulate<Set.Set<Nat>>(
          chunkSize,
          func _ = Set.fromIter(
            Random.nextEntries(range, size).values(),
            c
          )
        )
      }
    }
  }
};

func run_all_props(range : (Nat, Nat), size : Nat, set_samples : Nat, query_samples : Nat) {
  func prop(name : Text, f : Set.Set<Nat> -> Bool) : Suite.Suite {
    var error_msg : Text = "";
    test(
      name,
      do {
        var error = true;
        label stop for (sets in setGenN(set_samples, size, range, 1)) {
          if (not f(sets[0])) {
            error_msg := "Property \"" # name # "\" failed\n";
            error_msg #= "\n s: " # debug_show ((sets[0].values()).toArray());
            break stop
          }
        };
        error_msg
      },
      M.describedAs(error_msg, M.equals(T.text("")))
    )
  };

  func prop2(name : Text, f : (Set.Set<Nat>, Set.Set<Nat>) -> Bool) : Suite.Suite {
    var error_msg : Text = "";
    test(
      name,
      do {
        var error = true;
        label stop for (sets in setGenN(set_samples, size, range, 2)) {
          if (not f(sets[0], sets[1])) {
            error_msg := "Property \"" # name # "\" failed\n";
            error_msg #= "\n s1: " # debug_show ((sets[0].values()).toArray());
            error_msg #= "\n s2: " # debug_show ((sets[1].values()).toArray());
            break stop
          }
        };
        error_msg
      },
      M.describedAs(error_msg, M.equals(T.text("")))
    )
  };

  func prop3(name : Text, f : (Set.Set<Nat>, Set.Set<Nat>, Set.Set<Nat>) -> Bool) : Suite.Suite {
    var error_msg : Text = "";
    test(
      name,
      do {
        var error = true;
        label stop for (sets in setGenN(set_samples, size, range, 3)) {
          if (not f(sets[0], sets[1], sets[2])) {
            error_msg := "Property \"" # name # "\" failed\n";
            error_msg #= "\n s1: " # debug_show ((sets[0].values()).toArray());
            error_msg #= "\n s2: " # debug_show ((sets[1].values()).toArray());
            error_msg #= "\n s3: " # debug_show ((sets[2].values()).toArray());
            break stop
          }
        };
        error_msg
      },
      M.describedAs(error_msg, M.equals(T.text("")))
    )
  };

  func prop_with_elem(name : Text, f : (Set.Set<Nat>, Nat) -> Bool) : Suite.Suite {
    var error_msg : Text = "";
    test(
      name,
      do {
        label stop for (sets in setGenN(set_samples, size, range, 1)) {
          for (_query_ix in Nat.range(0, query_samples)) {
            let key = Random.nextNat(range);
            if (not f(sets[0], key)) {
              error_msg #= "Property \"" # name # "\" failed";
              error_msg #= "\n s: " # debug_show ((sets[0].values()).toArray());
              error_msg #= "\n e: " # debug_show (key);
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
              "not contains(empty(), e, c)",
              label res : Bool {
                for (_query_ix in Nat.range(0, query_samples)) {
                  let elem = Random.nextNat(range);
                  if (Set.contains(Set.empty(), c, elem)) break res(false)
                };
                true
              },
              M.equals(T.bool(true))
            )
          ]
        ),

        suite(
          "contains & add",
          [
            prop_with_elem(
              "contains(add(s, c, e), c,  e)",
              func(s, e) {
                Set.contains(Set.add(s, c, e), c, e)
              }
            ),
            prop_with_elem(
              "add(add(s, c, e), c, e) == add(s, c, e)",
              func(s, e) {
                let s1 = Set.add(s, c, e);
                let s2 = Set.add(Set.add(s, c, e), c, e);
                SetMatcher(s1).matches(s2)
              }
            )
          ]
        ),

        suite(
          "folds",
          [
            prop(
              "foldLeft as values()",
              func(m) {
                let it = m.values();
                Set.foldLeft<Nat, Bool>(m, true, func(acc, v) { acc and it.next() == ?v })
              }
            ),
            prop(
              "foldRight as valsRev()",
              func(m) {
                let it = m.reverseValues();
                Set.foldRight<Nat, Bool>(m, true, func(v, acc) { acc and it.next() == ?v })
              }
            )
          ]
        ),

        suite(
          "min/max",
          [
            prop(
              "max through fold",
              func(s) {
                let expected = Set.foldLeft<Nat, ?Nat>(s, null : ?Nat, func(_, v) = ?v);
                M.equals(T.optional(T.natTestable, expected)).matches(Set.max(s))
              }
            ),
            prop(
              "min through fold",
              func(s) {
                let expected = Set.foldRight<Nat, ?Nat>(s, null : ?Nat, func(v, _) = ?v);
                M.equals(T.optional(T.natTestable, expected)).matches(Set.min(s))
              }
            )
          ]
        ),

        suite(
          "all/any",
          [
            prop(
              "all through fold",
              func(s) {
                let pred = func(k : Nat) : Bool = (k <= range.1 - 2 and range.0 + 2 <= k);
                Set.all(s, pred) == Set.foldLeft<Nat, Bool>(s, true, func(acc, v) { acc and pred(v) })
              }
            ),
            prop(
              "any through fold",
              func(s) {
                let pred = func(k : Nat) : Bool = (k >= range.1 - 1 or range.0 + 1 >= k);
                Set.any(s, pred) == Set.foldLeft<Nat, Bool>(s, false, func(acc, v) { acc or pred(v) })
              }
            )
          ]
        ),

        suite(
          "remove",
          [
            prop_with_elem(
              "not contains(s, c, e) ==> remove(s, c, e) == s",
              func(s, e) {
                if (not Set.contains(s, c, e)) {
                  SetMatcher(s).matches(Set.remove(s, c, e))
                } else { true }
              }
            ),
            prop_with_elem(
              "remove(add(s, c, e), c, e) == s",
              func(s, e) {
                if (not Set.contains(s, c, e)) {
                  SetMatcher(s).matches(Set.remove(Set.add(s, c, e), c, e))
                } else { true }
              }
            ),
            prop_with_elem(
              "remove(remove(s, c, e), c, e)) == remove(s, c, e)",
              func(s, e) {
                let s1 = Set.remove(Set.remove(s, c, e), c, e);
                let s2 = Set.remove(s, c, e);
                SetMatcher(s2).matches(s1)
              }
            )
          ]
        ),

        suite(
          "size",
          [
            prop_with_elem(
              "size(add(s, c, e)) == size(s) + int(not contains(s, c, e))",
              func(s, e) {
                Set.size(Set.add(s, c, e)) == Set.size(s) + (if (not Set.contains(s, c, e)) { 1 } else { 0 })
              }
            ),
            prop_with_elem(
              "size(remove(s, c, e)) + int(contains(s, c, e)) == size(s)",
              func(s, e) {
                Set.size(Set.remove(s, c, e)) + (if (Set.contains(s, c, e)) { 1 } else { 0 }) == Set.size(s)
              }
            )
          ]
        ),

        suite(
          "values/reverseValues",
          [
            prop(
              "fromIter(values(s), c) == s",
              func(s) {
                SetMatcher(s).matches(Set.fromIter(s.values(), c))
              }
            ),
            prop(
              "fromIter(reverseValue(s), c) == s",
              func(s) {
                SetMatcher(s).matches(Set.fromIter(s.reverseValues(), c))
              }
            ),
            prop(
              "toArray(values(s)).reverse() == toArray(reverseValues(s))",
              func(s) {
                let a = Array.reverse((s.values()).toArray());
                let b = (s.reverseValues()).toArray();
                M.equals(T.array<Nat>(T.natTestable, a)).matches(b)
              }
            )
          ]
        ),

        suite(
          ("Internal"),
          [
            prop(
              "search tree invariant",
              func(s) {
                Set.assertValid(s, c);
                true
              }
            )
          ]
        ),

        suite(
          "filterMap",
          [
            prop_with_elem(
              "not contains(filterMap(s, c, (!=e)), c, e)",
              func(s, e) {
                not Set.contains(
                  Set.filterMap<Nat, Nat>(
                    s,
                    c,
                    func(ei) { if (ei != e) { ?ei } else { null } }
                  ),
                  c,
                  e
                )
              }
            ),
            prop_with_elem(
              "contains(filterMap(add(s, c, e), c, (==e)), c, e)",
              func(s, e) {
                Set.contains(
                  Set.filterMap<Nat, Nat>(
                    Set.add(s, c, e),
                    c,
                    func(ei) { if (ei == e) { ?ei } else { null } }
                  ),
                  c,
                  e
                )
              }
            )
          ]
        ),

        suite(
          "map",
          [
            prop(
              "map(s, id) == s",
              func(s) {
                SetMatcher(s).matches(Set.map<Nat, Nat>(s, c, func(e) { e }))
              }
            )
          ]
        ),

        suite(
          "set operations",
          [
            prop(
              "isSubset(s, s, c)",
              func(s) {
                Set.isSubset(s, s, c)
              }
            ),
            prop(
              "isSubset(empty(), s, c)",
              func(s) {
                Set.isSubset(Set.empty(), s, c)
              }
            ),
            prop_with_elem(
              "isSubset(remove(s, c, e), s, c)",
              func(s, e) {
                Set.isSubset(Set.remove(s, c, e), s, c)
              }
            ),
            prop_with_elem(
              "contains(s, e) ==> not isSubset(s, remove(s, e))",
              func(s, e) {
                if (Set.contains(s, c, e)) {
                  not Set.isSubset(s, Set.remove(s, c, e), c)
                } else { true }
              }
            ),
            prop_with_elem(
              "isSubset(s  add(s, c, e), c)",
              func(s, e) {
                Set.isSubset(s, Set.add(s, c, e), c)
              }
            ),
            prop_with_elem(
              "not contains(s, c, e) ==> not isSubset(add(s, c, e), s, c)",
              func(s, e) {
                if (not Set.contains(s, c, e)) {
                  not Set.isSubset(Set.add(s, c, e), s, c)
                } else { true }
              }
            ),
            prop(
              "intersection(empty(), s, c) == empty()",
              func(s) {
                SetMatcher(Set.empty()).matches(Set.intersection(Set.empty(), s, c))
              }
            ),
            prop(
              "intersection(s, empty(), c) == empty()",
              func(s) {
                SetMatcher(Set.empty()).matches(Set.intersection(s, Set.empty(), c))
              }
            ),
            prop(
              "union(s, empty(), c) == s",
              func(s) {
                SetMatcher(s).matches(Set.union(s, Set.empty(), c))
              }
            ),
            prop(
              "union(empty(), s, c) == s",
              func(s) {
                SetMatcher(s).matches(Set.union(Set.empty(), s, c))
              }
            ),
            prop(
              "difference(empty(), s, c) == empty()",
              func(s) {
                SetMatcher(Set.empty()).matches(Set.difference(Set.empty(), s, c))
              }
            ),
            prop(
              "difference(s, empty(), c) == s",
              func(s) {
                SetMatcher(s).matches(Set.difference(s, Set.empty(), c))
              }
            ),
            prop(
              "intersection(s, s, c) == s",
              func(s) {
                SetMatcher(s).matches(Set.intersection(s, s, c))
              }
            ),
            prop(
              "union(s, s, c) == s",
              func(s) {
                SetMatcher(s).matches(Set.union(s, s, c))
              }
            ),
            prop(
              "difference(s, s, c) == empty()",
              func(s) {
                SetMatcher(Set.empty()).matches(Set.difference(s, s, c))
              }
            ),
            prop2(
              "intersection(s1, s2, c) == intersection(s2, s1, c)",
              func(s1, s2) {
                SetMatcher(Set.intersection(s1, s2, c)).matches(Set.intersection(s2, s1, c))
              }
            ),
            prop2(
              "union(s1, s2, c) == union(s2, s1, c)",
              func(s1, s2) {
                SetMatcher(Set.union(s1, s2, c)).matches(Set.union(s2, s1, c))
              }
            ),
            prop2(
              "isSubset(difference(s1, s2, c), s1, c)",
              func(s1, s2) {
                Set.isSubset(Set.difference(s1, s2, c), s1, c)
              }
            ),
            prop2(
              "intersection(difference(s1, s2, c), s2, c) == empty()",
              func(s1, s2) {
                SetMatcher(Set.intersection(Set.difference(s1, s2, c), s2, c)).matches(Set.empty())
              }
            ),
            prop3(
              "union(union(s1, s2, c), s3, c) == union(s1, union(s2, s3, c), c)",
              func(s1, s2, s3) {
                SetMatcher(Set.union(Set.union(s1, s2, c), s3, c)).matches(Set.union(s1, Set.union(s2, s3, c), c))
              }
            ),
            prop3(
              "intersection(intersection(s1, s2, c), s3, c) == intersection(s1, intersection(s2, s3, c), c)",
              func(s1, s2, s3) {
                SetMatcher(Set.intersection(Set.intersection(s1, s2, c), s3, c)).matches(Set.intersection(s1, Set.intersection(s2, s3, c), c))
              }
            ),
            prop3(
              "union(s1, intersection(s2, s3, c), c) == intersection(union(s1, s2, c), union(s1, s3, c))",
              func(s1, s2, s3) {
                SetMatcher(Set.union(s1, Set.intersection(s2, s3, c), c)).matches(
                  Set.intersection(Set.union(s1, s2, c), Set.union(s1, s3, c), c)
                )
              }
            ),
            prop3(
              "intersection(s1, union(s2, s3), c) == union(intersection(s1, s2, c), intersection(s1, s3))",
              func(s1, s2, s3) {
                SetMatcher(Set.intersection(s1, Set.union(s2, s3, c), c)).matches(
                  Set.union(Set.intersection(s1, s2, c), Set.intersection(s1, s3, c), c)
                )
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
