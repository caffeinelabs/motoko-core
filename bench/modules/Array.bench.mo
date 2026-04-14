import Bench "mo:bench";
import Array "../../src/Array";
import Int "../../src/Int";
import Iter "../../src/Iter";
import Nat "../../src/Nat";
import Random "../../src/Random";
import Runtime "../../src/Runtime";

module {
  public func init() : Bench.Bench {
    let bench = Bench.Bench();
    bench.name("Array");
    bench.description("Benchmarks for the Array module");
    bench.rows([
      "all",
      "any",
      "binarySearch",
      "compare",
      "concat",
      "contains",
      "empty",
      "enumerate",
      "equal",
      "filter",
      "filterMap",
      "find",
      "findIndex",
      "flatMap",
      "flatten",
      "foldLeft",
      "foldRight",
      "forEach",
      "fromIter",
      "fromVarArray",
      "indexOf",
      "isEmpty",
      "isSorted",
      "keys",
      "lastIndexOf",
      "map",
      "repeat",
      "reverse",
      "singleton",
      "size",
      "sliceToArray",
      "sort",
      "tabulate",
      "toText",
      "toVarArray",
      "values"
    ]);
    bench.cols(["100", "1_000", "10_000"]);

    let rng = Random.seed(0x7f3a2b1c);
    let a100 = Array.tabulate<Nat>(100, func(_) = rng.natRange(0, 1_000_000));
    let a1000 = Array.tabulate<Nat>(1_000, func(_) = rng.natRange(0, 1_000_000));
    let a10000 = Array.tabulate<Nat>(10_000, func(_) = rng.natRange(0, 1_000_000));

    let rngB = Random.seed(0x9e4c1d2a);
    let b100 = Array.tabulate<Nat>(100, func(_) = rngB.natRange(0, 1_000_000));
    let b1000 = Array.tabulate<Nat>(1_000, func(_) = rngB.natRange(0, 1_000_000));
    let b10000 = Array.tabulate<Nat>(10_000, func(_) = rngB.natRange(0, 1_000_000));

    let a100copy = Array.tabulate<Nat>(100, func(i) = a100[i]);
    let a1000copy = Array.tabulate<Nat>(1_000, func(i) = a1000[i]);
    let a10000copy = Array.tabulate<Nat>(10_000, func(i) = a10000[i]);

    let sorted100 = Array.sort(a100, Nat.compare);
    let sorted1000 = Array.sort(a1000, Nat.compare);
    let sorted10000 = Array.sort(a10000, Nat.compare);

    let nest100 = Array.tabulate<[Nat]>(100, func(_) = [1, 2, 3]);
    let nest1000 = Array.tabulate<[Nat]>(1_000, func(_) = [1, 2, 3]);
    let nest10000 = Array.tabulate<[Nat]>(10_000, func(_) = [1, 2, 3]);

    let va100 = Array.toVarArray<Nat>(a100);
    let va1000 = Array.toVarArray<Nat>(a1000);
    let va10000 = Array.toVarArray<Nat>(a10000);

    bench.runner(
      func(row, col) {
        let arr = switch col {
          case "100" a100;
          case "1_000" a1000;
          case "10_000" a10000;
          case _ Runtime.unreachable()
        };
        let arrEq = switch col {
          case "100" a100copy;
          case "1_000" a1000copy;
          case "10_000" a10000copy;
          case _ Runtime.unreachable()
        };
        let sorted = switch col {
          case "100" sorted100;
          case "1_000" sorted1000;
          case "10_000" sorted10000;
          case _ Runtime.unreachable()
        };
        let nest = switch col {
          case "100" nest100;
          case "1_000" nest1000;
          case "10_000" nest10000;
          case _ Runtime.unreachable()
        };
        let brr = switch col {
          case "100" b100;
          case "1_000" b1000;
          case "10_000" b10000;
          case _ Runtime.unreachable()
        };
        let vaImm = switch col {
          case "100" va100;
          case "1_000" va1000;
          case "10_000" va10000;
          case _ Runtime.unreachable()
        };
        let mid = arr.size() / 2;
        let key = sorted[mid];
        switch row {
          case "all" ignore Array.all<Nat>(arr, func x = x < 2_000_000);
          case "any" ignore Array.any<Nat>(arr, func x = x == arr[0]);
          case "binarySearch" ignore Array.binarySearch<Nat>(sorted, Nat.compare, key);
          case "compare" ignore Array.compare<Nat>(arr, brr, Nat.compare);
          case "concat" ignore Array.concat<Nat>(arr, brr);
          case "contains" ignore Array.contains<Nat>(arr, Nat.equal, arr[mid]);
          case "empty" ignore Array.empty<Nat>();
          case "enumerate" {
            for ((i, x) in Array.enumerate(arr)) {
              ignore (i, x)
            }
          };
          case "equal" ignore Array.equal<Nat>(arr, arrEq, Nat.equal);
          case "filter" ignore Array.filter<Nat>(arr, func x = x % 2 == 0);
          case "filterMap" ignore Array.filterMap<Nat, Nat>(arr, func x = if (x % 2 == 0) { ?x } else { null });
          case "find" ignore Array.find<Nat>(arr, func x = x == arr[mid]);
          case "findIndex" ignore Array.findIndex<Nat>(arr, func x = x == arr[mid]);
          case "flatMap" ignore Array.flatMap<Nat, Nat>(arr, func x = Iter.singleton(x));
          case "flatten" ignore Array.flatten<Nat>(nest);
          case "foldLeft" ignore Array.foldLeft<Nat, Nat>(arr, 0, func(acc, x) = acc + x);
          case "foldRight" ignore Array.foldRight<Nat, Nat>(arr, 0, func(x, acc) = x + acc);
          case "forEach" Array.forEach<Nat>(arr, func x = ignore x);
          case "fromIter" ignore Array.fromIter<Nat>(arr.values());
          case "fromVarArray" ignore Array.fromVarArray<Nat>(vaImm);
          case "indexOf" ignore Array.indexOf<Nat>(arr, Nat.equal, arr[mid]);
          case "isEmpty" ignore Array.isEmpty(arr);
          case "isSorted" ignore Array.isSorted<Nat>(sorted, Nat.compare);
          case "keys" {
            var s = 0 : Nat;
            for (k in Array.keys(arr)) {
              s += k
            };
            ignore s
          };
          case "lastIndexOf" ignore Array.lastIndexOf<Nat>(arr, Nat.equal, arr[0]);
          case "map" ignore Array.map<Nat, Nat>(arr, func x = x + 1);
          case "repeat" ignore Array.repeat<Nat>(0 : Nat, arr.size());
          case "reverse" ignore Array.reverse<Nat>(arr);
          case "singleton" ignore Array.singleton<Nat>(0 : Nat);
          case "size" ignore Array.size(arr);
          case "sliceToArray" ignore Array.sliceToArray<Nat>(arr, 0, Int.fromNat(arr.size()));
          case "sort" ignore Array.sort<Nat>(arr, Nat.compare);
          case "tabulate" ignore Array.tabulate<Nat>(arr.size(), func i = i);
          case "toText" ignore Array.toText<Nat>(arr, Nat.toText);
          case "toVarArray" ignore Array.toVarArray<Nat>(arr);
          case "values" {
            var s = 0 : Nat;
            for (x in Array.values(arr)) {
              s += x
            };
            ignore s
          };
          case _ Runtime.unreachable()
        }
      }
    );
    bench
  }
}
