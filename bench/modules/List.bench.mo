import Bench "mo:bench";
import List "../../src/List";
import Array "../../src/Array";
import Nat "../../src/Nat";
import Random "../../src/Random";
import Runtime "../../src/Runtime";

module {
  public func init() : Bench.Bench {
    let bench = Bench.Bench();
    bench.name("List");
    bench.description("Benchmarks for the List module");
    bench.rows([
      "fromArray",
      "add",
      "addAll",
      "sort",
      "sortInPlace",
      "map",
      "filter",
      "foldLeft",
      "contains",
      "clone",
      "reverse",
      "reverseInPlace",
      "toArray",
      "equal"
    ]);
    bench.cols(["100", "1_000", "10_000"]);

    let rng = Random.seed(0xaabbccdd);
    let a100 = Array.tabulate<Nat>(100, func(_) = rng.natRange(0, 1_000_000));
    let a1000 = Array.tabulate<Nat>(1_000, func(_) = rng.natRange(0, 1_000_000));
    let a10000 = Array.tabulate<Nat>(10_000, func(_) = rng.natRange(0, 1_000_000));
    let l100 = List.fromArray<Nat>(a100);
    let l1000 = List.fromArray<Nat>(a1000);
    let l10000 = List.fromArray<Nat>(a10000);

    bench.runner(
      func(row, col) {
        let (arr, theList) = switch col {
          case ("100") (a100, l100);
          case ("1_000") (a1000, l1000);
          case ("10_000") (a10000, l10000);
          case _ Runtime.unreachable()
        };
        switch row {
          case ("fromArray") ignore List.fromArray<Nat>(arr);
          case ("add") {
            let list = List.empty<Nat>();
            for (x in arr.vals()) { List.add<Nat>(list, x) }
          };
          case ("addAll") {
            let list = List.empty<Nat>();
            List.addAll<Nat>(list, arr.vals())
          };
          case ("sort") ignore List.sort<Nat>(theList, Nat.compare);
          case ("sortInPlace") {
            let list = List.clone<Nat>(theList);
            List.sortInPlace<Nat>(list, Nat.compare)
          };
          case ("map") ignore List.map<Nat, Nat>(theList, func(x) = x + 1);
          case ("filter") ignore List.filter<Nat>(theList, func(x) = x % 2 == 0);
          case ("foldLeft") ignore List.foldLeft<Nat, Nat>(theList, 0, func(a, x) = a + x);
          case ("contains") ignore List.contains<Nat>(theList, Nat.equal, arr[0]);
          case ("clone") ignore List.clone<Nat>(theList);
          case ("reverse") ignore List.reverse<Nat>(theList);
          case ("reverseInPlace") {
            let list = List.clone<Nat>(theList);
            List.reverseInPlace<Nat>(list)
          };
          case ("toArray") ignore List.toArray<Nat>(theList);
          case ("equal") ignore List.equal<Nat>(theList, List.clone<Nat>(theList), Nat.equal);
          case _ Runtime.unreachable()
        }
      }
    );
    bench
  }
}
