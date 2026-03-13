/// Contains modules for working with tuples of different sizes.
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
    /// assert Tuple2.toText((1, "hello"), Nat.toText, func (x: Text): Text = x) == "(1, hello)";
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
    /// This is useful when you need to reuse the same toText conversion multiple times.
    ///
    /// ```motoko
    /// import { Tuple2 } "mo:core/Tuples";
    /// import Nat "mo:core/Nat";
    ///
    /// let tupleToText = Tuple2.makeToText<Nat, Text>(Nat.toText, func x = x);
    /// assert tupleToText((1, "hello")) == "(1, hello)";
    /// ```
    public func makeToText<A, B>(
      toTextA : (implicit : (toText : A -> Text)),
      toTextB : (implicit : (toText : B -> Text))
    ) : ((A, B)) -> Text = func t = toText(t, toTextA, toTextB);

    /// Creates an `equal` function for a tuple given `equal` functions for its elements.
    /// This is useful when you need to reuse the same equality comparison multiple times.
    ///
    /// ```motoko
    /// import { Tuple2 } "mo:core/Tuples";
    /// import Nat "mo:core/Nat";
    /// import Text "mo:core/Text";
    ///
    /// let tupleEqual = Tuple2.makeEqual(Nat.equal, Text.equal);
    /// assert tupleEqual((1, "hello"), (1, "hello"));
    /// ```
    public func makeEqual<A, B>(
      equalA : (implicit : (equal : (A, A) -> Bool)),
      equalB : (implicit : (equal : (B, B) -> Bool))
    ) : ((A, B), (A, B)) -> Bool = func(t1, t2) = equal(t1, t2, equalA, equalB);

    /// Creates a `compare` function for a tuple given `compare` functions for its elements.
    /// This is useful when you need to reuse the same comparison multiple times.
    ///
    /// ```motoko
    /// import { Tuple2 } "mo:core/Tuples";
    /// import Nat "mo:core/Nat";
    /// import Text "mo:core/Text";
    ///
    /// let tupleCompare = Tuple2.makeCompare(Nat.compare, Text.compare);
    /// assert tupleCompare((1, "hello"), (1, "world")) == #less;
    /// ```
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
    /// assert Tuple3.toText((1, "hello", 2), Nat.toText, func (x: Text): Text = x, Nat.toText) == "(1, hello, 2)";
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
    /// This is useful when you need to reuse the same toText conversion multiple times.
    ///
    /// ```motoko
    /// import { Tuple3 } "mo:core/Tuples";
    ///
    /// import Nat "mo:core/Nat";
    /// let toText = Tuple3.makeToText<Nat, Text, Nat>(Nat.toText, func x = x, Nat.toText);
    /// assert toText((1, "hello", 2)) == "(1, hello, 2)";
    /// ```
    public func makeToText<A, B, C>(
      toTextA : (implicit : (toText : A -> Text)),
      toTextB : (implicit : (toText : B -> Text)),
      toTextC : (implicit : (toText : C -> Text))
    ) : ((A, B, C)) -> Text = func t = toText(t, toTextA, toTextB, toTextC);

    /// Creates an `equal` function for a 3-tuple given `equal` functions for its elements.
    /// This is useful when you need to reuse the same equality comparison multiple times.
    ///
    /// ```motoko
    /// import { Tuple3 } "mo:core/Tuples";
    ///
    /// import Nat "mo:core/Nat";
    /// import Text "mo:core/Text";
    /// let equal = Tuple3.makeEqual(Nat.equal, Text.equal, Nat.equal);
    /// assert equal((1, "hello", 2), (1, "hello", 2));
    /// ```
    public func makeEqual<A, B, C>(
      equalA : (implicit : (equal : (A, A) -> Bool)),
      equalB : (implicit : (equal : (B, B) -> Bool)),
      equalC : (implicit : (equal : (C, C) -> Bool))
    ) : ((A, B, C), (A, B, C)) -> Bool = func(t1, t2) = equal(t1, t2, equalA, equalB, equalC);

    /// Creates a `compare` function for a 3-tuple given `compare` functions for its elements.
    /// This is useful when you need to reuse the same comparison multiple times.
    ///
    /// ```motoko
    /// import { Tuple3 } "mo:core/Tuples";
    ///
    /// import Nat "mo:core/Nat";
    /// import Text "mo:core/Text";
    /// let compare = Tuple3.makeCompare(Nat.compare, Text.compare, Nat.compare);
    /// assert compare((1, "hello", 2), (1, "world", 1)) == #less;
    /// ```
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
    /// assert Tuple4.toText((1, "hello", 2, 3), Nat.toText, func (x: Text): Text = x, Nat.toText, Nat.toText) == "(1, hello, 2, 3)";
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
    /// This is useful when you need to reuse the same toText conversion multiple times.
    ///
    /// ```motoko
    /// import { Tuple4 } "mo:core/Tuples";
    ///
    /// import Nat "mo:core/Nat";
    /// let toText = Tuple4.makeToText(Nat.toText, func (x: Text): Text = x, Nat.toText, Nat.toText);
    /// assert toText((1, "hello", 2, 3)) == "(1, hello, 2, 3)";
    /// ```
    public func makeToText<A, B, C, D>(
      toTextA : (implicit : (toText : A -> Text)),
      toTextB : (implicit : (toText : B -> Text)),
      toTextC : (implicit : (toText : C -> Text)),
      toTextD : (implicit : (toText : D -> Text))
    ) : ((A, B, C, D)) -> Text = func t = toText(t, toTextA, toTextB, toTextC, toTextD);

    /// Creates an `equal` function for a 4-tuple given `equal` functions for its elements.
    /// This is useful when you need to reuse the same equality comparison multiple times.
    ///
    /// ```motoko
    /// import { Tuple4 } "mo:core/Tuples";
    ///
    /// import Nat "mo:core/Nat";
    /// import Text "mo:core/Text";
    /// let equal = Tuple4.makeEqual(Nat.equal, Text.equal, Nat.equal, Nat.equal);
    /// assert equal((1, "hello", 2, 3), (1, "hello", 2, 3));
    /// ```
    public func makeEqual<A, B, C, D>(
      equalA : (implicit : (equal : (A, A) -> Bool)),
      equalB : (implicit : (equal : (B, B) -> Bool)),
      equalC : (implicit : (equal : (C, C) -> Bool)),
      equalD : (implicit : (equal : (D, D) -> Bool))
    ) : ((A, B, C, D), (A, B, C, D)) -> Bool = func(t1, t2) = equal(t1, t2, equalA, equalB, equalC, equalD);

    /// Creates a `compare` function for a 4-tuple given `compare` functions for its elements.
    /// This is useful when you need to reuse the same comparison multiple times.
    ///
    /// ```motoko
    /// import { Tuple4 } "mo:core/Tuples";
    ///
    /// import Nat "mo:core/Nat";
    /// import Text "mo:core/Text";
    /// let compare = Tuple4.makeCompare(Nat.compare, Text.compare, Nat.compare, Nat.compare);
    /// assert compare((1, "hello", 2, 3), (1, "world", 1, 3)) == #less;
    /// ```
    public func makeCompare<A, B, C, D>(
      compareA : (implicit : (compare : (A, A) -> Types.Order)),
      compareB : (implicit : (compare : (B, B) -> Types.Order)),
      compareC : (implicit : (compare : (C, C) -> Types.Order)),
      compareD : (implicit : (compare : (D, D) -> Types.Order))
    ) : ((A, B, C, D), (A, B, C, D)) -> Types.Order = func(t1, t2) = compare(t1, t2, compareA, compareB, compareC, compareD)
  }
}
