import Bench "mo:bench";

import Array "../src/Array";
import List "../src/pure/List";

module {
  public func init() : Bench.Bench {
    let bench = Bench.Bench();

    bench.name("pure/List");
    bench.description("Immutable `pure/List<Nat>` of `n` elements `0, 1, ..., n - 1`. `concat (empty)` appends the empty list. `take (all)` and `split (all)` take `n` elements, `take (half)` and `split (half)` take `n / 2`. `filter (all)` keeps every element, `filter (second half)` the elements `>= n / 2`, `filter (even)` every second element, `filter (none)` no element.");

    bench.rows(["concat (empty)", "take (all)", "take (half)", "split (all)", "split (half)", "filter (all)", "filter (second half)", "filter (even)", "filter (none)"]);
    bench.cols(["100", "1000", "10000"]);

    let sizes = [100, 1000, 10000];
    let lists = sizes.map(func(n) = List.tabulate(n, func i = i));
    var held : Any = ();

    bench.runner(
      func(row, col) {
        let ci = switch col { case "100" 0; case "1000" 1; case _ 2 };
        let n = sizes[ci];
        let l = lists[ci];
        switch row {
          case "concat (empty)" held := l.concat(null);
          case "take (all)" held := l.take(n);
          case "take (half)" held := l.take(n / 2);
          case "split (all)" held := l.split(n);
          case "split (half)" held := l.split(n / 2);
          case "filter (all)" held := l.filter(func x = true);
          case "filter (second half)" held := l.filter(func x = x >= n / 2);
          case "filter (even)" held := l.filter(func x = x % 2 == 0);
          case "filter (none)" held := l.filter(func x = false);
          case _ {};
        };
      }
    );

    bench;
  };
};
