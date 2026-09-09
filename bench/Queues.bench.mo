import Bench "mo:bench";

import Array "../src/Array";
import Nat "../src/Nat";
import Option "../src/Option";
import OldQueue "../src/pure/Queue";
import NewQueue "../src/pure/RealTimeQueue";
import MutQueue "../src/Queue";
import Runtime "../src/Runtime";

module {
  public func init() : Bench.Bench {
    let bench = Bench.Bench();

    bench.name("Different queue implementations");
    bench.description("Compare the performance of the following queue implementations_:
- `pure/Queue`: The default immutable double-ended queue implementation.
  * Pros: Good amortized performance, meaning that the average cost of operations is low `O(1)`.
  * Cons: In worst case, an operation can take `O(size)` time rebuilding the queue as demonstrated in the `Pop front 2 elements` scenario.
- `pure/RealTimeQueue`
  * Pros: Every operation is guaranteed to take at most `O(1)` time and space.
  * Cons: Poor amortized performance: Instruction cost is on average 3x for *pop* and 8x for *push* compared to `pure/Queue`.
- mutable `Queue`
  * Pros: Also `O(1)` guarantees with a lower constant factor than `pure/RealTimeQueue`. Amortized performance is comparable to `pure/Queue`.
  * Cons: It is mutable and cannot be used in `shared` types (not shareable)_.");

    bench.rows([
      "Initialize with 2 elements",
      "Push 500 elements",
      "Pop front 2 elements",
      "Pop 150 front&back"
    ]);
    bench.cols([
      "pure/Queue",
      "pure/RealTimeQueue",
      "mutable Queue"
    ]);

    let init = Array.repeat(1, 2);
    var newQ = NewQueue.empty<Nat>();
    var oldQ = OldQueue.empty<Nat>();
    var mutQ = MutQueue.empty<Nat>();

    let toPush = Array.repeat(7, 500);

    bench.runner(
      func(row, col) = switch (col, row) {
        case ("pure/RealTimeQueue", "Initialize with 2 elements") newQ := NewQueue.fromIter<Nat>(init.values());
        case ("pure/Queue", "Initialize with 2 elements") oldQ := OldQueue.fromIter<Nat>(init.values());
        case ("mutable Queue", "Initialize with 2 elements") mutQ := MutQueue.fromIter<Nat>(init.values());
        case ("pure/RealTimeQueue", "Push 500 elements") {
          for (i in toPush.values()) {
            newQ := NewQueue.pushBack<Nat>(newQ, i)
          }
        };
        case ("pure/Queue", "Push 500 elements") {
          for (i in toPush.values()) {
            oldQ := OldQueue.pushBack<Nat>(oldQ, i)
          }
        };
        case ("mutable Queue", "Push 500 elements") {
          for (i in toPush.values()) {
            MutQueue.pushBack<Nat>(mutQ, i)
          }
        };
        case ("pure/RealTimeQueue", "Pop front 2 elements") Option.unwrap(
          do ? {
            newQ := NewQueue.popFront<Nat>(NewQueue.popFront<Nat>(newQ)!.1)!.1
          }
        );
        case ("pure/Queue", "Pop front 2 elements") Option.unwrap(
          do ? {
            oldQ := OldQueue.popFront<Nat>(OldQueue.popFront<Nat>(oldQ)!.1)!.1
          }
        );
        case ("mutable Queue", "Pop front 2 elements") Option.unwrap(
          do ? {
            ignore MutQueue.popFront<Nat>(mutQ);
            ignore MutQueue.popFront<Nat>(mutQ)
          }
        );
        case ("pure/RealTimeQueue", "Pop 150 front&back") {
          for (i in Nat.range(0, 150)) Option.unwrap(
            do ? {
              newQ := NewQueue.popBack<Nat>(NewQueue.popFront<Nat>(newQ)!.1)!.0
            }
          )
        };
        case ("pure/Queue", "Pop 150 front&back") {
          for (i in Nat.range(0, 150)) Option.unwrap(
            do ? {
              oldQ := OldQueue.popBack<Nat>(OldQueue.popFront<Nat>(oldQ)!.1)!.0
            }
          )
        };
        case ("mutable Queue", "Pop 150 front&back") {
          for (i in Nat.range(0, 150)) {
            ignore MutQueue.popFront<Nat>(mutQ);
            ignore MutQueue.popBack<Nat>(mutQ)
          }
        };
        case _ Runtime.unreachable()
      }
    );

    bench
  }
}
