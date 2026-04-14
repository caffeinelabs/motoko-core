import Bench "mo:bench";
import Queue "../../src/Queue";
import Array "../../src/Array";
import Nat "../../src/Nat";
import Random "../../src/Random";
import Runtime "../../src/Runtime";

module {
  public func init() : Bench.Bench {
    let bench = Bench.Bench();
    bench.name("Queue");
    bench.description("Benchmarks for the Queue module");
    bench.rows([
      "fromArray",
      "pushBack",
      "pushFront",
      "popFront",
      "popBack",
      "map",
      "filter",
      "forEach",
      "contains",
      "clone",
      "toArray",
      "equal"
    ]);
    bench.cols(["100", "1_000", "10_000"]);

    let rng = Random.seed(0xfeedface);
    let a100 = Array.tabulate<Nat>(100, func(_) = rng.natRange(0, 1_000_000));
    let a1000 = Array.tabulate<Nat>(1_000, func(_) = rng.natRange(0, 1_000_000));
    let a10000 = Array.tabulate<Nat>(10_000, func(_) = rng.natRange(0, 1_000_000));

    let q100 = Queue.fromArray<Nat>(a100);
    let q1000 = Queue.fromArray<Nat>(a1000);
    let q10000 = Queue.fromArray<Nat>(a10000);

    bench.runner(func(row, col) {
      let (arr, theQueue) = switch col {
        case "100" (a100, q100);
        case "1_000" (a1000, q1000);
        case "10_000" (a10000, q10000);
        case _ Runtime.unreachable()
      };
      switch row {
        case "fromArray" ignore Queue.fromArray<Nat>(arr);
        case "pushBack" {
          let q = Queue.empty<Nat>();
          for (x in arr.vals()) { Queue.pushBack<Nat>(q, x) }
        };
        case "pushFront" {
          let q = Queue.empty<Nat>();
          for (x in arr.vals()) { Queue.pushFront<Nat>(q, x) }
        };
        case "popFront" {
          let q = Queue.clone<Nat>(theQueue);
          label l loop { switch (Queue.popFront<Nat>(q)) { case null break l; case _ () } }
        };
        case "popBack" {
          let q = Queue.clone<Nat>(theQueue);
          label l loop { switch (Queue.popBack<Nat>(q)) { case null break l; case _ () } }
        };
        case "map" ignore Queue.map<Nat, Nat>(theQueue, func(x) = x + 1);
        case "filter" ignore Queue.filter<Nat>(theQueue, func(x) = x % 2 == 0);
        case "forEach" Queue.forEach<Nat>(theQueue, func(x) { ignore x });
        case "contains" ignore Queue.contains<Nat>(theQueue, Nat.equal, arr[0]);
        case "clone" ignore Queue.clone<Nat>(theQueue);
        case "toArray" ignore Queue.toArray<Nat>(theQueue);
        case "equal" ignore Queue.equal<Nat>(theQueue, Queue.clone<Nat>(theQueue), Nat.equal);
        case _ Runtime.unreachable()
      }
    });
    bench
  }
}