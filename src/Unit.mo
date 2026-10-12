/// Functions for the unit type `()`, whose only value is `()`.
///
/// With this module imported, the compiler finds `toText`, `equal`, and `compare` implicit
/// arguments for `()`, for example for the payload of a variant case without one.
///
/// Import from the core package to use this module.
/// ```motoko name=import
/// import Unit "mo:core/Unit";
/// ```

import Types "Types";

module {

  /// Returns `"()"`, the textual representation of the unit value.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert ().toText() == "()";
  /// ```
  public func toText(self : ()) : Text = debug_show self;

  /// Returns `true`, because `()` is the only unit value.
  ///
  /// Unlike most `equal` functions, it doesn't take `self`:
  /// in `().equal(())`, the argument `(())` is the same as passing no argument.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert Unit.equal((), ());
  /// ```
  public func equal(_ : (), _ : ()) : Bool = true;

  /// Returns `#equal`, because `()` is the only unit value.
  ///
  /// Unlike most `compare` functions, it doesn't take `self`:
  /// in `().compare(())`, the argument `(())` is the same as passing no argument.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert Unit.compare((), ()) == #equal;
  /// ```
  public func compare(_ : (), _ : ()) : Types.Order = #equal;

}
