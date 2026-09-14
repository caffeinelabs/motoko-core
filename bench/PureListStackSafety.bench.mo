import Bench "mo:bench";

import Nat "../src/Nat";
import Option "../src/Option";
import List "../src/pure/List";
import Queue "../src/pure/Queue";
import Runtime "../src/Runtime";

module {
  public func init() : Bench.Bench {
    let bench = Bench.Bench();

    bench.name("List Stack safety");
    bench.description("Check stack-safety of the following `pure/List`-related functions.");

    bench.rows([
      "pure/List.split",
      "pure/List.all",
      "pure/List.any",
      "pure/List.map",
      "pure/List.filter",
      "pure/List.filterMap",
      "pure/List.partition",
      "pure/List.join",
      "pure/List.flatten",
      "pure/List.take",
      "pure/List.drop",
      "pure/List.foldRight",
      "pure/List.merge",
      "pure/List.chunks",
      "pure/Queue"
    ]);
    bench.cols([""]);

    let list = List.repeat(1, 100_000);
    let listOfLists = List.repeat(List.repeat(1, 1), 100_000);
    let list02 = List.fromArray([0, 2]);

    bench.runner(
      func(row, col) {
        switch row {
          case "pure/List.split" ignore List.split(list, 99_999);
          case "pure/List.all" ignore List.all(list, func x = 1 == x);
          case "pure/List.any" ignore not List.any(list, func x = 1 != x);
          case "pure/List.map" ignore List.map(list, func x = x + 1);
          case "pure/List.filter" ignore List.filter(list, func x = x == 1);
          case "pure/List.filterMap" ignore List.filterMap(list, func x = if (x == 1) ?(x + 1) else null);
          case "pure/List.partition" ignore List.partition(list, func x = x == 1);
          case "pure/List.join" ignore List.join(List.values listOfLists);
          case "pure/List.flatten" ignore List.flatten(listOfLists);
          case "pure/List.take" ignore List.take(list, 99_999);
          case "pure/List.drop" ignore List.drop(list, 99_999);
          case "pure/List.foldRight" ignore List.foldRight(list, 0, Nat.add);
          case "pure/List.merge" ignore List.merge(list, list02, Nat.compare);
          case "pure/List.chunks" ignore List.chunks(list, 1);
          case "pure/Queue" {
            var q = Queue.empty<Nat>();
            let n = 100_000;
            for (i in Nat.range(0, 2 * n)) q := Queue.pushBack(q, i);
            assert Queue.size(q) == 2 * n;
            for (_ in Nat.range(0, n)) {
              q := Option.unwrap(Queue.popBack(q)).0;
              q := Option.unwrap(Queue.popFront(q)).1
            };
            assert Queue.size(q) == 0
          };
          case _ Runtime.unreachable()
        }
      }
    );

    bench
  }
}
