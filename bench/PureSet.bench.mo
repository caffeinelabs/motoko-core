import Bench "mo:bench";

import Array "../src/Array";
import Nat "../src/Nat";
import Nat64 "../src/Nat64";
import Set "../src/pure/Set";
import VarArray "../src/VarArray";

module {
  public func init() : Bench.Bench {
    let bench = Bench.Bench();

    bench.name("pure/Set");
    bench.description("Red-black tree `pure/Set<Nat>` with `n` elements inserted in random order. Each operation is applied to all `n` elements: `add` builds the set, `add (existing)` adds every element again to the full set, `contains (misses)` and `remove (misses)` use `n` absent elements, `remove` removes every second element. `equal`, `isSubset` and `compare` compare the set with an equal copy built separately.");

    bench.rows(["add", "add (existing)", "contains (hits)", "contains (misses)", "remove", "remove (misses)", "equal", "isSubset", "compare"]);
    bench.cols(["100", "1000", "10000"]);

    // Distinct elements in a deterministic random order: an LCG permutation.
    func elements(n : Nat, offset : Nat) : [Nat] {
      var x : Nat64 = 0x5eed;
      let a : [Nat] = Array.tabulate(n, func(i) = 2 * i + offset);
      let v = a.toVarArray<Nat>();
      var i = n;
      while (i > 1) {
        x := x *% 6364136223846793005 +% 1442695040888963407;
        let j = (x >> 33).toNat() % i;
        i -= 1;
        let t = v[i];
        v[i] := v[j];
        v[j] := t;
      };
      v.toArray();
    };

    let sizes = [100, 1000, 10000];
    let present = sizes.map(func(n) = elements(n, 0));
    let absent = sizes.map(func(n) = elements(n, 1));
    func build(es : [Nat]) : Set.Set<Nat> {
      var s = Set.empty<Nat>();
      for (e in es.values()) { s := s.add(Nat.compare, e) };
      s;
    };
    let built = present.map(build);
    let copies = present.map(build);
    var held : Any = ();

    bench.runner(
      func(row, col) {
        let ci = switch col { case "100" 0; case "1000" 1; case _ 2 };
        let s = built[ci];
        switch row {
          case "add" held := build(present[ci]);
          case "add (existing)" for (e in present[ci].values()) ignore s.add(Nat.compare, e);
          case "contains (hits)" for (e in present[ci].values()) ignore s.contains(Nat.compare, e);
          case "contains (misses)" for (e in absent[ci].values()) ignore s.contains(Nat.compare, e);
          case "remove" {
            var r = s;
            var i = 0;
            for (e in present[ci].values()) {
              if (i % 2 == 0) r := r.remove(Nat.compare, e);
              i += 1;
            };
            held := r;
          };
          case "remove (misses)" for (e in absent[ci].values()) ignore s.remove(Nat.compare, e);
          case "equal" ignore s.equal(copies[ci], Nat.compare);
          case "isSubset" ignore s.isSubset(copies[ci], Nat.compare);
          case "compare" ignore s.compare(copies[ci], Nat.compare);
          case _ {};
        };
      }
    );

    bench;
  };
};
