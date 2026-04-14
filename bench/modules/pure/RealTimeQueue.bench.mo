import Bench "mo:bench";
import RealTimeQueue "../../../src/pure/RealTimeQueue";
import Array "../../../src/Array";
import Nat "../../../src/Nat";
import Random "../../../src/Random";
import Runtime "../../../src/Runtime";

module {
  public func init() : Bench.Bench {
    let bench = Bench.Bench();
    bench.name("pure/RealTimeQueue");
    bench.description("Benchmarks for the pure RealTimeQueue module");
    bench.rows([
      "fromIter",
      "pushBack",
      "pushFront",
      "popFront",
      "popBack",
      "map",
      "filter",
      "forEach",
      "contains",
      "equal",
      "reverse"
    ]);
    bench.cols(["100", "1_000", "10_000"]);

    let rng = Random.seed(0xabcdef01);
    let a100 = Array.tabulate<Nat>(100, func(_) = rng.natRange(0, 1_000_000));
    let a1000 = Array.tabulate<Nat>(1_000, func(_) = rng.natRange(0, 1_000_000));
    let a10000 = Array.tabulate<Nat>(10_000, func(_) = rng.natRange(0, 1_000_000));

    let a100copy = Array.tabulate<Nat>(100, func(i) = a100[i]);
    let a1000copy = Array.tabulate<Nat>(1_000, func(i) = a1000[i]);
    let a10000copy = Array.tabulate<Nat>(10_000, func(i) = a10000[i]);

    let q100 = RealTimeQueue.fromIter<Nat>(a100.values());
    let q1000 = RealTimeQueue.fromIter<Nat>(a1000.values());
    let q10000 = RealTimeQueue.fromIter<Nat>(a10000.values());

    let q100copy = RealTimeQueue.fromIter<Nat>(a100copy.values());
    let q1000copy = RealTimeQueue.fromIter<Nat>(a1000copy.values());
    let q10000copy = RealTimeQueue.fromIter<Nat>(a10000copy.values());

    bench.runner(func(row, col) {
      let arr = switch col {
        case "100" a100;
        case "1_000" a1000;
        case "10_000" a10000;
        case _ Runtime.unreachable()
      };
      let theQueue = switch col {
        case "100" q100;
        case "1_000" q1000;
        case "10_000" q10000;
        case _ Runtime.unreachable()
      };
      let theQueueEq = switch col {
        case "100" q100copy;
        case "1_000" q1000copy;
        case "10_000" q10000copy;
        case _ Runtime.unreachable()
      };
      let key = arr[arr.size() / 2];
      switch row {
        case "fromIter" ignore RealTimeQueue.fromIter<Nat>(arr.values());
        case "pushBack" {
          var q = RealTimeQueue.empty<Nat>();
          for (x in arr.vals()) { q := RealTimeQueue.pushBack<Nat>(q, x) }
        };
        case "pushFront" {
          var q = RealTimeQueue.empty<Nat>();
          for (x in arr.vals()) { q := RealTimeQueue.pushFront<Nat>(q, x) }
        };
        case "popFront" {
          var q = theQueue;
          label l loop {
            switch (RealTimeQueue.popFront<Nat>(q)) {
              case null break l;
              case (?(_, rest)) q := rest
            }
          }
        };
        case "popBack" {
          var q = theQueue;
          label l loop {
            switch (RealTimeQueue.popBack<Nat>(q)) {
              case null break l;
              case (?result) q := result.0
            }
          }
        };
        case "map" ignore RealTimeQueue.map<Nat, Nat>(theQueue, func x = x + 1);
        case "filter" ignore RealTimeQueue.filter<Nat>(theQueue, func x = x % 2 == 0);
        case "forEach" RealTimeQueue.forEach<Nat>(theQueue, func x = ignore x);
        case "contains" ignore RealTimeQueue.contains<Nat>(theQueue, Nat.equal, key);
        case "equal" ignore RealTimeQueue.equal<Nat>(theQueue, theQueueEq, Nat.equal);
        case "reverse" ignore RealTimeQueue.reverse<Nat>(theQueue);
        case _ Runtime.unreachable()
      }
    });
    bench
  }
}