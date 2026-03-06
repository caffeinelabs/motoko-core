/// Natural numbers with infinite precision.
///
/// Most operations on natural numbers (e.g. addition) are available as built-in operators (e.g. `1 + 1`).
/// This module provides equivalent functions and `Text` conversion.
///
/// Import from the core package to use this module.
/// ```motoko name=import
/// import Nat "mo:core/Nat";
/// ```

import Int "Int";
import Prim "mo:⛔";
import Char "Char";
import Iter "Iter";
import Runtime "Runtime";
import Order "Order";

module {

  /// Infinite precision natural numbers.
  public type Nat = Prim.Types.Nat;

  /// Converts a natural number to its textual representation. Textual
  /// representation _do not_ contain underscores to represent commas.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert Nat.toText(1234) == "1234";
  /// ```
  public let toText : (self : Nat) -> Text = Int.toText;

  /// Creates a natural number from its textual representation. Returns `null`
  /// if the input is not a valid natural number.
  ///
  /// The textual representation _must not_ contain underscores.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert Nat.fromText("1234") == ?1234;
  /// ```
  public func fromText(text : Text) : ?Nat {
    if (text == "") {
      return null
    };
    var n = 0;
    for (c in text.chars()) {
      if (Char.isDigit(c)) {
        let charAsNat = Prim.nat32ToNat(Prim.charToNat32(c) -% Prim.charToNat32('0'));
        n := n * 10 + charAsNat
      } else {
        return null
      }
    };
    ?n
  };

  /// Creates a natural number from its textual representation. Returns `null`
  /// if the input is not a valid natural number.
  ///
  /// The textual representation _must not_ contain underscores.
  ///
  /// This functions is meant to be used with contextual-dot notation.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert "1234".toNat() == ?1234;
  /// ```
  public let toNat : (self : Text) -> ?Nat = fromText;

  /// Converts an integer to a natural number. Traps if the integer is negative.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert Nat.fromInt(1234) == (1234 : Nat);
  /// ```
  /// @deprecated M0235
  public func fromInt(int : Int) : Nat {
    if (int < 0) {
      Runtime.trap("Nat.fromInt(): negative input value")
    } else {
      Int.abs(int)
    }
  };

  /// Conversion to Float. May result in `Inf`.
  ///
  /// Note: The floating point number may be imprecise for large Nat values.
  /// Returns `inf` if the integer is greater than the maximum floating point number.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert Nat.toFloat(123) == 123.0;
  /// ```
  public let toFloat : (self : Nat) -> Float = Int.toFloat;

  /// Converts a natural number to an integer.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert Nat.toInt(1234) == 1234;
  /// ```
  public func toInt(self : Nat) : Int {
    self : Int
  };

  /// Converts an unsigned integer with infinite precision to an 8-bit unsigned integer.
  ///
  /// Traps on overflow.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert Nat.toNat8(123) == (123 : Nat8);
  /// ```
  public let toNat8 : (self : Nat) -> Nat8 = Prim.natToNat8;

  /// Converts an unsigned integer with infinite precision to a 16-bit unsigned integer.
  ///
  /// Traps on overflow.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert Nat.toNat16(123) == (123 : Nat16);
  /// ```
  public let toNat16 : (self : Nat) -> Nat16 = Prim.natToNat16;

  /// Converts an unsigned integer with infinite precision to a 32-bit unsigned integer.
  ///
  /// Traps on overflow.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert Nat.toNat32(123) == (123 : Nat32);
  /// ```
  public let toNat32 : (self : Nat) -> Nat32 = Prim.natToNat32;

  /// Converts an unsigned integer with infinite precision to a 64-bit unsigned integer.
  ///
  /// Traps on overflow.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert Nat.toNat64(123) == (123 : Nat64);
  /// ```
  public let toNat64 : (self : Nat) -> Nat64 = Prim.natToNat64;

  /// Converts an 8-bit unsigned integer to an unsigned integer with infinite precision.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert Nat.fromNat8(123) == (123 : Nat);
  /// ```
  public let fromNat8 : Nat8 -> Nat = Prim.nat8ToNat;

  /// Converts a 16-bit unsigned integer to an unsigned integer with infinite precision.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert Nat.fromNat16(123) == (123 : Nat);
  /// ```
  public let fromNat16 : Nat16 -> Nat = Prim.nat16ToNat;

  /// Converts a 32-bit unsigned integer to an unsigned integer with infinite precision.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert Nat.fromNat32(123) == (123 : Nat);
  /// ```
  public let fromNat32 : Nat32 -> Nat = Prim.nat32ToNat;

  /// Converts a 64-bit unsigned integer to an unsigned integer with infinite precision.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert Nat.fromNat64(123) == (123 : Nat);
  /// ```
  public let fromNat64 : Nat64 -> Nat = Prim.nat64ToNat;

  /// Returns the minimum of `x` and `y`.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert Nat.min(1, 2) == 1;
  /// ```
  public func min(x : Nat, y : Nat) : Nat {
    if (x < y) { x } else { y }
  };

  /// Returns the maximum of `x` and `y`.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert Nat.max(1, 2) == 2;
  /// ```
  public func max(x : Nat, y : Nat) : Nat {
    if (x < y) { y } else { x }
  };

  /// Equality function for Nat types.
  /// This is equivalent to `x == y`.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert Nat.equal(1, 1);
  /// assert 1 == 1;
  /// ```
  ///
  /// Note: The reason why this function is defined in this library (in addition
  /// to the existing `==` operator) is so that you can use it as a function
  /// value to pass to a higher order function. It is not possible to use `==`
  /// as a function value at the moment.
  ///
  /// Example:
  /// ```motoko include=import
  /// let a = 111;
  /// let b = 222;
  /// assert not Nat.equal(a, b);
  /// ```
  public func equal(x : Nat, y : Nat) : Bool { x == y };

  /// Inequality function for Nat types.
  /// This is equivalent to `x != y`.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert Nat.notEqual(1, 2);
  /// assert 1 != 2;
  /// ```
  ///
  /// Note: The reason why this function is defined in this library (in addition
  /// to the existing `!=` operator) is so that you can use it as a function
  /// value to pass to a higher order function. It is not possible to use `!=`
  /// as a function value at the moment.
  public func notEqual(x : Nat, y : Nat) : Bool { x != y };

  /// "Less than" function for Nat types.
  /// This is equivalent to `x < y`.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert Nat.less(1, 2);
  /// assert 1 < 2;
  /// ```
  ///
  /// Note: The reason why this function is defined in this library (in addition
  /// to the existing `<` operator) is so that you can use it as a function
  /// value to pass to a higher order function. It is not possible to use `<`
  /// as a function value at the moment.
  public func less(x : Nat, y : Nat) : Bool { x < y };

  /// "Less than or equal" function for Nat types.
  /// This is equivalent to `x <= y`.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert Nat.lessOrEqual(1, 2);
  /// assert 1 <= 2;
  /// ```
  ///
  /// Note: The reason why this function is defined in this library (in addition
  /// to the existing `<=` operator) is so that you can use it as a function
  /// value to pass to a higher order function. It is not possible to use `<=`
  /// as a function value at the moment.
  public func lessOrEqual(x : Nat, y : Nat) : Bool { x <= y };

  /// "Greater than" function for Nat types.
  /// This is equivalent to `x > y`.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert Nat.greater(2, 1);
  /// assert 2 > 1;
  /// ```
  ///
  /// Note: The reason why this function is defined in this library (in addition
  /// to the existing `>` operator) is so that you can use it as a function
  /// value to pass to a higher order function. It is not possible to use `>`
  /// as a function value at the moment.
  public func greater(x : Nat, y : Nat) : Bool { x > y };

  /// "Greater than or equal" function for Nat types.
  /// This is equivalent to `x >= y`.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert Nat.greaterOrEqual(2, 1);
  /// assert 2 >= 1;
  /// ```
  ///
  /// Note: The reason why this function is defined in this library (in addition
  /// to the existing `>=` operator) is so that you can use it as a function
  /// value to pass to a higher order function. It is not possible to use `>=`
  /// as a function value at the moment.
  public func greaterOrEqual(x : Nat, y : Nat) : Bool { x >= y };

  /// General purpose comparison function for `Nat`. Returns the `Order` (
  /// either `#less`, `#equal`, or `#greater`) of comparing `x` with `y`.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert Nat.compare(2, 3) == #less;
  /// ```
  ///
  /// This function can be used as value for a high order function, such as a sort function.
  ///
  /// Example:
  /// ```motoko include=import
  /// import Array "mo:core/Array";
  /// assert Array.sort([2, 3, 1], Nat.compare) == [1, 2, 3];
  /// ```
  public func compare(x : Nat, y : Nat) : Order.Order {
    if (x < y) { #less } else if (x == y) { #equal } else {
      #greater
    }
  };

  /// Returns the sum of `x` and `y`, `x + y`. This operator will never overflow
  /// because `Nat` is infinite precision.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert Nat.add(1, 2) == 3;
  /// assert 1 + 2 == 3;
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
  /// assert Array.foldLeft([2, 3, 1], 0, Nat.add) == 6;
  /// ```
  public func add(x : Nat, y : Nat) : Nat { x + y };

  /// Returns the difference of `x` and `y`, `x - y`.
  /// Traps on underflow below `0`.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert Nat.sub(2, 1) == 1;
  /// // Add a type annotation to avoid a warning about the subtraction
  /// assert 2 - 1 : Nat == 1;
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
  /// assert Array.foldLeft([2, 3, 1], 10, Nat.sub) == 4;
  /// ```
  public func sub(x : Nat, y : Nat) : Nat { x - y };

  /// Returns the product of `x` and `y`, `x * y`. This operator will never
  /// overflow because `Nat` is infinite precision.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert Nat.mul(2, 3) == 6;
  /// assert 2 * 3 == 6;
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
  /// assert Array.foldLeft([2, 3, 1], 1, Nat.mul) == 6;
  /// ```
  public func mul(x : Nat, y : Nat) : Nat { x * y };

  /// Returns the unsigned integer division of `x` by `y`,  `x / y`.
  /// Traps when `y` is zero.
  ///
  /// The quotient is rounded down, which is equivalent to truncating the
  /// decimal places of the quotient.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert Nat.div(6, 2) == 3;
  /// assert 6 / 2 == 3;
  /// ```
  ///
  /// Note: The reason why this function is defined in this library (in addition
  /// to the existing `/` operator) is so that you can use it as a function
  /// value to pass to a higher order function. It is not possible to use `/`
  /// as a function value at the moment.
  public func div(x : Nat, y : Nat) : Nat { x / y };

  /// Returns the remainder of unsigned integer division of `x` by `y`,  `x % y`.
  /// Traps when `y` is zero.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert Nat.rem(6, 4) == 2;
  /// assert 6 % 4 == 2;
  /// ```
  ///
  /// Note: The reason why this function is defined in this library (in addition
  /// to the existing `%` operator) is so that you can use it as a function
  /// value to pass to a higher order function. It is not possible to use `%`
  /// as a function value at the moment.
  public func rem(x : Nat, y : Nat) : Nat { x % y };

  /// Returns `x` to the power of `y`, `x ** y`. Traps when `y > 2^32`. This operator
  /// will never overflow because `Nat` is infinite precision.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert Nat.pow(2, 3) == 8;
  /// assert 2 ** 3 == 8;
  /// ```
  ///
  /// Note: The reason why this function is defined in this library (in addition
  /// to the existing `**` operator) is so that you can use it as a function
  /// value to pass to a higher order function. It is not possible to use `**`
  /// as a function value at the moment.
  public func pow(x : Nat, y : Nat) : Nat { x ** y };

  /// Returns the (conceptual) bitwise shift left of `x` by `y`, `x * (2 ** y)`.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert Nat.bitshiftLeft(1, 3) == 8;
  /// ```
  ///
  /// Note: The reason why this function is defined in this library (in absence
  /// of the `<<` operator) is so that you can use it as a function
  /// value to pass to a higher order function. While `Nat` is not defined in terms
  /// of bit patterns, conceptually it can be regarded as such, and the operation
  /// is provided as a high-performance version of the corresponding arithmetic
  /// rule.
  public let bitshiftLeft : (x : Nat, y : Nat32) -> Nat = Prim.shiftLeft;

  /// Returns the (conceptual) bitwise shift right of `x` by `y`, `x / (2 ** y)`.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert Nat.bitshiftRight(8, 3) == 1;
  /// ```
  ///
  /// Note: The reason why this function is defined in this library (in absence
  /// of the `>>` operator) is so that you can use it as a function
  /// value to pass to a higher order function. While `Nat` is not defined in terms
  /// of bit patterns, conceptually it can be regarded as such, and the operation
  /// is provided as a high-performance version of the corresponding arithmetic
  /// rule.
  public let bitshiftRight : (x : Nat, y : Nat32) -> Nat = Prim.shiftRight;

  /// Returns an iterator over `Nat` values from the first to second argument with an exclusive upper bound.
  /// ```motoko include=import
  /// import Iter "mo:core/Iter";
  ///
  /// let iter = Nat.range(1, 4);
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
  /// let iter = Nat.range(4, 1);
  /// assert iter.next() == null; // empty iterator
  /// ```
  public func range(fromInclusive : Nat, toExclusive : Nat) : Iter.Iter<Nat> {
    if (fromInclusive >= toExclusive) {
      Iter.empty()
    } else {
      object {
        var n = fromInclusive;
        public func next() : ?Nat {
          if (n >= toExclusive) {
            return null
          };
          let current = n;
          n += 1;
          ?current
        }
      }
    }
  };

  /// Returns an iterator over `Nat` values from the first to second argument with an exclusive upper bound,
  /// incrementing by the specified step size. The step can be positive or negative.
  /// ```motoko include=import
  /// import Iter "mo:core/Iter";
  ///
  /// // Positive step
  /// let iter1 = Nat.rangeBy(1, 7, 2);
  /// assert iter1.next() == ?1;
  /// assert iter1.next() == ?3;
  /// assert iter1.next() == ?5;
  /// assert iter1.next() == null;
  ///
  /// // Negative step
  /// let iter2 = Nat.rangeBy(7, 1, -2);
  /// assert iter2.next() == ?7;
  /// assert iter2.next() == ?5;
  /// assert iter2.next() == ?3;
  /// assert iter2.next() == null;
  /// ```
  ///
  /// If `step` is 0 or if the iteration would not progress towards the bound, returns an empty iterator.
  public func rangeBy(fromInclusive : Nat, toExclusive : Nat, step : Int) : Iter.Iter<Nat> {
    if (step == 0 or (step > 0 and fromInclusive >= toExclusive) or (step < 0 and fromInclusive <= toExclusive)) {
      Iter.empty()
    } else if (step > 0) {
      object {
        let stepMagnitude = Int.abs(step);
        var n = fromInclusive;
        public func next() : ?Nat {
          if (n >= toExclusive) {
            return null
          };
          let current = n;
          n += stepMagnitude;
          ?current
        }
      }
    } else {
      object {
        let stepMagnitude = Int.abs(step);
        var n = fromInclusive;
        public func next() : ?Nat {
          if (n <= toExclusive) {
            return null
          };
          let current = n;
          if (stepMagnitude > n) {
            n := 0
          } else {
            n -= stepMagnitude
          };
          ?current
        }
      }
    }
  };

  /// Returns an iterator over the integers from the first to second argument, inclusive.
  /// ```motoko include=import
  /// import Iter "mo:core/Iter";
  ///
  /// let iter = Nat.rangeInclusive(1, 3);
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
  /// let iter = Nat.rangeInclusive(3, 1);
  /// assert iter.next() == null; // empty iterator
  /// ```
  public func rangeInclusive(from : Nat, to : Nat) : Iter.Iter<Nat> {
    if (from > to) {
      Iter.empty()
    } else {
      object {
        var n = from;
        public func next() : ?Nat {
          if (n > to) {
            return null
          };
          let current = n;
          n += 1;
          ?current
        }
      }
    }
  };

  /// Returns an iterator over the integers from the first to second argument, inclusive,
  /// incrementing by the specified step size. The step can be positive or negative.
  /// ```motoko include=import
  /// import Iter "mo:core/Iter";
  ///
  /// // Positive step
  /// let iter1 = Nat.rangeByInclusive(1, 7, 2);
  /// assert iter1.next() == ?1;
  /// assert iter1.next() == ?3;
  /// assert iter1.next() == ?5;
  /// assert iter1.next() == ?7;
  /// assert iter1.next() == null;
  ///
  /// // Negative step
  /// let iter2 = Nat.rangeByInclusive(7, 1, -2);
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
  public func rangeByInclusive(from : Nat, to : Nat, step : Int) : Iter.Iter<Nat> {
    if (from == to) {
      Iter.singleton(from)
    } else if (step == 0 or (step > 0 and from > to) or (step < 0 and from < to)) {
      Iter.empty()
    } else if (step > 0) {
      object {
        let stepMagnitude = Int.abs(step);
        var n = from;
        public func next() : ?Nat {
          if (n > to) {
            return null
          };
          let current = n;
          n += stepMagnitude;
          ?current
        }
      }
    } else {
      object {
        let stepMagnitude = Int.abs(step);
        var n = from;
        var done = false;
        public func next() : ?Nat {
          if (done) {
            null
          } else {
            let current = n;
            if (n < to + stepMagnitude) {
              done := true
            } else {
              n -= stepMagnitude
            };
            ?current
          }
        }
      }
    }
  };

  /// Returns an infinite iterator over all possible `Nat` values.
  /// ```motoko include=import
  /// import Iter "mo:core/Iter";
  ///
  /// let iter = Nat.allValues();
  /// assert iter.next() == ?0;
  /// assert iter.next() == ?1;
  /// assert iter.next() == ?2;
  /// // ...
  /// ```
  public func allValues() : Iter.Iter<Nat> = object {
    var n = 0;
    public func next() : ?Nat {
      let current = n;
      n += 1;
      ?current
    }
  };

}
