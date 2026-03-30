/// Single precision (32-bit) floating-point numbers in IEEE 754 representation.
///
/// This module contains common floating-point constants and utility functions.
///
/// ```motoko name=import
/// import Float32 "mo:core/Float32";
/// ```
///
/// Notation for special values in the documentation below:
/// `+inf`: Positive infinity
/// `-inf`: Negative infinity
/// `NaN`: "not a number" (can have different sign bit values, but `NaN != NaN` regardless of the sign).
///
/// Note:
/// Floating point numbers have limited precision and operations may inherently result in numerical errors.
/// `Float32` has less precision than `Float` (64-bit); only about 7 significant decimal digits.
///
/// Examples of numerical errors:
///   ```motoko
///   assert 0.1 + 0.1 + 0.1 != 0.3;
///   ```
///
/// Advice:
/// * Floating point number comparisons by `==` or `!=` are discouraged. Instead, it is better to compare
///   floating-point numbers with a numerical tolerance, called epsilon.
///
///   Example:
///   ```motoko
///   import Float32 "mo:core/Float32";
///   let x = 0.1 + 0.1 + 0.1 : Float32;
///   let y = 0.3 : Float32;
///
///   let epsilon = 1e-5 : Float32; // This depends on the application case (needs a numerical error analysis).
///   assert Float32.equal(x, y, epsilon);
///   ```
///
/// * For absolute precision, it is recommended to encode the fraction number as a pair of a Nat for the base
///   and a Nat for the exponent (decimal point).
///
/// Note: As of `moc` 1.4, `Float32` support is experimental.
///
/// NaN sign:
/// * The NaN sign is only applied by `abs`, `neg`, and `copySign`. Other operations can have an arbitrary
///   sign bit for NaN results.

import Prim "mo:⛔";
import Order "Order";

module {

  /// 32-bit floating point number type.
  public type Float32 = Prim.Types.Float32;

  /// Conversion to Float (64-bit double precision).
  ///
  /// This is a lossless widening conversion.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert Float32.toFloat(1.5) == 1.5;
  /// ```
  public let toFloat : (self : Float32) -> Float = Prim.float32ToFloat;

  /// Conversion from Float (64-bit double precision) to Float32.
  ///
  /// Note: This may lose precision for values that are not exactly representable in 32-bit.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert Float32.fromFloat(1.5) == 1.5;
  /// ```
  public let fromFloat : (x : Float) -> Float32 = Prim.floatToFloat32;

  /// Ratio of the circumference of a circle to its diameter.
  /// Note: Limited precision (approximately 7 significant decimal digits).
  public let pi : Float32 = 3.14159265358979323846;

  /// Base of the natural logarithm.
  /// Note: Limited precision (approximately 7 significant decimal digits).
  public let e : Float32 = 2.7182818284590452354;

  /// Determines whether the `number` is a `NaN` ("not a number" in the floating point representation).
  /// Notes:
  /// * Equality test of `NaN` with itself or another number is always `false`.
  /// * There exist many internal `NaN` value representations, such as positive and negative NaN,
  ///   signalling and quiet NaNs, each with many different bit representations.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert Float32.isNaN(0.0/0.0);
  /// ```
  public func isNaN(self : Float32) : Bool {
    self != self
  };

  /// Returns the absolute value of `x`.
  ///
  /// Special cases:
  /// ```
  /// abs(+inf) => +inf
  /// abs(-inf) => +inf
  /// abs(-NaN)  => +NaN
  /// abs(-0.0) => 0.0
  /// ```
  ///
  /// Example:
  /// ```motoko include=import
  /// let epsilon = 1e-5 : Float32;
  /// assert Float32.equal(Float32.abs(-1.2), 1.2, epsilon);
  /// ```
  public func abs(x : Float32) : Float32 {
    fromFloat(Prim.floatAbs(toFloat(x)))
  };

  /// Returns the square root of `x`.
  ///
  /// Special cases:
  /// ```
  /// sqrt(+inf) => +inf
  /// sqrt(-0.0) => -0.0
  /// sqrt(x)    => NaN if x < 0.0
  /// sqrt(NaN)  => NaN
  /// ```
  ///
  /// Example:
  /// ```motoko include=import
  /// let epsilon = 1e-5 : Float32;
  /// assert Float32.equal(Float32.sqrt(6.25), 2.5, epsilon);
  /// ```
  public func sqrt(x : Float32) : Float32 {
    fromFloat(Prim.floatSqrt(toFloat(x)))
  };

  /// Returns the smallest integral float greater than or equal to `x`.
  ///
  /// Special cases:
  /// ```
  /// ceil(+inf) => +inf
  /// ceil(-inf) => -inf
  /// ceil(NaN)  => NaN
  /// ceil(0.0)  => 0.0
  /// ceil(-0.0) => -0.0
  /// ```
  ///
  /// Example:
  /// ```motoko include=import
  /// let epsilon = 1e-5 : Float32;
  /// assert Float32.equal(Float32.ceil(1.2), 2.0, epsilon);
  /// ```
  public func ceil(x : Float32) : Float32 {
    fromFloat(Prim.floatCeil(toFloat(x)))
  };

  /// Returns the largest integral float less than or equal to `x`.
  ///
  /// Special cases:
  /// ```
  /// floor(+inf) => +inf
  /// floor(-inf) => -inf
  /// floor(NaN)  => NaN
  /// floor(0.0)  => 0.0
  /// floor(-0.0) => -0.0
  /// ```
  ///
  /// Example:
  /// ```motoko include=import
  /// let epsilon = 1e-5 : Float32;
  /// assert Float32.equal(Float32.floor(1.2), 1.0, epsilon);
  /// ```
  public func floor(x : Float32) : Float32 {
    fromFloat(Prim.floatFloor(toFloat(x)))
  };

  /// Returns the nearest integral float not greater in magnitude than `x`.
  /// This is equivalent to returning `x` with truncating its decimal places.
  ///
  /// Special cases:
  /// ```
  /// trunc(+inf) => +inf
  /// trunc(-inf) => -inf
  /// trunc(NaN)  => NaN
  /// trunc(0.0)  => 0.0
  /// trunc(-0.0) => -0.0
  /// ```
  ///
  /// Example:
  /// ```motoko include=import
  /// let epsilon = 1e-5 : Float32;
  /// assert Float32.equal(Float32.trunc(2.75), 2.0, epsilon);
  /// ```
  public func trunc(x : Float32) : Float32 {
    fromFloat(Prim.floatTrunc(toFloat(x)))
  };

  /// Returns the nearest integral float to `x`.
  /// A decimal place of exactly .5 is rounded to the nearest even integral float.
  ///
  /// Special cases:
  /// ```
  /// nearest(+inf) => +inf
  /// nearest(-inf) => -inf
  /// nearest(NaN)  => NaN
  /// nearest(0.0)  => 0.0
  /// nearest(-0.0) => -0.0
  /// nearest(14.5) => 14.0
  /// ```
  ///
  /// Example:
  /// ```motoko include=import
  /// assert Float32.nearest(2.75) == 3.0
  /// ```
  public func nearest(x : Float32) : Float32 {
    fromFloat(Prim.floatNearest(toFloat(x)))
  };

  /// Returns `x` if `x` and `y` have same sign, otherwise `x` with negated sign.
  ///
  /// The sign bit of zero, infinity, and `NaN` is considered.
  ///
  /// Example:
  /// ```motoko include=import
  /// let epsilon = 1e-5 : Float32;
  /// assert Float32.equal(Float32.copySign(1.2, -2.3), -1.2, epsilon);
  /// ```
  public func copySign(x : Float32, y : Float32) : Float32 {
    fromFloat(Prim.floatCopySign(toFloat(x), toFloat(y)))
  };

  /// Returns the smaller value of `x` and `y`.
  ///
  /// Special cases:
  /// ```
  /// min(NaN, y) => NaN for any Float32 y
  /// min(x, NaN) => NaN for any Float32 x
  /// ```
  ///
  /// Example:
  /// ```motoko include=import
  /// assert Float32.min(1.2, -2.3) == -2.3; // with numerical imprecision
  /// ```
  public func min(x : Float32, y : Float32) : Float32 {
    fromFloat(Prim.floatMin(toFloat(x), toFloat(y)))
  };

  /// Returns the larger value of `x` and `y`.
  ///
  /// Special cases:
  /// ```
  /// max(NaN, y) => NaN for any Float32 y
  /// max(x, NaN) => NaN for any Float32 x
  /// ```
  ///
  /// Example:
  /// ```motoko include=import
  /// assert Float32.max(1.2, -2.3) == 1.2;
  /// ```
  public func max(x : Float32, y : Float32) : Float32 {
    fromFloat(Prim.floatMax(toFloat(x), toFloat(y)))
  };

  /// Returns the sine of the radian angle `x`.
  ///
  /// Special cases:
  /// ```
  /// sin(+inf) => NaN
  /// sin(-inf) => NaN
  /// sin(NaN) => NaN
  /// ```
  ///
  /// Example:
  /// ```motoko include=import
  /// let epsilon = 1e-5 : Float32;
  /// assert Float32.equal(Float32.sin(Float32.pi / 2.0), 1.0, epsilon);
  /// ```
  public func sin(x : Float32) : Float32 {
    fromFloat(Prim.sin(toFloat(x)))
  };

  /// Returns the cosine of the radian angle `x`.
  ///
  /// Special cases:
  /// ```
  /// cos(+inf) => NaN
  /// cos(-inf) => NaN
  /// cos(NaN)  => NaN
  /// ```
  ///
  /// Example:
  /// ```motoko include=import
  /// let epsilon = 1e-5 : Float32;
  /// assert Float32.equal(Float32.cos(Float32.pi / 2.0), 0.0, epsilon);
  /// ```
  public func cos(x : Float32) : Float32 {
    fromFloat(Prim.cos(toFloat(x)))
  };

  /// Returns the tangent of the radian angle `x`.
  ///
  /// Special cases:
  /// ```
  /// tan(+inf) => NaN
  /// tan(-inf) => NaN
  /// tan(NaN)  => NaN
  /// ```
  ///
  /// Example:
  /// ```motoko include=import
  /// let epsilon = 1e-5 : Float32;
  /// assert Float32.equal(Float32.tan(Float32.pi / 4.0), 1.0, epsilon);
  /// ```
  public func tan(x : Float32) : Float32 {
    fromFloat(Prim.tan(toFloat(x)))
  };

  /// Returns the arc sine of `x` in radians.
  ///
  /// Special cases:
  /// ```
  /// arcsin(x)   => NaN if x > 1.0
  /// arcsin(x)   => NaN if x < -1.0
  /// arcsin(NaN) => NaN
  /// ```
  ///
  /// Example:
  /// ```motoko include=import
  /// let epsilon = 1e-5 : Float32;
  /// assert Float32.equal(Float32.arcsin(1.0), Float32.pi / 2.0, epsilon);
  /// ```
  public func arcsin(x : Float32) : Float32 {
    fromFloat(Prim.arcsin(toFloat(x)))
  };

  /// Returns the arc cosine of `x` in radians.
  ///
  /// Special cases:
  /// ```
  /// arccos(x)   => NaN if x > 1.0
  /// arccos(x)   => NaN if x < -1.0
  /// arccos(NaN) => NaN
  /// ```
  ///
  /// Example:
  /// ```motoko include=import
  /// let epsilon = 1e-5 : Float32;
  /// assert Float32.equal(Float32.arccos(1.0), 0.0, epsilon);
  /// ```
  public func arccos(x : Float32) : Float32 {
    fromFloat(Prim.arccos(toFloat(x)))
  };

  /// Returns the arc tangent of `x` in radians.
  ///
  /// Special cases:
  /// ```
  /// arctan(+inf) => pi / 2
  /// arctan(-inf) => -pi / 2
  /// arctan(NaN)  => NaN
  /// ```
  ///
  /// Example:
  /// ```motoko include=import
  /// let epsilon = 1e-5 : Float32;
  /// assert Float32.equal(Float32.arctan(1.0), Float32.pi / 4.0, epsilon);
  /// ```
  public func arctan(x : Float32) : Float32 {
    fromFloat(Prim.arctan(toFloat(x)))
  };

  /// Given `(y, x)`, returns the arc tangent in radians of `y/x` based on the signs of both values to determine the correct quadrant.
  ///
  /// Special cases:
  /// ```
  /// arctan2(0.0, 0.0)   => 0.0
  /// arctan2(-0.0, 0.0)  => -0.0
  /// arctan2(0.0, -0.0)  => pi
  /// arctan2(-0.0, -0.0) => -pi
  /// arctan2(+inf, +inf) => pi / 4
  /// arctan2(+inf, -inf) => 3 * pi / 4
  /// arctan2(-inf, +inf) => -pi / 4
  /// arctan2(-inf, -inf) => -3 * pi / 4
  /// arctan2(NaN, x)     => NaN for any Float32 x
  /// arctan2(y, NaN)     => NaN for any Float32 y
  /// ```
  ///
  /// Example:
  /// ```motoko include=import
  /// let sqrt2over2 = Float32.sqrt(2.0) / 2.0;
  /// assert Float32.arctan2(sqrt2over2, sqrt2over2) == Float32.pi / 4.0;
  /// ```
  public func arctan2(x : Float32, y : Float32) : Float32 {
    fromFloat(Prim.arctan2(toFloat(x), toFloat(y)))
  };

  /// Returns the value of `e` raised to the `x`-th power.
  ///
  /// Special cases:
  /// ```
  /// exp(+inf) => +inf
  /// exp(-inf) => 0.0
  /// exp(NaN)  => NaN
  /// ```
  ///
  /// Example:
  /// ```motoko include=import
  /// let epsilon = 1e-5 : Float32;
  /// assert Float32.equal(Float32.exp(1.0), Float32.e, epsilon);
  /// ```
  public func exp(x : Float32) : Float32 {
    fromFloat(Prim.exp(toFloat(x)))
  };

  /// Returns the natural logarithm (base-`e`) of `x`.
  ///
  /// Special cases:
  /// ```
  /// log(0.0)  => -inf
  /// log(-0.0) => -inf
  /// log(x)    => NaN if x < 0.0
  /// log(+inf) => +inf
  /// log(NaN)  => NaN
  /// ```
  ///
  /// Example:
  /// ```motoko include=import
  /// let epsilon = 1e-5 : Float32;
  /// assert Float32.equal(Float32.log(Float32.e), 1.0, epsilon);
  /// ```
  public func log(x : Float32) : Float32 {
    fromFloat(Prim.log(toFloat(x)))
  };

  /// Formatting. `format(fmt, x)` formats `x` to `Text` according to the
  /// formatting directive `fmt`, which can take one of the following forms:
  ///
  /// * `#fix prec` as fixed-point format with `prec` digits
  /// * `#exp prec` as exponential format with `prec` digits
  /// * `#gen prec` as generic format with `prec` digits
  /// * `#exact` as exact format that can be decoded without loss.
  ///
  /// `-0.0` is formatted with negative sign bit.
  /// Positive infinity is formatted as "inf".
  /// Negative infinity is formatted as "-inf".
  ///
  /// The numerical precision and the text format can vary between
  /// Motoko versions and runtime configuration. Moreover, `NaN` can be printed
  /// differently, i.e. "NaN" or "nan", potentially omitting the `NaN` sign.
  ///
  /// Example:
  /// ```motoko include=import no-validate
  /// assert Float32.format(123.0 : Float32, #exp (3 : Nat8)) == "1.230e+02";
  /// ```
  public func format(self : Float32, fmt : { #fix : Nat8; #exp : Nat8; #gen : Nat8; #exact }) : Text {
    let f = toFloat(self);
    switch fmt {
      case (#fix(prec)) { Prim.floatToFormattedText(f, prec, 0) };
      case (#exp(prec)) { Prim.floatToFormattedText(f, prec, 1) };
      case (#gen(prec)) { Prim.floatToFormattedText(f, prec, 2) };
      case (#exact) { Prim.floatToFormattedText(f, 17, 2) }
    }
  };

  /// Conversion to Text. Use `format(fmt, x)` for more detailed control.
  ///
  /// `-0.0` is formatted with negative sign bit.
  /// Positive infinity is formatted as `inf`.
  /// Negative infinity is formatted as `-inf`.
  /// `NaN` is formatted as `NaN` or `-NaN` depending on its sign bit.
  ///
  /// The numerical precision and the text format can vary between
  /// Motoko versions and runtime configuration. Moreover, `NaN` can be printed
  /// differently, i.e. "NaN" or "nan", potentially omitting the `NaN` sign.
  ///
  /// Example:
  /// ```motoko include=import no-validate
  /// assert Float32.toText(1.5) == "1.5";
  /// ```
  public func toText(self : Float32) : Text {
    Prim.floatToText(toFloat(self))
  };

  /// Conversion to Int64 by truncating Float32, equivalent to `toInt64(trunc(f))`
  ///
  /// Traps if the floating point number is larger or smaller than the representable Int64.
  /// Also traps for `inf`, `-inf`, and `NaN`.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert Float32.toInt64(-12.0) == -12;
  /// ```
  public func toInt64(self : Float32) : Int64 {
    Prim.floatToInt64(toFloat(self))
  };

  /// Conversion from Int64.
  ///
  /// Note: The floating point number may be imprecise for large or small Int64.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert Float32.fromInt64(-42) == -42.0;
  /// ```
  public func fromInt64(x : Int64) : Float32 {
    fromFloat(Prim.int64ToFloat(x))
  };

  /// Conversion to Int.
  ///
  /// Traps for `inf`, `-inf`, and `NaN`.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert Float32.toInt(1.0e6) == +1_000_000;
  /// ```
  public func toInt(self : Float32) : Int {
    Prim.floatToInt(toFloat(self))
  };

  /// Determines whether `x` is equal to `y` within the defined tolerance of `epsilon`.
  /// The `epsilon` considers numerical errors, see comment above.
  /// Equivalent to `Float32.abs(x - y) <= epsilon` for a non-negative epsilon.
  ///
  /// Traps if `epsilon` is negative or `NaN`.
  ///
  /// Special cases:
  /// ```
  /// equal(+0.0, -0.0, epsilon) => true for any `epsilon >= 0.0`
  /// equal(-0.0, +0.0, epsilon) => true for any `epsilon >= 0.0`
  /// equal(+inf, +inf, epsilon) => true for any `epsilon >= 0.0`
  /// equal(-inf, -inf, epsilon) => true for any `epsilon >= 0.0`
  /// equal(x, NaN, epsilon)     => false for any x and `epsilon >= 0.0`
  /// equal(NaN, y, epsilon)     => false for any y and `epsilon >= 0.0`
  /// ```
  ///
  /// Example:
  /// ```motoko include=import
  /// let epsilon = 1e-5 : Float32;
  /// assert Float32.equal(-12.3, -1.23e1, epsilon);
  /// ```
  public func equal(x : Float32, y : Float32, epsilon : Float32) : Bool {
    if (not (epsilon >= (0.0 : Float32))) {
      // also considers NaN, not identical to `epsilon < 0.0`
      Prim.trap("Float32.equal(): epsilon must be greater or equal 0.0")
    };
    x == y or abs(x - y) <= epsilon // `x == y` to also consider infinity equal
  };

  /// Determines whether `x` is not equal to `y` within the defined tolerance of `epsilon`.
  /// The `epsilon` considers numerical errors, see comment above.
  /// Equivalent to `not equal(x, y, epsilon)`.
  ///
  /// Traps if `epsilon` is negative or `NaN`.
  ///
  /// Special cases:
  /// ```
  /// notEqual(+0.0, -0.0, epsilon) => false for any `epsilon >= 0.0`
  /// notEqual(-0.0, +0.0, epsilon) => false for any `epsilon >= 0.0`
  /// notEqual(+inf, +inf, epsilon) => false for any `epsilon >= 0.0`
  /// notEqual(-inf, -inf, epsilon) => false for any `epsilon >= 0.0`
  /// notEqual(x, NaN, epsilon)     => true for any x and `epsilon >= 0.0`
  /// notEqual(NaN, y, epsilon)     => true for any y and `epsilon >= 0.0`
  /// ```
  ///
  /// Example:
  /// ```motoko include=import
  /// let epsilon = 1e-5 : Float32;
  /// assert not Float32.notEqual(-12.3, -1.23e1, epsilon);
  /// ```
  public func notEqual(x : Float32, y : Float32, epsilon : Float32) : Bool {
    if (not (epsilon >= (0.0 : Float32))) {
      // also considers NaN, not identical to `epsilon < 0.0`
      Prim.trap("Float32.notEqual(): epsilon must be greater or equal 0.0")
    };
    not (x == y or abs(x - y) <= epsilon)
  };

  /// Returns `x < y`.
  ///
  /// Special cases:
  /// ```
  /// less(+0.0, -0.0) => false
  /// less(-0.0, +0.0) => false
  /// less(NaN, y)     => false for any Float32 y
  /// less(x, NaN)     => false for any Float32 x
  /// ```
  ///
  /// Example:
  /// ```motoko include=import
  /// assert Float32.less(Float32.e, Float32.pi);
  /// ```
  public func less(x : Float32, y : Float32) : Bool { x < y };

  /// Returns `x <= y`.
  ///
  /// Special cases:
  /// ```
  /// lessOrEqual(+0.0, -0.0) => true
  /// lessOrEqual(-0.0, +0.0) => true
  /// lessOrEqual(NaN, y)     => false for any Float32 y
  /// lessOrEqual(x, NaN)     => false for any Float32 x
  /// ```
  ///
  /// Example:
  /// ```motoko include=import
  /// assert Float32.lessOrEqual(0.123, 0.1234);
  /// ```
  public func lessOrEqual(x : Float32, y : Float32) : Bool { x <= y };

  /// Returns `x > y`.
  ///
  /// Special cases:
  /// ```
  /// greater(+0.0, -0.0) => false
  /// greater(-0.0, +0.0) => false
  /// greater(NaN, y)     => false for any Float32 y
  /// greater(x, NaN)     => false for any Float32 x
  /// ```
  ///
  /// Example:
  /// ```motoko include=import
  /// assert Float32.greater(Float32.pi, Float32.e);
  /// ```
  public func greater(x : Float32, y : Float32) : Bool { x > y };

  /// Returns `x >= y`.
  ///
  /// Special cases:
  /// ```
  /// greaterOrEqual(+0.0, -0.0) => true
  /// greaterOrEqual(-0.0, +0.0) => true
  /// greaterOrEqual(NaN, y)     => false for any Float32 y
  /// greaterOrEqual(x, NaN)     => false for any Float32 x
  /// ```
  ///
  /// Example:
  /// ```motoko include=import
  /// assert Float32.greaterOrEqual(0.1234, 0.123);
  /// ```
  public func greaterOrEqual(x : Float32, y : Float32) : Bool {
    x >= y
  };

  /// Defines a total order of `x` and `y` for use in sorting.
  ///
  /// Note: Using this operation to determine equality or inequality is discouraged for two reasons:
  /// * It does not consider numerical errors, see comment above. Use `equal(x, y, epsilon)` or
  ///   `notEqual(x, y, epsilon)` to test for equality or inequality, respectively.
  /// * `NaN` are here considered equal if their sign matches, which is different to the standard equality
  ///    by `==` or when using `equal()` or `notEqual()`.
  ///
  /// Total order:
  /// * negative NaN (no distinction between signalling and quiet negative NaN)
  /// * negative infinity
  /// * negative numbers (including negative subnormal numbers in standard order)
  /// * negative zero (`-0.0`)
  /// * positive zero (`+0.0`)
  /// * positive numbers (including positive subnormal numbers in standard order)
  /// * positive infinity
  /// * positive NaN (no distinction between signalling and quiet positive NaN)
  ///
  /// Example:
  /// ```motoko include=import
  /// assert Float32.compare(0.123, 0.1234) == #less;
  /// ```
  public func compare(x : Float32, y : Float32) : Order.Order {
    if (isNaN(x)) {
      if (isNegative(x)) {
        if (isNaN(y) and isNegative(y)) { #equal } else { #less }
      } else {
        if (isNaN(y) and not isNegative(y)) { #equal } else { #greater }
      }
    } else if (isNaN(y)) {
      if (isNegative(y)) {
        #greater
      } else {
        #less
      }
    } else {
      if (x == y) { #equal } else if (x < y) { #less } else {
        #greater
      }
    }
  };

  func isNegative(self : Float32) : Bool {
    copySign(1.0, self) < (0.0 : Float32)
  };

  /// Returns the negation of `x`, `-x`.
  ///
  /// Changes the sign bit for infinity.
  ///
  /// Special cases:
  /// ```
  /// neg(+inf) => -inf
  /// neg(-inf) => +inf
  /// neg(+NaN) => -NaN
  /// neg(-NaN) => +NaN
  /// neg(+0.0) => -0.0
  /// neg(-0.0) => +0.0
  /// ```
  ///
  /// Example:
  /// ```motoko include=import
  /// let epsilon = 1e-5 : Float32;
  /// assert Float32.equal(Float32.neg(1.23), -1.23, epsilon);
  /// ```
  public func neg(x : Float32) : Float32 { -x };

  /// Returns the sum of `x` and `y`, `x + y`.
  ///
  /// Note: Numerical errors may occur, see comment above.
  ///
  /// Special cases:
  /// ```
  /// add(+inf, y)    => +inf if y is any Float32 except -inf and NaN
  /// add(-inf, y)    => -inf if y is any Float32 except +inf and NaN
  /// add(+inf, -inf) => NaN
  /// add(NaN, y)     => NaN for any Float32 y
  /// ```
  /// The same cases apply commutatively, i.e. for `add(y, x)`.
  ///
  /// Example:
  /// ```motoko include=import
  /// let epsilon = 1e-5 : Float32;
  /// assert Float32.equal(Float32.add(1.23, 0.123), 1.353, epsilon);
  /// ```
  public func add(x : Float32, y : Float32) : Float32 { x + y };

  /// Returns the difference of `x` and `y`, `x - y`.
  ///
  /// Note: Numerical errors may occur, see comment above.
  ///
  /// Special cases:
  /// ```
  /// sub(+inf, y)    => +inf if y is any Float32 except +inf or NaN
  /// sub(-inf, y)    => -inf if y is any Float32 except -inf and NaN
  /// sub(x, +inf)    => -inf if x is any Float32 except +inf and NaN
  /// sub(x, -inf)    => +inf if x is any Float32 except -inf and NaN
  /// sub(+inf, +inf) => NaN
  /// sub(-inf, -inf) => NaN
  /// sub(NaN, y)     => NaN for any Float32 y
  /// sub(x, NaN)     => NaN for any Float32 x
  /// ```
  ///
  /// Example:
  /// ```motoko include=import
  /// let epsilon = 1e-5 : Float32;
  /// assert Float32.equal(Float32.sub(1.23, 0.123), 1.107, epsilon);
  /// ```
  public func sub(x : Float32, y : Float32) : Float32 { x - y };

  /// Returns the product of `x` and `y`, `x * y`.
  ///
  /// Note: Numerical errors may occur, see comment above.
  ///
  /// Special cases:
  /// ```
  /// mul(+inf, y) => +inf if y > 0.0
  /// mul(-inf, y) => -inf if y > 0.0
  /// mul(+inf, y) => -inf if y < 0.0
  /// mul(-inf, y) => +inf if y < 0.0
  /// mul(+inf, 0.0) => NaN
  /// mul(-inf, 0.0) => NaN
  /// mul(NaN, y) => NaN for any Float32 y
  /// ```
  /// The same cases apply commutatively, i.e. for `mul(y, x)`.
  ///
  /// Example:
  /// ```motoko include=import
  /// let epsilon = 1e-5 : Float32;
  /// assert Float32.equal(Float32.mul(1.23, 1e2), 123.0, epsilon);
  /// ```
  public func mul(x : Float32, y : Float32) : Float32 { x * y };

  /// Returns the division of `x` by `y`, `x / y`.
  ///
  /// Note: Numerical errors may occur, see comment above.
  ///
  /// Special cases:
  /// ```
  /// div(0.0, 0.0) => NaN
  /// div(x, 0.0)   => +inf for x > 0.0
  /// div(x, 0.0)   => -inf for x < 0.0
  /// div(x, +inf)  => 0.0 for any x except +inf, -inf, and NaN
  /// div(x, -inf)  => 0.0 for any x except +inf, -inf, and NaN
  /// div(+inf, y)  => +inf if y >= 0.0
  /// div(+inf, y)  => -inf if y < 0.0
  /// div(-inf, y)  => -inf if y >= 0.0
  /// div(-inf, y)  => +inf if y < 0.0
  /// div(NaN, y)   => NaN for any Float32 y
  /// div(x, NaN)   => NaN for any Float32 x
  /// ```
  ///
  /// Example:
  /// ```motoko include=import
  /// let epsilon = 1e-5 : Float32;
  /// assert Float32.equal(Float32.div(1.23, 1e2), 0.0123, epsilon);
  /// ```
  public func div(x : Float32, y : Float32) : Float32 { x / y };

  /// Returns the floating point division remainder `x % y`,
  /// which is defined as `x - trunc(x / y) * y`.
  ///
  /// Note: Numerical errors may occur, see comment above.
  ///
  /// Special cases:
  /// ```
  /// rem(0.0, 0.0) => NaN
  /// rem(x, +inf)  => x for any x except +inf, -inf, and NaN
  /// rem(x, -inf)  => x for any x except +inf, -inf, and NaN
  /// rem(+inf, y)  => NaN for any Float32 y
  /// rem(-inf, y)  => NaN for any Float32 y
  /// rem(NaN, y)   => NaN for any Float32 y
  /// rem(x, NaN)   => NaN for any Float32 x
  /// ```
  ///
  /// Example:
  /// ```motoko include=import
  /// let epsilon = 1e-5 : Float32;
  /// assert Float32.equal(Float32.rem(7.2, 2.3), 0.3, epsilon);
  /// ```
  public func rem(x : Float32, y : Float32) : Float32 {
    fromFloat(toFloat(x) % toFloat(y))
  };

  /// Returns `x` to the power of `y`, `x ** y`.
  ///
  /// Note: Numerical errors may occur, see comment above.
  ///
  /// Special cases:
  /// ```
  /// pow(+inf, y)    => +inf for any y > 0.0 including +inf
  /// pow(+inf, 0.0)  => 1.0
  /// pow(+inf, y)    => 0.0 for any y < 0.0 including -inf
  /// pow(x, +inf)    => +inf if x > 0.0 or x < 0.0
  /// pow(0.0, +inf)  => 0.0
  /// pow(x, -inf)    => 0.0 if x > 0.0 or x < 0.0
  /// pow(0.0, -inf)  => +inf
  /// pow(x, y)       => NaN if x < 0.0 and y is a non-integral Float32
  /// pow(NaN, y)     => NaN if y != 0.0
  /// pow(NaN, 0.0)   => 1.0
  /// pow(x, NaN)     => NaN for any Float32 x
  /// ```
  ///
  /// Example:
  /// ```motoko include=import
  /// let epsilon = 1e-5 : Float32;
  /// assert Float32.equal(Float32.pow(2.5, 2.0), 6.25, epsilon);
  /// ```
  public func pow(x : Float32, y : Float32) : Float32 { x ** y };

}
