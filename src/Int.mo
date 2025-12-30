/// Signed integer numbers with infinite precision (also called big integers).
///
/// Most operations on integer numbers (e.g. addition) are available as built-in operators (e.g. `-1 + 1`).
/// This module provides equivalent functions and `Text` conversion.
///
/// Import from the core package to use this module.
/// ```motoko name=import
/// import Int "mo:core/Int";
/// ```

import Prim "mo:⛔";
import Char "Char";
import Runtime "Runtime";
import Iter "Iter";
import Order "Order";

module {

  /// Infinite precision signed integers.
  public type Int = Prim.Types.Int;

  /// Returns the absolute value of `x`.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert Int.abs(-12) == 12;
  /// ```
  public let abs : (x : Int) -> Nat = Prim.abs;

  /// Converts an integer number to its textual representation. Textual
  /// representation _do not_ contain underscores to represent commas.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert Int.toText(-1234) == "-1234";
  /// ```
  public func toText(self : Int) : Text {
    if (self == 0) {
      return "0"
    };

    let isNegative = self < 0;
    var int = if isNegative { -self } else { self };

    var text = "";
    let base = 10;

    while (int > 0) {
      let rem = int % base;
      text := (
        switch (rem) {
          case 0 { "0" };
          case 1 { "1" };
          case 2 { "2" };
          case 3 { "3" };
          case 4 { "4" };
          case 5 { "5" };
          case 6 { "6" };
          case 7 { "7" };
          case 8 { "8" };
          case 9 { "9" };
          case _ { Runtime.unreachable() }
        }
      ) # text;
      int := int / base
    };

    return if isNegative { "-" # text } else { text }
  };

  /// Creates a integer from its textual representation. Returns `null`
  /// if the input is not a valid integer.
  ///
  /// The textual representation _must not_ contain underscores but may
  /// begin with a '+' or '-' character.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert Int.fromText("-1234") == ?-1234;
  /// ```
  public func fromText(text : Text) : ?Int {
    if (text == "") {
      return null
    };
    var n = 0;
    var isFirst = true;
    var isNegative = false;
    var hasDigits = false;
    for (c in text.chars()) {
      if (isFirst and c == '+') {
        // Skip character
      } else if (isFirst and c == '-') {
        isNegative := true
      } else if (Char.isDigit(c)) {
        hasDigits := true;
        let charAsNat = Prim.nat32ToNat(Prim.charToNat32(c) -% Prim.charToNat32('0'));
        n := n * 10 + charAsNat
      } else {
        return null
      };
      isFirst := false
    };
    if (not hasDigits) {
      return null
    };
    ?(if (isNegative) { -n } else { n })
  };

  /// Creates a integer from its textual representation. Returns `null`
  /// if the input is not a valid integer.
  ///
  /// This functions is meant to be used with contextual-dot notation.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert "-1234".toInt() == ?-1234;
  /// ```
  public func toInt(self : Text) : ?Int {
    fromText(self)
  };

  /// Converts an integer to a natural number. Traps if the integer is negative.
  ///
  /// Example:
  /// ```motoko include=import
  /// import Debug "mo:core/Debug";
  /// assert Int.toNat(1234 : Int) == (1234 : Nat);
  /// ```
  public func toNat(self : Int) : Nat {
    if (self < 0) {
      Runtime.trap("Int.toNat(): negative input value")
    } else {
      abs(self)
    }
  };

  /// Converts a natural number to an integer.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert Int.fromNat(1234 : Nat) == (1234 : Int);
  /// ```
  public func fromNat(nat : Nat) : Int {
    nat : Int
  };

  /// Conversion to Float. May result in `Inf`.
  ///
  /// Note: The floating point number may be imprecise for large or small Int values.
  /// Returns `inf` if the integer is greater than the maximum floating point number.
  /// Returns `-inf` if the integer is less than the minimum floating point number.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert Int.toFloat(-123) == -123.0;
  /// ```
  public let toFloat : (self : Int) -> Float = Prim.intToFloat;

  /// Converts a signed integer with infinite precision to an 8-bit signed integer.
  ///
  /// Traps on overflow/underflow.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert Int.toInt8(123) == (123 : Int8);
  /// ```
  public let toInt8 : (self : Int) -> Int8 = Prim.intToInt8;

  /// Converts a signed integer with infinite precision to a 16-bit signed integer.
  ///
  /// Traps on overflow/underflow.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert Int.toInt16(12_345) == (12_345 : Int16);
  /// ```
  public let toInt16 : (self : Int) -> Int16 = Prim.intToInt16;

  /// Converts a signed integer with infinite precision to a 32-bit signed integer.
  ///
  /// Traps on overflow/underflow.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert Int.toInt32(123_456) == (123_456 : Int32);
  /// ```
  public let toInt32 : (self : Int) -> Int32 = Prim.intToInt32;

  /// Converts a signed integer with infinite precision to a 64-bit signed integer.
  ///
  /// Traps on overflow/underflow.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert Int.toInt64(123_456_789) == (123_456_789 : Int64);
  /// ```
  public let toInt64 : (self : Int) -> Int64 = Prim.intToInt64;

  /// Converts an 8-bit signed integer to a signed integer with infinite precision.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert Int.fromInt8(123 : Int8) == 123;
  /// ```
  public let fromInt8 : (x : Int8) -> Int = Prim.int8ToInt;

  /// Converts a 16-bit signed integer to a signed integer with infinite precision.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert Int.fromInt16(12_345 : Int16) == 12_345;
  /// ```
  public let fromInt16 : (x : Int16) -> Int = Prim.int16ToInt;

  /// Converts a 32-bit signed integer to a signed integer with infinite precision.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert Int.fromInt32(123_456 : Int32) == 123_456;
  /// ```
  public let fromInt32 : (x : Int32) -> Int = Prim.int32ToInt;

  /// Converts a 64-bit signed integer to a signed integer with infinite precision.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert Int.fromInt64(123_456_789 : Int64) == 123_456_789;
  /// ```
  public let fromInt64 : (x : Int64) -> Int = Prim.int64ToInt;

  /// Returns the minimum of `x` and `y`.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert Int.min(2, -3) == -3;
  /// ```
  public func min(x : Int, y : Int) : Int {
    if (x < y) { x } else { y }
  };

  /// Returns the maximum of `x` and `y`.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert Int.max(2, -3) == 2;
  /// ```
  public func max(x : Int, y : Int) : Int {
    if (x < y) { y } else { x }
  };

  /// Equality function for Int types.
  /// This is equivalent to `x == y`.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert Int.equal(-1, -1);
  /// ```
  ///
  /// Note: The reason why this function is defined in this library (in addition
  /// to the existing `==` operator) is so that you can use it as a function
  /// value to pass to a higher order function. It is not possible to use `==`
  /// as a function value at the moment.
  ///
  /// Example:
  /// ```motoko include=import
  /// let a : Int = 1;
  /// let b : Int = -1;
  /// assert not Int.equal(a, b);
  /// ```
  public func equal(x : Int, y : Int) : Bool { x == y };

  /// Inequality function for Int types.
  /// This is equivalent to `x != y`.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert Int.notEqual(-1, -2);
  /// ```
  ///
  /// Note: The reason why this function is defined in this library (in addition
  /// to the existing `!=` operator) is so that you can use it as a function
  /// value to pass to a higher order function. It is not possible to use `!=`
  /// as a function value at the moment.
  public func notEqual(x : Int, y : Int) : Bool { x != y };

  /// "Less than" function for Int types.
  /// This is equivalent to `x < y`.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert Int.less(-2, 1);
  /// ```
  ///
  /// Note: The reason why this function is defined in this library (in addition
  /// to the existing `<` operator) is so that you can use it as a function
  /// value to pass to a higher order function. It is not possible to use `<`
  /// as a function value at the moment.
  public func less(x : Int, y : Int) : Bool { x < y };

  /// "Less than or equal" function for Int types.
  /// This is equivalent to `x <= y`.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert Int.lessOrEqual(-2, 1);
  /// ```
  ///
  /// Note: The reason why this function is defined in this library (in addition
  /// to the existing `<=` operator) is so that you can use it as a function
  /// value to pass to a higher order function. It is not possible to use `<=`
  /// as a function value at the moment.
  public func lessOrEqual(x : Int, y : Int) : Bool { x <= y };

  /// "Greater than" function for Int types.
  /// This is equivalent to `x > y`.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert Int.greater(1, -2);
  /// ```
  ///
  /// Note: The reason why this function is defined in this library (in addition
  /// to the existing `>` operator) is so that you can use it as a function
  /// value to pass to a higher order function. It is not possible to use `>`
  /// as a function value at the moment.
  public func greater(x : Int, y : Int) : Bool { x > y };

  /// "Greater than or equal" function for Int types.
  /// This is equivalent to `x >= y`.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert Int.greaterOrEqual(1, -2);
  /// ```
  ///
  /// Note: The reason why this function is defined in this library (in addition
  /// to the existing `>=` operator) is so that you can use it as a function
  /// value to pass to a higher order function. It is not possible to use `>=`
  /// as a function value at the moment.
  public func greaterOrEqual(x : Int, y : Int) : Bool { x >= y };

  /// General-purpose comparison function for `Int`. Returns the `Order` (
  /// either `#less`, `#equal`, or `#greater`) of comparing `x` with `y`.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert Int.compare(-3, 2) == #less;
  /// ```
  ///
  /// This function can be used as value for a high order function, such as a sort function.
  ///
  /// Example:
  /// ```motoko include=import
  /// import Array "mo:core/Array";
  /// assert Array.sort([1, -2, -3], Int.compare) == [-3, -2, 1];
  /// ```
  public func compare(x : Int, y : Int) : Order.Order {
    if (x < y) { #less } else if (x == y) { #equal } else {
      #greater
    }
  };

  /// Returns the negation of `x`, `-x` .
  ///
  /// Example:
  /// ```motoko include=import
  /// assert Int.neg(123) == -123;
  /// ```
  ///
  /// Note: The reason why this function is defined in this library (in addition
  /// to the existing `-` operator) is so that you can use it as a function
  /// value to pass to a higher order function. It is not possible to use `-`
  /// as a function value at the moment.
  public func neg(x : Int) : Int { -x };

  /// Returns the sum of `x` and `y`, `x + y`.
  ///
  /// No overflow since `Int` has infinite precision.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert Int.add(1, -2) == -1;
  /// ```
  ///
  /// Note: The reason why this function is defined in this library (in addition
  /// to the existing `+` operator) is so that you can use it as a function
  /// value to pass to a higher order function. It is not possible to use `+`
  /// as a function value at the moment.
  ///
  /// Example:
  /// ```motoko include=import
  /// import Array "mo:core/Array";
  /// assert Array.foldLeft([1, -2, -3], 0, Int.add) == -4;
  /// ```
  public func add(x : Int, y : Int) : Int { x + y };

  /// Returns the difference of `x` and `y`, `x - y`.
  ///
  /// No overflow since `Int` has infinite precision.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert Int.sub(1, 2) == -1;
  /// ```
  ///
  /// Note: The reason why this function is defined in this library (in addition
  /// to the existing `-` operator) is so that you can use it as a function
  /// value to pass to a higher order function. It is not possible to use `-`
  /// as a function value at the moment.
  ///
  /// Example:
  /// ```motoko include=import
  /// import Array "mo:core/Array";
  /// assert Array.foldLeft([1, -2, -3], 0, Int.sub) == 4;
  /// ```
  public func sub(x : Int, y : Int) : Int { x - y };

  /// Returns the product of `x` and `y`, `x * y`.
  ///
  /// No overflow since `Int` has infinite precision.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert Int.mul(-2, 3) == -6;
  /// ```
  ///
  /// Note: The reason why this function is defined in this library (in addition
  /// to the existing `*` operator) is so that you can use it as a function
  /// value to pass to a higher order function. It is not possible to use `*`
  /// as a function value at the moment.
  ///
  /// Example:
  /// ```motoko include=import
  /// import Array "mo:core/Array";
  /// assert Array.foldLeft([1, -2, -3], 1, Int.mul) == 6;
  /// ```
  public func mul(x : Int, y : Int) : Int { x * y };

  /// Returns the signed integer division of `x` by `y`,  `x / y`.
  /// Rounds the quotient towards zero, which is the same as truncating the decimal places of the quotient.
  ///
  /// Traps when `y` is zero.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert Int.div(6, -2) == -3;
  /// ```
  ///
  /// Note: The reason why this function is defined in this library (in addition
  /// to the existing `/` operator) is so that you can use it as a function
  /// value to pass to a higher order function. It is not possible to use `/`
  /// as a function value at the moment.
  public func div(x : Int, y : Int) : Int { x / y };

  /// Returns the remainder of the signed integer division of `x` by `y`, `x % y`,
  /// which is defined as `x - x / y * y`.
  ///
  /// Traps when `y` is zero.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert Int.rem(6, -4) == 2;
  /// ```
  ///
  /// Note: The reason why this function is defined in this library (in addition
  /// to the existing `%` operator) is so that you can use it as a function
  /// value to pass to a higher order function. It is not possible to use `%`
  /// as a function value at the moment.
  public func rem(x : Int, y : Int) : Int { x % y };

  /// Returns `x` to the power of `y`, `x ** y`.
  ///
  /// Traps when `y` is negative or `y > 2 ** 32 - 1`.
  /// No overflow since `Int` has infinite precision.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert Int.pow(-2, 3) == -8;
  /// ```
  ///
  /// Note: The reason why this function is defined in this library (in addition
  /// to the existing `**` operator) is so that you can use it as a function
  /// value to pass to a higher order function. It is not possible to use `**`
  /// as a function value at the moment.
  public func pow(x : Int, y : Int) : Int { x ** y };

  /// Returns an iterator over the integers from the first to second argument with an exclusive upper bound.
  /// ```motoko include=import
  /// import Iter "mo:core/Iter";
  ///
  /// let iter = Int.range(1, 4);
  /// assert iter.next() == ?1;
  /// assert iter.next() == ?2;
  /// assert iter.next() == ?3;
  /// assert iter.next() == null;
  /// ```
  ///
  /// If the first argument is greater than the second argument, the function returns an empty iterator.
  /// ```motoko include=import
  /// import Iter "mo:core/Iter";
  ///
  /// let iter = Int.range(4, 1);
  /// assert iter.next() == null; // empty iterator
  /// ```
  public func range(fromInclusive : Int, toExclusive : Int) : Iter.Iter<Int> {
    if (fromInclusive >= toExclusive) {
      Iter.empty()
    } else {
      object {
        var n = fromInclusive;
        public func next() : ?Int {
          if (n >= toExclusive) {
            null
          } else {
            let result = n;
            n += 1;
            ?result
          }
        }
      }
    }
  };

  /// Returns an iterator over `Int` values from the first to second argument with an exclusive upper bound,
  /// incrementing by the specified step size.
  /// ```motoko include=import
  /// import Iter "mo:core/Iter";
  ///
  /// // Positive step
  /// let iter1 = Int.rangeBy(1, 7, 2);
  /// assert iter1.next() == ?1;
  /// assert iter1.next() == ?3;
  /// assert iter1.next() == ?5;
  /// assert iter1.next() == null;
  ///
  /// // Negative step
  /// let iter2 = Int.rangeBy(7, 1, -2);
  /// assert iter2.next() == ?7;
  /// assert iter2.next() == ?5;
  /// assert iter2.next() == ?3;
  /// assert iter2.next() == null;
  /// ```
  ///
  /// If `step` is 0 or if the iteration would not progress towards the bound, returns an empty iterator.
  public func rangeBy(fromInclusive : Int, toExclusive : Int, step : Int) : Iter.Iter<Int> {
    if (step == 0) {
      Iter.empty()
    } else if (step > 0 and fromInclusive < toExclusive) {
      object {
        var n = fromInclusive;
        public func next() : ?Int {
          if (n >= toExclusive) {
            null
          } else {
            let current = n;
            n += step;
            ?current
          }
        }
      }
    } else if (step < 0 and fromInclusive > toExclusive) {
      object {
        var n = fromInclusive;
        public func next() : ?Int {
          if (n <= toExclusive) {
            null
          } else {
            let current = n;
            n += step;
            ?current
          }
        }
      }
    } else {
      Iter.empty()
    }
  };

  /// Returns an iterator over the integers from the first to second argument, inclusive.
  /// ```motoko include=import
  /// import Iter "mo:core/Iter";
  ///
  /// let iter = Int.rangeInclusive(1, 3);
  /// assert iter.next() == ?1;
  /// assert iter.next() == ?2;
  /// assert iter.next() == ?3;
  /// assert iter.next() == null;
  /// ```
  ///
  /// If the first argument is greater than the second argument, the function returns an empty iterator.
  /// ```motoko include=import
  /// import Iter "mo:core/Iter";
  ///
  /// let iter = Int.rangeInclusive(3, 1);
  /// assert iter.next() == null; // empty iterator
  /// ```
  public func rangeInclusive(from : Int, to : Int) : Iter.Iter<Int> {
    if (from > to) {
      Iter.empty()
    } else {
      object {
        var n = from;
        public func next() : ?Int {
          if (n > to) {
            null
          } else {
            let result = n;
            n += 1;
            ?result
          }
        }
      }
    }
  };

  /// Returns an iterator over the integers from the first to second argument, inclusive,
  /// incrementing by the specified step size.
  /// ```motoko include=import
  /// import Iter "mo:core/Iter";
  ///
  /// // Positive step
  /// let iter1 = Int.rangeByInclusive(1, 7, 2);
  /// assert iter1.next() == ?1;
  /// assert iter1.next() == ?3;
  /// assert iter1.next() == ?5;
  /// assert iter1.next() == ?7;
  /// assert iter1.next() == null;
  ///
  /// // Negative step
  /// let iter2 = Int.rangeByInclusive(7, 1, -2);
  /// assert iter2.next() == ?7;
  /// assert iter2.next() == ?5;
  /// assert iter2.next() == ?3;
  /// assert iter2.next() == ?1;
  /// assert iter2.next() == null;
  /// ```
  ///
  /// If `from == to`, return an iterator which only returns that value.
  ///
  /// Otherwise, if `step` is 0 or if the iteration would not progress towards the bound, returns an empty iterator.
  public func rangeByInclusive(from : Int, to : Int, step : Int) : Iter.Iter<Int> {
    if (from == to) {
      Iter.singleton(from)
    } else if (step == 0) {
      Iter.empty()
    } else if (step > 0 and from < to) {
      object {
        var n = from;
        public func next() : ?Int {
          if (n >= to + 1) {
            null
          } else {
            let current = n;
            n += step;
            ?current
          }
        }
      }
    } else if (step < 0 and from > to) {
      object {
        var n = from;
        public func next() : ?Int {
          if (n + 1 <= to) {
            null
          } else {
            let current = n;
            n += step;
            ?current
          }
        }
      }
    } else {
      Iter.empty()
    }
  };

}
