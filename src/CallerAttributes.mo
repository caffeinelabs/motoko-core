/// Allows accessing the Internet Computer's caller attributes.
/// TODO: link to official documentation, once it's available.

import Prim "mo:⛔";
import Test "Text";
import Iter "Iter";
import Runtime "Runtime";
import Principal "Principal";

module {

  func getSigner<system>() : ?Principal {
    let signer : Blob = Prim.callerInfoSigner<system>();
    // An empty signer means no attributes where sent in this call.
    if (signer.size() == 0) {
      return null
    };
    ?Prim.principalOfBlob(signer)
  };

  /// Returns the attribute data attached to the current call, but only
  /// when the signer is listed in the `trusted_attribute_signers`
  /// canister environment variable.
  ///
  /// Returns `null` if the current call carries no caller attributes, if
  /// the `trusted_attribute_signers` environment variable is not set, or
  /// if the signer is not contained in that list.
  ///
  /// `trusted_attribute_signers` is expected to be a comma-separated list
  /// of principal texts, for example:
  /// `"aaaaa-aa,un4fu-tqaaa-aaaab-qadjq-cai"`.
  ///
  /// ```motoko no-repl
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
    let ?signer = getSigner<system>() else { return null };
    let ?trustedSigners = Runtime.envVar<system>("trusted_attribute_signers") else {
      return null
    };
    let trustedSignerList = trustedSigners.split(#char(','));

    if (trustedSignerList.any(func(t) { Principal.fromText(t) == signer })) {
      return ?Prim.callerInfoData<system>()
    };
    return null
  };

  /// Returns the signer principal and the attribute data attached to the
  /// current call, without verifying that the signer is trusted.
  ///
  /// Returns `null` if the current call does not carry any caller
  /// attributes.
  ///
  /// The returned data is *not* validated by this function: the caller is
  /// responsible for deciding whether the signer should be trusted. Prefer
  /// `getAttributes` unless you need to implement a custom trust policy.
  ///
  /// ```motoko no-repl
  /// persistent actor {
  ///   public shared func handle() : async () {
  ///     switch (CallerAttributes.getUntrustedAttributes()) {
  ///       case (?(signer, data)) { /* inspect signer and data */ };
  ///       case null { /* no attributes on this call */ };
  ///     };
  ///   };
  /// }
  /// ```
  public func getUntrustedAttributes<system>() : ?(Principal, Blob) {
    let ?signer = getSigner<system>() else { return null };
    ?(signer, Prim.callerInfoData<system>())
  }
}
