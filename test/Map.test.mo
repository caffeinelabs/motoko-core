// @testmode wasi
import Suite "mo:matchers/Suite";
import T "mo:matchers/Testable";
import M "mo:matchers/Matchers";
import Test "mo:test";
import Map "../src/Map";
import Iter "../src/Iter";
import Nat "../src/Nat";
import Runtime "../src/Runtime";
import Text "../src/Text";
import Array "../src/Array";
import PureMap "../src/pure/Map";
import { Tuple2 } "../src/Tuples";

let { run; test; suite } = Suite;

let entryTestable = T.tuple2Testable(T.natTestable, T.textTestable);

run(
  suite(
    "empty",
    [
      test(
        "size",
        Map.size(Map.empty<Nat, Text>()),
        M.equals(T.nat(0))
      ),
      test(
        "is empty",
        Map.isEmpty(Map.empty<Nat, Text>()),
        M.equals(T.bool(true))
      ),
      test(
        "add empty",
        do {
          let map = Map.empty<Nat, Text>();
          Map.add(map, Nat.compare, 0, "0");
          Iter.toArray(Map.entries(map))
        },
        M.equals(T.array(entryTestable, [(0, "0")]))
      ),
      test(
        "insert empty",
        do {
          let map = Map.empty<Nat, Text>();
          assert map.insert(0, "0");
          Iter.toArray(Map.entries(map))
        },
        M.equals(T.array(entryTestable, [(0, "0")]))
      ),
      test(
        "remove empty",
        do {
          let map = Map.empty<Nat, Text>();
          map.remove(0);
          Iter.toArray(Map.entries(map))
        },
        M.equals(T.array<(Nat, Text)>(entryTestable, []))
      ),
      test(
        "delete empty",
        do {
          let map = Map.empty<Nat, Text>();
          assert (not map.delete(0));
          Iter.toArray(Map.entries(map))
        },
        M.equals(T.array<(Nat, Text)>(entryTestable, []))
      ),
      test(
        "take absent",
        do {
          let map = Map.empty<Nat, Text>();
          map.take(0)
        },
        M.equals(T.optional(T.textTestable, null : ?Text))
      ),
      test(
        "clone",
        do {
          let original = Map.empty<Nat, Text>();
          let clone = Map.clone(original);
          Map.size(clone)
        },
        M.equals(T.nat(0))
      ),
      test(
        "clone no alias",
        do {
          let original = Map.empty<Nat, Text>();
          let clone = Map.clone(original);
          original.add(0, "0");
          Map.size(clone)
        },
        M.equals(T.nat(0))
      ),
      test(
        "iterate forward",
        Iter.toArray(Map.entries(Map.empty<Nat, Text>())),
        M.equals(T.array<(Nat, Text)>(entryTestable, []))
      ),
      test(
        "iterate backward",
        Iter.toArray(Map.reverseEntries(Map.empty<Nat, Text>())),
        M.equals(T.array<(Nat, Text)>(entryTestable, []))
      ),
      test(
        "contains key",
        do {
          let map = Map.empty<Nat, Text>();
          map.containsKey(0)
        },
        M.equals(T.bool(false))
      ),
      test(
        "get absent",
        do {
          let map = Map.empty<Nat, Text>();
          map.get(0)
        },
        M.equals(T.optional(T.textTestable, null : ?Text))
      ),
      test(
        "update absent",
        do {
          let map = Map.empty<Nat, Text>();
          map.swap(0, "0")
        },
        M.equals(T.optional(T.textTestable, null : ?Text))
      ),
      test(
        "replace if exists",
        do {
          let map = Map.empty<Nat, Text>();
          assert (map.replace(0, "0") == null);
          Map.size(map)
        },
        M.equals(T.nat(0))
      ),
      test(
        "clear",
        do {
          let map = Map.empty<Nat, Text>();
          Map.clear(map);
          Map.isEmpty(map)
        },
        M.equals(T.bool(true))
      ),
      test(
        "equal",
        do {
          let map1 = Map.empty<Nat, Text>();
          let map2 = Map.empty<Nat, Text>();
          // Note: This is pretty neat, both the comparison for K as well as equals for V are implicit
          map1.equal(map2)
        },
        M.equals(T.bool(true))
      ),
      test(
        "maximum entry",
        do {
          let map = Map.empty<Nat, Text>();
          Map.maxEntry(map)
        },
        M.equals(T.optional(entryTestable, null : ?(Nat, Text)))
      ),
      test(
        "minimum entry",
        do {
          let map = Map.empty<Nat, Text>();
          Map.minEntry(map)
        },
        M.equals(T.optional(entryTestable, null : ?(Nat, Text)))
      ),
      test(
        "iterate keys",
        Iter.toArray(Map.keys(Map.empty<Nat, Text>())),
        M.equals(T.array<Nat>(T.natTestable, []))
      ),
      test(
        "iterate values",
        Iter.toArray(Map.values(Map.empty<Nat, Text>())),
        M.equals(T.array<Text>(T.textTestable, []))
      ),
      test(
        "from iterator",
        do {
          let map = Map.fromIter<Nat, Text>(Iter.empty<(Nat, Text)>());
          Map.size(map)
        },
        M.equals(T.nat(0))
      ),
      test(
        "for each",
        do {
          let map = Map.empty<Nat, Text>();
          Map.forEach<Nat, Text>(
            map,
            func(_, _) {
              assert false
            }
          );
          Map.size(map)
        },
        M.equals(T.nat(0))
      ),
      test(
        "filter",
        do {
          let input = Map.empty<Nat, Text>();
          let output = input.filter(
            func(_, _) {
              Runtime.trap("test failed")
            }
          );
          Map.size(output)
        },
        M.equals(T.nat(0))
      ),
      test(
        "map",
        do {
          let input = Map.empty<Nat, Text>();
          let output = Map.map<Nat, Text, Int>(
            input,
            func(_, _) {
              Runtime.trap("test failed")
            }
          );
          Map.size(output)
        },
        M.equals(T.nat(0))
      ),
      test(
        "filter map",
        do {
          let input = Map.empty<Nat, Text>();
          let output = input.filterMap<Nat, Text, Int>(
            func(_, _) {
              Runtime.trap("test failed")
            }
          );
          Map.size(output)
        },
        M.equals(T.nat(0))
      ),
      test(
        "fold left",
        do {
          let map = Map.empty<Nat, Text>();
          Map.foldLeft<Nat, Text, Nat>(
            map,
            0,
            func(_, _, _) {
              Runtime.trap("test failed")
            }
          )
        },
        M.equals(T.nat(0))
      ),
      test(
        "fold right",
        do {
          let map = Map.empty<Nat, Text>();
          Map.foldRight<Nat, Text, Nat>(
            map,
            0,
            func(_, _, _) {
              Runtime.trap("test failed")
            }
          )
        },
        M.equals(T.nat(0))
      ),
      test(
        "all",
        do {
          let map = Map.empty<Nat, Text>();
          Map.all<Nat, Text>(
            map,
            func(_, _) {
              Runtime.trap("test failed")
            }
          )
        },
        M.equals(T.bool(true))
      ),
      test(
        "any",
        do {
          let map = Map.empty<Nat, Text>();
          Map.any<Nat, Text>(
            map,
            func(_, _) {
              Runtime.trap("test failed")
            }
          )
        },
        M.equals(T.bool(false))
      ),
      test(
        "to text",
        do {
          let map = Map.empty<Nat, Text>();
          map.toText()
        },
        M.equals(T.text("Map{}"))
      ),
      test(
        "compare",
        do {
          let map1 = Map.empty<Nat, Text>();
          let map2 = Map.empty<Nat, Text>();
          // NOTE: Can't make both compare's implicit because of the name overlap
          assert (Map.compare(map1, map2, Nat.compare, Text.compare) == #equal);
          true
        },
        M.equals(T.bool(true))
      ),
      // TODO: Test freeze and thaw
    ]
  )
);

run(
  suite(
    "singleton",
    [
      test(
        "size",
        Map.size<Nat, Text>(Map.singleton(0, "0")),
        M.equals(T.nat(1))
      ),
      test(
        "is empty",
        Map.isEmpty<Nat, Text>(Map.singleton(0, "0")),
        M.equals(T.bool(false))
      ),
      test(
        "add singleton old",
        do {
          let map = Map.singleton<Nat, Text>(0, "0");
          Map.add(map, Nat.compare, 0, "1");
          Iter.toArray(Map.entries(map))
        },
        M.equals(T.array<(Nat, Text)>(entryTestable, [(0, "1")]))
      ),
      test(
        "add singleton new",
        do {
          let map = Map.singleton<Nat, Text>(0, "0");
          Map.add(map, Nat.compare, 1, "1");
          Iter.toArray(Map.entries(map))
        },
        M.equals(T.array<(Nat, Text)>(entryTestable, [(0, "0"), (1, "1")]))
      ),
      test(
        "insert singleton old",
        do {
          let map = Map.singleton<Nat, Text>(0, "0");
          assert (not Map.insert(map, Nat.compare, 0, "1"));
          Iter.toArray(Map.entries(map))
        },
        M.equals(T.array<(Nat, Text)>(entryTestable, [(0, "1")]))
      ),
      test(
        "insert singleton new",
        do {
          let map = Map.singleton<Nat, Text>(0, "0");
          assert Map.insert(map, Nat.compare, 1, "1");
          Iter.toArray(Map.entries(map))
        },
        M.equals(T.array<(Nat, Text)>(entryTestable, [(0, "0"), (1, "1")]))
      ),
      test(
        "remove singleton old",
        do {
          let map = Map.singleton<Nat, Text>(0, "0");
          Map.remove(map, Nat.compare, 0);
          Iter.toArray(Map.entries(map))
        },
        M.equals(T.array<(Nat, Text)>(entryTestable, []))
      ),
      test(
        "remove singleton new",
        do {
          let map = Map.singleton<Nat, Text>(0, "0");
          Map.remove(map, Nat.compare, 1);
          Iter.toArray(Map.entries(map))
        },
        M.equals(T.array<(Nat, Text)>(entryTestable, [(0, "0")]))
      ),
      test(
        "delete singleton old",
        do {
          let map = Map.singleton<Nat, Text>(0, "0");
          assert (Map.delete(map, Nat.compare, 0));
          Iter.toArray(Map.entries(map))
        },
        M.equals(T.array<(Nat, Text)>(entryTestable, []))
      ),
      test(
        "delete singleton new",
        do {
          let map = Map.singleton<Nat, Text>(0, "0");
          assert (not Map.delete(map, Nat.compare, 1));
          Iter.toArray(Map.entries(map))
        },
        M.equals(T.array<(Nat, Text)>(entryTestable, [(0, "0")]))
      ),
      test(
        "take function result",
        do {
          let map = Map.singleton<Nat, Text>(0, "0");
          Map.take(map, Nat.compare, 0)
        },
        M.equals(T.optional(T.textTestable, ?"0"))
      ),
      test(
        "take map result",
        do {
          let map = Map.singleton<Nat, Text>(0, "0");
          ignore Map.take(map, Nat.compare, 0);
          Map.size(map)
        },
        M.equals(T.nat(0))
      ),
      test(
        "clone",
        do {
          let original = Map.singleton<Nat, Text>(0, "0");
          let clone = Map.clone(original);
          assert (Map.equal(original, clone, Nat.compare, Text.equal));
          Map.size(clone)
        },
        M.equals(T.nat(1))
      ),
      test(
        "clone no alias",
        do {
          let original = Map.singleton<Nat, Text>(0, "0");
          let clone = Map.clone(original);
          Map.add(original, Nat.compare, 0, "1");
          assert (Map.get(clone, Nat.compare, 0) == ?"0");
          Map.size(clone)
        },
        M.equals(T.nat(1))
      ),
      test(
        "iterate forward",
        Iter.toArray(Map.entries(Map.singleton<Nat, Text>(0, "0"))),
        M.equals(T.array<(Nat, Text)>(entryTestable, [(0, "0")]))
      ),
      test(
        "iterate backward",
        Iter.toArray(Map.reverseEntries(Map.singleton<Nat, Text>(0, "0"))),
        M.equals(T.array<(Nat, Text)>(entryTestable, [(0, "0")]))
      ),
      test(
        "contains present key",
        do {
          let map = Map.singleton<Nat, Text>(0, "0");
          Map.containsKey(map, Nat.compare, 0)
        },
        M.equals(T.bool(true))
      ),
      test(
        "contains absent key",
        do {
          let map = Map.singleton<Nat, Text>(0, "0");
          Map.containsKey(map, Nat.compare, 1)
        },
        M.equals(T.bool(false))
      ),
      test(
        "get present",
        do {
          let map = Map.singleton<Nat, Text>(0, "0");
          Map.get(map, Nat.compare, 0)
        },
        M.equals(T.optional(T.textTestable, ?"0"))
      ),
      test(
        "get absent",
        do {
          let map = Map.singleton<Nat, Text>(0, "0");
          Map.get(map, Nat.compare, 1)
        },
        M.equals(T.optional(T.textTestable, null : ?Text))
      ),
      test(
        "update present",
        do {
          let map = Map.singleton<Nat, Text>(0, "0");
          Map.swap(map, Nat.compare, 0, "Zero")
        },
        M.equals(T.optional(T.textTestable, ?"0"))
      ),
      test(
        "update absent",
        do {
          let map = Map.singleton<Nat, Text>(0, "0");
          Map.swap(map, Nat.compare, 1, "1")
        },
        M.equals(T.optional(T.textTestable, null : ?Text))
      ),
      test(
        "replace if exists present",
        do {
          let map = Map.singleton<Nat, Text>(0, "0");
          assert (Map.replace(map, Nat.compare, 0, "Zero") == ?"0");
          Map.size(map)
        },
        M.equals(T.nat(1))
      ),
      test(
        "replace if exists absent",
        do {
          let map = Map.singleton<Nat, Text>(0, "0");
          assert (Map.replace(map, Nat.compare, 1, "1") == null);
          Map.size(map)
        },
        M.equals(T.nat(1))
      ),
      test(
        "delete",
        do {
          let map = Map.singleton<Nat, Text>(0, "0");
          assert Map.delete(map, Nat.compare, 0);
          Map.size(map)
        },
        M.equals(T.nat(0))
      ),
      test(
        "clear",
        do {
          let map = Map.singleton<Nat, Text>(0, "0");
          Map.clear(map);
          Map.isEmpty(map)
        },
        M.equals(T.bool(true))
      ),
      test(
        "equal",
        do {
          let map1 = Map.singleton<Nat, Text>(0, "0");
          let map2 = Map.singleton<Nat, Text>(0, "0");
          Map.equal(map1, map2, Nat.compare, Text.equal)
        },
        M.equals(T.bool(true))
      ),
      test(
        "not equal",
        do {
          let map1 = Map.singleton<Nat, Text>(0, "0");
          let map2 = Map.singleton<Nat, Text>(1, "1");
          Map.equal(map1, map2, Nat.compare, Text.equal)
        },
        M.equals(T.bool(false))
      ),
      test(
        "maximum entry",
        do {
          let map = Map.singleton<Nat, Text>(0, "0");
          Map.maxEntry(map)
        },
        M.equals(T.optional(entryTestable, ?(0, "0")))
      ),
      test(
        "minimum entry",
        do {
          let map = Map.singleton<Nat, Text>(0, "0");
          Map.minEntry(map)
        },
        M.equals(T.optional(entryTestable, ?(0, "0")))
      ),
      test(
        "iterate keys",
        Iter.toArray(Map.keys(Map.singleton<Nat, Text>(0, "0"))),
        M.equals(T.array<Nat>(T.natTestable, [0]))
      ),
      test(
        "iterate values",
        Iter.toArray(Map.values(Map.singleton<Nat, Text>(0, "0"))),
        M.equals(T.array<Text>(T.textTestable, ["0"]))
      ),
      test(
        "from iterator",
        do {
          let map = Map.fromIter([(0, "0")].values(), Nat.compare);
          assert (Map.get(map, Nat.compare, 0) == ?"0");
          assert (Map.equal(map, Map.singleton<Nat, Text>(0, "0"), Nat.compare, Text.equal));
          Map.size(map)
        },
        M.equals(T.nat(1))
      ),
      test(
        "for each",
        do {
          let map = Map.singleton<Nat, Text>(0, "0");
          Map.forEach<Nat, Text>(
            map,
            func(key, value) {
              assert (key == 0);
              assert (value == "0")
            }
          );
          Map.size(map)
        },
        M.equals(T.nat(1))
      ),
      test(
        "filter",
        do {
          let input = Map.singleton<Nat, Text>(0, "0");
          let output = Map.filter(
            input,
            Nat.compare,
            func(key, value) {
              assert (key == 0);
              assert (value == "0");
              true
            }
          );
          assert (Map.equal(input, output, Nat.compare, Text.equal));
          Map.size(output)
        },
        M.equals(T.nat(1))
      ),
      test(
        "map",
        do {
          let input = Map.singleton<Nat, Text>(0, "0");
          let output = Map.map(
            input,
            func(key, value) {
              assert (key == 0);
              assert (value == "0");
              +key
            }
          );
          assert (Map.get(output, Nat.compare, 0) == ?+0);
          Map.size(output)
        },
        M.equals(T.nat(1))
      ),
      test(
        "filter map",
        do {
          let input = Map.singleton<Nat, Text>(0, "0");
          let output = Map.filterMap(
            input,
            Nat.compare,
            func(key, value) {
              assert (key == 0);
              assert (value == "0");
              ?+key
            }
          );
          assert (Map.get(output, Nat.compare, 0) == ?+0);
          Map.size(output)
        },
        M.equals(T.nat(1))
      ),
      test(
        "fold left",
        do {
          let map = Map.singleton<Nat, Text>(1, "1");
          Map.foldLeft<Nat, Text, Nat>(
            map,
            0,
            func(accumulator, key, value) {
              accumulator + key
            }
          )
        },
        M.equals(T.nat(1))
      ),
      test(
        "fold right",
        do {
          let map = Map.singleton<Nat, Text>(1, "1");
          Map.foldRight<Nat, Text, Nat>(
            map,
            0,
            func(key, value, accumulator) {
              key + accumulator
            }
          )
        },
        M.equals(T.nat(1))
      ),
      test(
        "all",
        do {
          let map = Map.singleton<Nat, Text>(1, "1");
          Map.all<Nat, Text>(
            map,
            func(key, value) {
              key == 1 and value == "1"
            }
          )
        },
        M.equals(T.bool(true))
      ),
      test(
        "not all",
        do {
          let map = Map.singleton<Nat, Text>(1, "1");
          Map.all<Nat, Text>(
            map,
            func(key, value) {
              key == 0
            }
          )
        },
        M.equals(T.bool(false))
      ),
      test(
        "any",
        do {
          let map = Map.singleton<Nat, Text>(1, "1");
          Map.any<Nat, Text>(
            map,
            func(key, value) {
              key == 1 and value == "1"
            }
          )
        },
        M.equals(T.bool(true))
      ),
      test(
        "not any",
        do {
          let map = Map.singleton<Nat, Text>(1, "1");
          Map.any<Nat, Text>(
            map,
            func(key, value) {
              key == 0
            }
          )
        },
        M.equals(T.bool(false))
      ),
      test(
        "to text",
        do {
          let map = Map.singleton<Nat, Text>(1, "1");
          Map.toText<Nat, Text>(map, Nat.toText, func(value) { value })
        },
        M.equals(T.text("Map{(1, 1)}"))
      ),
      test(
        "compare less key",
        do {
          let map1 = Map.singleton<Nat, Text>(0, "0");
          let map2 = Map.singleton<Nat, Text>(1, "1");
          assert (Map.compare(map1, map2, Nat.compare, Text.compare) == #less);
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "compare less value",
        do {
          let map1 = Map.singleton<Nat, Text>(0, "0");
          let map2 = Map.singleton<Nat, Text>(0, "Zero");
          assert (Map.compare(map1, map2, Nat.compare, Text.compare) == #less);
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "compare equal",
        do {
          let map1 = Map.singleton<Nat, Text>(0, "0");
          let map2 = Map.singleton<Nat, Text>(0, "0");
          assert (Map.compare(map1, map2, Nat.compare, Text.compare) == #equal);
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "compare greater key",
        do {
          let map1 = Map.singleton<Nat, Text>(1, "1");
          let map2 = Map.singleton<Nat, Text>(0, "0");
          assert (Map.compare(map1, map2, Nat.compare, Text.compare) == #greater);
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "compare greater value",
        do {
          let map1 = Map.singleton<Nat, Text>(0, "Zero");
          let map2 = Map.singleton<Nat, Text>(0, "0");
          assert (Map.compare(map1, map2, Nat.compare, Text.compare) == #greater);
          true
        },
        M.equals(T.bool(true))
      ),
      // TODO: Test freeze and thaw
    ]
  )
);

let smallSize = 100;
func smallMap() : Map.Map<Nat, Text> {
  let map = Map.empty<Nat, Text>();
  for (index in Nat.range(0, smallSize)) {
    Map.add(map, Nat.compare, index, Nat.toText(index))
  };
  map
};

run(
  suite(
    "small map",
    [
      test(
        "size",
        Map.size<Nat, Text>(smallMap()),
        M.equals(T.nat(smallSize))
      ),
      test(
        "is empty",
        Map.isEmpty<Nat, Text>(smallMap()),
        M.equals(T.bool(false))
      ),
      test(
        "clone",
        do {
          let original = smallMap();
          let clone = Map.clone(original);
          assert (Map.equal(original, clone, Nat.compare, Text.equal));
          Map.size(clone)
        },
        M.equals(T.nat(smallSize))
      ),
      test(
        "clone no alias",
        do {
          let original = smallMap();
          let copy = smallMap();
          let clone = Map.clone(original);
          let keys = Iter.toArray(Map.keys(original));
          for (key in keys.vals()) {
            Map.add(original, Nat.compare, key, "X")
          };
          for (key in keys.vals()) {
            assert Map.get(clone, Nat.compare, key) == Map.get(copy, Nat.compare, key)
          };
          Map.size(clone)
        },
        M.equals(T.nat(smallSize))
      ),
      test(
        "iterate forward",
        Iter.toArray(Map.entries(smallMap())),
        M.equals(
          T.array<(Nat, Text)>(
            entryTestable,
            Array.tabulate<(Nat, Text)>(smallSize, func(index) { (index, Nat.toText(index)) })
          )
        )
      ),
      test(
        "iterate backward",
        Iter.toArray(Map.reverseEntries(smallMap())),
        M.equals(T.array<(Nat, Text)>(entryTestable, Array.reverse(Array.tabulate<(Nat, Text)>(smallSize, func(index) { (index, Nat.toText(index)) }))))
      ),
      test(
        "contains present keys",
        do {
          let map = smallMap();
          for (index in Nat.range(0, smallSize)) {
            assert (Map.containsKey(map, Nat.compare, index))
          };
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "contains absent key",
        do {
          let map = smallMap();
          Map.containsKey(map, Nat.compare, smallSize)
        },
        M.equals(T.bool(false))
      ),
      test(
        "get present",
        do {
          let map = smallMap();
          for (index in Nat.range(0, smallSize)) {
            assert (Map.get(map, Nat.compare, index) == ?Nat.toText(index))
          };
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "get absent",
        do {
          let map = smallMap();
          Map.get(map, Nat.compare, smallSize)
        },
        M.equals(T.optional(T.textTestable, null : ?Text))
      ),
      test(
        "update present",
        do {
          let map = smallMap();
          for (index in Nat.range(0, smallSize)) {
            assert (Map.swap(map, Nat.compare, index, Nat.toText(index) # "!") == ?Nat.toText(index))
          };
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "update absent",
        do {
          let map = smallMap();
          Map.swap(map, Nat.compare, smallSize, Nat.toText(smallSize))
        },
        M.equals(T.optional(T.textTestable, null : ?Text))
      ),
      test(
        "replace if exists present",
        do {
          let map = smallMap();
          for (index in Nat.range(0, smallSize)) {
            assert (Map.replace(map, Nat.compare, index, Nat.toText(index) # "!") == ?Nat.toText(index))
          };
          Map.size(map)
        },
        M.equals(T.nat(smallSize))
      ),
      test(
        "replace if exists absent",
        do {
          let map = smallMap();
          assert (Map.replace(map, Nat.compare, smallSize, Nat.toText(smallSize)) == null);
          Map.size(map)
        },
        M.equals(T.nat(smallSize))
      ),
      test(
        "delete",
        do {
          let map = smallMap();
          for (index in Nat.range(0, smallSize)) {
            assert Map.delete(map, Nat.compare, index)
          };
          Map.isEmpty(map)
        },
        M.equals(T.bool(true))
      ),
      test(
        "clear",
        do {
          let map = smallMap();
          Map.clear(map);
          Map.isEmpty(map)
        },
        M.equals(T.bool(true))
      ),
      test(
        "equal",
        do {
          let map1 = smallMap();
          let map2 = smallMap();
          Map.equal(map1, map2, Nat.compare, Text.equal)
        },
        M.equals(T.bool(true))
      ),
      test(
        "not equal",
        do {
          let map1 = smallMap();
          let map2 = smallMap();
          assert Map.delete(map2, Nat.compare, smallSize - 1 : Nat);
          Map.equal(map1, map2, Nat.compare, Text.equal)
        },
        M.equals(T.bool(false))
      ),
      test(
        "maximum entry",
        do {
          let map = smallMap();
          Map.maxEntry(map)
        },
        M.equals(T.optional(entryTestable, ?(smallSize - 1 : Nat, Nat.toText(smallSize - 1))))
      ),
      test(
        "minimum entry",
        do {
          let map = smallMap();
          Map.minEntry(map)
        },
        M.equals(T.optional(entryTestable, ?(0, "0")))
      ),
      test(
        "iterate keys",
        Iter.toArray(Map.keys(smallMap())),
        M.equals(T.array<Nat>(T.natTestable, Array.tabulate<Nat>(smallSize, func(index) { index })))
      ),
      test(
        "iterate values",
        Iter.toArray(Map.values(smallMap())),
        M.equals(T.array<Text>(T.textTestable, Array.tabulate<Text>(smallSize, func(index) { Nat.toText(index) })))
      ),
      test(
        "from iterator",
        do {
          let array = Array.tabulate(smallSize, func(index) { (index, Nat.toText(index)) });
          let map = Map.fromIter(array.values(), Nat.compare);
          for (index in Nat.range(0, smallSize)) {
            assert (Map.get(map, Nat.compare, index) == ?Nat.toText(index))
          };
          assert (Map.equal(map, smallMap(), Nat.compare, Text.equal));
          Map.size(map)
        },
        M.equals(T.nat(smallSize))
      ),
      test(
        "for each",
        do {
          let map = smallMap();
          var index = 0;
          Map.forEach<Nat, Text>(
            map,
            func(key, value) {
              assert (key == index);
              assert (value == Nat.toText(index));
              index += 1
            }
          );
          Map.size(map)
        },
        M.equals(T.nat(smallSize))
      ),
      test(
        "filter",
        do {
          let input = smallMap();
          let output = Map.filter(
            input,
            Nat.compare,
            func(key, value) {
              key % 2 == 0
            }
          );
          for (index in Nat.range(0, smallSize)) {
            let present = Map.containsKey(output, Nat.compare, index);
            if (index % 2 == 0) {
              assert (present);
              assert (Map.get(output, Nat.compare, index) == ?Nat.toText(index))
            } else {
              assert (not present);
              assert (Map.get(output, Nat.compare, index) == null)
            }
          };
          Map.size(output)
        },
        M.equals(T.nat((smallSize + 1) / 2))
      ),
      test(
        "map",
        do {
          let input = smallMap();
          let output = Map.map(
            input,
            func(key, value) {
              +key
            }
          );
          for (index in Nat.range(0, smallSize)) {
            assert (Map.get(output, Nat.compare, index) == ?+index)
          };
          Map.size(output)
        },
        M.equals(T.nat(smallSize))
      ),
      test(
        "filter map",
        do {
          let input = smallMap();
          let output = Map.filterMap(
            input,
            Nat.compare,
            func(key, value) {
              if (key % 2 == 0) {
                ?+key
              } else {
                null
              }
            }
          );
          for (index in Nat.range(0, smallSize)) {
            let present = Map.containsKey(output, Nat.compare, index);
            if (index % 2 == 0) {
              assert (present);
              assert (Map.get(output, Nat.compare, index) == ?+index)
            } else {
              assert (not present);
              assert (Map.get(output, Nat.compare, index) == null)
            }
          };
          Map.size(output)
        },
        M.equals(T.nat((smallSize + 1) / 2))
      ),
      test(
        "fold left",
        do {
          let map = smallMap();
          Map.foldLeft<Nat, Text, Nat>(
            map,
            0,
            func(accumulator, key, value) {
              accumulator + key
            }
          )
        },
        M.equals(T.nat((smallSize * (smallSize - 1)) / 2))
      ),
      test(
        "fold right",
        do {
          let map = smallMap();
          Map.foldRight<Nat, Text, Nat>(
            map,
            0,
            func(key, value, accumulator) {
              key + accumulator
            }
          )
        },
        M.equals(T.nat((smallSize * (smallSize - 1)) / 2))
      ),
      test(
        "all",
        do {
          let map = smallMap();
          Map.all<Nat, Text>(
            map,
            func(key, value) {
              key < smallSize
            }
          )
        },
        M.equals(T.bool(true))
      ),
      test(
        "any",
        do {
          let map = smallMap();
          Map.any<Nat, Text>(
            map,
            func(key, value) {
              key == (smallSize - 1 : Nat)
            }
          )
        },
        M.equals(T.bool(true))
      ),
      test(
        "to text",
        do {
          let map = smallMap();
          Map.toText<Nat, Text>(map, Nat.toText, func(value) { value })
        },
        do {
          var text = "Map{";
          for (index in Nat.range(0, smallSize)) {
            if (text != "Map{") {
              text #= ", "
            };
            text #= "(" # Nat.toText(index) # ", " # Nat.toText(index) # ")"
          };
          text #= "}";
          M.equals(T.text(text))
        }
      ),
      test(
        "compare less key",
        do {
          let map1 = smallMap();
          assert Map.delete(map1, Nat.compare, smallSize - 1 : Nat);
          let map2 = smallMap();
          assert (Map.compare(map1, map2, Nat.compare, Text.compare) == #less);
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "compare less value",
        do {
          let map1 = smallMap();
          let map2 = smallMap();
          ignore Map.swap(map2, Nat.compare, smallSize - 1 : Nat, "Last");
          assert (Map.compare(map1, map2, Nat.compare, Text.compare) == #less);
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "compare equal",
        do {
          let map1 = smallMap();
          let map2 = smallMap();
          assert (Map.compare(map1, map2, Nat.compare, Text.compare) == #equal);
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "compare greater key",
        do {
          let map1 = smallMap();
          let map2 = smallMap();
          assert Map.delete(map2, Nat.compare, smallSize - 1 : Nat);
          assert (Map.compare(map1, map2, Nat.compare, Text.compare) == #greater);
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "compare greater value",
        do {
          let map1 = smallMap();
          ignore Map.swap(map1, Nat.compare, smallSize - 1 : Nat, "Last");
          let map2 = smallMap();
          assert (Map.compare(map1, map2, Nat.compare, Text.compare) == #greater);
          true
        },
        M.equals(T.bool(true))
      ),
      // TODO: Test freeze and thaw
    ]
  )
);

// TODO: Use `mo:core/Random`
class Random(seed : Nat) {
  var number = seed;

  public func reset() {
    number := seed
  };

  public func next() : Nat {
    number := (123138118391 * number + 133489131) % 9999;
    number
  }
};

let randomSeed = 4711;
let numberOfEntries = 10_000;

run(
  suite(
    "large map",
    [
      test(
        "add",
        do {
          let map = Map.empty<Nat, Text>();
          for (index in Nat.range(0, numberOfEntries)) {
            Map.add(map, Nat.compare, index, Nat.toText(index));
            assert (Map.size(map) == index + 1);
            assert (Map.get(map, Nat.compare, index) == ?Nat.toText(index))
          };
          for (index in Nat.range(0, numberOfEntries)) {
            assert (Map.get(map, Nat.compare, index) == ?Nat.toText(index))
          };
          assert (Map.get(map, Nat.compare, numberOfEntries) == null);
          Map.assertValid(map, Nat.compare);
          Map.size(map)
        },
        M.equals(T.nat(numberOfEntries))
      ),
      test(
        "insert",
        do {
          let map = Map.empty<Nat, Text>();
          for (index in Nat.range(0, numberOfEntries)) {
            assert Map.insert(map, Nat.compare, index, Nat.toText(index));
            assert (Map.size(map) == index + 1);
            assert (Map.get(map, Nat.compare, index) == ?Nat.toText(index))
          };
          for (index in Nat.range(0, numberOfEntries)) {
            assert (not Map.insert(map, Nat.compare, index, Nat.toText(index)));
            assert (Map.get(map, Nat.compare, index) == ?Nat.toText(index))
          };
          assert (Map.get(map, Nat.compare, numberOfEntries) == null);
          Map.assertValid(map, Nat.compare);
          Map.size(map)
        },
        M.equals(T.nat(numberOfEntries))
      ),
      test(
        "get",
        do {
          let map = Map.empty<Nat, Text>();
          let random = Random(randomSeed);
          for (index in Nat.range(0, numberOfEntries)) {
            let key = random.next();
            ignore Map.swap(map, Nat.compare, key, Nat.toText(key))
          };
          random.reset();
          for (index in Nat.range(0, numberOfEntries)) {
            let key = random.next();
            assert (Map.get(map, Nat.compare, key) == ?Nat.toText(key))
          };
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "update",
        do {
          let map = Map.empty<Nat, Text>();
          let random = Random(randomSeed);
          for (index in Nat.range(0, numberOfEntries)) {
            let key = random.next();
            ignore Map.swap(map, Nat.compare, key, Nat.toText(key))
          };
          random.reset();
          for (index in Nat.range(0, numberOfEntries)) {
            let key = random.next();
            assert (Map.containsKey(map, Nat.compare, key));
            let oldValue = Map.swap(map, Nat.compare, key, Nat.toText(key) # "!");
            assert (oldValue != null)
          };
          random.reset();
          for (index in Nat.range(0, numberOfEntries)) {
            let key = random.next();
            assert (Map.containsKey(map, Nat.compare, key));
            assert (Map.get(map, Nat.compare, key) == ?(Nat.toText(key) # "!"))
          };
          Map.assertValid(map, Nat.compare);
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "remove",
        do {
          let map = Map.empty<Nat, Text>();
          let random = Random(randomSeed);
          for (index in Nat.range(0, numberOfEntries)) {
            let key = random.next();
            ignore Map.swap(map, Nat.compare, key, Nat.toText(key))
          };
          random.reset();
          for (index in Nat.range(0, numberOfEntries)) {
            let key = random.next();
            assert (Map.containsKey(map, Nat.compare, key));
            assert (Map.get(map, Nat.compare, key) == ?Nat.toText(key))
          };
          random.reset();
          for (index in Nat.range(0, numberOfEntries)) {
            let key = random.next();
            if (Map.containsKey(map, Nat.compare, key)) {
              Map.remove(map, Nat.compare, key);
              assert (not Map.containsKey(map, Nat.compare, key))
            } else {
              Map.remove(map, Nat.compare, key)
            };
            assert (Map.get(map, Nat.compare, key) == null)
          };
          Map.assertValid(map, Nat.compare);
          Map.size(map)
        },
        M.equals(T.nat(0))
      ),
      test(
        "delete",
        do {
          let map = Map.empty<Nat, Text>();
          let random = Random(randomSeed);
          for (index in Nat.range(0, numberOfEntries)) {
            let key = random.next();
            ignore Map.swap(map, Nat.compare, key, Nat.toText(key))
          };
          random.reset();
          for (index in Nat.range(0, numberOfEntries)) {
            let key = random.next();
            assert (Map.containsKey(map, Nat.compare, key));
            assert (Map.get(map, Nat.compare, key) == ?Nat.toText(key))
          };
          random.reset();
          for (index in Nat.range(0, numberOfEntries)) {
            let key = random.next();
            if (Map.containsKey(map, Nat.compare, key)) {
              assert Map.delete(map, Nat.compare, key);
              assert (not Map.containsKey(map, Nat.compare, key))
            } else {
              assert not Map.delete(map, Nat.compare, key)
            };
            assert (Map.get(map, Nat.compare, key) == null)
          };
          Map.assertValid(map, Nat.compare);
          Map.size(map)
        },
        M.equals(T.nat(0))
      ),
      test(
        "take",
        do {
          let map = Map.empty<Nat, Text>();
          let random = Random(randomSeed);
          for (index in Nat.range(0, numberOfEntries)) {
            let key = random.next();
            ignore Map.swap(map, Nat.compare, key, Nat.toText(key))
          };
          random.reset();
          for (index in Nat.range(0, numberOfEntries)) {
            let key = random.next();
            assert (Map.containsKey(map, Nat.compare, key));
            assert (Map.get(map, Nat.compare, key) == ?Nat.toText(key))
          };
          random.reset();
          for (index in Nat.range(0, numberOfEntries)) {
            let key = random.next();
            if (Map.containsKey(map, Nat.compare, key)) {
              assert Map.take(map, Nat.compare, key) == ?(Nat.toText(key));
              assert (not Map.containsKey(map, Nat.compare, key))
            } else {
              assert Map.take(map, Nat.compare, key) == null
            };
            assert (Map.get(map, Nat.compare, key) == null)
          };
          Map.assertValid(map, Nat.compare);
          Map.size(map)
        },
        M.equals(T.nat(0))
      ),
      test(
        "iterate",
        do {
          let map = Map.empty<Nat, Text>();
          for (index in Nat.range(0, numberOfEntries)) {
            Map.add(map, Nat.compare, index, Nat.toText(index))
          };
          var index = 0;
          for ((key, value) in Map.entries(map)) {
            assert (key == index);
            assert (value == Nat.toText(index));
            index += 1
          };
          index
        },
        M.equals(T.nat(numberOfEntries))
      ),
      test(
        "reverseIterate",
        do {
          let map = Map.empty<Nat, Text>();
          for (index in Nat.range(0, numberOfEntries)) {
            Map.add(map, Nat.compare, index, Nat.toText(index))
          };
          var index = numberOfEntries;
          for ((key, value) in Map.reverseEntries(map)) {
            index -= 1;
            assert (key == index);
            assert (value == Nat.toText(index))
          };
          index
        },
        M.equals(T.nat(0))
      )
    ]
  )
);

run(
  suite(
    "add, update, put",
    [
      test(
        "add disjoint",
        do {
          let map = Map.empty<Nat, Text>();
          Map.add(map, Nat.compare, 0, "0");
          Map.add(map, Nat.compare, 1, "1");
          Map.size(map)
        },
        M.equals(T.nat(2))
      ),
      test(
        "put existing",
        do {
          let map = Map.empty<Nat, Text>();
          Map.add(map, Nat.compare, 0, "0");
          Map.add(map, Nat.compare, 0, "Zero");
          Map.get(map, Nat.compare, 0)
        },
        M.equals(T.optional(T.textTestable, ?"Zero"))
      )
    ]
  )
);

run(
  suite(
    "map conversion",
    [
      test(
        "toPure",
        do {
          let map = Map.empty<Nat, Text>();
          for (index in Nat.range(0, numberOfEntries)) {
            Map.add(map, Nat.compare, index, Nat.toText(index))
          };
          let pureMap = Map.toPure(map, Nat.compare);
          for (index in Nat.range(0, numberOfEntries)) {
            assert (PureMap.get(pureMap, Nat.compare, index) == ?Nat.toText(index))
          };
          PureMap.assertValid(pureMap, Nat.compare);
          PureMap.size(pureMap)
        },
        M.equals(T.nat(numberOfEntries))
      ),
      test(
        "fromPure",
        do {
          var pureMap = PureMap.empty<Nat, Text>();
          for (index in Nat.range(0, numberOfEntries)) {
            pureMap := PureMap.add(pureMap, Nat.compare, index, Nat.toText(index))
          };
          let map = Map.fromPure(pureMap, Nat.compare);
          for (index in Nat.range(0, numberOfEntries)) {
            assert (Map.get(map, Nat.compare, index) == ?Nat.toText(index))
          };
          Map.assertValid(map, Nat.compare);
          Map.size(map)
        },
        M.equals(T.nat(numberOfEntries))
      )
    ]
  )
);

Test.suite(
  "entriesFrom",
  func() {
    Test.test(
      "Simple",
      func() {
        let map = Map.empty<Nat, Text>();
        Map.add(map, Nat.compare, 1, "1");
        Map.add(map, Nat.compare, 2, "2");
        Map.add(map, Nat.compare, 4, "4");
        func check(from : Nat, expected : [(Nat, Text)]) {
          let actual = Iter.toArray(Map.entriesFrom(map, Nat.compare, from));
          Test.expect.array(actual, Tuple2.makeToText(Nat.toText, Text.toText), Tuple2.makeEqual(Nat.equal, Text.equal)).equal(expected)
        };
        check(0, [(1, "1"), (2, "2"), (4, "4")]);
        check(1, [(1, "1"), (2, "2"), (4, "4")]);
        check(2, [(2, "2"), (4, "4")]);
        check(3, [(4, "4")]);
        check(4, [(4, "4")]);
        check(5, [])
      }
    );
    Test.test(
      "Extensive 2D test",
      func() {
        let map = Map.empty<Nat, Text>();
        let n = 100;
        for (i in Nat.rangeBy(1, n, 2)) {
          Map.add(map, Nat.compare, i, Nat.toText(i));
          for (j in Nat.range(0, i + 2)) {
            let actual = Iter.toArray(Map.entriesFrom(map, Nat.compare, j));
            let expected = Iter.toArray(Iter.dropWhile(Map.entries(map), func(k, v) = k < j));
            Test.expect.array(actual, Tuple2.makeToText(Nat.toText, Text.toText), Tuple2.makeEqual(Nat.equal, Text.equal)).equal(expected)
          }
        }
      }
    )
  }
);

Test.suite(
  "reverseEntriesFrom",
  func() {
    Test.test(
      "Simple",
      func() {
        let map = Map.empty<Nat, Text>();
        Map.add(map, Nat.compare, 1, "1");
        Map.add(map, Nat.compare, 2, "2");
        Map.add(map, Nat.compare, 4, "4");
        func check(from : Nat, expected : [(Nat, Text)]) {
          let actual = Iter.toArray(Map.reverseEntriesFrom(map, Nat.compare, from));
          Test.expect.array(actual, Tuple2.makeToText(Nat.toText, Text.toText), Tuple2.makeEqual(Nat.equal, Text.equal)).equal(expected)
        };
        check(0, []);
        check(1, [(1, "1")]);
        check(2, [(2, "2"), (1, "1")]);
        check(3, [(2, "2"), (1, "1")]);
        check(4, [(4, "4"), (2, "2"), (1, "1")]);
        check(5, [(4, "4"), (2, "2"), (1, "1")])
      }
    );
    Test.test(
      "Extensive 2D test",
      func() {
        let map = Map.empty<Nat, Text>();
        let n = 100;
        for (i in Nat.rangeBy(1, n, 2)) {
          Map.add(map, Nat.compare, i, Nat.toText(i));
          for (j in Nat.range(0, i + 2)) {
            let actual = Iter.toArray(Map.reverseEntriesFrom(map, Nat.compare, j));
            let expected = Iter.toArray(Iter.dropWhile(Map.reverseEntries(map), func(k, v) = k > j));
            Test.expect.array(actual, Tuple2.makeToText(Nat.toText, Text.toText), Tuple2.makeEqual(Nat.equal, Text.equal)).equal(expected)
          }
        }
      }
    )
  }
)
