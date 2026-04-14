import Bench "mo:bench";
import PureSet "../../../src/pure/Set";
import Array "../../../src/Array";
import Nat "../../../src/Nat";
import Random "../../../src/Random";
import Runtime "../../../src/Runtime";

module {
  public func init() : Bench.Bench {
    let bench = Bench.Bench();
    bench.name("pure/Set");
    bench.description("Benchmarks for the pure Set module");
    bench.rows([
      "fromIter",
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
      "values",
      "equal"
    ]);
    bench.cols(["100", "1_000", "10_000"]);

    let rng = Random.seed(0x87654321);
    let arr100 = Array.tabulate<Nat>(100, func(i) = rng.natRange(0, 1_000_000));
    let arr1000 = Array.tabulate<Nat>(1_000, func(i) = rng.natRange(0, 1_000_000));
    let arr10000 = Array.tabulate<Nat>(10_000, func(i) = rng.natRange(0, 1_000_000));

    let rngOther = Random.seed(0x12345678);
    let other100 = Array.tabulate<Nat>(100, func(i) = rngOther.natRange(0, 1_000_000));
    let other1000 = Array.tabulate<Nat>(1_000, func(i) = rngOther.natRange(0, 1_000_000));
    let other10000 = Array.tabulate<Nat>(10_000, func(i) = rngOther.natRange(0, 1_000_000));

    let s100 = PureSet.fromIter<Nat>(arr100.vals(), Nat.compare);
    let s1000 = PureSet.fromIter<Nat>(arr1000.vals(), Nat.compare);
    let s10000 = PureSet.fromIter<Nat>(arr10000.vals(), Nat.compare);

    let o100 = PureSet.fromIter<Nat>(other100.vals(), Nat.compare);
    let o1000 = PureSet.fromIter<Nat>(other1000.vals(), Nat.compare);
    let o10000 = PureSet.fromIter<Nat>(other10000.vals(), Nat.compare);

    bench.runner(func(row, col) {
      let arr = switch col {
        case "100" arr100;
        case "1_000" arr1000;
        case "10_000" arr10000;
        case _ Runtime.unreachable()
      };
      let theSet = switch col {
        case "100" s100;
        case "1_000" s1000;
        case "10_000" s10000;
        case _ Runtime.unreachable()
      };
      let otherSet = switch col {
        case "100" o100;
        case "1_000" o1000;
        case "10_000" o10000;
        case _ Runtime.unreachable()
      };
      switch row {
        case "fromIter" ignore PureSet.fromIter<Nat>(arr.vals(), Nat.compare);
        case "add" {
          var s = PureSet.empty<Nat>();
          for (x in arr.vals()) {
            s := PureSet.add<Nat>(s, Nat.compare, x)
          }
        };
        case "contains" for (x in arr.vals()) {
          ignore PureSet.contains<Nat>(theSet, Nat.compare, x)
        };
        case "delete" {
          var s = theSet;
          for (x in arr.vals()) {
            let (newS, _) = PureSet.delete<Nat>(s, Nat.compare, x);
            s := newS
          }
        };
        case "union" ignore PureSet.union<Nat>(theSet, otherSet, Nat.compare);
        case "intersection" ignore PureSet.intersection<Nat>(theSet, otherSet, Nat.compare);
        case "difference" ignore PureSet.difference<Nat>(theSet, otherSet, Nat.compare);
        case "isSubset" ignore PureSet.isSubset<Nat>(theSet, otherSet, Nat.compare);
        case "map" ignore PureSet.map<Nat, Nat>(theSet, Nat.compare, func x = x + 1);
        case "filter" ignore PureSet.filter<Nat>(theSet, Nat.compare, func x = x % 2 == 0);
        case "foldLeft" ignore PureSet.foldLeft<Nat, Nat>(theSet, 0, func(acc, x) = acc + x);
        case "values" for (_ in PureSet.values<Nat>(theSet)) {};
        case "equal" ignore PureSet.equal<Nat>(theSet, theSet, Nat.compare);
        case _ Runtime.unreachable()
      }
    });
    bench
  }
}