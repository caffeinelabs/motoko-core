import Bench "mo:bench";
import Array "../../src/Array";
import Iter "../../src/Iter";
import Nat "../../src/Nat";
import Random "../../src/Random";
import Runtime "../../src/Runtime";
import VarArray "../../src/VarArray";

module {
  public func init() : Bench.Bench {
    let bench = Bench.Bench();
    bench.name("VarArray");
    bench.description("Benchmarks for the VarArray module");
    bench.rows([
      "tabulate",
      "sort",
      "sortInPlace",
      "map",
      "filter",
      "foldLeft",
      "reverse",
      "reverseInPlace",
      "contains",
      "clone",
      "mapInPlace",
      "concat",
      "equal",
      "repeat",
      "fromIter",
      "fromArray",
      "filterMap",
      "flatMap",
      "forEach",
      "find",
      "binarySearch",
      "flatten"
    ]);
    bench.cols(["100", "1_000", "10_000"]);

    let rng = Random.seed(0x4b2c8d1e);
    let va100 = VarArray.tabulate<Nat>(100, func(_) = rng.natRange(0, 1_000_000));
    let va1000 = VarArray.tabulate<Nat>(1_000, func(_) = rng.natRange(0, 1_000_000));
    let va10000 = VarArray.tabulate<Nat>(10_000, func(_) = rng.natRange(0, 1_000_000));

    let rngB = Random.seed(0x5c3d9e2f);
    let vb100 = VarArray.tabulate<Nat>(100, func(_) = rngB.natRange(0, 1_000_000));
    let vb1000 = VarArray.tabulate<Nat>(1_000, func(_) = rngB.natRange(0, 1_000_000));
    let vb10000 = VarArray.tabulate<Nat>(10_000, func(_) = rngB.natRange(0, 1_000_000));

    let va100copy = VarArray.clone(va100);
    let va1000copy = VarArray.clone(va1000);
    let va10000copy = VarArray.clone(va10000);

    let sva100 = VarArray.sort(va100, Nat.compare);
    let sva1000 = VarArray.sort(va1000, Nat.compare);
    let sva10000 = VarArray.sort(va10000, Nat.compare);

    let imm100 = Array.tabulate<Nat>(100, func(i) = va100[i]);
    let imm1000 = Array.tabulate<Nat>(1_000, func(i) = va1000[i]);
    let imm10000 = Array.tabulate<Nat>(10_000, func(i) = va10000[i]);

    let vn100 = VarArray.tabulate<[var Nat]>(100, func(_) = VarArray.tabulate<Nat>(3, func j = j));
    let vn1000 = VarArray.tabulate<[var Nat]>(1_000, func(_) = VarArray.tabulate<Nat>(3, func j = j));
    let vn10000 = VarArray.tabulate<[var Nat]>(10_000, func(_) = VarArray.tabulate<Nat>(3, func j = j));

    bench.runner(
      func(row, col) {
        let varr = switch col {
          case "100" va100;
          case "1_000" va1000;
          case "10_000" va10000;
          case _ Runtime.unreachable()
        };
        let varrB = switch col {
          case "100" vb100;
          case "1_000" vb1000;
          case "10_000" vb10000;
          case _ Runtime.unreachable()
        };
        let varrEq = switch col {
          case "100" va100copy;
          case "1_000" va1000copy;
          case "10_000" va10000copy;
          case _ Runtime.unreachable()
        };
        let sorted = switch col {
          case "100" sva100;
          case "1_000" sva1000;
          case "10_000" sva10000;
          case _ Runtime.unreachable()
        };
        let imm = switch col {
          case "100" imm100;
          case "1_000" imm1000;
          case "10_000" imm10000;
          case _ Runtime.unreachable()
        };
        let nested = switch col {
          case "100" vn100;
          case "1_000" vn1000;
          case "10_000" vn10000;
          case _ Runtime.unreachable()
        };
        let mid = varr.size() / 2;
        let key = sorted[mid];
        switch row {
          case "tabulate" ignore VarArray.tabulate<Nat>(varr.size(), func i = i);
          case "sort" ignore VarArray.sort<Nat>(varr, Nat.compare);
          case "sortInPlace" {
            let w = VarArray.clone(varr);
            VarArray.sortInPlace<Nat>(w, Nat.compare)
          };
          case "map" ignore VarArray.map<Nat, Nat>(varr, func x = x + 1);
          case "filter" ignore VarArray.filter<Nat>(varr, func x = x % 2 == 0);
          case "foldLeft" ignore VarArray.foldLeft<Nat, Nat>(varr, 0, func(acc, x) = acc + x);
          case "reverse" ignore VarArray.reverse<Nat>(varr);
          case "reverseInPlace" {
            let w = VarArray.clone(varr);
            VarArray.reverseInPlace<Nat>(w)
          };
          case "contains" ignore VarArray.contains<Nat>(varr, Nat.equal, varr[mid]);
          case "clone" ignore VarArray.clone<Nat>(varr);
          case "mapInPlace" {
            let w = VarArray.clone(varr);
            VarArray.mapInPlace<Nat>(w, func x = x + 1)
          };
          case "concat" ignore VarArray.concat<Nat>(varr, varrB);
          case "equal" ignore VarArray.equal<Nat>(varr, varrEq, Nat.equal);
          case "repeat" ignore VarArray.repeat<Nat>(0 : Nat, varr.size());
          case "fromIter" ignore VarArray.fromIter<Nat>(varr.values());
          case "fromArray" ignore VarArray.fromArray<Nat>(imm);
          case "filterMap" ignore VarArray.filterMap<Nat, Nat>(varr, func x = if (x % 2 == 0) { ?x } else { null });
          case "flatMap" ignore VarArray.flatMap<Nat, Nat>(varr, func x = Iter.singleton(x));
          case "forEach" VarArray.forEach<Nat>(varr, func x = ignore x);
          case "find" ignore VarArray.find<Nat>(varr, func x = x == varr[mid]);
          case "binarySearch" ignore VarArray.binarySearch<Nat>(sorted, Nat.compare, key);
          case "flatten" ignore VarArray.flatten<Nat>(nested);
          case _ Runtime.unreachable()
        }
      }
    );
    bench
  }
}
