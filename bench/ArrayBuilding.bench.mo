import Bench "mo:bench";

import List "../src/List";
import PureList "../src/pure/List";
import Runtime "../src/Runtime";
import Nat "../src/Nat";
import Array "../src/Array";
import VarArray "../src/VarArray";

module {
  public func init() : Bench.Bench {
    let bench = Bench.Bench();

    bench.name("Large known-size array building");
    bench.description("Compares performance of different data structures for building arrays of known size.");

    bench.rows([
      "List",
      "pure/List",
      "VarArray ?T",
      "VarArray T",
      "Array (baseline)"
    ]);
    bench.cols([
      "1000",
      "100000",
      "1000000"
    ]);

    bench.runner(
      func(row, col) {
        let ?size = Nat.fromText(col) else Runtime.trap("Invalid size");
        switch row {
          case "List" {
            let list = List.empty<Nat>();
            var i = 0;
            while (i < size) {
              List.add(list, i);
              i += 1
            };
            ignore List.toArray(list)
          };
          case "pure/List" {
            var list = PureList.empty<Nat>();
            var i = 0;
            while (i < size) {
              list := ?(i, list); // Wrong order, but ignore...
              i += 1
            };
            ignore PureList.toArray(list)
          };
          case "VarArray ?T" {
            var array = VarArray.repeat<?Nat>(null, size);
            var i = 0;
            while (i < size) {
              array[i] := ?i;
              i += 1
            };
            ignore Array.tabulate(
              size,
              func i = switch (array[i]) {
                case (?v) v;
                case null Runtime.trap("Invalid value")
              }
            )
          };
          case "VarArray T" {
            var array = VarArray.repeat<Nat>(0, size);
            var i = 0;
            while (i < size) {
              array[i] := i;
              i += 1
            };
            ignore array.toArray()
          };
          case "Array (baseline)" {
            ignore Array.tabulate(size, func n = n)
          };
          case _ Runtime.unreachable()
        }
      }
    );

    bench
  }
}
