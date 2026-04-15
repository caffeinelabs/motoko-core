// @testmode wasi

import Float32 "../src/Float32";
import Order "../src/Order";

import Suite "mo:matchers/Suite";
import T "mo:matchers/Testable";
import M "mo:matchers/Matchers";

let { run; test; suite } = Suite;

class Float32Testable(number : Float32, epsilon : Float32) : T.TestableItem<Float32> {
  public let item = number;
  public func display(number : Float32) : Text {
    debug_show (number)
  };
  public let equals = func(x : Float32, y : Float32) : Bool {
    if (epsilon == (0.0 : Float32)) {
      x == y // to also test Float32.abs()
    } else {
      Float32.abs(x - y) < epsilon
    }
  }
};

class Int64Testable(number : Int64) : T.TestableItem<Int64> {
  public let item = number;
  public func display(number : Int64) : Text {
    debug_show (number)
  };
  public let equals = func(x : Int64, y : Int64) : Bool {
    x == y
  }
};

class FloatTestable(number : Float) : T.TestableItem<Float> {
  public let item = number;
  public func display(number : Float) : Text {
    debug_show (number)
  };
  public let equals = func(x : Float, y : Float) : Bool {
    x == y
  }
};

type Order = Order.Order;

class OrderTestable(value : Order) : T.TestableItem<Order> {
  public let item = value;
  public func display(value : Order) : Text {
    debug_show (value)
  };
  public let equals = func(x : Order, y : Order) : Bool {
    x == y
  }
};

let positiveInfinity : Float32 = 1.0 / 0.0;
let negativeInfinity : Float32 = -1.0 / 0.0;

let positiveNaN : Float32 = Float32.copySign(0.0 / 0.0, 1.0);
let negativeNaN : Float32 = Float32.copySign(0.0 / 0.0, -1.0);

let noEpsilon : Float32 = 0.0;
let smallEpsilon : Float32 = 1e-5;

class NaNMatcher() : M.Matcher<Float32> {
  public func describeMismatch(number : Float32, _description : M.Description) {};
  public func matches(number : Float32) : Bool {
    Float32.isNaN(number)
  }
};

run(
  suite(
    "Float32",
    [
      suite(
        "constants",
        [
          test(
            "pi",
            Float32.pi,
            M.equals(Float32Testable(3.14159265 : Float32, smallEpsilon))
          ),
          test(
            "e",
            Float32.e,
            M.equals(Float32Testable(2.71828182 : Float32, smallEpsilon))
          )
        ]
      ),
      suite(
        "isNaN",
        [
          test(
            "NaN is NaN",
            Float32.isNaN(0.0 / 0.0),
            M.equals(T.bool(true))
          ),
          test(
            "1.0 is not NaN",
            Float32.isNaN(1.0),
            M.equals(T.bool(false))
          ),
          test(
            "infinity is not NaN",
            Float32.isNaN(positiveInfinity),
            M.equals(T.bool(false))
          )
        ]
      ),
      suite(
        "abs",
        [
          test(
            "positive",
            Float32.abs(1.2),
            M.equals(Float32Testable(1.2, noEpsilon))
          ),
          test(
            "negative",
            Float32.abs(-1.2),
            M.equals(Float32Testable(1.2, noEpsilon))
          ),
          test(
            "+inf",
            Float32.abs(positiveInfinity),
            M.equals(Float32Testable(positiveInfinity, noEpsilon))
          ),
          test(
            "-inf",
            Float32.abs(negativeInfinity),
            M.equals(Float32Testable(positiveInfinity, noEpsilon))
          ),
          test(
            "NaN",
            Float32.abs(positiveNaN),
            NaNMatcher()
          )
        ]
      ),
      suite(
        "sqrt",
        [
          test(
            "exact",
            Float32.sqrt(6.25),
            M.equals(Float32Testable(2.5, noEpsilon))
          ),
          test(
            "+inf",
            Float32.sqrt(positiveInfinity),
            M.equals(Float32Testable(positiveInfinity, noEpsilon))
          ),
          test(
            "negative is NaN",
            Float32.sqrt(-1.0),
            NaNMatcher()
          )
        ]
      ),
      suite(
        "ceil",
        [
          test(
            "positive fraction",
            Float32.ceil(1.2),
            M.equals(Float32Testable(2.0, noEpsilon))
          ),
          test(
            "negative fraction",
            Float32.ceil(-1.2),
            M.equals(Float32Testable(-1.0, noEpsilon))
          ),
          test(
            "+inf",
            Float32.ceil(positiveInfinity),
            M.equals(Float32Testable(positiveInfinity, noEpsilon))
          )
        ]
      ),
      suite(
        "floor",
        [
          test(
            "positive fraction",
            Float32.floor(1.2),
            M.equals(Float32Testable(1.0, noEpsilon))
          ),
          test(
            "negative fraction",
            Float32.floor(-1.2),
            M.equals(Float32Testable(-2.0, noEpsilon))
          ),
          test(
            "+inf",
            Float32.floor(positiveInfinity),
            M.equals(Float32Testable(positiveInfinity, noEpsilon))
          )
        ]
      ),
      suite(
        "trunc",
        [
          test(
            "positive fraction",
            Float32.trunc(2.75),
            M.equals(Float32Testable(2.0, noEpsilon))
          ),
          test(
            "negative fraction",
            Float32.trunc(-2.75),
            M.equals(Float32Testable(-2.0, noEpsilon))
          )
        ]
      ),
      suite(
        "nearest",
        [
          test(
            "round up",
            Float32.nearest(2.75),
            M.equals(Float32Testable(3.0, noEpsilon))
          ),
          test(
            "round down",
            Float32.nearest(2.25),
            M.equals(Float32Testable(2.0, noEpsilon))
          ),
          test(
            "banker's rounding 14.5 => 14.0",
            Float32.nearest(14.5),
            M.equals(Float32Testable(14.0, noEpsilon))
          )
        ]
      ),
      suite(
        "copySign",
        [
          test(
            "positive to negative",
            Float32.copySign(1.2, -2.3),
            M.equals(Float32Testable(-1.2, noEpsilon))
          ),
          test(
            "negative to positive",
            Float32.copySign(-1.2, 2.3),
            M.equals(Float32Testable(1.2, noEpsilon))
          )
        ]
      ),
      suite(
        "min",
        [
          test(
            "smaller",
            Float32.min(1.2, -2.3),
            M.equals(Float32Testable(-2.3, noEpsilon))
          ),
          test(
            "equal",
            Float32.min(1.0, 1.0),
            M.equals(Float32Testable(1.0, noEpsilon))
          )
        ]
      ),
      suite(
        "max",
        [
          test(
            "larger",
            Float32.max(1.2, -2.3),
            M.equals(Float32Testable(1.2, noEpsilon))
          ),
          test(
            "equal",
            Float32.max(1.0, 1.0),
            M.equals(Float32Testable(1.0, noEpsilon))
          )
        ]
      ),
      suite(
        "trig",
        [
          test(
            "sin(pi/2) = 1",
            Float32.sin(Float32.pi / 2.0),
            M.equals(Float32Testable(1.0, smallEpsilon))
          ),
          test(
            "cos(0) = 1",
            Float32.cos(0.0),
            M.equals(Float32Testable(1.0, noEpsilon))
          ),
          test(
            "tan(pi/4) = 1",
            Float32.tan(Float32.pi / 4.0),
            M.equals(Float32Testable(1.0, smallEpsilon))
          ),
          test(
            "arcsin(1) = pi/2",
            Float32.arcsin(1.0),
            M.equals(Float32Testable(Float32.pi / 2.0, smallEpsilon))
          ),
          test(
            "arccos(1) = 0",
            Float32.arccos(1.0),
            M.equals(Float32Testable(0.0, smallEpsilon))
          ),
          test(
            "arctan(1) = pi/4",
            Float32.arctan(1.0),
            M.equals(Float32Testable(Float32.pi / 4.0, smallEpsilon))
          ),
          test(
            "arctan2(1, 1) = pi/4",
            Float32.arctan2(1.0, 1.0),
            M.equals(Float32Testable(Float32.pi / 4.0, smallEpsilon))
          )
        ]
      ),
      suite(
        "exp and log",
        [
          test(
            "exp(1) = e",
            Float32.exp(1.0),
            M.equals(Float32Testable(Float32.e, smallEpsilon))
          ),
          test(
            "log(e) = 1",
            Float32.log(Float32.e),
            M.equals(Float32Testable(1.0, smallEpsilon))
          ),
          test(
            "log(0) = -inf",
            Float32.log(0.0),
            M.equals(Float32Testable(negativeInfinity, noEpsilon))
          )
        ]
      ),
      suite(
        "toFloat / fromFloat",
        [
          test(
            "toFloat 1.5",
            Float32.toFloat(1.5),
            M.equals(FloatTestable(1.5))
          ),
          test(
            "fromFloat 1.5",
            Float32.fromFloat(1.5),
            M.equals(Float32Testable(1.5, noEpsilon))
          )
        ]
      ),
      suite(
        "toInt64 / fromInt64",
        [
          test(
            "toInt64 -12.0",
            Float32.toInt64(-12.0),
            M.equals(Int64Testable(-12))
          ),
          test(
            "fromInt64 -42",
            Float32.fromInt64(-42),
            M.equals(Float32Testable(-42.0, noEpsilon))
          )
        ]
      ),
      suite(
        "toInt",
        [
          test(
            "toInt 1000000",
            Float32.toInt(1.0e6),
            M.equals(T.int(+1_000_000))
          )
        ]
      ),
      suite(
        "equal",
        [
          test(
            "within epsilon",
            Float32.equal(-12.3, -1.23e1, smallEpsilon),
            M.equals(T.bool(true))
          ),
          test(
            "outside epsilon",
            Float32.equal(1.0, 2.0, smallEpsilon),
            M.equals(T.bool(false))
          ),
          test(
            "+inf equals +inf",
            Float32.equal(positiveInfinity, positiveInfinity, smallEpsilon),
            M.equals(T.bool(true))
          ),
          test(
            "NaN not equal to NaN",
            Float32.equal(positiveNaN, positiveNaN, smallEpsilon),
            M.equals(T.bool(false))
          )
        ]
      ),
      suite(
        "notEqual",
        [
          test(
            "within epsilon",
            Float32.notEqual(-12.3, -1.23e1, smallEpsilon),
            M.equals(T.bool(false))
          ),
          test(
            "outside epsilon",
            Float32.notEqual(1.0, 2.0, smallEpsilon),
            M.equals(T.bool(true))
          )
        ]
      ),
      suite(
        "comparisons",
        [
          test(
            "less: e < pi",
            Float32.less(Float32.e, Float32.pi),
            M.equals(T.bool(true))
          ),
          test(
            "lessOrEqual: 1.0 <= 1.0",
            Float32.lessOrEqual(1.0, 1.0),
            M.equals(T.bool(true))
          ),
          test(
            "greater: pi > e",
            Float32.greater(Float32.pi, Float32.e),
            M.equals(T.bool(true))
          ),
          test(
            "greaterOrEqual: 1.0 >= 1.0",
            Float32.greaterOrEqual(1.0, 1.0),
            M.equals(T.bool(true))
          )
        ]
      ),
      suite(
        "compare",
        [
          test(
            "less",
            Float32.compare(0.123, 0.1234),
            M.equals(OrderTestable(#less))
          ),
          test(
            "equal",
            Float32.compare(1.0, 1.0),
            M.equals(OrderTestable(#equal))
          ),
          test(
            "greater",
            Float32.compare(0.1234, 0.123),
            M.equals(OrderTestable(#greater))
          ),
          test(
            "positive NaN is greater than positive inf",
            Float32.compare(positiveNaN, positiveInfinity),
            M.equals(OrderTestable(#greater))
          )
        ]
      ),
      suite(
        "arithmetic",
        [
          test(
            "neg",
            Float32.neg(1.23),
            M.equals(Float32Testable(-1.23, smallEpsilon))
          ),
          test(
            "add",
            Float32.add(1.0, 2.0),
            M.equals(Float32Testable(3.0, noEpsilon))
          ),
          test(
            "sub",
            Float32.sub(3.0, 1.0),
            M.equals(Float32Testable(2.0, noEpsilon))
          ),
          test(
            "mul",
            Float32.mul(2.0, 3.0),
            M.equals(Float32Testable(6.0, noEpsilon))
          ),
          test(
            "div",
            Float32.div(6.0, 2.0),
            M.equals(Float32Testable(3.0, noEpsilon))
          ),
          test(
            "rem",
            Float32.rem(7.0, 3.0),
            M.equals(Float32Testable(1.0, noEpsilon))
          ),
          test(
            "pow",
            Float32.pow(2.5, 2.0),
            M.equals(Float32Testable(6.25, smallEpsilon))
          )
        ]
      )
    ]
  )
)
