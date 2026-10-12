/// Contains modules for working with tuples of different sizes.
///
/// `Tuple2`, `Tuple3`, and `Tuple4` provide `toText`, `equal`, and `compare` for tuples of their size.
/// The top-level `toText`, `equal`, and `compare` functions let the compiler derive these implicit
/// arguments for tuples of any size, as long as the element types have them.
/// The compiler prefers the faster `Tuple2`, `Tuple3`, and `Tuple4` functions when they're in scope:
/// on moc 2, importing this module is enough; on earlier versions, import them by name,
/// for example `import { Tuple2 } "mo:core/Tuples"`.
///
/// Usage example:
///
/// ```motoko
/// import { Tuple2; Tuple3 } "mo:core/Tuples";
/// import Bool "mo:core/Bool";
/// import Nat "mo:core/Nat";
///
/// let swapped = Tuple2.swap((1, "hello"));
/// assert swapped == ("hello", 1);
/// let text = Tuple3.toText((1, true, 3), Nat.toText, Bool.toText, Nat.toText);
/// assert text == "(1, true, 3)";
/// ```

import Types "Types";

module {

  /// Combines the `toText` results of a tuple's elements into `"(a, b, ...)"`.
  ///
  /// The compiler uses this function to derive an implicit `toText` argument for a tuple
  /// of any size from the `toText` functions of its element types, so you don't call it directly.
  ///
  /// ```motoko
  /// import Tuples "mo:core/Tuples";
  /// import Array "mo:core/Array";
  /// import Nat "mo:core/Nat";
  /// import Text "mo:core/Text";
  ///
  /// let rows = [(1, "a", 2, "b", 3)];
  /// assert rows.toText() == "[(1, a, 2, b, 3)]";
  /// ```
  public func toText(__tuple : [() -> Text]) : Text {
    var text = "(";
    var first = true;
    for (element in __tuple.values()) {
      if first { first := false } else { text #= ", " };
      text #= element()
    };
    text # ")"
  };

  /// Combines the `equal` results of two tuples' elements, stopping at the first unequal element.
  ///
  /// The compiler uses this function to derive an implicit `equal` argument for a tuple
  /// of any size from the `equal` functions of its element types, so you don't call it directly.
  ///
  /// ```motoko
  /// import Tuples "mo:core/Tuples";
  /// import Array "mo:core/Array";
  /// import Nat "mo:core/Nat";
  /// import Text "mo:core/Text";
  ///
  /// let rows = [(1, "a", 2, "b", 3)];
  /// assert rows.equal([(1, "a", 2, "b", 3)]);
  /// assert not rows.equal([(1, "a", 2, "b", 4)]);
  /// ```
  public func equal(__tuple : [() -> Bool]) : Bool {
    for (elementEqual in __tuple.values()) {
      if (not elementEqual()) return false
    };
    true
  };

  /// Combines the `compare` results of two tuples' elements lexicographically,
  /// stopping at the first element that is not `#equal`.
  ///
  /// The compiler uses this function to derive an implicit `compare` argument for a tuple
  /// of any size from the `compare` functions of its element types, so you don't call it directly.
  ///
  /// ```motoko
  /// import Tuples "mo:core/Tuples";
  /// import Array "mo:core/Array";
  /// import Nat "mo:core/Nat";
  /// import Text "mo:core/Text";
  ///
  /// let events = [(2026, 10, 12, 9, "standup"), (2026, 10, 12, 8, "coffee")];
  /// assert events.sort()[0] == (2026, 10, 12, 8, "coffee");
  /// ```
  public func compare(__tuple : [() -> Types.Order]) : Types.Order {
    for (elementCompare in __tuple.values()) {
      switch (elementCompare()) {
        case (#equal) {};
        case order { return order }
      }
    };
    #equal
  };

  public module Tuple2 {
    /// Swaps the elements of a tuple.
    ///
    /// ```motoko
    /// import { Tuple2 } "mo:core/Tuples";
    ///
    /// assert Tuple2.swap((1, "hello")) == ("hello", 1);
    /// ```
    public func swap<A, B>((a, b) : (A, B)) : (B, A) = (b, a);

    /// Creates a textual representation of a tuple for debugging purposes.
    ///
    /// ```motoko
    /// import { Tuple2 } "mo:core/Tuples";
    ///
    /// import Nat "mo:core/Nat";
    /// assert Tuple2.toText((1, "hello"), Nat.toText, func(x) : Text = x) == "(1, hello)";
    /// ```
    public func toText<A, B>(
      self : (A, B),
      toTextA : (implicit : (toText : A -> Text)),
      toTextB : (implicit : (toText : B -> Text))
    ) : Text = "(" # toTextA(self.0) # ", " # toTextB(self.1) # ")";

    /// Compares two tuples for equality.
    ///
    /// ```motoko
    /// import { Tuple2 } "mo:core/Tuples";
    ///
    /// import Nat "mo:core/Nat";
    /// import Text "mo:core/Text";
    /// assert Tuple2.equal((1, "hello"), (1, "hello"), Nat.equal, Text.equal);
    /// ```
    public func equal<A, B>(
      self : (A, B),
      other : (A, B),
      equalA : (implicit : (equal : (A, A) -> Bool)),
      equalB : (implicit : (equal : (B, B) -> Bool))
    ) : Bool = equalA(self.0, other.0) and equalB(self.1, other.1);

    /// Compares two tuples lexicographically.
    ///
    /// ```motoko
    /// import { Tuple2 } "mo:core/Tuples";
    ///
    /// import Nat "mo:core/Nat";
    /// import Text "mo:core/Text";
    /// assert Tuple2.compare((1, "hello"), (1, "world"), Nat.compare, Text.compare) == #less;
    /// assert Tuple2.compare((1, "hello"), (2, "hello"), Nat.compare, Text.compare) == #less;
    /// assert Tuple2.compare((1, "hello"), (1, "hello"), Nat.compare, Text.compare) == #equal;
    /// assert Tuple2.compare((2, "hello"), (1, "hello"), Nat.compare, Text.compare) == #greater;
    /// assert Tuple2.compare((1, "world"), (1, "hello"), Nat.compare, Text.compare) == #greater;
    /// ```
    public func compare<A, B>(
      self : (A, B),
      other : (A, B),
      compareA : (implicit : (compare : (A, A) -> Types.Order)),
      compareB : (implicit : (compare : (B, B) -> Types.Order))
    ) : Types.Order = switch (compareA(self.0, other.0)) {
      case (#equal) compareB(self.1, other.1);
      case order order
    };

    /// Creates a `toText` function for a tuple given `toText` functions for its elements.
    /// @deprecated Use `Tuple2.toText` instead. Omit the implicit argument to derive it, or pass `func t = t.toText()`.
    public func makeToText<A, B>(
      toTextA : (implicit : (toText : A -> Text)),
      toTextB : (implicit : (toText : B -> Text))
    ) : ((A, B)) -> Text = func t = toText(t, toTextA, toTextB);

    /// Creates an `equal` function for a tuple given `equal` functions for its elements.
    /// @deprecated Use `Tuple2.equal` instead. Omit the implicit argument to derive it, or pass `func(a, b) = a.equal(b)`.
    public func makeEqual<A, B>(
      equalA : (implicit : (equal : (A, A) -> Bool)),
      equalB : (implicit : (equal : (B, B) -> Bool))
    ) : ((A, B), (A, B)) -> Bool = func(t1, t2) = equal(t1, t2, equalA, equalB);

    /// Creates a `compare` function for a tuple given `compare` functions for its elements.
    /// @deprecated Use `Tuple2.compare` instead. Omit the implicit argument to derive it, or pass `func(a, b) = a.compare(b)`.
    public func makeCompare<A, B>(
      compareA : (implicit : (compare : (A, A) -> Types.Order)),
      compareB : (implicit : (compare : (B, B) -> Types.Order))
    ) : ((A, B), (A, B)) -> Types.Order = func(t1, t2) = compare(t1, t2, compareA, compareB)
  };

  public module Tuple3 {
    /// Creates a textual representation of a 3-tuple for debugging purposes.
    ///
    /// ```motoko
    /// import { Tuple3 } "mo:core/Tuples";
    ///
    /// import Nat "mo:core/Nat";
    /// assert Tuple3.toText((1, "hello", 2), Nat.toText, func(x) : Text = x, Nat.toText) == "(1, hello, 2)";
    /// ```
    public func toText<A, B, C>(
      self : (A, B, C),
      toTextA : (implicit : (toText : A -> Text)),
      toTextB : (implicit : (toText : B -> Text)),
      toTextC : (implicit : (toText : C -> Text))
    ) : Text = "(" # toTextA(self.0) # ", " # toTextB(self.1) # ", " # toTextC(self.2) # ")";

    /// Compares two 3-tuples for equality.
    ///
    /// ```motoko
    /// import { Tuple3 } "mo:core/Tuples";
    ///
    /// import Nat "mo:core/Nat";
    /// import Text "mo:core/Text";
    /// assert Tuple3.equal((1, "hello", 2), (1, "hello", 2), Nat.equal, Text.equal, Nat.equal);
    /// ```
    public func equal<A, B, C>(
      self : (A, B, C),
      other : (A, B, C),
      equalA : (implicit : (equal : (A, A) -> Bool)),
      equalB : (implicit : (equal : (B, B) -> Bool)),
      equalC : (implicit : (equal : (C, C) -> Bool))
    ) : Bool = equalA(self.0, other.0) and equalB(self.1, other.1) and equalC(self.2, other.2);

    /// Compares two 3-tuples lexicographically.
    ///
    /// ```motoko
    /// import { Tuple3 } "mo:core/Tuples";
    ///
    /// import Nat "mo:core/Nat";
    /// import Text "mo:core/Text";
    /// assert Tuple3.compare((1, "hello", 2), (1, "world", 1), Nat.compare, Text.compare, Nat.compare) == #less;
    /// assert Tuple3.compare((1, "hello", 2), (2, "hello", 2), Nat.compare, Text.compare, Nat.compare) == #less;
    /// assert Tuple3.compare((1, "hello", 2), (1, "hello", 2), Nat.compare, Text.compare, Nat.compare) == #equal;
    /// assert Tuple3.compare((2, "hello", 2), (1, "hello", 2), Nat.compare, Text.compare, Nat.compare) == #greater;
    /// ```
    public func compare<A, B, C>(
      self : (A, B, C),
      other : (A, B, C),
      compareA : (implicit : (compare : (A, A) -> Types.Order)),
      compareB : (implicit : (compare : (B, B) -> Types.Order)),
      compareC : (implicit : (compare : (C, C) -> Types.Order))
    ) : Types.Order = switch (compareA(self.0, other.0)) {
      case (#equal) {
        switch (compareB(self.1, other.1)) {
          case (#equal) compareC(self.2, other.2);
          case order order
        }
      };
      case order order
    };

    /// Creates a `toText` function for a 3-tuple given `toText` functions for its elements.
    /// @deprecated Use `Tuple3.toText` instead. Omit the implicit argument to derive it, or pass `func t = t.toText()`.
    public func makeToText<A, B, C>(
      toTextA : (implicit : (toText : A -> Text)),
      toTextB : (implicit : (toText : B -> Text)),
      toTextC : (implicit : (toText : C -> Text))
    ) : ((A, B, C)) -> Text = func t = toText(t, toTextA, toTextB, toTextC);

    /// Creates an `equal` function for a 3-tuple given `equal` functions for its elements.
    /// @deprecated Use `Tuple3.equal` instead. Omit the implicit argument to derive it, or pass `func(a, b) = a.equal(b)`.
    public func makeEqual<A, B, C>(
      equalA : (implicit : (equal : (A, A) -> Bool)),
      equalB : (implicit : (equal : (B, B) -> Bool)),
      equalC : (implicit : (equal : (C, C) -> Bool))
    ) : ((A, B, C), (A, B, C)) -> Bool = func(t1, t2) = equal(t1, t2, equalA, equalB, equalC);

    /// Creates a `compare` function for a 3-tuple given `compare` functions for its elements.
    /// @deprecated Use `Tuple3.compare` instead. Omit the implicit argument to derive it, or pass `func(a, b) = a.compare(b)`.
    public func makeCompare<A, B, C>(
      compareA : (implicit : (compare : (A, A) -> Types.Order)),
      compareB : (implicit : (compare : (B, B) -> Types.Order)),
      compareC : (implicit : (compare : (C, C) -> Types.Order))
    ) : ((A, B, C), (A, B, C)) -> Types.Order = func(t1, t2) = compare(t1, t2, compareA, compareB, compareC)
  };

  public module Tuple4 {
    /// Creates a textual representation of a 4-tuple for debugging purposes.
    ///
    /// ```motoko
    /// import { Tuple4 } "mo:core/Tuples";
    ///
    /// import Nat "mo:core/Nat";
    /// assert Tuple4.toText((1, "hello", 2, 3), Nat.toText, func(x) : Text = x, Nat.toText, Nat.toText) == "(1, hello, 2, 3)";
    /// ```
    public func toText<A, B, C, D>(
      self : (A, B, C, D),
      toTextA : (implicit : (toText : A -> Text)),
      toTextB : (implicit : (toText : B -> Text)),
      toTextC : (implicit : (toText : C -> Text)),
      toTextD : (implicit : (toText : D -> Text))
    ) : Text = "(" # toTextA(self.0) # ", " # toTextB(self.1) # ", " # toTextC(self.2) # ", " # toTextD(self.3) # ")";

    /// Compares two 4-tuples for equality.
    ///
    /// ```motoko
    /// import { Tuple4 } "mo:core/Tuples";
    ///
    /// import Nat "mo:core/Nat";
    /// import Text "mo:core/Text";
    /// assert Tuple4.equal((1, "hello", 2, 3), (1, "hello", 2, 3), Nat.equal, Text.equal, Nat.equal, Nat.equal);
    /// ```
    public func equal<A, B, C, D>(
      self : (A, B, C, D),
      other : (A, B, C, D),
      equalA : (implicit : (equal : (A, A) -> Bool)),
      equalB : (implicit : (equal : (B, B) -> Bool)),
      equalC : (implicit : (equal : (C, C) -> Bool)),
      equalD : (implicit : (equal : (D, D) -> Bool))
    ) : Bool = equalA(self.0, other.0) and equalB(self.1, other.1) and equalC(self.2, other.2) and equalD(self.3, other.3);

    /// Compares two 4-tuples lexicographically.
    ///
    /// ```motoko
    /// import { Tuple4 } "mo:core/Tuples";
    ///
    /// import Nat "mo:core/Nat";
    /// import Text "mo:core/Text";
    /// assert Tuple4.compare((1, "hello", 2, 3), (1, "world", 1, 3), Nat.compare, Text.compare, Nat.compare, Nat.compare) == #less;
    /// assert Tuple4.compare((1, "hello", 2, 3), (2, "hello", 2, 3), Nat.compare, Text.compare, Nat.compare, Nat.compare) == #less;
    /// assert Tuple4.compare((1, "hello", 2, 3), (1, "hello", 2, 3), Nat.compare, Text.compare, Nat.compare, Nat.compare) == #equal;
    /// assert Tuple4.compare((2, "hello", 2, 3), (1, "hello", 2, 3), Nat.compare, Text.compare, Nat.compare, Nat.compare) == #greater;
    /// ```
    public func compare<A, B, C, D>(
      self : (A, B, C, D),
      other : (A, B, C, D),
      compareA : (implicit : (compare : (A, A) -> Types.Order)),
      compareB : (implicit : (compare : (B, B) -> Types.Order)),
      compareC : (implicit : (compare : (C, C) -> Types.Order)),
      compareD : (implicit : (compare : (D, D) -> Types.Order))
    ) : Types.Order = switch (compareA(self.0, other.0)) {
      case (#equal) {
        switch (compareB(self.1, other.1)) {
          case (#equal) {
            switch (compareC(self.2, other.2)) {
              case (#equal) compareD(self.3, other.3);
              case order order
            }
          };
          case order order
        }
      };
      case order order
    };

    /// Creates a `toText` function for a 4-tuple given `toText` functions for its elements.
    /// @deprecated Use `Tuple4.toText` instead. Omit the implicit argument to derive it, or pass `func t = t.toText()`.
    public func makeToText<A, B, C, D>(
      toTextA : (implicit : (toText : A -> Text)),
      toTextB : (implicit : (toText : B -> Text)),
      toTextC : (implicit : (toText : C -> Text)),
      toTextD : (implicit : (toText : D -> Text))
    ) : ((A, B, C, D)) -> Text = func t = toText(t, toTextA, toTextB, toTextC, toTextD);

    /// Creates an `equal` function for a 4-tuple given `equal` functions for its elements.
    /// @deprecated Use `Tuple4.equal` instead. Omit the implicit argument to derive it, or pass `func(a, b) = a.equal(b)`.
    public func makeEqual<A, B, C, D>(
      equalA : (implicit : (equal : (A, A) -> Bool)),
      equalB : (implicit : (equal : (B, B) -> Bool)),
      equalC : (implicit : (equal : (C, C) -> Bool)),
      equalD : (implicit : (equal : (D, D) -> Bool))
    ) : ((A, B, C, D), (A, B, C, D)) -> Bool = func(t1, t2) = equal(t1, t2, equalA, equalB, equalC, equalD);

    /// Creates a `compare` function for a 4-tuple given `compare` functions for its elements.
    /// @deprecated Use `Tuple4.compare` instead. Omit the implicit argument to derive it, or pass `func(a, b) = a.compare(b)`.
    public func makeCompare<A, B, C, D>(
      compareA : (implicit : (compare : (A, A) -> Types.Order)),
      compareB : (implicit : (compare : (B, B) -> Types.Order)),
      compareC : (implicit : (compare : (C, C) -> Types.Order)),
      compareD : (implicit : (compare : (D, D) -> Types.Order))
    ) : ((A, B, C, D), (A, B, C, D)) -> Types.Order = func(t1, t2) = compare(t1, t2, compareA, compareB, compareC, compareD)
  }
}
