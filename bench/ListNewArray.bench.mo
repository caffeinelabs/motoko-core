import Bench "mo:bench";

import List "../src/List";
import PureList "../src/pure/List";
import Runtime "../src/Runtime";

module {
  public func init() : Bench.Bench {
    let bench = Bench.Bench();

    bench.name("List vs. pure/List for creating known-size arrays");
    bench.description("Performance comparison between List and pure/List for creating a new array.");

    bench.rows([
      "List",
      "pure/List"
    ]);
    bench.cols([
      "0 (baseline)",
      "1",
      "5",
      "10",
      "100 (for loop)"
    ]);

    bench.runner(
      func(row, col) {
        switch row {
          case "List" {
            switch col {
              case "0 (baseline)" {
                let list = List.empty<Nat>();
                ignore List.toArray(list)
              };
              case "1" {
                let list = List.empty<Nat>();
                List.add(list, 0);
                ignore List.toArray(list)
              };
              case "5" {
                let list = List.empty<Nat>();
                List.add(list, 0);
                List.add(list, 1);
                List.add(list, 2);
                List.add(list, 3);
                List.add(list, 4);
                ignore List.toArray(list)
              };
              case "10" {
                let list = List.empty<Nat>();
                List.add(list, 0);
                List.add(list, 1);
                List.add(list, 2);
                List.add(list, 3);
                List.add(list, 4);
                List.add(list, 5);
                List.add(list, 6);
                List.add(list, 7);
                List.add(list, 8);
                List.add(list, 9);
                ignore List.toArray(list)
              };
              case "100 (for loop)" {
                let list = List.empty<Nat>();
                var i = 0;
                while (i < 100) {
                  List.add(list, i);
                  i += 1
                };
                ignore List.toArray(list)
              };
              case _ Runtime.unreachable()
            }
          };
          case "pure/List" {
            switch col {
              case "0 (baseline)" {
                var list = PureList.empty<Nat>();
                ignore PureList.toArray(list)
              };
              case "1" {
                var list = PureList.empty<Nat>();
                list := ?(0, list);
                ignore PureList.toArray(list)
              };
              case "5" {
                var list = PureList.empty<Nat>();
                list := ?(4, list);
                list := ?(3, list);
                list := ?(2, list);
                list := ?(1, list);
                list := ?(0, list);
                ignore PureList.toArray(list)
              };
              case "10" {
                var list = PureList.empty<Nat>();
                list := ?(9, list);
                list := ?(8, list);
                list := ?(7, list);
                list := ?(6, list);
                list := ?(5, list);
                list := ?(4, list);
                list := ?(3, list);
                list := ?(2, list);
                list := ?(1, list);
                list := ?(0, list);
                ignore PureList.toArray(list)
              };
              case "100 (for loop)" {
                var list = PureList.empty<Nat>();
                var i = 0;
                while (i < 100) {
                  list := ?(i, list);
                  i += 1
                };
                ignore PureList.toArray(list)
              };
              case _ Runtime.unreachable()
            }
          };
          case _ Runtime.unreachable()
        }
      }
    );

    bench
  }
}
