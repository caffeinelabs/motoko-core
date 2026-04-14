import Bench "mo:bench";
import PureMap "../../../src/pure/Map";
import Array "../../../src/Array";
import Nat "../../../src/Nat";
import Random "../../../src/Random";
import Runtime "../../../src/Runtime";

module {
  public func init() : Bench.Bench {
    let bench = Bench.Bench();
    bench.name("pure/Map");
    bench.description("Benchmarks for the pure Map module");
    bench.rows([
      "fromIter",
      "add",
      "get",
      "containsKey",
      "delete",
      "remove",
      "map",
      "filter",
      "foldLeft",
      "entries",
      "equal",
      "size"
    ]);
    bench.cols(["100", "1_000", "10_000"]);

    let rng = Random.seed(0x87654321);
    let pairs100 = Array.tabulate<(Nat, Nat)>(100, func(i) = (rng.natRange(0, 1_000_000), i));
    let pairs1000 = Array.tabulate<(Nat, Nat)>(1_000, func(i) = (rng.natRange(0, 1_000_000), i));
    let pairs10000 = Array.tabulate<(Nat, Nat)>(10_000, func(i) = (rng.natRange(0, 1_000_000), i));

    let pm100 = PureMap.fromIter<Nat, Nat>(pairs100.vals(), Nat.compare);
    let pm1000 = PureMap.fromIter<Nat, Nat>(pairs1000.vals(), Nat.compare);
    let pm10000 = PureMap.fromIter<Nat, Nat>(pairs10000.vals(), Nat.compare);

    bench.runner(func(row, col) {
      let pairs = switch col {
        case "100" pairs100;
        case "1_000" pairs1000;
        case "10_000" pairs10000;
        case _ Runtime.unreachable()
      };
      let theMap = switch col {
        case "100" pm100;
        case "1_000" pm1000;
        case "10_000" pm10000;
        case _ Runtime.unreachable()
      };
      switch row {
        case "fromIter" ignore PureMap.fromIter<Nat, Nat>(pairs.vals(), Nat.compare);
        case "add" {
          var m = PureMap.empty<Nat, Nat>();
          for ((k, v) in pairs.vals()) {
            m := PureMap.add<Nat, Nat>(m, Nat.compare, k, v)
          }
        };
        case "get" for ((k, _) in pairs.vals()) {
          ignore PureMap.get<Nat, Nat>(theMap, Nat.compare, k)
        };
        case "containsKey" for ((k, _) in pairs.vals()) {
          ignore PureMap.containsKey<Nat, Nat>(theMap, Nat.compare, k)
        };
        case "delete" {
          var m = theMap;
          for ((k, _) in pairs.vals()) {
            let (newM, _) = PureMap.delete<Nat, Nat>(m, Nat.compare, k);
            m := newM
          }
        };
        case "remove" {
          var m = theMap;
          for ((k, _) in pairs.vals()) {
            m := PureMap.remove<Nat, Nat>(m, Nat.compare, k)
          }
        };
        case "map" ignore PureMap.map<Nat, Nat, Nat>(theMap, func(k, v) = k + v);
        case "filter" ignore PureMap.filter<Nat, Nat>(theMap, Nat.compare, func(k, _) = k % 2 == 0);
        case "foldLeft" ignore PureMap.foldLeft<Nat, Nat, Nat>(theMap, 0, func(acc, k, v) = acc + k + v);
        case "entries" for (_ in PureMap.entries<Nat, Nat>(theMap)) {};
        case "equal" ignore PureMap.equal<Nat, Nat>(theMap, theMap, Nat.compare, Nat.equal);
        case "size" ignore PureMap.size<Nat, Nat>(theMap);
        case _ Runtime.unreachable()
      }
    });
    bench
  }
}