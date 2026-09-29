import Bench "mo:bench";

import Array "../src/Array";
import Nat8 "../src/Nat8";
import Nat16 "../src/Nat16";
import Nat32 "../src/Nat32";
import Nat64 "../src/Nat64";
import Int8 "../src/Int8";
import Int16 "../src/Int16";
import Int32 "../src/Int32";
import Int64 "../src/Int64";
import Runtime "../src/Runtime";

module {
  public func init() : Bench.Bench {
    let bench = Bench.Bench();

    bench.name("Int conversions");
    bench.description("Compares performance of different Nat conversions");

    bench.rows([
      "Nat8.toNat16",
      "Nat8.toNat32",
      "Nat8.toNat64",
      "Nat16.toNat32",
      "Nat16.toNat64",
      "Nat32.toNat64",
      "Int8.toInt16",
      "Int8.toInt32",
      "Int8.toInt64",
      "Int16.toInt32",
      "Int16.toInt64",
      "Int32.toInt64",
      "Nat8.fromNat16",
      "Nat8.fromNat32",
      "Nat8.fromNat64",
      "Nat32.toNat16",
      "Nat64.toNat16",
      "Nat64.toNat32",
      "Int16.toInt8",
      "Int32.toInt8",
      "Int64.toInt8",
      "Int32.toInt16",
      "Int64.toInt16",
      "Int64.toInt32"
    ]);
    bench.cols([
      "1000"
    ]);

    let source8 = Array.tabulate(1000, func i = Nat8.fromIntWrap(i));
    let source16 = Array.tabulate(1000, func i = Nat16.fromIntWrap(i));
    let source32 = Array.tabulate(1000, func i = Nat32.fromIntWrap(i));
    let source64 = Array.tabulate(1000, func i = Nat64.fromIntWrap(i));
    let source8int = Array.tabulate(1000, func i = Int8.fromIntWrap(i));
    let source16int = Array.tabulate(1000, func i = Int16.fromIntWrap(i));
    let source32int = Array.tabulate(1000, func i = Int32.fromIntWrap(i));
    let source64int = Array.tabulate(1000, func i = Int64.fromIntWrap(i));
    let size = 1000;

    bench.runner(
      func(row, col) {
        switch row {
          case "Nat8.toNat16" {
            var i = 0;
            while (i < size) {
              ignore source8[i].toNat16();
              i += 1
            }
          };
          case "Nat8.toNat32" {
            var i = 0;
            while (i < size) {
              ignore source8[i].toNat32();
              i += 1
            }
          };
          case "Nat8.toNat64" {
            var i = 0;
            while (i < size) {
              ignore source8[i].toNat64();
              i += 1
            }
          };
          case "Nat16.toNat32" {
            var i = 0;
            while (i < size) {
              ignore source16[i].toNat32();
              i += 1
            }
          };
          case "Nat16.toNat64" {
            var i = 0;
            while (i < size) {
              ignore source16[i].toNat64();
              i += 1
            }
          };
          case "Nat32.toNat64" {
            var i = 0;
            while (i < size) {
              ignore source32[i].toNat64();
              i += 1
            }
          };
          case "Int8.toInt16" {
            var i = 0;
            while (i < size) {
              ignore source8int[i].toInt16();
              i += 1
            }
          };
          case "Int8.toInt32" {
            var i = 0;
            while (i < size) {
              ignore source8int[i].toInt32();
              i += 1
            }
          };
          case "Int8.toInt64" {
            var i = 0;
            while (i < size) {
              ignore source8int[i].toInt64();
              i += 1
            }
          };
          case "Int16.toInt32" {
            var i = 0;
            while (i < size) {
              ignore source16int[i].toInt32();
              i += 1
            }
          };
          case "Int16.toInt64" {
            var i = 0;
            while (i < size) {
              ignore source16int[i].toInt64();
              i += 1
            }
          };
          case "Int32.toInt64" {
            var i = 0;
            while (i < size) {
              ignore source32int[i].toInt64();
              i += 1
            }
          };
          case "Nat8.fromNat16" {
            var i = 0;
            while (i < size) {
              ignore Nat8.fromNat16(source16[i] >> 8);
              i += 1
            }
          };
          case "Nat8.fromNat32" {
            var i = 0;
            while (i < size) {
              ignore Nat8.fromNat32(source32[i] >> 24);
              i += 1
            }
          };
          case "Nat8.fromNat64" {
            var i = 0;
            while (i < size) {
              ignore Nat8.fromNat64(source64[i] >> 56);
              i += 1
            }
          };
          case "Nat32.toNat16" {
            var i = 0;
            while (i < size) {
              ignore (source32[i] >> 16).toNat16();
              i += 1
            }
          };
          case "Nat64.toNat16" {
            var i = 0;
            while (i < size) {
              ignore (source64[i] >> 48).toNat16();
              i += 1
            }
          };
          case "Nat64.toNat32" {
            var i = 0;
            while (i < size) {
              ignore (source64[i] >> 32).toNat32();
              i += 1
            }
          };
          case "Int16.toInt8" {
            var i = 0;
            while (i < size) {
              ignore (source16int[i] & 0x7f).toInt8();
              i += 1
            }
          };
          case "Int32.toInt8" {
            var i = 0;
            while (i < size) {
              ignore (source32int[i] & 0x7f).toInt8();
              i += 1
            }
          };
          case "Int64.toInt8" {
            var i = 0;
            while (i < size) {
              ignore (source64int[i] & 0x7f).toInt8();
              i += 1
            }
          };
          case "Int32.toInt16" {
            var i = 0;
            while (i < size) {
              ignore (source32int[i] & 0x7fff).toInt16();
              i += 1
            }
          };
          case "Int64.toInt16" {
            var i = 0;
            while (i < size) {
              ignore (source64int[i] & 0x7fff).toInt16();
              i += 1
            }
          };
          case "Int64.toInt32" {
            var i = 0;
            while (i < size) {
              ignore (source64int[i] & 0x7fffffff).toInt32();
              i += 1
            }
          };
          case _ Runtime.unreachable()
        }
      }
    );

    bench
  }
}
