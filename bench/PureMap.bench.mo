import Bench "mo:bench";

import Array "../src/Array";
import Nat "../src/Nat";
import Nat64 "../src/Nat64";
import Map "../src/pure/Map";
import VarArray "../src/VarArray";

module {
  public func init() : Bench.Bench {
    let bench = Bench.Bench();

    bench.name("pure/Map");
    bench.description("Red-black tree `pure/Map<Nat, Nat>` with `n` keys inserted in random order. Each operation is applied to all `n` keys (`add (existing)` overwrites the value of every key in the full map, `get` misses to `n` keys that are absent, `remove` to every second key, `remove (misses)` to `n` absent keys, each removed from the full map). `map` builds a structural copy (new nodes, keys and values shared), so its Heap value is the memory of the tree. `equal` and `compare` compare the map with an equal copy built separately.");

    bench.rows(["add", "add (existing)", "get (hits)", "get (misses)", "remove", "remove (misses)", "map", "equal", "compare"]);
    bench.cols(["100", "1000", "10000"]);

    // Distinct keys in a deterministic random order: an LCG permutation.
    func keys(n : Nat, offset : Nat) : [Nat] {
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
    let present = sizes.map(func(n) = keys(n, 0));
    let absent = sizes.map(func(n) = keys(n, 1));
    func build(ks : [Nat]) : Map.Map<Nat, Nat> {
      var m = Map.empty<Nat, Nat>();
      for (k in ks.values()) { m := m.add(Nat.compare, k, k) };
      m;
    };
    let built = present.map(build);
    let copies = present.map(build);
    var held : Any = ();

    bench.runner(
      func(row, col) {
        let ci = switch col { case "100" 0; case "1000" 1; case _ 2 };
        let m = built[ci];
        switch row {
          case "add" held := build(present[ci]);
          case "add (existing)" for (k in present[ci].values()) ignore m.add(Nat.compare, k, k + 1);
          case "get (hits)" for (k in present[ci].values()) ignore m.get(Nat.compare, k);
          case "get (misses)" for (k in absent[ci].values()) ignore m.get(Nat.compare, k);
          case "remove" {
            var r = m;
            var i = 0;
            for (k in present[ci].values()) {
              if (i % 2 == 0) r := r.remove(Nat.compare, k);
              i += 1;
            };
            held := r;
          };
          case "remove (misses)" for (k in absent[ci].values()) ignore m.remove(Nat.compare, k);
          case "map" held := m.map(func(_, v) = v);
          case "equal" ignore m.equal(copies[ci], Nat.compare, Nat.equal);
          case "compare" ignore m.compare(copies[ci], Nat.compare, Nat.compare);
          case _ {};
        };
      }
    );

    bench;
  };
};
