import Bench "mo:bench";
import Float "../../src/Float";
import Nat "../../src/Nat";
import Runtime "../../src/Runtime";

module {
  public func init() : Bench.Bench {
    let bench = Bench.Bench();

    bench.name("Float");
    bench.description("Float scalar operations");

    bench.rows([
      "add",
      "mul",
      "div",
      "sqrt",
      "sin",
      "cos",
      "exp",
      "log",
      "pow",
      "compare",
      "toText",
      "fromInt"
    ]);
    bench.cols([
      "1_000",
      "10_000",
      "100_000"
    ]);

    bench.runner(
      func(row, col) {
        let n = switch (col) {
          case ("1_000") 1_000;
          case ("10_000") 10_000;
          case ("100_000") 100_000;
          case (_) Runtime.unreachable()
        };
        switch (row) {
          case ("add") {
            for (_ in Nat.range(0, n)) {
              ignore Float.add(3.14159, 2.71828)
            }
          };
          case ("mul") {
            for (_ in Nat.range(0, n)) {
              ignore Float.mul(3.14159, 2.71828)
            }
          };
          case ("div") {
            for (_ in Nat.range(0, n)) {
              ignore Float.div(3.14159, 2.71828)
            }
          };
          case ("sqrt") {
            for (_ in Nat.range(0, n)) {
              ignore Float.sqrt(2.71828)
            }
          };
          case ("sin") {
            for (_ in Nat.range(0, n)) {
              ignore Float.sin(3.14159)
            }
          };
          case ("cos") {
            for (_ in Nat.range(0, n)) {
              ignore Float.cos(3.14159)
            }
          };
          case ("exp") {
            for (_ in Nat.range(0, n)) {
              ignore Float.exp(2.71828)
            }
          };
          case ("log") {
            for (_ in Nat.range(0, n)) {
              ignore Float.log(2.71828)
            }
          };
          case ("pow") {
            for (_ in Nat.range(0, n)) {
              ignore Float.pow(3.14159, 2.71828)
            }
          };
          case ("compare") {
            for (_ in Nat.range(0, n)) {
              ignore Float.compare(3.14159, 2.71828)
            }
          };
          case ("toText") {
            for (_ in Nat.range(0, n)) {
              ignore Float.toText(3.14159)
            }
          };
          case ("fromInt") {
            for (_ in Nat.range(0, n)) {
              ignore Float.fromInt(314159)
            }
          };
          case (_) Runtime.unreachable()
        }
      }
    );

    bench
  }
}