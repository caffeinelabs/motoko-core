/// Typesafe nullable values.
///
/// Optional values can be seen as a typesafe `null`. A value of type `?Int` can
/// be constructed with either `null` or `?42`. The simplest way to get at the
/// contents of an optional is to use pattern matching:
///
/// ```motoko
/// let optionalInt1 : ?Int = ?42;
/// let optionalInt2 : ?Int = null;
///
/// let int1orZero : Int = switch optionalInt1 {
///   case null 0;
///   case (?int) int;
/// };
/// assert int1orZero == 42;
///
/// let int2orZero : Int = switch optionalInt2 {
///   case null 0;
///   case (?int) int;
/// };
/// assert int2orZero == 0;
/// ```
///
/// The functions in this module capture some common operations when working
/// with optionals that can be more succinct than using pattern matching.

import Runtime "Runtime";
import Types "Types";

module {

  /// Unwraps an optional value, with a default value, i.e. `get(?x, d) = x` and
  /// `get(null, d) = d`.
  public func get<T>(self : ?T, default : T) : T = switch self {
    case null { default };
    case (?x_) { x_ }
  };

  /// Unwraps an optional value using a function, or returns the default, i.e.
  /// `option(?x, f, d) = f x` and `option(null, f, d) = d`.
  public func getMapped<T, R>(self : ?T, f : T -> R, default : R) : R = switch self {
    case null { default };
    case (?x_) { f(x_) }
  };

  /// Applies a function to the wrapped value. `null`'s are left untouched.
  /// ```motoko
  /// import Option "mo:core/Option";
  /// assert Option.map<Nat, Nat>(?42, func x = x + 1) == ?43;
  /// assert Option.map<Nat, Nat>(null, func x = x + 1) == null;
  /// ```
  public func map<T, R>(self : ?T, f : T -> R) : ?R = switch self {
    case null { null };
    case (?x_) { ?f(x_) }
  };

  /// Applies a function to the wrapped value, but discards the result. Use
  /// `forEach` if you're only interested in the side effect `f` produces.
  ///
  /// ```motoko
  /// import Option "mo:core/Option";
  /// var counter : Nat = 0;
  /// Option.forEach(?5, func (x) { counter += x });
  /// assert counter == 5;
  /// Option.forEach(null, func (x) { counter += x });
  /// assert counter == 5;
  /// ```
  public func forEach<T>(self : ?T, f : T -> ()) = switch self {
    case null {};
    case (?x_) { f(x_) }
  };

  /// Applies an optional function to an optional value. Returns `null` if at
  /// least one of the arguments is `null`.
  public func apply<T, R>(self : ?T, f : ?(T -> R)) : ?R {
    switch (f, self) {
      case (?f_, ?x_) { ?f_(x_) };
      case (_, _) { null }
    }
  };

  /// Applies a function to an optional value. Returns `null` if the argument is
  /// `null`, or the function returns `null`.
  public func chain<T, R>(self : ?T, f : T -> ?R) : ?R {
    switch (self) {
      case (?x_) { f(x_) };
      case (null) { null }
    }
  };

  /// Given an optional optional value, removes one layer of optionality.
  /// ```motoko
  /// import Option "mo:core/Option";
  /// assert Option.flatten(?(?(42))) == ?42;
  /// assert Option.flatten(?(null)) == null;
  /// assert Option.flatten(null) == null;
  /// ```
  public func flatten<T>(self : ??T) : ?T {
    chain(self, func(x_ : ?T) : ?T = x_)
  };

  /// Creates an optional value from a definite value.
  /// ```motoko
  /// import Option "mo:core/Option";
  /// assert Option.some(42) == ?42;
  /// ```
  public func some<T>(self : T) : ?T = ?self; // ignore-self-type-check

  /// Returns true if the argument is not `null`, otherwise returns false.
  public func isSome(self : ?Any) : Bool {
    self != null
  };

  /// Returns true if the argument is `null`, otherwise returns false.
  public func isNull(self : ?Any) : Bool {
    self == null
  };

  /// Returns true if the optional arguments are equal according to the equality function provided, otherwise returns false.
  public func equal<T>(self : ?T, other : ?T, eq : (implicit : (equal : (T, T) -> Bool))) : Bool = switch (self, other) {
    case (null, null) { true };
    case (?x_, ?y_) { eq(x_, y_) };
    case (_, _) { false }
  };

  /// Compares two optional values using the provided comparison function.
  ///
  /// Returns:
  /// - `#equal` if both values are `null`,
  /// - `#less` if the first value is `null` and the second is not,
  /// - `#greater` if the first value is not `null` and the second is,
  /// - the result of the comparison function when both values are not `null`.
  public func compare<T>(self : ?T, other : ?T, compare : (implicit : (T, T) -> Types.Order)) : Types.Order = switch (self, other) {
    case (null, null) #equal;
    case (null, _) #less;
    case (_, null) #greater;
    case (?x_, ?y_) { compare(x_, y_) }
  };

  /// Unwraps an optional value, i.e. `unwrap(?x) = x`.
  ///
  /// `Option.unwrap()` fails if the argument is null. Consider using a `switch` or `do?` expression instead.
  public func unwrap<T>(self : ?T) : T = switch self {
    case null { Runtime.trap("Option.unwrap()") };
    case (?x_) { x_ }
  };

  /// Returns the textural representation of an optional value for debugging purposes.
  public func toText<T>(self : ?T, toText : (implicit : T -> Text)) : Text = switch self {
    case null { "null" };
    case (?x_) { "?" # toText(x_) }
  };

}
