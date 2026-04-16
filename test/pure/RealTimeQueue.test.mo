// @testmode wasi

import Queue "../../src/pure/RealTimeQueue";
import Array "../../src/Array";
import Nat "../../src/Nat";
import Iter "../../src/Iter";
import Prim "mo:prim";
import { suite; test; expect } "mo:test";
import Text "../../src/Text";

type Queue<T> = Queue.Queue<T>;

func iterateForward<T>(queue : Queue<T>) : Iter.Iter<T> = queue.values();

func iterateBackward<T>(queue : Queue<T>) : Iter.Iter<T> = Queue.reverse(queue).values();

func frontToText(t : (Nat, Queue<Nat>)) : Text {
  "(" # Nat.toText(t.0) # ", " # Queue.toText(t.1, Nat.toText) # ")"
};

func frontEqual(t1 : (Nat, Queue<Nat>), t2 : (Nat, Queue<Nat>)) : Bool {
  t1.0 == t2.0 and Queue.equal(t1.1, t2.1, Nat.equal)
};

func backToText(t : (Queue<Nat>, Nat)) : Text {
  "(" # Queue.toText(t.0, Nat.toText) # ", " # Nat.toText(t.1) # ")"
};

func backEqual(t1 : (Queue<Nat>, Nat), t2 : (Queue<Nat>, Nat)) : Bool {
  t1.1 == t2.1 and Queue.equal(t1.0, t2.0, Nat.equal)
};

func reduceFront<T>(queue : Queue<T>, amount : Nat) : Queue<T> {
  var current = queue;
  for (_ in Nat.range(0, amount)) {
    switch (Queue.popFront(current)) {
      case null Prim.trap("should not be null");
      case (?result) current := result.1
    }
  };
  current
};

func reduceBack<T>(queue : Queue<T>, amount : Nat) : Queue<T> {
  var current = queue;
  for (_ in Nat.range(0, amount)) {
    switch (Queue.popBack(current)) {
      case null Prim.trap("should not be null");
      case (?result) current := result.0
    }
  };
  current
};

var queue = Queue.empty<Nat>();

suite(
  "construct",
  func() {
    test(
      "empty",
      func() {
        expect.bool(Queue.isEmpty(queue)).isTrue()
      }
    );

    test(
      "iterate forward",
      func() {
        expect.array<Nat>((iterateForward(queue)).toArray(), Nat.toText, Nat.equal).size(0)
      }
    );

    test(
      "iterate backward",
      func() {
        expect.array((iterateBackward(queue)).toArray(), Nat.toText, Nat.equal).size(0)
      }
    );

    test(
      "peek front",
      func() {
        expect.option(Queue.peekFront(queue), Nat.toText, Nat.equal).isNull()
      }
    );

    test(
      "peek back",
      func() {
        expect.option(Queue.peekBack(queue), Nat.toText, Nat.equal).isNull()
      }
    );

    test(
      "pop front",
      func() {
        expect.option(
          Queue.popFront(queue),
          frontToText,
          frontEqual
        ).isNull()
      }
    );

    test(
      "pop back",
      func() {
        expect.option(
          Queue.popBack(queue),
          backToText,
          backEqual
        ).isNull()
      }
    )
  }
);

queue := Queue.pushFront(Queue.empty<Nat>(), 1);

suite(
  "single item",
  func() {
    test(
      "not empty",
      func() {
        expect.bool(Queue.isEmpty(queue)).isFalse()
      }
    );

    test(
      "iterate forward",
      func() {
        expect.array((iterateForward(queue)).toArray(), Nat.toText, Nat.equal).equal([1])
      }
    );

    test(
      "iterate backward",
      func() {
        expect.array((iterateBackward(queue)).toArray(), Nat.toText, Nat.equal).equal([1])
      }
    );

    test(
      "peek front",
      func() {
        expect.option(Queue.peekFront(queue), Nat.toText, Nat.equal).equal(?1)
      }
    );

    test(
      "peek back",
      func() {
        expect.option(Queue.peekBack(queue), Nat.toText, Nat.equal).equal(?1)
      }
    );

    test(
      "pop front",
      func() {
        expect.option(
          Queue.popFront(queue),
          frontToText,
          frontEqual
        ).equal(?(1, Queue.empty()))
      }
    );

    test(
      "pop back",
      func() {
        expect.option(
          Queue.popBack(queue),
          backToText,
          backEqual
        ).equal(?(Queue.empty(), 1))
      }
    )
  }
);

let testSize = 100;

func populateForward(from : Nat, to : Nat) : Queue<Nat> {
  var queue = Queue.empty<Nat>();
  for (number in Nat.range(from, to)) {
    queue := Queue.pushFront(queue, number)
  };
  queue
};

queue := populateForward(1, testSize + 1);

suite(
  "forward insertion",
  func() {
    test(
      "not empty",
      func() {
        expect.bool(Queue.isEmpty(queue)).isFalse()
      }
    );

    test(
      "iterate forward",
      func() {
        expect.array(
          (iterateForward(queue)).toArray(),
          Nat.toText,
          Nat.equal
        ).equal(
          Array.tabulate(
            testSize,
            func(index : Nat) : Nat {
              testSize - index
            }
          )
        )
      }
    );

    test(
      "iterate backward",
      func() {
        expect.array(
          (iterateBackward(queue)).toArray(),
          Nat.toText,
          Nat.equal
        ).equal(
          Array.tabulate(
            testSize,
            func(index : Nat) : Nat {
              index + 1
            }
          )
        )
      }
    );

    test(
      "peek front",
      func() {
        expect.option(Queue.peekFront(queue), Nat.toText, Nat.equal).equal(?testSize)
      }
    );

    test(
      "peek back",
      func() {
        expect.option(Queue.peekBack(queue), Nat.toText, Nat.equal).equal(?1)
      }
    );

    test(
      "pop front",
      func() {
        expect.option(
          Queue.popFront(queue),
          frontToText,
          frontEqual
        ).equal(?(testSize, populateForward(1, testSize)))
      }
    );

    test(
      "empty after front removal",
      func() {
        expect.bool(Queue.isEmpty(reduceFront(queue, testSize))).isTrue()
      }
    );

    test(
      "empty after back removal",
      func() {
        expect.bool(Queue.isEmpty(reduceBack(queue, testSize))).isTrue()
      }
    )
  }
);

func populateBackward(from : Nat, to : Nat) : Queue<Nat> {
  var queue = Queue.empty<Nat>();
  for (number in Nat.range(from, to)) {
    queue := Queue.pushBack(queue, number)
  };
  queue
};

queue := populateBackward(1, testSize + 1);

suite(
  "backward insertion",
  func() {
    test(
      "not empty",
      func() {
        expect.bool(Queue.isEmpty(queue)).isFalse()
      }
    );

    test(
      "iterate forward",
      func() {
        expect.array(
          (iterateForward(queue)).toArray(),
          Nat.toText,
          Nat.equal
        ).equal(
          Array.tabulate(
            testSize,
            func(index : Nat) : Nat {
              index + 1
            }
          )
        )
      }
    );

    test(
      "iterate backward",
      func() {
        expect.array(
          (iterateBackward(queue)).toArray(),
          Nat.toText,
          Nat.equal
        ).equal(
          Array.tabulate(
            testSize,
            func(index : Nat) : Nat {
              testSize - index
            }
          )
        )
      }
    );

    test(
      "peek front",
      func() {
        expect.option(Queue.peekFront(queue), Nat.toText, Nat.equal).equal(?1)
      }
    );

    test(
      "peek back",
      func() {
        expect.option(Queue.peekBack(queue), Nat.toText, Nat.equal).equal(?testSize)
      }
    );

    test(
      "pop front",
      func() {
        expect.option(
          Queue.popFront(queue),
          frontToText,
          frontEqual
        ).equal(?(1, populateBackward(2, testSize + 1)))
      }
    );

    test(
      "pop back",
      func() {
        expect.option(
          Queue.popBack(queue),
          backToText,
          backEqual
        ).equal(?(populateBackward(1, testSize), testSize))
      }
    );

    test(
      "empty after front removal",
      func() {
        expect.bool(Queue.isEmpty(reduceFront(queue, testSize))).isTrue()
      }
    );

    test(
      "empty after back removal",
      func() {
        expect.bool(Queue.isEmpty(reduceBack(queue, testSize))).isTrue()
      }
    )
  }
);

queue := Queue.filter<Nat>(Queue.fromIter([1, 2, 3, 4, 5].values()), func n = n < 3);

suite(
  "filter invariants",
  func() {
    test(
      "not empty",
      func() {
        expect.bool(Queue.isEmpty(queue)).isFalse()
      }
    );

    test(
      "peek front",
      func() {
        expect.option(Queue.peekFront(queue), Nat.toText, Nat.equal).equal(?1)
      }
    );

    test(
      "peek back",
      func() {
        expect.option(Queue.peekBack(queue), Nat.toText, Nat.equal).equal(?2)
      }
    )
  }
);

object Random {
  var number = 4711;
  public func next() : Int {
    number := (123138118391 * number + 133489131) % 9999;
    number
  }
};

func randomPopulate(amount : Nat) : Queue<Nat> {
  var current = Queue.empty<Nat>();
  for (number in Nat.range(0, amount)) {
    current := if (Random.next() % 2 == 0) {
      Queue.pushFront(current, Nat.sub(amount, number))
    } else {
      Queue.pushBack(current, amount + number)
    }
  };
  current
};

func isSorted(queue : Queue<Nat>) : Bool {
  let array = (iterateForward(queue)).toArray();
  let sorted = Array.sort(array, Nat.compare);
  Array.equal(array, sorted, Nat.equal)
};

func randomRemoval(queue : Queue<Nat>, amount : Nat) : Queue<Nat> {
  var current = queue;
  for (number in Nat.range(0, amount)) {
    current := if (Random.next() % 2 == 0) {
      let pair = Queue.popFront(current);
      switch pair {
        case null Prim.trap("should not be null");
        case (?result) result.1
      }
    } else {
      let pair = Queue.popBack(current);
      switch pair {
        case null Prim.trap("should not be null");
        case (?result) result.0
      }
    }
  };
  current
};

queue := randomPopulate(testSize);

suite(
  "random insertion",
  func() {
    test(
      "not empty",
      func() {
        expect.bool(Queue.isEmpty(queue)).isFalse()
      }
    );

    test(
      "correct order",
      func() {
        expect.bool(isSorted(queue)).isTrue()
      }
    );

    test(
      "consistent iteration",
      func() {
        expect.array(
          (iterateForward(queue)).toArray(),
          Nat.toText,
          Nat.equal
        ).equal(Array.reverse((iterateBackward(queue)).toArray()))
      }
    );

    test(
      "random quarter removal",
      func() {
        expect.bool(isSorted(randomRemoval(queue, testSize / 4))).isTrue()
      }
    );

    test(
      "random half removal",
      func() {
        expect.bool(isSorted(randomRemoval(queue, testSize / 2))).isTrue()
      }
    );

    test(
      "random three quarter removal",
      func() {
        expect.bool(isSorted(randomRemoval(queue, testSize * 3 / 4))).isTrue()
      }
    );

    test(
      "random total removal",
      func() {
        expect.bool(Queue.isEmpty(randomRemoval(queue, testSize))).isTrue()
      }
    )
  }
);

func randomInsertionDeletion(steps : Nat) : Queue<Nat> {
  var current = Queue.empty<Nat>();
  var size = 0;
  for (number in Nat.range(0, steps - 1)) {
    let random = Random.next();
    current := switch (random % 4) {
      case 0 {
        size += 1;
        Queue.pushFront(current, Nat.sub(steps, number))
      };
      case 1 {
        size += 1;
        Queue.pushBack(current, steps + number)
      };
      case 2 {
        switch (Queue.popFront(current)) {
          case null {
            assert (size == 0);
            current
          };
          case (?result) {
            size -= 1;
            result.1
          }
        }
      };
      case 3 {
        switch (Queue.popBack(current)) {
          case null {
            assert (size == 0);
            current
          };
          case (?result) {
            size -= 1;
            result.0
          }
        }
      };
      case _ Prim.trap("Impossible case")
    };
    assert (isSorted(current))
  };
  current
};

suite(
  "completely random",
  func() {
    test(
      "random insertion and deletion",
      func() {
        expect.bool(isSorted(randomInsertionDeletion(1000))).isTrue()
      }
    )
  }
);

suite(
  "code coverage",
  func() {
    test(
      "singleton",
      func() {
        let q = Queue.singleton(1);
        expect.bool(Queue.isEmpty(q)).isFalse();
        expect.option(Queue.peekFront(q), Nat.toText, Nat.equal).equal(?1);
        expect.option(Queue.peekBack(q), Nat.toText, Nat.equal).equal(?1)
      }
    );

    test(
      "all",
      func() {
        let testAll = func(testElements : [Nat]) {
          let q = Queue.fromIter(testElements.values());
          expect.bool(Queue.all<Nat>(q, func n = n > 0)).isTrue();
          expect.bool(Queue.all<Nat>(q, func n = n < 3)).isFalse()
        };
        testAll([4]);
        testAll([1, 5]);
        testAll([1, 2, 6]);
        testAll([1, 2, 3, 4]);
        testAll([1, 2, 2, 3, 3, 4]);
        testAll([1, 2, 2, 3, 3, 4, 5, 6, 7, 8, 9])
      }
    );

    test(
      "filterMap",
      func() {
        let testFilterMap = func(testElements : [Nat]) {
          let q = Queue.fromIter(testElements.values());
          let mapped = Queue.filterMap<Nat, Text>(
            q,
            func n = if (n % 2 == 0) ?Nat.toText(n) else null
          );
          expect.array<Text>(
            mapped.values().toArray(),
            func t = t,
            Text.equal
          ).equal(Array.filterMap<Nat, Text>(testElements, func n = if (n % 2 == 0) ?Nat.toText(n) else null))
        };
        testFilterMap([]);
        testFilterMap([1]);
        testFilterMap([1, 2]);
        testFilterMap([1, 2, 3]);
        testFilterMap([1, 2, 3, 4]);
        testFilterMap([1, 2, 2, 3, 3, 4]);
        testFilterMap([1, 2, 2, 3, 3, 4, 5, 6, 7, 8, 9])
      }
    );

    test(
      "forEach",
      func() {
        let testForEach = func(testElements : [Nat]) {
          let q = Queue.fromIter(testElements.values());
          var result = "";
          Queue.forEach<Nat>(
            q,
            func n {
              result #= Nat.toText n
            }
          );
          expect.text(result).equal(Array.foldLeft<Nat, Text>(testElements, "", func(acc, n) = acc # Nat.toText n))
        };
        testForEach([]);
        testForEach([1]);
        testForEach([1, 2]);
        testForEach([1, 2, 3]);
        testForEach([1, 2, 3, 4]);
        testForEach([1, 2, 2, 3, 3, 4]);
        testForEach([1, 2, 2, 3, 3, 4, 5, 6, 7, 8, 9])
      }
    );

    test(
      "toText",
      func() {
        let testToText = func(testElements : [Nat]) {
          let q = Queue.fromIter(testElements.values());
          expect.text(Queue.toText(q, Nat.toText)).equal("RealTimeQueue" # Array.toText<Nat>(testElements, Nat.toText))
        };
        testToText([]);
        testToText([1]);
        testToText([1, 2]);
        testToText([1, 2, 3]);
        testToText([1, 2, 3, 4]);
        testToText([1, 2, 2, 3, 3, 4]);
        testToText([1, 2, 2, 3, 3, 4, 5, 6, 7, 8, 9])
      }
    );

    test(
      "size",
      func() {
        let testSize = func(testElements : [Nat]) {
          let q = Queue.fromIter(testElements.values());
          expect.nat(Queue.size(q)).equal(testElements.size())
        };
        testSize([]);
        testSize([1]);
        testSize([1, 2]);
        testSize([1, 2, 3]);
        testSize([1, 2, 3, 4]);
        testSize([1, 2, 2, 3, 3, 4]);
        testSize([1, 2, 2, 3, 3, 4, 5, 6, 7, 8, 9])
      }
    );

    test(
      "contains",
      func() {
        let testContains = func(testElements : [Nat]) {
          let q = Queue.fromIter(testElements.values());
          let alwaysThere = 1;
          let neverThere = 123;
          expect.bool(Queue.contains(q, Nat.equal, alwaysThere)).equal(Array.find<Nat>(testElements, func n = Nat.equal(n, alwaysThere)) != null);
          expect.bool(Queue.contains(q, Nat.equal, neverThere)).equal(Array.find<Nat>(testElements, func n = Nat.equal(n, neverThere)) != null)
        };
        testContains([]);
        testContains([1]);
        testContains([1, 2]);
        testContains([1, 2, 3]);
        testContains([1, 2, 3, 4]);
        testContains([1, 2, 2, 3, 3, 4]);
        testContains([1, 2, 2, 3, 3, 4, 5, 6, 7, 8, 9])
      }
    );

    test(
      "any",
      func() {
        let testAny = func(testElements : [Nat]) {
          let q = Queue.fromIter(testElements.values());
          expect.bool(Queue.any<Nat>(q, func n = n > 2)).equal(Array.any<Nat>(testElements, func n = n > 2));
          expect.bool(Queue.any<Nat>(q, func n = n > 3)).equal(Array.any<Nat>(testElements, func n = n > 3))
        };
        testAny([]);
        testAny([3]);
        testAny([1, 3]);
        testAny([1, 2, 3]);
        testAny([1, 2, 3, 2]);
        testAny([1, 2, 3, 2, 1]);
        testAny([1, 2, 0, 2, 1, 3]);
        testAny([1, 2, 0, 2, 1, 3, 1])
      }
    );

    test(
      "map",
      func() {
        let testMap = func(testElements : [Nat]) {
          let q = Queue.fromIter(testElements.values());
          let mapped = Queue.map<Nat, Nat>(q, func n = n * 2);
          expect.array(
            mapped.values().toArray(),
            Nat.toText,
            Nat.equal
          ).equal(Array.map<Nat, Nat>(testElements, func n = n * 2))
        };
        testMap([]);
        testMap([1]);
        testMap([1, 2]);
        testMap([1, 2, 3]);
        testMap([1, 2, 3, 4]);
        testMap([1, 2, 2, 3, 3, 4]);
        testMap([1, 2, 2, 3, 3, 4, 5, 6, 7, 8, 9])
      }
    );

    test(
      "reverse",
      func() {
        let testReverse = func(testElements : [Nat]) {
          let q = Queue.fromIter(testElements.values());
          let reversed = Queue.reverse(q);
          expect.array(
            reversed.values().toArray(),
            Nat.toText,
            Nat.equal
          ).equal(Array.reverse(testElements))
        };

        testReverse([]);
        testReverse([1]);
        testReverse([1, 2]);
        testReverse([1, 2, 3]);
        testReverse([1, 2, 3, 4]);
        testReverse([1, 2, 2, 3, 3, 4]);
        testReverse([1, 2, 2, 3, 3, 4, 5, 6, 7, 8, 9])
      }
    );

    test(
      "compare",
      func() {
        let testCompare = func(testElements1 : [Nat], testElements2 : [Nat]) {
          let q1 = Queue.fromIter(testElements1.values());
          let q2 = Queue.fromIter(testElements2.values());
          expect.bool(q1.compare(q2) == Array.compare<Nat>(testElements1, testElements2, Nat.compare)).isTrue()
        };

        testCompare([], []);
        testCompare([1], []);
        testCompare([], [1]);
        testCompare([1], [1]);
        testCompare([1], [2]);
        testCompare([1, 2], [1]);
        testCompare([1], [1, 2]);
        testCompare([1, 2], [1, 2]);
        testCompare([1, 2], [2, 1]);
        testCompare([1, 2, 4], [1, 2, 3]);
        testCompare([1, 2, 3], [1, 2, 4]);
        testCompare([1, 2, 3], [1, 3, 3]);
        testCompare([1, 2, 3], [2, 2, 3]);
        testCompare([1, 2, 3], [2, 3, 3]);
        testCompare([1, 2, 3], [2, 3, 4])
      }
    )
  }
);

suite(
  "edge cases",
  func() {
    test(
      "empty queue operations",
      func() {
        let q = Queue.empty<Nat>();
        expect.bool(Queue.isEmpty(q)).isTrue();
        expect.nat(Queue.size(q)).equal(0);
        expect.option(Queue.peekFront(q), Nat.toText, Nat.equal).isNull();
        expect.option(Queue.peekBack(q), Nat.toText, Nat.equal).isNull();
        expect.option(
          Queue.popFront(q),
          frontToText,
          frontEqual
        ).isNull();
        expect.option(
          Queue.popBack(q),
          backToText,
          backEqual
        ).isNull()
      }
    );

    test(
      "rebalancing threshold",
      func() {
        // Create a queue that's exactly at the rebalancing threshold
        var q = Queue.empty<Nat>();
        for (i in Nat.range(1, 4)) {
          q := Queue.pushFront(q, i)
        };
        for (i in Nat.range(5, 12)) {
          q := Queue.pushBack(q, i)
        };
        let #rebal(_) = q else Prim.trap "Should be in rebalancing state";
        // Test operations during rebalancing
        expect.text(Queue.toText(q, Nat.toText)).equal("RealTimeQueue[3, 2, 1, 5, 6, 7, 8, 9, 10, 11]");
        q := Queue.pushFront(q, 0);
        q := Queue.pushBack(q, 13);
        expect.bool(Queue.isEmpty(q)).isFalse();
        expect.option(Queue.peekFront(q), Nat.toText, Nat.equal).equal(?0);
        expect.option(Queue.peekBack(q), Nat.toText, Nat.equal).equal(?13)
      }
    );

    test(
      "alternating operations",
      func() {
        var q = Queue.empty<Nat>();
        // Alternating pushes
        for (i in Nat.range(0, 5)) {
          q := Queue.pushFront(q, i);
          q := Queue.pushBack(q, i + 100)
        };
        // Mixed operations
        expect.option(Queue.popFront(q), frontToText, frontEqual).equal(?(4, Queue.fromIter([3, 2, 1, 0, 100, 101, 102, 103, 104].values())));
        q := Queue.pushBack(q, 200);
        expect.option(Queue.popBack(q), backToText, backEqual).equal(?(Queue.fromIter([4, 3, 2, 1, 0, 100, 101, 102, 103, 104].values()), 200));
        q := Queue.pushFront(q, 300);
        // Verify order is maintained
        expect.array(
          q.values().toArray(),
          Nat.toText,
          Nat.equal
        ).equal([300, 4, 3, 2, 1, 0, 100, 101, 102, 103, 104, 200])
      }
    )
  }
);

suite(
  "regression: stack overflow should not happen when iterating over large queues",
  func() {
    let queue = populateForward(1, 17_001);
    let actual = (iterateBackward(queue)).toArray();
    expect.array(
      actual,
      Nat.toText,
      Nat.equal
    ).equal(
      Array.tabulate<Nat>(17_000, func i = i + 1)
    )
  }
)
