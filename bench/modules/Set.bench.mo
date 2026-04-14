import Bench "mo:bench";
import Set "../../src/Set";
import Array "../../src/Array";
import Nat "../../src/Nat";
import Random "../../src/Random";
import Runtime "../../src/Runtime";

module {
  public func init() : Bench.Bench {
    let bench = Bench.Bench();
    bench.name("Set");
    bench.description("Benchmarks for the Set module");
    bench.rows([
      "fromArray",
      "add",
      "contains",
      "delete",
      "union",
      "intersection",
      "difference",
      "isSubset",
      "map",
      "filter",
      "foldLeft",
      "clone",
      "equal",
      "forEach"
    ]);
    bench.cols(["100", "1_000", "10_000"]);

    let rng = Random.seed(0x12345678);
    let vals100_a = Array.tabulate<Nat>(100, func(_) = rng.natRange(0, 1_000_000));
    let vals100_b = Array.tabulate<Nat>(100, func(i) = if (i < 50) { vals100_a[i] } else { rng.natRange(1_000_000, 2_000_000) });
    let vals1000_a = Array.tabulate<Nat>(1_000, func(_) = rng.natRange(0, 1_000_000));
    let vals1000_b = Array.tabulate<Nat>(1_000, func(i) = if (i < 500) { vals1000_a[i] } else { rng.natRange(1_000_000, 2_000_000) });
    let vals10000_a = Array.tabulate<Nat>(10_000, func(_) = rng.natRange(0, 1_000_000));
    let vals10000_b = Array.tabulate<Nat>(10_000, func(i) = if (i < 5_000) { vals10000_a[i] } else { rng.natRange(1_000_000, 2_000_000) });

    let vals100_sub = Array.tabulate<Nat>(50, func(i) = vals100_a[i]);
    let vals1000_sub = Array.tabulate<Nat>(500, func(i) = vals1000_a[i]);
    let vals10000_sub = Array.tabulate<Nat>(5_000, func(i) = vals10000_a[i]);

    let s100_a = Set.fromArray<Nat>(vals100_a, Nat.compare);
    let s1000_a = Set.fromArray<Nat>(vals1000_a, Nat.compare);
    let s10000_a = Set.fromArray<Nat>(vals10000_a, Nat.compare);

    let s100_b = Set.fromArray<Nat>(vals100_b, Nat.compare);
    let s1000_b = Set.fromArray<Nat>(vals1000_b, Nat.compare);
    let s10000_b = Set.fromArray<Nat>(vals10000_b, Nat.compare);

    let s100_sub = Set.fromArray<Nat>(vals100_sub, Nat.compare);
    let s1000_sub = Set.fromArray<Nat>(vals1000_sub, Nat.compare);
    let s10000_sub = Set.fromArray<Nat>(vals10000_sub, Nat.compare);

    bench.runner(
      func(row, col) {
        let vals = switch col {
          case "100" vals100_a;
          case "1_000" vals1000_a;
          case "10_000" vals10000_a;
          case _ Runtime.unreachable()
        };
        let theSet = switch col {
          case "100" s100_a;
          case "1_000" s1000_a;
          case "10_000" s10000_a;
          case _ Runtime.unreachable()
        };
        let otherSet = switch col {
          case "100" s100_b;
          case "1_000" s1000_b;
          case "10_000" s10000_b;
          case _ Runtime.unreachable()
        };
        let subsetSet = switch col {
          case "100" s100_sub;
          case "1_000" s1000_sub;
          case "10_000" s10000_sub;
          case _ Runtime.unreachable()
        };
        let n = switch col {
          case "100" 100;
          case "1_000" 1_000;
          case "10_000" 10_000;
          case _ Runtime.unreachable()
        };
        switch row {
          case "fromArray" ignore Set.fromArray<Nat>(vals, Nat.compare);
          case "add" {
            let s = Set.empty<Nat>();
            for (x in vals.vals()) {
              Set.add<Nat>(s, Nat.compare, x)
            }
          };
          case "contains" for (x in vals.vals()) {
            ignore Set.contains<Nat>(theSet, Nat.compare, x)
          };
          case "delete" {
            let s = Set.clone<Nat>(theSet);
            for (x in vals.vals()) {
              ignore Set.delete<Nat>(s, Nat.compare, x)
            }
          };
          case "union" ignore Set.union<Nat>(theSet, otherSet, Nat.compare);
          case "intersection" ignore Set.intersection<Nat>(theSet, otherSet, Nat.compare);
          case "difference" ignore Set.difference<Nat>(theSet, otherSet, Nat.compare);
          case "isSubset" ignore Set.isSubset<Nat>(subsetSet, theSet, Nat.compare);
          case "map" ignore Set.map<Nat, Nat>(theSet, Nat.compare, func(x) = x + 1);
          case "filter" ignore Set.filter<Nat>(theSet, Nat.compare, func(x) = x % 2 == 0);
          case "foldLeft" ignore Set.foldLeft<Nat, Nat>(theSet, 0, func(acc, x) = acc + x);
          case "clone" ignore Set.clone<Nat>(theSet);
          case "equal" for (_ in Nat.range(0, n)) {
            ignore Set.equal<Nat>(theSet, theSet, Nat.compare)
          };
          case "forEach" {
            Set.forEach<Nat>(theSet, func(_) {})
          };
          case _ Runtime.unreachable()
        }
      }
    );
    bench
  }
}
