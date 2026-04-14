import Bench "mo:bench";
import Float32 "../../src/Float32";
import Nat "../../src/Nat";
import Runtime "../../src/Runtime";

module {
  public func init() : Bench.Bench {
    let bench = Bench.Bench();

    bench.name("Float32");
    bench.description("Float32 scalar operations");

    let x : Float32 = Float32.fromFloat(3.14159);
    let y : Float32 = Float32.fromFloat(2.71828);

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
      "fromFloat"
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
              ignore Float32.add(x, y)
            }
          };
          case ("mul") {
            for (_ in Nat.range(0, n)) {
              ignore Float32.mul(x, y)
            }
          };
          case ("div") {
            for (_ in Nat.range(0, n)) {
              ignore Float32.div(x, y)
            }
          };
          case ("sqrt") {
            for (_ in Nat.range(0, n)) {
              ignore Float32.sqrt(y)
            }
          };
          case ("sin") {
            for (_ in Nat.range(0, n)) {
              ignore Float32.sin(x)
            }
          };
          case ("cos") {
            for (_ in Nat.range(0, n)) {
              ignore Float32.cos(x)
            }
          };
          case ("exp") {
            for (_ in Nat.range(0, n)) {
              ignore Float32.exp(y)
            }
          };
          case ("log") {
            for (_ in Nat.range(0, n)) {
              ignore Float32.log(y)
            }
          };
          case ("pow") {
            for (_ in Nat.range(0, n)) {
              ignore Float32.pow(x, y)
            }
          };
          case ("compare") {
            for (_ in Nat.range(0, n)) {
              ignore Float32.compare(x, y)
            }
          };
          case ("toText") {
            for (_ in Nat.range(0, n)) {
              ignore Float32.toText(x)
            }
          };
          case ("fromFloat") {
            for (_ in Nat.range(0, n)) {
              ignore Float32.fromFloat(3.14159)
            }
          };
          case (_) Runtime.unreachable()
        }
      }
    );

    bench
  }
}