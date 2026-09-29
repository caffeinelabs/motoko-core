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
        expect.nat(PriorityQueue.empty<Nat>().size()).equal(0)
      }
    );

    test(
      "is empty",
      func() {
        expect.bool(PriorityQueue.empty<Nat>().isEmpty()).equal(true)
      }
    );

    test(
      "push",
      func() {
        let priorityQueue = PriorityQueue.empty<Nat>();
        priorityQueue.push(Nat.compare, 42);
        expect.nat(priorityQueue.size()).equal(1);
        let top = priorityQueue.peek();
        expect.option(top, Nat.toText, Nat.equal).equal(?42)
      }
    );

    test(
      "peek",
      func() {
        let priorityQueue = PriorityQueue.empty<Nat>();
        let top = priorityQueue.peek();
        expect.bool(priorityQueue.isEmpty()).equal(true);
        expect.option(top, Nat.toText, Nat.equal).equal(null)
      }
    );

    test(
      "pop",
      func() {
        let priorityQueue = PriorityQueue.empty<Nat>();
        let top = priorityQueue.pop(Nat.compare);
        expect.bool(priorityQueue.isEmpty()).equal(true);
        expect.option(top, Nat.toText, Nat.equal).equal(null)
      }
    );

    test(
      "clear",
      func() {
        let priorityQueue = PriorityQueue.singleton<Nat>(0);
        priorityQueue.clear();
        expect.bool(priorityQueue.isEmpty()).equal(true)
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
        expect.nat(PriorityQueue.singleton<Nat>(42).size()).equal(1)
      }
    );

    test(
      "is empty",
      func() {
        expect.bool(PriorityQueue.singleton<Nat>(42).isEmpty()).equal(false)
      }
    );

    test(
      "push smaller",
      func() {
        let priorityQueue = PriorityQueue.singleton<Nat>(42);
        priorityQueue.push(Nat.compare, 41);
        expect.nat(priorityQueue.size()).equal(2);
        let top = priorityQueue.peek();
        expect.option(top, Nat.toText, Nat.equal).equal(?42)
      }
    );

    test(
      "push equal",
      func() {
        let priorityQueue = PriorityQueue.singleton<Nat>(42);
        priorityQueue.push(Nat.compare, 42);
        expect.nat(priorityQueue.size()).equal(2);
        let top = priorityQueue.peek();
        expect.option(top, Nat.toText, Nat.equal).equal(?42)
      }
    );

    test(
      "push larger",
      func() {
        let priorityQueue = PriorityQueue.singleton<Nat>(42);
        priorityQueue.push(Nat.compare, 43);
        expect.nat(priorityQueue.size()).equal(2);
        let top = priorityQueue.peek();
        expect.option(top, Nat.toText, Nat.equal).equal(?43)
      }
    );

    test(
      "peek",
      func() {
        let priorityQueue = PriorityQueue.singleton<Nat>(42);
        let top = priorityQueue.peek();
        expect.nat(priorityQueue.size()).equal(1);
        expect.option(top, Nat.toText, Nat.equal).equal(?42)
      }
    );

    test(
      "pop",
      func() {
        let priorityQueue = PriorityQueue.singleton<Nat>(42);
        let top = priorityQueue.pop(Nat.compare);
        expect.bool(priorityQueue.isEmpty()).equal(true);
        expect.option(top, Nat.toText, Nat.equal).equal(?42)
      }
    );

    test(
      "clear",
      func() {
        let priorityQueue = PriorityQueue.singleton<Nat>(42);
        priorityQueue.clear();
        expect.bool(priorityQueue.isEmpty()).equal(true)
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

  for ((i, v) in values.values().enumerate()) {
    priorityQueue.push(compare, v);
    expect.nat(priorityQueue.size()).equal(i + 1);
    let top = priorityQueue.peek();
    expect.option(top, toText, equal).equal(
      values.values()
      |> _.take(i + 1) |> _.max(compare)
    )
  };

  let extractedValues = VarArray.repeat<?T>(null, values.size());
  for (i in Nat.range(0, values.size())) {
    extractedValues[i] := priorityQueue.pop(compare);
    expect.nat(priorityQueue.size()).equal(values.size() - i - 1)
  };

  expect.array(
    extractedValues.map(
      func(optTop) {
        switch (optTop) {
          case (?top) top;
          case _ Runtime.trap("priorityQueue unexpectedly empty")
        }
      }
    ) |> _.toArray(),
    toText,
    equal
  ).equal(
    values.sort(compare) |> _.reverse()
  )
};

func testPushAndPeekThenPopArrayNat(values : [Nat]) = testPushAndPeekThenPopArray(values, Nat.compare, Nat.equal, Nat.toText);
func testPushAndPeekThenPopArrayText(values : [Text]) = testPushAndPeekThenPopArray(values, Text.compare, Text.equal, func x = x);

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
        "values = " # values.toText(Nat.toText),
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
        for ((tag, v) in values.values().enumerate()) {
          priorityQueue.push(compareValue, (tag, v))
        };

        let extractedTags = Array.tabulate(
          values.size(),
          func _ {
            let ?(tag, v) = priorityQueue.pop(compareValue) else Runtime.trap("priorityQueue unexpectedly empty");
            tag
          }
        );

        expect.array(
          extractedTags.sort(Nat.compare),
          Nat.toText,
          Nat.equal
        ).equal(Array.tabulate(values.size(), func tag = tag))
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
  let shown = Array.tabulate(
    Nat.min(ops.size(), cap),
    func i {
      opToText(ops[i], toText)
    }
  );

  let body = shown.toText(func x = x); // join with ", "

  let ?stripped = body.stripEnd(#char ']');
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
        priorityQueue.push(compare, element);
        PriorityQueueSet.push(priorityQueueSet, compare, element)
      };
      case (#Pop) {
        let top = priorityQueue.pop(compare);
        let expectedTop = PriorityQueueSet.pop(priorityQueueSet, compare);
        // Verify that the popped values are equal.
        expect.option(top, toText, equal).equal(expectedTop)
      };
      case (#Clear) {
        priorityQueue.clear();
        PriorityQueueSet.clear(priorityQueueSet)
      }
    };
    // After every operation, validate that query methods yield the same results.
    let top = priorityQueue.peek();
    let expectedTop = PriorityQueueSet.peek(priorityQueueSet);
    expect.option(top, toText, equal).equal(expectedTop);
    expect.nat(priorityQueue.size()).equal(PriorityQueueSet.size(priorityQueueSet));
    expect.bool(priorityQueue.isEmpty()).equal(PriorityQueueSet.isEmpty(priorityQueueSet))
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
  Array.tabulate(
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
    if useClear { [#Clear] } else []
  ]);
  let shorterSeqs = genOpsNatAllSeqs(operationsCount - 1, maxValueExclusive, useClear);
  allowedOps.flatMap(
    func(op : PriorityQueueUpdateOperation<Nat>) : Types.Iter<[PriorityQueueUpdateOperation<Nat>]> {
      shorterSeqs.values().map(
        func(shorterSeq : [PriorityQueueUpdateOperation<Nat>]) : [PriorityQueueUpdateOperation<Nat>] {
          [op].concat(shorterSeq)
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
        operationsCount.toText() # " operations" # (if useClear "" else ", no clear"),
        func() {
          for (
            ops in genOpsNatAllSeqs(
              /* operationsCount = */ operationsCount,
              /* maxValueExclusive = */ operationsCount,
              /* useClear = */ useClear
            ).values()
          ) {
            //Debug.print("ops = " # opsToText(ops, Nat.toText));
            runOpsTwoQueues(ops, Nat.compare, Nat.equal, Nat.toText)
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
        runOpsTwoQueues(ops, Nat.compare, Nat.equal, Nat.toText)
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
        runOpsTwoQueues(ops, Nat.compare, Nat.equal, Nat.toText)
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
        runOpsTwoQueues(ops, Nat.compare, Nat.equal, Nat.toText)
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
        runOpsTwoQueues(ops, Nat.compare, Nat.equal, Nat.toText)
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
        runOpsTwoQueues(ops, Nat.compare, Nat.equal, Nat.toText)
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
        runOpsTwoQueues(ops, Nat.compare, Nat.equal, Nat.toText)
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
        let pq = PriorityQueue.fromIter(Iter.empty<Nat>(), Nat.compare);
        expect.bool(pq.isEmpty()).equal(true);
        expect.nat(pq.size()).equal(0)
      }
    );

    test(
      "single element",
      func() {
        let pq = PriorityQueue.fromIter([42].values(), Nat.compare);
        expect.nat(pq.size()).equal(1);
        expect.option(pq.peek(), Nat.toText, Nat.equal).equal(?42)
      }
    );

    test(
      "multiple elements",
      func() {
        let pq = PriorityQueue.fromIter([5, 10, 3].values(), Nat.compare);
        expect.nat(pq.size()).equal(3);
        expect.option(pq.peek(), Nat.toText, Nat.equal).equal(?10)
      }
    );

    test(
      "preserves all elements in priority order",
      func() {
        let pq = PriorityQueue.fromIter([3, 1, 4, 1, 5, 9, 2, 6].values(), Nat.compare);
        expect.nat(pq.size()).equal(8);
        expect.option(pq.pop(Nat.compare), Nat.toText, Nat.equal).equal(?9);
        expect.option(pq.pop(Nat.compare), Nat.toText, Nat.equal).equal(?6);
        expect.option(pq.pop(Nat.compare), Nat.toText, Nat.equal).equal(?5);
        expect.option(pq.pop(Nat.compare), Nat.toText, Nat.equal).equal(?4);
        expect.option(pq.pop(Nat.compare), Nat.toText, Nat.equal).equal(?3);
        expect.option(pq.pop(Nat.compare), Nat.toText, Nat.equal).equal(?2);
        expect.option(pq.pop(Nat.compare), Nat.toText, Nat.equal).equal(?1);
        expect.option(pq.pop(Nat.compare), Nat.toText, Nat.equal).equal(?1);
        expect.option(pq.pop(Nat.compare), Nat.toText, Nat.equal).equal(null)
      }
    );

    test(
      "duplicates",
      func() {
        let pq = PriorityQueue.fromIter([5, 5, 5].values(), Nat.compare);
        expect.nat(pq.size()).equal(3);
        expect.option(pq.pop(Nat.compare), Nat.toText, Nat.equal).equal(?5);
        expect.option(pq.pop(Nat.compare), Nat.toText, Nat.equal).equal(?5);
        expect.option(pq.pop(Nat.compare), Nat.toText, Nat.equal).equal(?5);
        expect.option(pq.pop(Nat.compare), Nat.toText, Nat.equal).equal(null)
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
        let copy = original.clone();
        expect.bool(copy.isEmpty()).equal(true)
      }
    );

    test(
      "deep copy preserves elements",
      func() {
        let original = PriorityQueue.fromIter([5, 10, 3].values(), Nat.compare);
        let copy = original.clone();
        expect.nat(copy.size()).equal(3);
        expect.option(copy.peek(), Nat.toText, Nat.equal).equal(?10)
      }
    );

    test(
      "mutating the copy does not affect the original",
      func() {
        let original = PriorityQueue.fromIter([5, 10, 3].values(), Nat.compare);
        let copy = original.clone();
        ignore copy.pop(Nat.compare);
        ignore copy.pop(Nat.compare);
        expect.nat(copy.size()).equal(1);
        expect.nat(original.size()).equal(3);
        expect.option(original.peek(), Nat.toText, Nat.equal).equal(?10)
      }
    );

    test(
      "mutating the original does not affect the copy",
      func() {
        let original = PriorityQueue.fromIter([5, 10, 3].values(), Nat.compare);
        let copy = original.clone();
        original.clear();
        expect.bool(original.isEmpty()).equal(true);
        expect.nat(copy.size()).equal(3);
        expect.option(copy.peek(), Nat.toText, Nat.equal).equal(?10)
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
        let vals = pq.values(Nat.compare).toArray();
        expect.array(vals, Nat.toText, Nat.equal).equal([])
      }
    );

    test(
      "singleton",
      func() {
        let pq = PriorityQueue.singleton<Nat>(42);
        let vals = pq.values(Nat.compare).toArray();
        expect.array(vals, Nat.toText, Nat.equal).equal([42])
      }
    );

    test(
      "yields elements in descending priority order",
      func() {
        let pq = PriorityQueue.fromIter([5, 10, 3].values(), Nat.compare);
        let vals = pq.values(Nat.compare).toArray();
        expect.array(vals, Nat.toText, Nat.equal).equal([10, 5, 3])
      }
    );

    test(
      "does not modify the original queue",
      func() {
        let pq = PriorityQueue.fromIter([5, 10, 3].values(), Nat.compare);
        ignore pq.values(Nat.compare).toArray();
        expect.nat(pq.size()).equal(3);
        expect.option(pq.peek(), Nat.toText, Nat.equal).equal(?10)
      }
    );

    test(
      "with duplicates",
      func() {
        let pq = PriorityQueue.fromIter([3, 1, 4, 1, 5].values(), Nat.compare);
        let vals = pq.values(Nat.compare).toArray();
        expect.array(vals, Nat.toText, Nat.equal).equal([5, 4, 3, 1, 1])
      }
    );

    test(
      "can be called multiple times",
      func() {
        let pq = PriorityQueue.fromIter([2, 7, 1].values(), Nat.compare);
        let vals1 = pq.values(Nat.compare).toArray();
        let vals2 = pq.values(Nat.compare).toArray();
        expect.array(vals1, Nat.toText, Nat.equal).equal([7, 2, 1]);
        expect.array(vals2, Nat.toText, Nat.equal).equal([7, 2, 1])
      }
    )
  }
)
