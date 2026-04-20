/// Allows accessing the Internet Computer's caller attributes.

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
      return null;
    };
    ?Prim.principalOfBlob(signer)
  };

  public func getUntrustedAttributes<system>() : ?(Principal, Blob) {
    let ?signer = getSigner<system>() else { return null };
    ?(signer, Prim.callerInfoData<system>())
  };

  public func getAttributes<system>() : ?Blob {
    let ?signer = getSigner<system>() else { return null };
    let ?trustedSigners = Runtime.envVar<system>("trusted_attribute_signers") else { return null };
    let trustedSignerList = trustedSigners.split(#char(','));

    if (trustedSignerList.any(func (t) { Principal.fromText(t) == signer })) {
      return ?Prim.callerInfoData<system>()
    };
    return null;
  };
}
