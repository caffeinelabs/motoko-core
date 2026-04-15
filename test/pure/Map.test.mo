// @testmode wasi

import Map "../../src/pure/Map";
import Nat "../../src/Nat";
import Iter "../../src/Iter";
import Debug "../../src/Debug";
import Array "../../src/Array";
import Runtime "../../src/Runtime";
import Text "../../src/Text";

import Suite "mo:matchers/Suite";
import T "mo:matchers/Testable";
import M "mo:matchers/Matchers";

let { run; test; suite } = Suite;

let entryTestable = T.tuple2Testable(T.natTestable, T.textTestable);

class MapMatcher(expected : [(Nat, Text)]) : M.Matcher<Map.Map<Nat, Text>> {
  public func describeMismatch(actual : Map.Map<Nat, Text>, _description : M.Description) {
    Debug.print(debug_show (Iter.toArray(actual.entries())) # " should be " # debug_show (expected))
  };

  public func matches(actual : Map.Map<Nat, Text>) : Bool {
    Iter.toArray(actual.entries()) == expected
  }
};

func checkMap(m : Map.Map<Nat, Text>) { m.assertValid() };

func insert(rbTree : Map.Map<Nat, Text>, key : Nat) : Map.Map<Nat, Text> {
  let updatedTree = rbTree.add(key, debug_show (key));
  checkMap(updatedTree);
  updatedTree
};

func getAll(rbTree : Map.Map<Nat, Text>, keys : [Nat]) {
  for (key in keys.vals()) {
    let value = rbTree.get(key);
    assert (value == ?debug_show (key))
  }
};

func clear(initialRbMap : Map.Map<Nat, Text>) : Map.Map<Nat, Text> {
  var rbMap = initialRbMap;
  for ((key, value) in initialRbMap.entries()) {
    // stable iteration
    assert (value == debug_show (key));
    let (newMap, result) = rbMap.take(key);
    rbMap := newMap;
    assert (result == ?debug_show (key));
    checkMap(rbMap)
  };
  rbMap
};

func expectedEntries(keys : [Nat]) : [(Nat, Text)] {
  Array.tabulate<(Nat, Text)>(keys.size(), func(index) { (keys[index], debug_show (keys[index])) })
};

func concatenateKeys(key : Nat, value : Text, accum : Text) : Text {
  accum # debug_show (key)
};

func concatenateKeys2(accum : Text, key : Nat, value : Text) : Text {
  accum # debug_show (key)
};

func concatenateValues(key : Nat, value : Text, accum : Text) : Text {
  accum # value
};

func concatenateValues2(accum : Text, key : Nat, value : Text) : Text {
  accum # value
};

func multiplyKeyAndConcat(key : Nat, value : Text) : Text {
  debug_show (key * 2) # value
};

func ifKeyLessThan(threshold : Nat, f : (Nat, Text) -> Text) : (Nat, Text) -> ?Text = func(key, value) {
  if (key < threshold) ?f(key, value) else null
};

/* --------------------------------------- */

var buildTestMap = func() : Map.Map<Nat, Text> {
  Map.empty()
};

run(
  suite(
    "empty",
    [
      test(
        "size",
        buildTestMap().size,
        M.equals(T.nat(0))
      ),
      test(
        "entries",
        Iter.toArray(buildTestMap().entries()),
        M.equals(T.array<(Nat, Text)>(entryTestable, []))
      ),
      test(
        "reverseEntries",
        Iter.toArray(buildTestMap().reverseEntries()),
        M.equals(T.array<(Nat, Text)>(entryTestable, []))
      ),
      test(
        "keys",
        Iter.toArray(buildTestMap().keys()),
        M.equals(T.array<Nat>(T.natTestable, []))
      ),
      test(
        "vals",
        Iter.toArray(buildTestMap().values()),
        M.equals(T.array<Text>(T.textTestable, []))
      ),
      test(
        "empty from iter",
        Map.fromIter(Iter.fromArray([]), Nat.compare),
        MapMatcher([])
      ),
      test(
        "get absent",
        Map.get(buildTestMap(), Nat.compare, 0),
        M.equals(T.optional(T.textTestable, null : ?Text))
      ),
      test(
        "containsKey absent",
        Map.containsKey(buildTestMap(), Nat.compare, 0),
        M.equals(T.bool(false))
      ),
      test(
        "maxEntry",
        Map.maxEntry(buildTestMap()),
        M.equals(T.optional(entryTestable, null : ?(Nat, Text)))
      ),
      test(
        "minEntry",
        Map.minEntry(buildTestMap()),
        M.equals(T.optional(entryTestable, null : ?(Nat, Text)))
      ),
      test(
        "take absent",
        Map.take(buildTestMap(), Nat.compare, 0).1,
        M.equals(T.optional(T.textTestable, null : ?Text))
      ),
      test(
        "replace absent/no value",
        Map.swap(buildTestMap(), Nat.compare, 0, "Test").1,
        M.equals(T.optional(T.textTestable, null : ?Text))
      ),
      test(
        "replace absent/key appeared",
        Map.swap(buildTestMap(), Nat.compare, 0, "Test").0,
        MapMatcher([(0, "Test")])
      ),
      test(
        "empty right fold keys",
        Map.foldRight(buildTestMap(), "", concatenateKeys),
        M.equals(T.text(""))
      ),
      test(
        "empty left fold keys",
        Map.foldLeft(buildTestMap(), "", concatenateKeys2),
        M.equals(T.text(""))
      ),
      test(
        "empty right fold values",
        Map.foldRight(buildTestMap(), "", concatenateValues),
        M.equals(T.text(""))
      ),
      test(
        "empty left fold values",
        Map.foldLeft(buildTestMap(), "", concatenateValues2),
        M.equals(T.text(""))
      ),
      test(
        "traverse empty map",
        Map.map(buildTestMap(), multiplyKeyAndConcat),
        MapMatcher([])
      ),
      test(
        "empty map filter",
        Map.filterMap(buildTestMap(), Nat.compare, ifKeyLessThan(0, multiplyKeyAndConcat)),
        MapMatcher([])
      ),
      test(
        "empty all",
        Map.all<Nat, Text>(buildTestMap(), func(k, v) = false),
        M.equals(T.bool(true))
      ),
      test(
        "empty any",
        Map.any<Nat, Text>(buildTestMap(), func(k, v) = true),
        M.equals(T.bool(false))
      ),
      test(
        "empty to text",
        Map.toText<Nat, Text>(buildTestMap(), Nat.toText, func(value) { value }),
        M.equals(T.text("PureMap{}"))
      ),
      test(
        "for each",
        do {
          let map = Map.empty<Nat, Text>();
          map.forEach(
            func(_, _) {
              assert false
            }
          );
          map.size
        },
        M.equals(T.nat(0))
      ),
      test(
        "filter",
        do {
          let input = Map.empty<Nat, Text>();
          let output = input.filter<Nat, Text>(func(_, _) {
              Runtime.trap("test failed")
            }
          );
          output.size
        },
        M.equals(T.nat(0))
      ),
      test(
        "compare",
        do {
          let map1 = Map.empty<Nat, Text>();
          let map2 = Map.empty<Nat, Text>();
          assert (map1.compare(map2) == #equal);
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "equal",
        do {
          let map1 = Map.empty<Nat, Text>();
          let map2 = Map.empty<Nat, Text>();
          map1.equal(map2)
        },
        M.equals(T.bool(true))
      ),

    ]
  )
);

/* --------------------------------------- */

buildTestMap := func() : Map.Map<Nat, Text> {
  insert(Map.empty(), 0)
};

var expected = expectedEntries([0]);

run(
  suite(
    "singleton",
    [
      test(
        "singleton valid",
        do {
          let map = Map.singleton(0, "Zero");
          map.assertValid();
          map.size
        },
        M.equals(T.nat(1))
      ),

      test(
        "size",
        buildTestMap().size,
        M.equals(T.nat(1))
      ),
      test(
        "entries",
        Iter.toArray(buildTestMap().entries()),
        M.equals(T.array<(Nat, Text)>(entryTestable, expected))
      ),
      test(
        "reverseEntries",
        Iter.toArray(buildTestMap().reverseEntries()),
        M.equals(T.array<(Nat, Text)>(entryTestable, expected))
      ),
      test(
        "keys",
        Iter.toArray(buildTestMap().keys()),
        M.equals(T.array<Nat>(T.natTestable, [0]))
      ),
      test(
        "values",
        Iter.toArray(buildTestMap().values()),
        M.equals(T.array<Text>(T.textTestable, ["0"]))
      ),
      test(
        "from iter",
        Map.fromIter(Iter.fromArray(expected), Nat.compare),
        MapMatcher(expected)
      ),
      test(
        "get",
        Map.get(buildTestMap(), Nat.compare, 0),
        M.equals(T.optional(T.textTestable, ?"0"))
      ),
      test(
        "containsKey",
        Map.containsKey(buildTestMap(), Nat.compare, 0),
        M.equals(T.bool(true))
      ),
      test(
        "maxEntry",
        Map.maxEntry(buildTestMap()),
        M.equals(T.optional(entryTestable, ?(0, "0")))
      ),
      test(
        "minEntry",
        Map.minEntry(buildTestMap()),
        M.equals(T.optional(entryTestable, ?(0, "0")))
      ),
      test(
        "swap function result",
        Map.swap(buildTestMap(), Nat.compare, 0, "TEST").1,
        M.equals(T.optional(T.textTestable, ?"0"))
      ),
      test(
        "swap map result",
        do {
          let rbMap = buildTestMap();
          rbMap.swap(0, "TEST").0
        },
        MapMatcher([(0, "TEST")])
      ),
      test(
        "take function result",
        Map.take(buildTestMap(), Nat.compare, 0).1,
        M.equals(T.optional(T.textTestable, ?"0"))
      ),
      test(
        "take map result",
        do {
          var rbMap = buildTestMap();
          rbMap := rbMap.take(0).0;
          checkMap(rbMap);
          rbMap
        },
        MapMatcher([])
      ),
      test(
        "right fold keys",
        Map.foldRight(buildTestMap(), "", concatenateKeys),
        M.equals(T.text("0"))
      ),
      test(
        "left fold keys",
        Map.foldLeft(buildTestMap(), "", concatenateKeys2),
        M.equals(T.text("0"))
      ),
      test(
        "right fold values",
        Map.foldRight(buildTestMap(), "", concatenateValues),
        M.equals(T.text("0"))
      ),
      test(
        "left fold values",
        Map.foldLeft(buildTestMap(), "", concatenateValues2),
        M.equals(T.text("0"))
      ),
      test(
        "traverse map",
        Map.map(buildTestMap(), multiplyKeyAndConcat),
        MapMatcher([(0, "00")])
      ),
      test(
        "filter map/filter all",
        Map.filterMap(buildTestMap(), Nat.compare, ifKeyLessThan(0, multiplyKeyAndConcat)),
        MapMatcher([])
      ),
      test(
        "filter map/no filter",
        Map.filterMap(buildTestMap(), Nat.compare, ifKeyLessThan(1, multiplyKeyAndConcat)),
        MapMatcher([(0, "00")])
      ),
      test(
        "all",
        Map.all<Nat, Text>(buildTestMap(), func(k, v) = (k == 0)),
        M.equals(T.bool(true))
      ),
      test(
        "any",
        Map.any<Nat, Text>(buildTestMap(), func(k, v) = (k == 0)),
        M.equals(T.bool(true))
      ),
      test(
        "to text",
        Map.toText<Nat, Text>(buildTestMap(), Nat.toText, func(value) { value }),
        M.equals(T.text("PureMap{(0, 0)}"))
      ),
      test(
        "for each",
        do {
          let map = Map.singleton<Nat, Text>(0, "0");
          map.forEach(
            func(key, value) {
              assert (key == 0);
              assert (value == "0")
            }
          );
          map.size
        },
        M.equals(T.nat(1))
      ),
      test(
        "filter",
        do {
          let input = Map.singleton<Nat, Text>(0, "0");
          let output = input.filter<Nat, Text>(func(key, value) {
              assert (key == 0);
              assert (value == "0");
              true
            }
          );
          assert (input.equal(output));
          output.size
        },
        M.equals(T.nat(1))
      ),
      test(
        "singleton size",
        Map.size<Nat, Text>(Map.singleton(0, "0")),
        M.equals(T.nat(1))
      ),
      test(
        "singleton entries",
        Map.singleton(0, "Zero"),
        MapMatcher([(0, "Zero")])
      ),
      test(
        "compare less key",
        do {
          let map1 = Map.singleton<Nat, Text>(0, "0");
          let map2 = Map.singleton<Nat, Text>(1, "1");
          assert (map1.compare(map2) == #less);
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "compare less value",
        do {
          let map1 = Map.singleton<Nat, Text>(0, "0");
          let map2 = Map.singleton<Nat, Text>(0, "Zero");
          assert (map1.compare(map2) == #less);
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "compare equal",
        do {
          let map1 = Map.singleton<Nat, Text>(0, "0");
          let map2 = Map.singleton<Nat, Text>(0, "0");
          assert (map1.compare(map2) == #equal);
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "compare greater key",
        do {
          let map1 = Map.singleton<Nat, Text>(1, "1");
          let map2 = Map.singleton<Nat, Text>(0, "0");
          assert (map1.compare(map2) == #greater);
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "compare greater value",
        do {
          let map1 = Map.singleton<Nat, Text>(0, "Zero");
          let map2 = Map.singleton<Nat, Text>(0, "0");
          assert (map1.compare(map2) == #greater);
          true
        },
        M.equals(T.bool(true))
      )
    ]
  )
);
/* --------------------------------------- */

expected := expectedEntries([0, 1, 2]);

func rebalanceTests(buildTestMap : () -> Map.Map<Nat, Text>) : [Suite.Suite] = [
  test(
    "size",
    buildTestMap().size,
    M.equals(T.nat(3))
  ),
  test(
    "map match",
    buildTestMap(),
    MapMatcher(expected)
  ),
  test(
    "entries",
    Iter.toArray(buildTestMap().entries()),
    M.equals(T.array<(Nat, Text)>(entryTestable, expected))
  ),
  test(
    "reverserEntries",
    Iter.toArray(buildTestMap().reverseEntries()),
    M.equals(T.array<(Nat, Text)>(entryTestable, Array.reverse(expected)))
  ),
  test(
    "keys",
    Iter.toArray(buildTestMap().keys()),
    M.equals(T.array<Nat>(T.natTestable, [0, 1, 2]))
  ),
  test(
    "values",
    Iter.toArray(buildTestMap().values()),
    M.equals(T.array<Text>(T.textTestable, ["0", "1", "2"]))
  ),
  test(
    "from iter",
    Map.fromIter(Iter.fromArray(expected), Nat.compare),
    MapMatcher(expected)
  ),
  test(
    "get all",
    do {
      let rbMap = buildTestMap();
      getAll(rbMap, [0, 1, 2]);
      rbMap
    },
    MapMatcher(expected)
  ),
  test(
    "containsKey",
    Array.tabulate<Bool>(4, func(k : Nat) = (Map.containsKey(buildTestMap(), Nat.compare, k))),
    M.equals(T.array<Bool>(T.boolTestable, [true, true, true, false]))
  ),
  test(
    "maxEntry",
    Map.maxEntry(buildTestMap()),
    M.equals(T.optional(entryTestable, ?(2, "2")))
  ),
  test(
    "minEntry",
    Map.minEntry(buildTestMap()),
    M.equals(T.optional(entryTestable, ?(0, "0")))
  ),
  test(
    "clear",
    clear(buildTestMap()),
    MapMatcher([])
  ),
  test(
    "right fold keys",
    Map.foldRight(buildTestMap(), "", concatenateKeys),
    M.equals(T.text("210"))
  ),
  test(
    "left fold keys",
    Map.foldLeft(buildTestMap(), "", concatenateKeys2),
    M.equals(T.text("012"))
  ),
  test(
    "right fold values",
    Map.foldRight(buildTestMap(), "", concatenateValues),
    M.equals(T.text("210"))
  ),
  test(
    "left fold values",
    Map.foldLeft(buildTestMap(), "", concatenateValues2),
    M.equals(T.text("012"))
  ),
  test(
    "traverse map",
    Map.map(buildTestMap(), multiplyKeyAndConcat),
    MapMatcher([(0, "00"), (1, "21"), (2, "42")])
  ),
  test(
    "filter map/filter all",
    Map.filterMap(buildTestMap(), Nat.compare, ifKeyLessThan(0, multiplyKeyAndConcat)),
    MapMatcher([])
  ),
  test(
    "filter map/filter one",
    Map.filterMap(buildTestMap(), Nat.compare, ifKeyLessThan(1, multiplyKeyAndConcat)),
    MapMatcher([(0, "00")])
  ),
  test(
    "filter map/no filter",
    Map.filterMap(buildTestMap(), Nat.compare, ifKeyLessThan(3, multiplyKeyAndConcat)),
    MapMatcher([(0, "00"), (1, "21"), (2, "42")])
  ),
  test(
    "all true",
    Map.all<Nat, Text>(buildTestMap(), func(k, v) = (k >= 0)),
    M.equals(T.bool(true))
  ),
  test(
    "all false",
    Map.all<Nat, Text>(buildTestMap(), func(k, v) = (k > 0)),
    M.equals(T.bool(false))
  ),
  test(
    "any true",
    Map.any<Nat, Text>(buildTestMap(), func(k, v) = (k >= 2)),
    M.equals(T.bool(true))
  ),
  test(
    "any false",
    Map.any<Nat, Text>(buildTestMap(), func(k, v) = (k > 2)),
    M.equals(T.bool(false))
  ),
  test(
    "to text",
    Map.toText<Nat, Text>(buildTestMap(), Nat.toText, func(value) { value }),
    M.equals(T.text("PureMap{(0, 0), (1, 1), (2, 2)}"))
  ),
  test(
    "for each",
    do {
      let map = buildTestMap();
      var index = 0;
      map.forEach(
        func(key, value) {
          assert (key == index);
          assert (value == Nat.toText(index));
          index += 1
        }
      );
      map.size
    },
    M.equals(T.nat(3))
  ),
  test(
    "filter",
    do {
      let input = buildTestMap();
      let output = input.filter<Nat, Text>(func(key, value) {
          key % 2 == 0
        }
      );
      for (index in Nat.range(0, input.size)) {
        let present = output.containsKey(index);
        if (index % 2 == 0) {
          assert (present);
          assert (output.get(index) == ?Nat.toText(index))
        } else {
          assert (not present);
          assert (output.get(index) == null)
        }
      };
      output.size
    },
    M.equals(T.nat((3 + 1) / 2))
  )
];

buildTestMap := func() : Map.Map<Nat, Text> {
  var rbMap = Map.empty() : Map.Map<Nat, Text>;
  rbMap := insert(rbMap, 2);
  rbMap := insert(rbMap, 1);
  rbMap := insert(rbMap, 0);
  rbMap
};

run(suite("rebalance left, left", rebalanceTests(buildTestMap)));

/* --------------------------------------- */

buildTestMap := func() : Map.Map<Nat, Text> {
  var rbMap = Map.empty() : Map.Map<Nat, Text>;
  rbMap := insert(rbMap, 2);
  rbMap := insert(rbMap, 0);
  rbMap := insert(rbMap, 1);
  rbMap
};

run(suite("rebalance left, right", rebalanceTests(buildTestMap)));

/* --------------------------------------- */

buildTestMap := func() : Map.Map<Nat, Text> {
  var rbMap = Map.empty() : Map.Map<Nat, Text>;
  rbMap := insert(rbMap, 0);
  rbMap := insert(rbMap, 2);
  rbMap := insert(rbMap, 1);
  rbMap
};

run(suite("rebalance right, left", rebalanceTests(buildTestMap)));

/* --------------------------------------- */

buildTestMap := func() : Map.Map<Nat, Text> {
  var rbMap = Map.empty() : Map.Map<Nat, Text>;
  rbMap := insert(rbMap, 0);
  rbMap := insert(rbMap, 1);
  rbMap := insert(rbMap, 2);
  rbMap
};

run(suite("rebalance right, right", rebalanceTests(buildTestMap)));

/* --------------------------------------- */

run(
  suite(
    "repeated operations",
    [
      test(
        "repeated put",
        do {
          var rbMap = buildTestMap();
          assert (rbMap.get(1) == ?"1");
          rbMap := rbMap.add(1, "TEST-1");
          rbMap.get(1)
        },
        M.equals(T.optional(T.textTestable, ?"TEST-1"))
      ),
      test(
        "repeated swap",
        do {
          let rbMap0 = buildTestMap();
          let (rbMap1, firstResult) = rbMap0.swap(1, "TEST-1");
          assert (firstResult == ?"1");
          let (rbMap2, secondResult) = rbMap1.swap(1, "1");
          assert (secondResult == ?"TEST-1");
          rbMap2
        },
        MapMatcher(expected)
      ),
      test(
        "repeated take",
        do {
          var rbMap0 = buildTestMap();
          let (rbMap1, result) = rbMap0.take(1);
          assert (result == ?"1");
          checkMap(rbMap1);
          rbMap1.take(1).1
        },
        M.equals(T.optional(T.textTestable, null : ?Text))
      ),
      test(
        "repeated delete",
        do {
          let map = buildTestMap();
          let (map1, result1) = map.delete(1);
          assert result1;
          let (map2, result2) = map1.delete(1);
          assert not result2;
          map2
        },
        MapMatcher(expectedEntries([0, 2]))
      )
    ]
  )
);

let smallSize = 100;
func smallMap() : Map.Map<Nat, Text> {
  var map = Map.empty<Nat, Text>();
  for (index in Nat.range(0, smallSize)) {
    map := map.add(index, Nat.toText(index))
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
            assert (map.containsKey(index))
          };
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "contains absent key",
        do {
          let map = smallMap();
          map.containsKey(smallSize)
        },
        M.equals(T.bool(false))
      ),
      test(
        "get present",
        do {
          let map = smallMap();
          for (index in Nat.range(0, smallSize)) {
            assert (map.get(index) == ?Nat.toText(index))
          };
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "get absent",
        do {
          let map = smallMap();
          map.get(smallSize)
        },
        M.equals(T.optional(T.textTestable, null : ?Text))
      ),
      test(
        "update present",
        do {
          let map = smallMap();
          for (index in Nat.range(0, smallSize)) {
            assert (map.swap(index, Nat.toText(index) # "!").1 == ?Nat.toText(index))
          };
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "update absent",
        do {
          let map = smallMap();
          map.swap(smallSize, Nat.toText(smallSize)).1
        },
        M.equals(T.optional(T.textTestable, null : ?Text))
      ),
      test(
        "replace if exists present",
        do {
          let map = smallMap();
          for (index in Nat.range(0, smallSize)) {
            assert (map.replace(index, Nat.toText(index) # "!").1 == ?Nat.toText(index))
          };
          map.size
        },
        M.equals(T.nat(smallSize))
      ),
      test(
        "replace if exists absent",
        do {
          let map0 = smallMap();
          let (map1, ov) = map0.replace(smallSize, Nat.toText(smallSize));
          assert (ov == null);
          map1.size
        },
        M.equals(T.nat(smallSize))
      ),
      test(
        "delete",
        do {
          var map = smallMap();
          for (index in Nat.range(0, smallSize)) {
            let (map1, changed) = map.delete(index);
            assert changed;
            map := map1
          };
          map.isEmpty()
        },
        M.equals(T.bool(true))
      ),
      test(
        "equal",
        do {
          let map1 = smallMap();
          let map2 = smallMap();
          map1.equal(map2)
        },
        M.equals(T.bool(true))
      ),
      test(
        "not equal",
        do {
          let map1 = smallMap();
          let (map2, _) = map1.delete(smallSize - 1 : Nat);
          map1.equal(map2)
        },
        M.equals(T.bool(false))
      ),
      test(
        "maximum entry",
        do {
          let map = smallMap();
          map.maxEntry()
        },
        M.equals(T.optional(entryTestable, ?(smallSize - 1 : Nat, Nat.toText(smallSize - 1))))
      ),
      test(
        "minimum entry",
        do {
          let map = smallMap();
          map.minEntry()
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
          let array = Array.tabulate<(Nat, Text)>(smallSize, func(index) { (index, Nat.toText(index)) });
          let map = Map.fromIter<Nat, Text>(Iter.fromArray(array), Nat.compare);
          for (index in Nat.range(0, smallSize)) {
            assert (map.get(index) == ?Nat.toText(index))
          };
          assert (Map.equal(map, smallMap(), Nat.compare, Text.equal));
          map.size
        },
        M.equals(T.nat(smallSize))
      ),
      test(
        "for each",
        do {
          let map = smallMap();
          var index = 0;
          map.forEach(
            func(key, value) {
              assert (key == index);
              assert (value == Nat.toText(index));
              index += 1
            }
          );
          map.size
        },
        M.equals(T.nat(smallSize))
      ),
      test(
        "filter",
        do {
          let input = smallMap();
          let output = input.filter<Nat, Text>(func(key, value) {
              key % 2 == 0
            }
          );
          for (index in Nat.range(0, smallSize)) {
            let present = output.containsKey(index);
            if (index % 2 == 0) {
              assert (present);
              assert (output.get(index) == ?Nat.toText(index))
            } else {
              assert (not present);
              assert (output.get(index) == null)
            }
          };
          output.size
        },
        M.equals(T.nat((smallSize + 1) / 2))
      ),
      test(
        "map",
        do {
          let input = smallMap();
          let output = Map.map<Nat, Text, Int>(
            input,
            func(key, value) {
              +key
            }
          );
          for (index in Nat.range(0, smallSize)) {
            assert (output.get(index) == ?index)
          };
          output.size
        },
        M.equals(T.nat(smallSize))
      ),
      test(
        "filter map",
        do {
          let input = smallMap();
          let output = Map.filterMap<Nat, Text, Int>(
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
            let present = output.containsKey(index);
            if (index % 2 == 0) {
              assert (present);
              assert (output.get(index) == ?+index)
            } else {
              assert (not present);
              assert (output.get(index) == null)
            }
          };
          output.size
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
          map.all<Nat, Text>(
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
          map.any<Nat, Text>(
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
          map.toText()
        },
        do {
          var text = "PureMap{";
          for (index in Nat.range(0, smallSize)) {
            if (text != "PureMap{") {
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
          let (map1, result1) = Map.delete(smallMap(), Nat.compare, smallSize - 1 : Nat);
          assert result1;
          let map2 = smallMap();
          assert (map1.compare(map2) == #less);
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "compare less value",
        do {
          let map1 = smallMap();
          let (map2, _) = Map.swap(smallMap(), Nat.compare, smallSize - 1 : Nat, "Last");
          assert (map1.compare(map2) == #less);
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "compare equal",
        do {
          let map1 = smallMap();
          let map2 = smallMap();
          assert (map1.compare(map2) == #equal);
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "compare greater key",
        do {
          let map1 = smallMap();
          let (map2, result2) = Map.delete(smallMap(), Nat.compare, smallSize - 1 : Nat);
          assert result2;
          assert (map1.compare(map2) == #greater);
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "compare greater value",
        do {
          let (map1, _) = Map.swap(smallMap(), Nat.compare, smallSize - 1 : Nat, "Last");
          let map2 = smallMap();
          assert (map1.compare(map2) == #greater);
          true
        },
        M.equals(T.bool(true))
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
          var map = Map.empty<Nat, Text>();
          map := map.add(0, "0");
          map := map.add(1, "1");
          map.size
        },
        M.equals(T.nat(2))
      ),
      test(
        "put existing",
        do {
          var map = Map.empty<Nat, Text>();
          map := map.add(0, "0");
          map := map.add(0, "Zero");
          map.get(0)
        },
        M.equals(T.optional(T.textTestable, ?"Zero"))
      )
    ]
  )
)
