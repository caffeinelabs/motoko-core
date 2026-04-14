import Bench "mo:bench";
import Map "../../src/Map";
import Array "../../src/Array";
import Nat "../../src/Nat";
import Random "../../src/Random";
import Runtime "../../src/Runtime";

module {
  public func init() : Bench.Bench {
    let bench = Bench.Bench();
    bench.name("Map");
    bench.description("Benchmarks for the Map module");
    bench.rows([
      "fromArray",
      "add",
      "get",
      "containsKey",
      "delete",
      "size",
      "entries",
      "map",
      "filter",
      "foldLeft",
      "clone",
      "equal",
      "minEntry",
      "forEach"
    ]);
    bench.cols(["100", "1_000", "10_000"]);

    let rng = Random.seed(0x12345678);
    let pairs100 = Array.tabulate<(Nat, Nat)>(100, func(i) = (rng.natRange(0, 1_000_000), i));
    let pairs1000 = Array.tabulate<(Nat, Nat)>(1_000, func(i) = (rng.natRange(0, 1_000_000), i));
    let pairs10000 = Array.tabulate<(Nat, Nat)>(10_000, func(i) = (rng.natRange(0, 1_000_000), i));

    let m100 = Map.fromArray<Nat, Nat>(pairs100, Nat.compare);
    let m1000 = Map.fromArray<Nat, Nat>(pairs1000, Nat.compare);
    let m10000 = Map.fromArray<Nat, Nat>(pairs10000, Nat.compare);

    bench.runner(
      func(row, col) {
        let pairs = switch col {
          case "100" pairs100;
          case "1_000" pairs1000;
          case "10_000" pairs10000;
          case _ Runtime.unreachable()
        };
        let theMap = switch col {
          case "100" m100;
          case "1_000" m1000;
          case "10_000" m10000;
          case _ Runtime.unreachable()
        };
        let n = switch col {
          case "100" 100;
          case "1_000" 1_000;
          case "10_000" 10_000;
          case _ Runtime.unreachable()
        };
        switch row {
          case "fromArray" ignore Map.fromArray<Nat, Nat>(pairs, Nat.compare);
          case "add" {
            let m = Map.empty<Nat, Nat>();
            for ((k, v) in pairs.vals()) {
              Map.add<Nat, Nat>(m, Nat.compare, k, v)
            }
          };
          case "get" for ((k, _) in pairs.vals()) {
            ignore Map.get<Nat, Nat>(theMap, Nat.compare, k)
          };
          case "containsKey" for ((k, _) in pairs.vals()) {
            ignore Map.containsKey<Nat, Nat>(theMap, Nat.compare, k)
          };
          case "delete" {
            let m = Map.clone<Nat, Nat>(theMap);
            for ((k, _) in pairs.vals()) {
              ignore Map.delete<Nat, Nat>(m, Nat.compare, k)
            }
          };
          case "size" for (_ in Nat.range(0, n)) {
            ignore Map.size<Nat, Nat>(theMap)
          };
          case "entries" for (e in Map.entries<Nat, Nat>(theMap)) {
            ignore e
          };
          case "map" ignore Map.map<Nat, Nat, Nat>(theMap, func(k, v) = k + v);
          case "filter" ignore Map.filter<Nat, Nat>(theMap, Nat.compare, func(k, _) = k % 2 == 0);
          case "foldLeft" ignore Map.foldLeft<Nat, Nat, Nat>(theMap, 0, func(a, k, v) = a + k + v);
          case "clone" ignore Map.clone<Nat, Nat>(theMap);
          case "equal" for (_ in Nat.range(0, n)) {
            ignore Map.equal<Nat, Nat>(theMap, theMap, Nat.compare, Nat.equal)
          };
          case "minEntry" for (_ in Nat.range(0, n)) {
            ignore Map.minEntry<Nat, Nat>(theMap)
          };
          case "forEach" {
            Map.forEach<Nat, Nat>(theMap, func(_, _) {})
          };
          case _ Runtime.unreachable()
        }
      }
    );
    bench
  }
}
