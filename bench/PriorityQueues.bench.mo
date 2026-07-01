import Bench "mo:bench";

import Array "../src/Array";
import Nat "../src/Nat";
import PriorityQueue "../src/PriorityQueue";
import PriorityQueueSet "utils/PriorityQueueSet";
import Random "../src/Random";
import Runtime "../src/Runtime";
import Map "../src/Map";
import Iter "../src/Iter";
import Text "../src/Text";

module {

  type PriorityQueueUpdateOperation<T> = {
    #Push : T;
    #Pop;
    #Clear
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

  // Generates a sequence of PriorityQueueUpdateOperations on Nat values:
  // 1. pushOperationsCount pushes, followed by
  // 2. pushOperationsCount pops.
  //
  // randomSeed          - seed for reproducible RNG
  // pushOperationsCount – total number of push operations to generate
  // maxValueExclusive   – upper bound (exclusive) for values pushed into the queue
  func genOpsPushThenPop(
    randomSeed : Nat64,
    pushOperationsCount : Nat,
    maxValueExclusive : Nat
  ) : [PriorityQueueUpdateOperation<Nat>] {
    let rng = Random.seed(randomSeed);
    Array.tabulate<PriorityQueueUpdateOperation<Nat>>(
      2 * pushOperationsCount,
      func(i) {
        switch (i < pushOperationsCount) {
          case true #Push(rng.natRange(0, maxValueExclusive));
          case false #Pop
        }
      }
    )
  };

  // Generates a sequence of PriorityQueueUpdateOperations on Nat values:
  // 1. size pushes, followed by
  // 2. popPushCount instances of a pop followed by a push.
  //
  // randomSeed          - seed for reproducible RNG
  // size                – initial size
  // popPushCount        - number of times to pop and then push
  // maxValueExclusive   – upper bound (exclusive) for values pushed into the queue
  func genOpsKeepConstantSize(
    randomSeed : Nat64,
    size : Nat,
    popPushCount : Nat,
    maxValueExclusive : Nat
  ) : [PriorityQueueUpdateOperation<Nat>] {
    let rng = Random.seed(randomSeed);
    Array.tabulate<PriorityQueueUpdateOperation<Nat>>(
      size + 2 * popPushCount,
      func(i) {
        if (i < size or (i - size) % 2 == 1) {
          #Push(rng.natRange(0, maxValueExclusive))
        } else {
          #Pop
        }
      }
    )
  };

  public func init() : Bench.Bench {
    let bench = Bench.Bench();

    bench.name("Different priority queue implementations");
    bench.description("Compare the performance of the following priority queue implementations:
- `PriorityQueue`: Binary heap implementation over `List`.
- `PriorityQueueSet`: Wrapper over `Set<(T, Nat)>`.");

    let testInstances : Map.Map<Text, [PriorityQueueUpdateOperation<Nat>]> = Map.fromIter(
      [
        (
          "1.) 100000 operations (push:pop = 1:1)",
          genOpsNatRandom(
            /* randomSeed = */ 23,
            /* operationsCount = */ 100000,
            /* maxValueExclusive = */ 100000,
            /* wPush = */ 1,
            /* wPop = */ 1,
            /* wClear = */ 0
          )
        ),
        (
          "2.) 100000 operations (push:pop = 2:1)",
          genOpsNatRandom(
            /* randomSeed = */ 24,
            /* operationsCount = */ 100000,
            /* maxValueExclusive = */ 100000,
            /* wPush = */ 2,
            /* wPop = */ 1,
            /* wClear = */ 0
          )
        ),
        (
          "3.) 100000 operations (push:pop = 10:1)",
          genOpsNatRandom(
            /* randomSeed = */ 42,
            /* operationsCount = */ 100000,
            /* maxValueExclusive = */ 100000,
            /* wPush = */ 10,
            /* wPop = */ 1,
            /* wClear = */ 0
          )
        ),
        (
          "4.) 100000 operations (only push)",
          genOpsNatRandom(
            /* randomSeed = */ 33,
            /* operationsCount = */ 100000,
            /* maxValueExclusive = */ 100000,
            /* wPush = */ 1,
            /* wPop = */ 0,
            /* wClear = */ 0
          )
        ),
        (
          "5.) 50000 pushes, then 50000 pops",
          genOpsPushThenPop(
            /* randomSeed = */ 13,
            /* pushOperationsCount = */ 50000,
            /* maxValueExclusive */ 100000
          )
        ),
        (
          "6.) 50000 pushes, then 25000 \"pop;push\"es",
          genOpsKeepConstantSize(
            /* randomSeed = */ 55,
            /* size = */ 50000,
            /* popPushCount = */ 25000,
            /* maxValueExclusive = */ 100000
          )
        )
      ].values(),
      Text.compare
    );
    bench.rows(Iter.toArray(Map.keys(testInstances)));

    let testRunners : Map.Map<Text, [PriorityQueueUpdateOperation<Nat>] -> ()> = Map.fromIter(
      [
        (
          "A) PriorityQueue",
          func(ops : [PriorityQueueUpdateOperation<Nat>]) {
            let priorityQueue = PriorityQueue.empty<Nat>();
            for (op in ops.values()) {
              switch (op) {
                case (#Push element) PriorityQueue.push(priorityQueue, Nat.compare, element);
                case (#Pop) ignore PriorityQueue.pop(priorityQueue, Nat.compare);
                case (#Clear) PriorityQueue.clear(priorityQueue)
              }
            }
          }
        ),
        (
          "B) PriorityQueueSet",
          func(ops : [PriorityQueueUpdateOperation<Nat>]) {
            let priorityQueueSet = PriorityQueueSet.empty<Nat>();
            for (op in ops.values()) {
              switch (op) {
                case (#Push element) PriorityQueueSet.push(priorityQueueSet, Nat.compare, element);
                case (#Pop) ignore PriorityQueueSet.pop(priorityQueueSet, Nat.compare);
                case (#Clear) PriorityQueueSet.clear(priorityQueueSet)
              }
            }
          }
        )
      ].values(),
      Text.compare
    );
    bench.cols(Iter.toArray(Map.keys(testRunners)));

    bench.runner(
      func(row, col) {
        switch (
          Map.get(testInstances, Text.compare, row),
          Map.get(testRunners, Text.compare, col)
        ) {
          case (?ops, ?runner) runner(ops);
          case _ Runtime.trap("Missing test instance or runner")
        }
      }
    );
    bench
  }
}
