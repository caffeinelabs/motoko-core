import Bench "mo:bench";
import Random "../src/Random";
import Array "../src/Array";
import Nat64 "../src/Nat64";
import VarArray "../src/VarArray";
import Order "../src/Order";
import Prim "mo:⛔";
import Text "../src/Text";
import Nat32 "../src/Nat32";

module {
  func sortInPlace<T>(self : [var T], compare : (implicit : (T, T) -> Order.Order)) : () {
    // Stable merge sort in a bottom-up iterative style. Same algorithm as the sort in Buffer.
    let size = self.size();
    if (size == 0) {
      return
    };
    let scratchSpace = Prim.Array_init<T>(size, self[0]);

    var currSize = 1; // current size of the subarrays being merged
    var oddIteration = false;

    // when the current size == size, the array has been merged into a single sorted array
    while (currSize < size) {
      let (fromArray, toArray) = if (oddIteration) (scratchSpace, self) else (self, scratchSpace);
      var leftStart = 0; // selects the current left subarray being merged

      while (leftStart < size) {
        let mid = if (leftStart + currSize < size) leftStart + currSize else size;
        let rightEnd = if (leftStart + 2 * currSize < size) leftStart + 2 * currSize else size;

        // merge [leftStart, mid) with [mid, rightEnd)
        var left = leftStart;
        var right = mid;
        var nextSorted = leftStart;
        while (left < mid and right < rightEnd) {
          let leftElement = fromArray[left];
          let rightElement = fromArray[right];
          toArray[nextSorted] := switch (compare(leftElement, rightElement)) {
            case (#less or #equal) {
              left += 1;
              leftElement
            };
            case (#greater) {
              right += 1;
              rightElement
            }
          };
          nextSorted += 1
        };
        while (left < mid) {
          toArray[nextSorted] := fromArray[left];
          nextSorted += 1;
          left += 1
        };
        while (right < rightEnd) {
          toArray[nextSorted] := fromArray[right];
          nextSorted += 1;
          right += 1
        };

        leftStart += 2 * currSize
      };

      currSize *= 2;
      oddIteration := not oddIteration
    };
    if (oddIteration) {
      var i = 0;
      while (i < size) {
        self[i] := scratchSpace[i];
        i += 1
      }
    }
  };

  public func init() : Bench.Bench {
    let bench = Bench.Bench();

    bench.name("Sort");
    bench.description("VarArray.sortInPlace<T> profiling");

    let rows = [
      "old-sort",
      "new-sort"
    ];
    let cols = [
      "100",
      "1000",
      "10000",
      "12000",
      "100000",
      "1000000"
    ];

    bench.rows(rows);
    bench.cols(cols);

    let rng : Random.Random = Random.seed(0x5f5f5f5f5f5f5f5f);

    let sourceArrays : [[Nat32]] = Array.tabulate(
      cols.size(),
      func(j) = Array.tabulate<Nat32>(
        [100, 1_000, 10_000, 12_000, 100_000, 1_000_000][j],
        func(i) = Nat64.toNat32(rng.nat64() % (2 ** 32))
      )
    );

    let routines : [() -> ()] = Array.tabulate<() -> ()>(
      rows.size() * cols.size(),
      func(i) {
        let row : Nat = i % rows.size();
        let col : Nat = i / rows.size();

        switch (row) {
          case (0) {
            let varSource = Array.toVarArray<Nat32>(sourceArrays[col]);
            func() = sortInPlace<Nat32>(varSource, Nat32.compare)
          };
          case (1) {
            let varSource = Array.toVarArray<Nat32>(sourceArrays[col]);
            func() = VarArray.sortInPlace<Nat32>(varSource, Nat32.compare)
          };
          case (_) Prim.trap("Row not implemented")
        }
      }
    );

    bench.runner(
      func(row, col) {
        let ?ri = Array.indexOf<Text>(rows, Text.equal, row) else Prim.trap("Unknown row");
        let ?ci = Array.indexOf<Text>(cols, Text.equal, col) else Prim.trap("Unknown column");
        routines[ci * rows.size() + ri]()
      }
    );

    bench
  }
}
