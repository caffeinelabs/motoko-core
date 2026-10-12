/// Derives `toText`, `equal`, and `compare` implicit arguments for record types.
///
/// With this module imported, the compiler builds these implicit arguments for any record
/// whose field types have them, for example to sort an array of records or to use a record
/// as a `Map` key. Fields are visited in lexicographic order of their names, not in the order
/// the record type declares them.
///
/// A named type that is a record, such as `Map.Map` or `List.List`, matches too. Import its module
/// so that its own `toText`, `equal`, and `compare` take precedence over the field-by-field derivation.
///
/// Import from the core package to use this module.
/// ```motoko name=import
/// import Records "mo:core/Records";
/// ```

import Types "Types";

module {

  /// Combines the `toText` results of a record's fields into `"{a = ...; b = ...}"`.
  ///
  /// The compiler uses this function to derive an implicit `toText` argument for a record
  /// from the `toText` functions of its field types, so you don't call it directly.
  ///
  /// ```motoko include=import
  /// import Array "mo:core/Array";
  /// import Nat "mo:core/Nat";
  /// import Text "mo:core/Text";
  ///
  /// let people = [{ name = "Alice"; age = 30 }];
  /// assert people.toText() == "[{age = 30; name = Alice}]";
  /// ```
  public func toText(__record : [(Text, () -> Text)]) : Text {
    var text = "{";
    var first = true;
    for ((field, value) in __record.values()) {
      if first { first := false } else { text #= "; " };
      text #= field # " = " # value()
    };
    text # "}"
  };

  /// Combines the `equal` results of two records' fields, stopping at the first unequal field.
  ///
  /// The compiler uses this function to derive an implicit `equal` argument for a record
  /// from the `equal` functions of its field types, so you don't call it directly.
  ///
  /// ```motoko include=import
  /// import Array "mo:core/Array";
  /// import Nat "mo:core/Nat";
  /// import Text "mo:core/Text";
  ///
  /// let people = [{ name = "Alice"; age = 30 }];
  /// assert people.equal([{ name = "Alice"; age = 30 }]);
  /// assert not people.equal([{ name = "Alice"; age = 31 }]);
  /// ```
  public func equal(__record : [(Text, () -> Bool)]) : Bool {
    for ((_, fieldEqual) in __record.values()) {
      if (not fieldEqual()) return false
    };
    true
  };

  /// Combines the `compare` results of two records' fields lexicographically,
  /// stopping at the first field that is not `#equal`.
  ///
  /// The compiler uses this function to derive an implicit `compare` argument for a record
  /// from the `compare` functions of its field types, so you don't call it directly.
  /// Fields are compared in lexicographic order of their names, so `age` comes before `name`.
  ///
  /// ```motoko include=import
  /// import Array "mo:core/Array";
  /// import Map "mo:core/Map";
  /// import Nat "mo:core/Nat";
  /// import Text "mo:core/Text";
  ///
  /// let people = [{ name = "Carol"; age = 30 }, { name = "Bob"; age = 25 }];
  /// assert people.sort()[0] == { name = "Bob"; age = 25 };
  ///
  /// let emails = Map.empty<{ name : Text; age : Nat }, Text>();
  /// emails.add({ name = "Bob"; age = 25 }, "bob@example.com");
  /// assert emails.get({ name = "Bob"; age = 25 }) == ?"bob@example.com";
  /// ```
  public func compare(__record : [(Text, () -> Types.Order)]) : Types.Order {
    for ((_, fieldCompare) in __record.values()) {
      switch (fieldCompare()) {
        case (#equal) {};
        case order { return order }
      }
    };
    #equal
  };

}
