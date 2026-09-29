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
          case "pure/List.split" ignore list.split(99_999);
          case "pure/List.all" ignore list.all(func x = 1 == x);
          case "pure/List.any" ignore not list.any(func x = 1 != x);
          case "pure/List.map" ignore List.map(list, func x = x + 1);
          case "pure/List.filter" ignore list.filter(func x = x == 1);
          case "pure/List.filterMap" ignore list.filterMap(func x = if (x == 1) ?(x + 1) else null);
          case "pure/List.partition" ignore list.partition(func x = x == 1);
          case "pure/List.join" ignore List.join(listOfLists.values());
          case "pure/List.flatten" ignore listOfLists.flatten();
          case "pure/List.take" ignore list.take(99_999);
          case "pure/List.drop" ignore list.drop(99_999);
          case "pure/List.foldRight" ignore list.foldRight(0, Nat.add);
          case "pure/List.merge" ignore list.merge(list02, Nat.compare);
          case "pure/List.chunks" ignore list.chunks(1);
          case "pure/Queue" {
            var q = Queue.empty<Nat>();
            let n = 100_000;
            for (i in Nat.range(0, 2 * n)) q := q.pushBack(i);
            assert q.size() == 2 * n;
            for (_ in Nat.range(0, n)) {
              q := q.popBack().unwrap().0;
              q := q.popFront().unwrap().1
            };
            assert q.size() == 0
          };
          case _ Runtime.unreachable()
        }
      }
    );

    bench
  }
}
