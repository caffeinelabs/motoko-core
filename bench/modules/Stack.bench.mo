import Bench "mo:bench";
import Stack "../../src/Stack";
import Array "../../src/Array";
import Nat "../../src/Nat";
import Random "../../src/Random";
import Runtime "../../src/Runtime";

module {
  public func init() : Bench.Bench {
    let bench = Bench.Bench();
    bench.name("Stack");
    bench.description("Benchmarks for the Stack module");
    bench.rows([
      "fromArray",
      "push",
      "pop",
      "map",
      "filter",
      "forEach",
      "contains",
      "clone",
      "toArray",
      "equal"
    ]);
    bench.cols(["100", "1_000", "10_000"]);

    let rng = Random.seed(0xaabbccdd);
    let a100 = Array.tabulate<Nat>(100, func(_) = rng.natRange(0, 1_000_000));
    let a1000 = Array.tabulate<Nat>(1_000, func(_) = rng.natRange(0, 1_000_000));
    let a10000 = Array.tabulate<Nat>(10_000, func(_) = rng.natRange(0, 1_000_000));
    let s100 = Stack.fromArray<Nat>(a100);
    let s1000 = Stack.fromArray<Nat>(a1000);
    let s10000 = Stack.fromArray<Nat>(a10000);

    bench.runner(
      func(row, col) {
        let (arr, theStack) = switch col {
          case ("100") (a100, s100);
          case ("1_000") (a1000, s1000);
          case ("10_000") (a10000, s10000);
          case _ Runtime.unreachable()
        };
        switch row {
          case ("fromArray") ignore Stack.fromArray<Nat>(arr);
          case ("push") {
            let s = Stack.empty<Nat>();
            for (x in arr.vals()) { Stack.push<Nat>(s, x) }
          };
          case ("pop") {
            let s = Stack.clone<Nat>(theStack);
            label l loop {
              switch (Stack.pop<Nat>(s)) {
                case null { break l };
                case (?_) {}
              }
            }
          };
          case ("map") ignore Stack.map<Nat, Nat>(theStack, func(x) = x + 1);
          case ("filter") ignore Stack.filter<Nat>(theStack, func(x) = x % 2 == 0);
          case ("forEach") Stack.forEach<Nat>(theStack, func(x) { ignore x });
          case ("contains") ignore Stack.contains<Nat>(theStack, Nat.equal, arr[0]);
          case ("clone") ignore Stack.clone<Nat>(theStack);
          case ("toArray") ignore Stack.toArray<Nat>(theStack);
          case ("equal") ignore Stack.equal<Nat>(theStack, Stack.clone<Nat>(theStack), Nat.equal);
          case _ Runtime.unreachable()
        }
      }
    );
    bench
  }
}
