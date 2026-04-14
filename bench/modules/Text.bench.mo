import Bench "mo:bench";

import Array "../../src/Array";
import Char "../../src/Char";
import Nat32 "../../src/Nat32";
import Runtime "../../src/Runtime";
import Text "../../src/Text";

module {
  public func init() : Bench.Bench {
    let bench = Bench.Bench();

    bench.name("Text");
    bench.description("Text operations across character lengths.");
    bench.rows([
      "size",
      "compare",
      "equal",
      "concat",
      "contains",
      "split",
      "replace",
      "map",
      "foldLeft",
      "reverse",
      "toArray",
      "fromArray",
      "encodeUtf8",
      "decodeUtf8",
      "toLower",
      "join"
    ]);
    bench.cols([
      "100",
      "1_000",
      "10_000"
    ]);

    let chars100 = Array.tabulate<Char>(100, func(i) = Char.fromNat32(Nat32.fromNat(97 + i % 26)));
    let chars1k = Array.tabulate<Char>(1_000, func(i) = Char.fromNat32(Nat32.fromNat(97 + i % 26)));
    let chars10k = Array.tabulate<Char>(10_000, func(i) = Char.fromNat32(Nat32.fromNat(97 + i % 26)));
    let text100 = Text.fromArray(chars100);
    let text1k = Text.fromArray(chars1k);
    let text10k = Text.fromArray(chars10k);
    let blob100 = Text.encodeUtf8(text100);
    let blob1k = Text.encodeUtf8(text1k);
    let blob10k = Text.encodeUtf8(text10k);
    let parts100 = Array.tabulate<Text>(10, func(i) = Text.fromArray(Array.tabulate<Char>(10, func(j) = chars100[i * 10 + j])));
    let parts1k = Array.tabulate<Text>(10, func(i) = Text.fromArray(Array.tabulate<Char>(100, func(j) = chars1k[i * 100 + j])));
    let parts10k = Array.tabulate<Text>(10, func(i) = Text.fromArray(Array.tabulate<Char>(1_000, func(j) = chars10k[i * 1_000 + j])));
    let texts = [text100, text1k, text10k];
    let charses = [chars100, chars1k, chars10k];
    let blobs = [blob100, blob1k, blob10k];
    let partses = [parts100, parts1k, parts10k];

    func colIdx(col : Text) : Nat {
      switch col {
        case "100" { 0 };
        case "1_000" { 1 };
        case "10_000" { 2 };
        case _ { Runtime.unreachable() }
      }
    };

    bench.runner(
      func(row, col) {
        let i = colIdx(col);
        let text = texts[i];
        let chars = charses[i];
        let blob = blobs[i];
        let parts = partses[i];
        switch row {
          case "size" { ignore Text.size(text) };
          case "compare" { ignore Text.compare(text, text) };
          case "equal" { ignore Text.equal(text, text) };
          case "concat" { ignore Text.concat(text, text) };
          case "contains" { ignore Text.contains(text, #text "ab") };
          case "split" {
            for (part in Text.split(text, #char 'a')) {
              ignore part
            }
          };
          case "replace" { ignore Text.replace(text, #char 'a', "x") };
          case "map" { ignore Text.map(text, func(c) = c) };
          case "foldLeft" { ignore Text.foldLeft(text, 0, func(a, _) = a + 1) };
          case "reverse" { ignore Text.reverse(text) };
          case "toArray" { ignore Text.toArray(text) };
          case "fromArray" { ignore Text.fromArray(chars) };
          case "encodeUtf8" { ignore Text.encodeUtf8(text) };
          case "decodeUtf8" { ignore Text.decodeUtf8(blob) };
          case "toLower" { ignore Text.toLower(text) };
          case "join" { ignore Text.join(parts.vals(), "|") };
          case _ { Runtime.unreachable() }
        }
      }
    );

    bench
  }
}