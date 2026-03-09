import PriorityQueue "../src/PriorityQueue";
import PriorityQueueSet "../bench/utils/PriorityQueueSet";
import Nat "../src/Nat";
import Iter "../src/Iter";
import Runtime "../src/Runtime";
import Array "../src/Array";
import Types "../src/Types";
import VarArray "../src/VarArray";
import Random "../src/Random";
import { Tuple2 } "../src/Tuples";
import Order "../src/Order";
import Debug "../src/Debug";
import Text "../src/Text";

import { suite; test; expect } "mo:test";

suite(
  "empty",
  func() {
    test(
      "size",
      func() {
        expect.nat(PriorityQueue.size(PriorityQueue.empty<Nat>())).equal(0)
      }
    );

    test(
      "is empty",
      func() {
        expect.bool(PriorityQueue.isEmpty(PriorityQueue.empty<Nat>())).equal(true)
      }
    );

    test(
      "push",
      func() {
        let priorityQueue = PriorityQueue.empty<Nat>();
        PriorityQueue.push(priorityQueue, Nat.compare, 42);
        expect.nat(PriorityQueue.size(priorityQueue)).equal(1);
        let top = PriorityQueue.peek(priorityQueue);
        expect.option<Nat>(top, Nat.toText, Nat.equal).equal(?42)
      }
    );

    test(
      "peek",
      func() {
        let priorityQueue = PriorityQueue.empty<Nat>();
        let top = PriorityQueue.peek(priorityQueue);
        expect.bool(PriorityQueue.isEmpty(priorityQueue)).equal(true);
        expect.option<Nat>(top, Nat.toText, Nat.equal).equal(null)
      }
    );

    test(
      "pop",
      func() {
        let priorityQueue = PriorityQueue.empty<Nat>();
        let top = PriorityQueue.pop(priorityQueue, Nat.compare);
        expect.bool(PriorityQueue.isEmpty(priorityQueue)).equal(true);
        expect.option<Nat>(top, Nat.toText, Nat.equal).equal(null)
      }
    );

    test(
      "clear",
      func() {
        let priorityQueue = PriorityQueue.singleton<Nat>(0);
        PriorityQueue.clear(priorityQueue);
        expect.bool(PriorityQueue.isEmpty(priorityQueue)).equal(true)
      }
    )
  }
);

suite(
  "singleton",
  func() {
    test(
      "size",
      func() {
        expect.nat(PriorityQueue.size(PriorityQueue.singleton<Nat>(42))).equal(1)
      }
    );

    test(
      "is empty",
      func() {
        expect.bool(PriorityQueue.isEmpty(PriorityQueue.singleton<Nat>(42))).equal(false)
      }
    );

    test(
      "push smaller",
      func() {
        let priorityQueue = PriorityQueue.singleton<Nat>(42);
        PriorityQueue.push(priorityQueue, Nat.compare, 41);
        expect.nat(PriorityQueue.size(priorityQueue)).equal(2);
        let top = PriorityQueue.peek(priorityQueue);
        expect.option<Nat>(top, Nat.toText, Nat.equal).equal(?42)
      }
    );

    test(
      "push equal",
      func() {
        let priorityQueue = PriorityQueue.singleton<Nat>(42);
        PriorityQueue.push(priorityQueue, Nat.compare, 42);
        expect.nat(PriorityQueue.size(priorityQueue)).equal(2);
        let top = PriorityQueue.peek(priorityQueue);
        expect.option<Nat>(top, Nat.toText, Nat.equal).equal(?42)
      }
    );

    test(
      "push larger",
      func() {
        let priorityQueue = PriorityQueue.singleton<Nat>(42);
        PriorityQueue.push(priorityQueue, Nat.compare, 43);
        expect.nat(PriorityQueue.size(priorityQueue)).equal(2);
        let top = PriorityQueue.peek(priorityQueue);
        expect.option<Nat>(top, Nat.toText, Nat.equal).equal(?43)
      }
    );

    test(
      "peek",
      func() {
        let priorityQueue = PriorityQueue.singleton<Nat>(42);
        let top = PriorityQueue.peek(priorityQueue);
        expect.nat(PriorityQueue.size(priorityQueue)).equal(1);
        expect.option<Nat>(top, Nat.toText, Nat.equal).equal(?42)
      }
    );

    test(
      "pop",
      func() {
        let priorityQueue = PriorityQueue.singleton<Nat>(42);
        let top = PriorityQueue.pop(priorityQueue, Nat.compare);
        expect.bool(PriorityQueue.isEmpty(priorityQueue)).equal(true);
        expect.option<Nat>(top, Nat.toText, Nat.equal).equal(?42)
      }
    );

    test(
      "clear",
      func() {
        let priorityQueue = PriorityQueue.singleton<Nat>(42);
        PriorityQueue.clear(priorityQueue);
        expect.bool(PriorityQueue.isEmpty(priorityQueue)).equal(true)
      }
    )
  }
);

func testPushAndPeekThenPopArray<T>(
  values : [T],
  compare : (T, T) -> Order.Order,
  equal : (T, T) -> Bool,
  toText : T -> Text
) {
  let priorityQueue = PriorityQueue.empty<T>();

  for ((i, v) in Iter.enumerate(values.values())) {
    PriorityQueue.push(priorityQueue, compare, v);
    expect.nat(PriorityQueue.size(priorityQueue)).equal(i + 1);
    let top = PriorityQueue.peek(priorityQueue);
    expect.option<T>(top, toText, equal).equal(
      values.values()
      |> Iter.take(_, i + 1) |> Iter.max(_, compare)
    )
  };

  let extractedValues = VarArray.repeat<?T>(null, values.size());
  for (i in Nat.range(0, values.size())) {
    extractedValues[i] := PriorityQueue.pop(priorityQueue, compare);
    expect.nat(PriorityQueue.size(priorityQueue)).equal(values.size() - i - 1)
  };

  expect.array<T>(
    VarArray.map<?T, T>(
      extractedValues,
      func(optTop) {
        switch (optTop) {
          case (?top) top;
          case _ Runtime.trap("priorityQueue unexpectedly empty")
        }
      }
    ) |> Array.fromVarArray(_),
    toText,
    equal
  ).equal(
    Array.sort(values, compare) |> Array.reverse(_)
  )
};

func testPushAndPeekThenPopArrayNat(values : [Nat]) = testPushAndPeekThenPopArray<Nat>(values, Nat.compare, Nat.equal, Nat.toText);
func testPushAndPeekThenPopArrayText(values : [Text]) = testPushAndPeekThenPopArray<Text>(values, Text.compare, Text.equal, func x = x);

suite(
  "push & peek, then pop",
  func() {
    for (
      values in [
        [3, 5, 2, 1, 4],
        [10, 3, 1, 13],
        [10, 3, 1, 10, 2, 1],
        [10, 3, 1, 7, 10, 2, 1, 7, 7, 13, 1, 1, 3]
      ].values()
    ) {
      test(
        "values = " # Array.toText(values, Nat.toText),
        func() {
          testPushAndPeekThenPopArrayNat(values)
        }
      )
    };
    test(
      "text",
      func() {
        testPushAndPeekThenPopArrayText(
          /* values = */ ["mirror", "mirror", "on", "the", "wall", "who", "is", "the", "fairest", "of", "them", "all"]
        )
      }
    );
    test(
      "non-equal equivalent elements",
      func() {
        let values = [1, 2, 1, 3, 1, 2, 2, 3, 2, 1, 1, 2];
        testPushAndPeekThenPopArrayNat(values);

        // Repeat the test, but with a different purpose:
        // ensure that no two popped elements are the same object.
        // Elements that are equal under the comparison function may still be distinct instances!
        // To check this, each element is paired with a unique tag (its insertion id),
        // and we verify that all tags are recovered exactly once after popping.
        let priorityQueue = PriorityQueue.empty<(Nat, Nat)>();
        func compareValue((tag1, v1) : (Nat, Nat), (tag2, v2) : (Nat, Nat)) : Order.Order = Nat.compare(v1, v2);
        for ((tag, v) in Iter.enumerate(values.values())) {
          PriorityQueue.push(priorityQueue, compareValue, (tag, v))
        };

        let extractedTags = Array.tabulate<Nat>(
          values.size(),
          func _ {
            let ?(tag, v) = PriorityQueue.pop(priorityQueue, compareValue) else Runtime.trap("priorityQueue unexpectedly empty");
            tag
          }
        );

        expect.array<Nat>(
          Array.sort(extractedTags, Nat.compare),
          Nat.toText,
          Nat.equal
        ).equal(Array.tabulate<Nat>(values.size(), func tag = tag))
      }
    )
  }
);

type PriorityQueueUpdateOperation<T> = {
  #Push : T;
  #Pop;
  #Clear
};

func opToText<T>(op : PriorityQueueUpdateOperation<T>, toText : T -> Text) : Text {
  switch (op) {
    case (#Push element) { "#Push(" # toText(element) # ")" };
    case (#Pop) { "#Pop" };
    case (#Clear) { "#Clear" }
  }
};

/// Returns Text like "[#Push(1), #Pop, ...]"; capped at 10 elements.
func opsToText<T>(ops : [PriorityQueueUpdateOperation<T>], toText : T -> Text) : Text {
  let cap : Nat = 10;
  let n = ops.size();
  let shown = Array.tabulate<Text>(
    Nat.min(ops.size(), cap),
    func i {
      opToText<T>(ops[i], toText)
    }
  );

  let body = Array.toText<Text>(shown, func x = x); // join with ", "

  let ?stripped = Text.stripEnd(body, #char ']');
  stripped # (if (n > cap) "...]" else "]")
};

// Runs a sequence of PriorityQueueUpdateOperations on two data structures in parallel:
// - PriorityQueue
// - PriorityQueueSet
//
// After each operation:
// - If it’s a pop, assert that both queues return the same value.
// - In all cases, compare peek, size, and isEmpty, asserting they match.
func runOpsTwoQueues<T>(
  ops : [PriorityQueueUpdateOperation<T>],
  compare : (T, T) -> Order.Order,
  equal : (T, T) -> Bool,
  toText : T -> Text
) {
  let priorityQueue = PriorityQueue.empty<T>();
  let priorityQueueSet = PriorityQueueSet.empty<T>();
  for (op in ops.values()) {
    // Apply the operation to both queues.
    switch (op) {
      case (#Push element) {
        PriorityQueue.push(priorityQueue, compare, element);
        PriorityQueueSet.push(priorityQueueSet, compare, element)
      };
      case (#Pop) {
        let top = PriorityQueue.pop(priorityQueue, compare);
        let expectedTop = PriorityQueueSet.pop(priorityQueueSet, compare);
        // Verify that the popped values are equal.
        expect.option<T>(top, toText, equal).equal(expectedTop)
      };
      case (#Clear) {
        PriorityQueue.clear(priorityQueue);
        PriorityQueueSet.clear(priorityQueueSet)
      }
    };
    // After every operation, validate that query methods yield the same results.
    let top = PriorityQueue.peek(priorityQueue);
    let expectedTop = PriorityQueueSet.peek(priorityQueueSet);
    expect.option<T>(top, toText, equal).equal(expectedTop);
    expect.nat(PriorityQueue.size(priorityQueue)).equal(PriorityQueueSet.size(priorityQueueSet));
    expect.bool(PriorityQueue.isEmpty(priorityQueue)).equal(PriorityQueueSet.isEmpty(priorityQueueSet))
  }
};

// Generates a randomized sequence of PriorityQueueUpdateOperations on Nat values.
// The distribution of operations is controlled by weights.
//
// randomSeed        - seed for reproducible RNG
// operationsCount   – total number of operations to generate
// maxValueExclusive – upper bound (exclusive) for values pushed into the queue
// wPush             – relative weight of #Push operations (values in [0, maxValueExclusive))
// wPop              – relative weight of #Pop operations
// wClear            – relative weight of #Clear operations
func genOpsNatRandom(
  randomSeed : Nat64,
  operationsCount : Nat,
  maxValueExclusive : Nat,
  wPush : Nat,
  wPop : Nat,
  wClear : Nat
) : [PriorityQueueUpdateOperation<Nat>] {
  let rng = Random.seed(randomSeed);
  Array.tabulate<PriorityQueueUpdateOperation<Nat>>(
    operationsCount,
    func(_) {
      let aux = rng.natRange(0, wPush + wPop + wClear);
      if (aux < wPush) {
        #Push(rng.natRange(0, maxValueExclusive))
      } else if (aux < wPush + wPop) {
        #Pop
      } else {
        #Clear
      }
    }
  )
};

// Generates all possible sequences of PriorityQueueUpdateOperation<Nat>,
// each sequence having exactly `operationsCount` elements.
// The allowed operations are:
//   - #Push(n), where 0 <= n < maxValueExclusive
//   - #Pop
//   - #Clear (only if useClear is true)
//
// operationsCount   – number of operations in each sequence
// maxValueExclusive – exclusive upper bound for values in #Push
// useClear          – whether #Clear operations are allowed
func genOpsNatAllSeqs(
  operationsCount : Nat,
  maxValueExclusive : Nat,
  useClear : Bool
) : [[PriorityQueueUpdateOperation<Nat>]] {
  if (operationsCount == 0) {
    return [[]]
  };
  let allowedOps = Array.flatten([
    Array.tabulate<PriorityQueueUpdateOperation<Nat>>(maxValueExclusive, func i = #Push(i)),
    [#Pop],
    if useClear[#Clear] else []
  ]);
  let shorterSeqs = genOpsNatAllSeqs(operationsCount - 1, maxValueExclusive, useClear);
  Array.flatMap(
    allowedOps,
    func(op : PriorityQueueUpdateOperation<Nat>) : Types.Iter<[PriorityQueueUpdateOperation<Nat>]> {
      Iter.map(
        shorterSeqs.values(),
        func(shorterSeq : [PriorityQueueUpdateOperation<Nat>]) : [PriorityQueueUpdateOperation<Nat>] {
          Array.concat([op], shorterSeq)
        }
      )
    }
  )
};

suite(
  "heap implementation vs. set implementation, all sequences",
  func() {
    for (operationsCount in Nat.rangeInclusive(1, 4)) {
      let useClear = operationsCount <= 3;
      test(
        Nat.toText(operationsCount) # " operations" # (if useClear "" else ", no clear"),
        func() {
          for (
            ops in genOpsNatAllSeqs(
              /* operationsCount = */ operationsCount,
              /* maxValueExclusive = */ operationsCount,
              /* useClear = */ useClear
            ).values()
          ) {
            //Debug.print("ops = " # opsToText(ops, Nat.toText));
            runOpsTwoQueues<Nat>(ops, Nat.compare, Nat.equal, Nat.toText)
          }
        }
      )
    }
  }
);

suite(
  "heap implementation vs. set implementation, random",
  func() {
    test(
      "10 operations, no clears",
      func() {
        let ops = genOpsNatRandom(
          /* randomSeed = */ 127,
          /* operationsCount = */ 10,
          /* maxValueExclusive = */ 10,
          /* wPush = */ 1,
          /* wPop = */ 1,
          /* wClear = */ 0
        );
        //Debug.print("ops = " # opsToText(ops, Nat.toText));
        runOpsTwoQueues<Nat>(ops, Nat.compare, Nat.equal, Nat.toText)
      }
    );
    test(
      "20 operations",
      func() {
        let ops = genOpsNatRandom(
          /* randomSeed = */ 666013,
          /* operationsCount = */ 20,
          /* maxValueExclusive = */ 20,
          /* wPush = */ 1,
          /* wPop = */ 1,
          /* wClear = */ 1
        );
        //Debug.print("ops = " # opsToText(ops, Nat.toText));
        runOpsTwoQueues<Nat>(ops, Nat.compare, Nat.equal, Nat.toText)
      }
    );
    test(
      "5000 operations, no clears",
      func() {
        let ops = genOpsNatRandom(
          /* randomSeed = */ 23,
          /* operationsCount = */ 5000,
          /* maxValueExclusive = */ 5000,
          /* wPush = */ 1,
          /* wPop = */ 1,
          /* wClear = */ 0
        );
        //Debug.print("ops = " # opsToText(ops, Nat.toText));
        runOpsTwoQueues<Nat>(ops, Nat.compare, Nat.equal, Nat.toText)
      }
    );
    test(
      "5000 operations, rare clears",
      func() {
        let ops = genOpsNatRandom(
          /* randomSeed = */ 41,
          /* operationsCount = */ 5000,
          /* maxValueExclusive = */ 5000,
          /* wPush = */ 10,
          /* wPop = */ 10,
          /* wClear = */ 1
        );
        //Debug.print("ops = " # opsToText(ops, Nat.toText));
        runOpsTwoQueues<Nat>(ops, Nat.compare, Nat.equal, Nat.toText)
      }
    );
    test(
      "5000 operations, rare pops, no clears",
      func() {
        let ops = genOpsNatRandom(
          /* randomSeed = */ 42,
          /* operationsCount = */ 5000,
          /* maxValueExclusive = */ 5000,
          /* wPush = */ 10,
          /* wPop = */ 1,
          /* wClear = */ 0
        );
        //Debug.print("ops = " # opsToText(ops, Nat.toText));
        runOpsTwoQueues<Nat>(ops, Nat.compare, Nat.equal, Nat.toText)
      }
    );
    test(
      "5000 operations, no pops, no clears",
      func() {
        let ops = genOpsNatRandom(
          /* randomSeed = */ 33,
          /* operationsCount = */ 5000,
          /* maxValueExclusive = */ 5000,
          /* wPush = */ 10,
          /* wPop = */ 0,
          /* wClear = */ 0
        );
        //Debug.print("ops = " # opsToText(ops, Nat.toText));
        runOpsTwoQueues<Nat>(ops, Nat.compare, Nat.equal, Nat.toText)
      }
    )
  }
);

suite(
  "fromIter",
  func() {
    test(
      "empty iterator",
      func() {
        let pq = PriorityQueue.fromIter<Nat>(Iter.empty<Nat>(), Nat.compare);
        expect.bool(PriorityQueue.isEmpty(pq)).equal(true);
        expect.nat(PriorityQueue.size(pq)).equal(0)
      }
    );

    test(
      "single element",
      func() {
        let pq = PriorityQueue.fromIter<Nat>([42].values(), Nat.compare);
        expect.nat(PriorityQueue.size(pq)).equal(1);
        expect.option<Nat>(PriorityQueue.peek(pq), Nat.toText, Nat.equal).equal(?42)
      }
    );

    test(
      "multiple elements",
      func() {
        let pq = PriorityQueue.fromIter<Nat>([5, 10, 3].values(), Nat.compare);
        expect.nat(PriorityQueue.size(pq)).equal(3);
        expect.option<Nat>(PriorityQueue.peek(pq), Nat.toText, Nat.equal).equal(?10)
      }
    );

    test(
      "preserves all elements in priority order",
      func() {
        let pq = PriorityQueue.fromIter<Nat>([3, 1, 4, 1, 5, 9, 2, 6].values(), Nat.compare);
        expect.nat(PriorityQueue.size(pq)).equal(8);
        expect.option<Nat>(PriorityQueue.pop(pq, Nat.compare), Nat.toText, Nat.equal).equal(?9);
        expect.option<Nat>(PriorityQueue.pop(pq, Nat.compare), Nat.toText, Nat.equal).equal(?6);
        expect.option<Nat>(PriorityQueue.pop(pq, Nat.compare), Nat.toText, Nat.equal).equal(?5);
        expect.option<Nat>(PriorityQueue.pop(pq, Nat.compare), Nat.toText, Nat.equal).equal(?4);
        expect.option<Nat>(PriorityQueue.pop(pq, Nat.compare), Nat.toText, Nat.equal).equal(?3);
        expect.option<Nat>(PriorityQueue.pop(pq, Nat.compare), Nat.toText, Nat.equal).equal(?2);
        expect.option<Nat>(PriorityQueue.pop(pq, Nat.compare), Nat.toText, Nat.equal).equal(?1);
        expect.option<Nat>(PriorityQueue.pop(pq, Nat.compare), Nat.toText, Nat.equal).equal(?1);
        expect.option<Nat>(PriorityQueue.pop(pq, Nat.compare), Nat.toText, Nat.equal).equal(null)
      }
    );

    test(
      "duplicates",
      func() {
        let pq = PriorityQueue.fromIter<Nat>([5, 5, 5].values(), Nat.compare);
        expect.nat(PriorityQueue.size(pq)).equal(3);
        expect.option<Nat>(PriorityQueue.pop(pq, Nat.compare), Nat.toText, Nat.equal).equal(?5);
        expect.option<Nat>(PriorityQueue.pop(pq, Nat.compare), Nat.toText, Nat.equal).equal(?5);
        expect.option<Nat>(PriorityQueue.pop(pq, Nat.compare), Nat.toText, Nat.equal).equal(?5);
        expect.option<Nat>(PriorityQueue.pop(pq, Nat.compare), Nat.toText, Nat.equal).equal(null)
      }
    )
  }
);

suite(
  "clone",
  func() {
    test(
      "empty queue",
      func() {
        let original = PriorityQueue.empty<Nat>();
        let copy = PriorityQueue.clone(original);
        expect.bool(PriorityQueue.isEmpty(copy)).equal(true)
      }
    );

    test(
      "deep copy preserves elements",
      func() {
        let original = PriorityQueue.fromIter<Nat>([5, 10, 3].values(), Nat.compare);
        let copy = PriorityQueue.clone(original);
        expect.nat(PriorityQueue.size(copy)).equal(3);
        expect.option<Nat>(PriorityQueue.peek(copy), Nat.toText, Nat.equal).equal(?10)
      }
    );

    test(
      "mutating the copy does not affect the original",
      func() {
        let original = PriorityQueue.fromIter<Nat>([5, 10, 3].values(), Nat.compare);
        let copy = PriorityQueue.clone(original);
        ignore PriorityQueue.pop(copy, Nat.compare);
        ignore PriorityQueue.pop(copy, Nat.compare);
        expect.nat(PriorityQueue.size(copy)).equal(1);
        expect.nat(PriorityQueue.size(original)).equal(3);
        expect.option<Nat>(PriorityQueue.peek(original), Nat.toText, Nat.equal).equal(?10)
      }
    );

    test(
      "mutating the original does not affect the copy",
      func() {
        let original = PriorityQueue.fromIter<Nat>([5, 10, 3].values(), Nat.compare);
        let copy = PriorityQueue.clone(original);
        PriorityQueue.clear(original);
        expect.bool(PriorityQueue.isEmpty(original)).equal(true);
        expect.nat(PriorityQueue.size(copy)).equal(3);
        expect.option<Nat>(PriorityQueue.peek(copy), Nat.toText, Nat.equal).equal(?10)
      }
    )
  }
);

suite(
  "values",
  func() {
    test(
      "empty queue",
      func() {
        let pq = PriorityQueue.empty<Nat>();
        let vals = Iter.toArray(PriorityQueue.values(pq, Nat.compare));
        expect.array<Nat>(vals, Nat.toText, Nat.equal).equal([])
      }
    );

    test(
      "singleton",
      func() {
        let pq = PriorityQueue.singleton<Nat>(42);
        let vals = Iter.toArray(PriorityQueue.values(pq, Nat.compare));
        expect.array<Nat>(vals, Nat.toText, Nat.equal).equal([42])
      }
    );

    test(
      "yields elements in descending priority order",
      func() {
        let pq = PriorityQueue.fromIter<Nat>([5, 10, 3].values(), Nat.compare);
        let vals = Iter.toArray(PriorityQueue.values(pq, Nat.compare));
        expect.array<Nat>(vals, Nat.toText, Nat.equal).equal([10, 5, 3])
      }
    );

    test(
      "does not modify the original queue",
      func() {
        let pq = PriorityQueue.fromIter<Nat>([5, 10, 3].values(), Nat.compare);
        ignore Iter.toArray(PriorityQueue.values(pq, Nat.compare));
        expect.nat(PriorityQueue.size(pq)).equal(3);
        expect.option<Nat>(PriorityQueue.peek(pq), Nat.toText, Nat.equal).equal(?10)
      }
    );

    test(
      "with duplicates",
      func() {
        let pq = PriorityQueue.fromIter<Nat>([3, 1, 4, 1, 5].values(), Nat.compare);
        let vals = Iter.toArray(PriorityQueue.values(pq, Nat.compare));
        expect.array<Nat>(vals, Nat.toText, Nat.equal).equal([5, 4, 3, 1, 1])
      }
    );

    test(
      "can be called multiple times",
      func() {
        let pq = PriorityQueue.fromIter<Nat>([2, 7, 1].values(), Nat.compare);
        let vals1 = Iter.toArray(PriorityQueue.values(pq, Nat.compare));
        let vals2 = Iter.toArray(PriorityQueue.values(pq, Nat.compare));
        expect.array<Nat>(vals1, Nat.toText, Nat.equal).equal([7, 2, 1]);
        expect.array<Nat>(vals2, Nat.toText, Nat.equal).equal([7, 2, 1])
      }
    )
  }
)
