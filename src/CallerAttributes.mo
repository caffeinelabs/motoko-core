/// Allows accessing the Internet Computer's caller attributes.
/// TODO: link to official documentation, once it's available.

import Prim "mo:⛔";
import Text "Text";
import Iter "Iter";
import Runtime "Runtime";
import Principal "Principal";

module {
  /// Returns the attribute data attached to the current call, but only
  /// when the signer is listed in the `trusted_attribute_signers`
  /// canister environment variable.
  ///
  /// Returns `null` if the current call carries no caller attributes.
  /// Traps if the signer isn't trusted.
  ///
  /// `trusted_attribute_signers` is expected to be a comma-separated list
  /// of principal texts, for example:
  /// `"aaaaa-aa,un4fu-tqaaa-aaaab-qadjq-cai"`.
  ///
  /// ```motoko no-repl
  /// import CallerAttributes "mo:core/CallerAttributes";
  ///
  /// persistent actor {
  ///   public shared func handle() : async () {
  ///     switch (CallerAttributes.getAttributes()) {
  ///       case (?data) { /* attributes came from a trusted signer */ };
  ///       case null { /* no attributes, or signer is not trusted */ };
  ///     };
  ///   };
  /// }
  /// ```
  public func getAttributes<system>() : ?Blob {
    let signerBlob : Blob = Prim.callerInfoSigner<system>();
    // An empty signer means no attributes where sent in this call.
    if (signerBlob.size() == 0) {
      return null
    };
    let signer = Principal.fromBlob(signerBlob);
    let ?trustedSigners = Runtime.envVar<system>("trusted_attribute_signers") else {
      Runtime.trap("trusted_attribute_signers environment variable is not set")
    };
    if (trustedSigners.split(#char(',')).any(func(t) { Principal.fromText(t) == signer })) {
      return ?Prim.callerInfoData<system>()
    };
    Runtime.trap("untrusted attribute signer")
  }
}
