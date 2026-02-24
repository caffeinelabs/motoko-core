
/// Provides access to canister environment variables.
///
/// Example:
/// ```motoko no-repl
/// import Canister "mo:core/Canister";
/// let names = Canister.envVarNames();
/// let value = Canister.envVar(names[0]);
/// assert value != null;
/// ```
import Prim "mo:⛔";

module {
  /// Returns the names of all canister environment variables.
  ///
  /// Example:
  /// ```motoko no-repl
  /// let names = Canister.envVarNames();
  /// ```
  public func envVarNames<system>() : [Text] {
    return Prim.envVarNames<system>()
  };

  /// Returns the value of the canister environment variable named `name`, or null if not set.
  ///
  /// Example:
  /// ```motoko no-repl
  /// let value = Canister.envVar("MY_ENV_VAR");
  /// if (value != null) {
  ///   // use value
  /// } else {
  ///   // variable not set
  /// }
  /// ```
  public func envVar<system>(name : Text) : ?Text {
    return Prim.envVar<system>(name)
  }
}
