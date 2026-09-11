/// Boolean type and operations.
///
/// Import from the core package to use this module.
/// ```motoko name=import
/// import Bool "mo:core/Bool";
/// ```
///
/// While boolean operators `_ and _` and `_ or _` are short-circuiting,
/// avoiding computation of the right argument when possible, the functions
/// `logicalAnd(_, _)` and `logicalOr(_, _)` are *strict* and will always evaluate *both*
/// of their arguments.
///
/// Example:
/// ```motoko include=import
/// let t = true;
/// let f = false;
///
/// // Short-circuiting AND
/// assert not (t and f);
///
/// // Short-circuiting OR
/// assert t or f;
/// ```

import Prim "mo:⛔";
import Iter "Iter";
import Order "Order";

module {

  /// Booleans with constants `true` and `false`.
  public type Bool = Prim.Types.Bool;

  /// Returns `a and b`.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert not true.logicalAnd(false);
  /// assert true.logicalAnd(true);
  /// ```
  public func logicalAnd(self : Bool, other : Bool) : Bool = self and other;

  /// Returns `a or b`.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert true.logicalOr(false);
  /// assert false.logicalOr(true);
  /// ```
  public func logicalOr(self : Bool, other : Bool) : Bool = self or other;

  /// Returns exclusive or of `a` and `b`, `a != b`.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert true.logicalXor(false);
  /// assert not true.logicalXor(true);
  /// assert not false.logicalXor(false);
  /// ```
  public func logicalXor(self : Bool, other : Bool) : Bool = self != other;

  /// Returns `not bool`.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert false.logicalNot();
  /// assert not true.logicalNot();
  /// ```
  public func logicalNot(self : Bool) : Bool = not self;

  /// Returns `a == b`.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert true.equal(true);
  /// assert not true.equal(false);
  /// ```
  public func equal(self : Bool, other : Bool) : Bool { self == other };

  /// Returns the ordering of `a` compared to `b`.
  /// Returns `#less` if `a` is `false` and `b` is `true`,
  /// `#equal` if `a` equals `b`,
  /// and `#greater` if `a` is `true` and `b` is `false`.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert true.compare(false) == #greater;
  /// assert true.compare(true) == #equal;
  /// assert false.compare(true) == #less;
  /// ```
  public func compare(self : Bool, other : Bool) : Order.Order {
    if (self == other) #equal else if self #greater else #less
  };

  /// Returns a text value which is either `"true"` or `"false"` depending on the input value.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert true.toText() == "true";
  /// assert false.toText() == "false";
  /// ```
  public func toText(self : Bool) : Text {
    if self "true" else "false"
  };

  /// Returns an iterator over all possible boolean values (`true` and `false`).
  ///
  /// Example:
  /// ```motoko include=import
  /// let iter = Bool.allValues();
  /// assert iter.next() == ?true;
  /// assert iter.next() == ?false;
  /// assert iter.next() == null;
  /// ```
  public func allValues() : Iter.Iter<Bool> = object {
    var state : ?Bool = ?true;
    public func next() : ?Bool {
      switch state {
        case (?true) { state := ?false; ?true };
        case (?false) { state := null; ?false };
        case null { null }
      }
    }
  };

}
