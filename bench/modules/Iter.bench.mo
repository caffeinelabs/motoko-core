import Bench "mo:bench";
import Array "../../src/Array";
import Nat "../../src/Nat";
import Iter "../../src/Iter";
import Random "../../src/Random";
import Runtime "../../src/Runtime";

module {
  public func init() : Bench.Bench {
    let bench = Bench.Bench();
    bench.name("Iter");
    bench.description("Benchmarks for the Iter module");
    bench.rows([
      "map",
      "filter",
      "foldLeft",
      "forEach",
      "concat",
      "take",
      "drop",
      "zip",
      "sort",
      "reverse",
      "toArray",
      "find",
      "all",
      "reduce",
      "enumerate"
    ]);
    bench.cols(["100", "1_000", "10_000"]);

    let rng = Random.seed(0xdeadbeef);
    let a100 = Array.tabulate<Nat>(100, func(_) = rng.natRange(0, 1_000_000));
    let a1000 = Array.tabulate<Nat>(1_000, func(_) = rng.natRange(0, 1_000_000));
    let a10000 = Array.tabulate<Nat>(10_000, func(_) = rng.natRange(0, 1_000_000));

    bench.runner(func(row, col) {
      let arr = switch col {
        case "100" a100;
        case "1_000" a1000;
        case "10_000" a10000;
        case _ Runtime.unreachable()
      };
      let half = arr.size() / 2;
      switch row {
        case "map" ignore Iter.toArray(Iter.map<Nat, Nat>(arr.vals(), func(x) = x + 1));
        case "filter" ignore Iter.toArray(Iter.filter<Nat>(arr.vals(), func(x) = x % 2 == 0));
        case "foldLeft" ignore Iter.foldLeft<Nat, Nat>(arr.vals(), 0, Nat.add);
        case "forEach" Iter.forEach<Nat>(arr.vals(), func(_) {});
        case "concat" ignore Iter.toArray(Iter.concat<Nat>(arr.vals(), arr.vals()));
        case "take" ignore Iter.toArray(Iter.take<Nat>(arr.vals(), half));
        case "drop" ignore Iter.toArray(Iter.drop<Nat>(arr.vals(), half));
        case "zip" ignore Iter.toArray(Iter.zip<Nat, Nat>(arr.vals(), arr.vals()));
        case "sort" ignore Iter.toArray(Iter.sort<Nat>(arr.vals(), Nat.compare));
        case "reverse" ignore Iter.toArray(Iter.reverse<Nat>(arr.vals()));
        case "toArray" ignore Iter.toArray<Nat>(arr.vals());
        case "find" ignore Iter.find<Nat>(arr.vals(), func(_) = true);
        case "all" ignore Iter.all<Nat>(arr.vals(), func(_) = true);
        case "reduce" ignore Iter.reduce<Nat>(arr.vals(), Nat.add);
        case "enumerate" ignore Iter.toArray(Iter.enumerate<Nat>(arr.vals()));
        case _ Runtime.unreachable()
      }
    });
    bench
  }
}