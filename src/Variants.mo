/// Derives `toText` implicit arguments for variant types.
///
/// With this module imported, the compiler builds a `toText` implicit argument for any variant
/// whose payload types have one, for example to print an array of variants or a record with a variant field.
/// A case without a payload has payload type `()`, so import `Unit` as well.
///
/// The compiler doesn't derive `equal` or `compare` for variants, because two values can be in different cases.
///
/// Import from the core package to use this module.
/// ```motoko name=import
/// import Variants "mo:core/Variants";
/// ```

import Text "Text";

module {

  /// Combines a variant's tag and the `toText` result of its payload the way `debug_show` prints them:
  /// `#tag` without a payload, `#tag(1, 2)` for a tuple payload, and `#tag(payload)` otherwise.
  ///
  /// The compiler uses this function to derive an implicit `toText` argument for a variant
  /// from the `toText` functions of its payload types, so you don't call it directly.
  /// It tells the payload kinds apart by their text: a payload that renders as `()` is dropped,
  /// and one that starts with `(` isn't wrapped in another pair of parentheses.
  ///
  /// Example:
  /// ```motoko include=import
  /// import Unit "mo:core/Unit";
  /// import Array "mo:core/Array";
  /// import Nat "mo:core/Nat";
  /// import Text "mo:core/Text";
  /// import { Tuple2 } "mo:core/Tuples";
  ///
  /// type Status = { #active; #suspended : Text; #banned : (Nat, Text) };
  /// let statuses : [Status] = [#active, #suspended "spam", #banned(3, "abuse")];
  /// assert statuses.toText() == "[#active, #suspended(spam), #banned(3, abuse)]";
  /// ```
  public func toText(__variant : (Text, () -> Text)) : Text {
    let (tag, payload) = __variant;
    let text = payload();
    if (text == "()") {
      "#" # tag
    } else if (text.startsWith(#char '(')) {
      "#" # tag # text
    } else {
      "#" # tag # "(" # text # ")"
    }
  };

}
