import Bench "mo:bench";
import Order "../../src/Order";
import Nat "../../src/Nat";
import Runtime "../../src/Runtime";

module {
  public func init() : Bench.Bench {
    let bench = Bench.Bench();
    bench.name("Order");
    bench.description("Benchmarks for the Order module");
    bench.rows(["equal", "isLess", "isEqual", "isGreater"]);
    bench.cols(["1_000", "10_000", "100_000"]);

    bench.runner(func(row, col) {
      let n = switch col {
        case "1_000" 1_000;
        case "10_000" 10_000;
        case "100_000" 100_000;
        case _ Runtime.unreachable()
      };
      let less = (#less : Order.Order);
      let equal = (#equal : Order.Order);
      let greater = (#greater : Order.Order);
      switch row {
        case "equal" for (_ in Nat.range(0, n)) { ignore Order.equal(less, greater) };
        case "isLess" for (_ in Nat.range(0, n)) { ignore Order.isLess(less) };
        case "isEqual" for (_ in Nat.range(0, n)) { ignore Order.isEqual(equal) };
        case "isGreater" for (_ in Nat.range(0, n)) { ignore Order.isGreater(greater) };
        case _ Runtime.unreachable()
      }
    });
    bench
  }
}