import Bench "mo:bench";
import PureList "../../../src/pure/List";
import Array "../../../src/Array";
import Nat "../../../src/Nat";
import Random "../../../src/Random";
import Runtime "../../../src/Runtime";

module {
  public func init() : Bench.Bench {
    let bench = Bench.Bench();
    bench.name("pure/List");
    bench.description("Benchmarks for the pure List module");
    bench.rows([
      "fromArray",
      "pushFront",
      "popFront",
      "map",
      "filter",
      "foldLeft",
      "concat",
      "reverse",
      "take",
      "drop",
      "merge",
      "find",
      "contains",
      "equal",
      "zip",
      "toArray"
    ]);
    bench.cols(["100", "1_000", "10_000"]);

    let rng = Random.seed(0xabcdef01);
    let a100 = Array.tabulate<Nat>(100, func(_) = rng.natRange(0, 1_000_000));
    let a1000 = Array.tabulate<Nat>(1_000, func(_) = rng.natRange(0, 1_000_000));
    let a10000 = Array.tabulate<Nat>(10_000, func(_) = rng.natRange(0, 1_000_000));

    let rngB = Random.seed(0x9e4c1d2a);
    let b100 = Array.tabulate<Nat>(100, func(_) = rngB.natRange(0, 1_000_000));
    let b1000 = Array.tabulate<Nat>(1_000, func(_) = rngB.natRange(0, 1_000_000));
    let b10000 = Array.tabulate<Nat>(10_000, func(_) = rngB.natRange(0, 1_000_000));

    let a100copy = Array.tabulate<Nat>(100, func(i) = a100[i]);
    let a1000copy = Array.tabulate<Nat>(1_000, func(i) = a1000[i]);
    let a10000copy = Array.tabulate<Nat>(10_000, func(i) = a10000[i]);

    let sorted100 = Array.sort(a100, Nat.compare);
    let sorted1000 = Array.sort(a1000, Nat.compare);
    let sorted10000 = Array.sort(a10000, Nat.compare);

    let pl100 = PureList.fromArray<Nat>(a100);
    let pl1000 = PureList.fromArray<Nat>(a1000);
    let pl10000 = PureList.fromArray<Nat>(a10000);

    let pl100copy = PureList.fromArray<Nat>(a100copy);
    let pl1000copy = PureList.fromArray<Nat>(a1000copy);
    let pl10000copy = PureList.fromArray<Nat>(a10000copy);

    let plB100 = PureList.fromArray<Nat>(b100);
    let plB1000 = PureList.fromArray<Nat>(b1000);
    let plB10000 = PureList.fromArray<Nat>(b10000);

    let half100 = 100 / 2;
    let half1000 = 1_000 / 2;
    let half10000 = 10_000 / 2;

    let mergeL100 = PureList.fromArray<Nat>(Array.tabulate(half100, func i = sorted100[i]));
    let mergeR100 = PureList.fromArray<Nat>(Array.tabulate(half100, func i = sorted100[half100 + i]));
    let mergeL1000 = PureList.fromArray<Nat>(Array.tabulate(half1000, func i = sorted1000[i]));
    let mergeR1000 = PureList.fromArray<Nat>(Array.tabulate(half1000, func i = sorted1000[half1000 + i]));
    let mergeL10000 = PureList.fromArray<Nat>(Array.tabulate(half10000, func i = sorted10000[i]));
    let mergeR10000 = PureList.fromArray<Nat>(Array.tabulate(half10000, func i = sorted10000[half10000 + i]));

    bench.runner(func(row, col) {
      let arr = switch col {
        case "100" a100;
        case "1_000" a1000;
        case "10_000" a10000;
        case _ Runtime.unreachable()
      };
      let pl = switch col {
        case "100" pl100;
        case "1_000" pl1000;
        case "10_000" pl10000;
        case _ Runtime.unreachable()
      };
      let plEq = switch col {
        case "100" pl100copy;
        case "1_000" pl1000copy;
        case "10_000" pl10000copy;
        case _ Runtime.unreachable()
      };
      let plB = switch col {
        case "100" plB100;
        case "1_000" plB1000;
        case "10_000" plB10000;
        case _ Runtime.unreachable()
      };
      let mergeL = switch col {
        case "100" mergeL100;
        case "1_000" mergeL1000;
        case "10_000" mergeL10000;
        case _ Runtime.unreachable()
      };
      let mergeR = switch col {
        case "100" mergeR100;
        case "1_000" mergeR1000;
        case "10_000" mergeR10000;
        case _ Runtime.unreachable()
      };
      let mid = arr.size() / 2;
      let key = arr[mid];
      switch row {
        case "fromArray" ignore PureList.fromArray<Nat>(arr);
        case "pushFront" {
          var list = PureList.empty<Nat>();
          for (x in arr.vals()) { list := PureList.pushFront<Nat>(list, x) }
        };
        case "popFront" {
          var list = pl;
          label l loop {
            let (item, rest) = PureList.popFront<Nat>(list);
            switch item { case null break l; case _ () };
            list := rest
          }
        };
        case "map" ignore PureList.map<Nat, Nat>(pl, func x = x + 1);
        case "filter" ignore PureList.filter<Nat>(pl, func x = x % 2 == 0);
        case "foldLeft" ignore PureList.foldLeft<Nat, Nat>(pl, 0, func (acc, x) = acc + x);
        case "concat" ignore PureList.concat<Nat>(pl, plB);
        case "reverse" ignore PureList.reverse<Nat>(pl);
        case "take" ignore PureList.take<Nat>(pl, mid);
        case "drop" ignore PureList.drop<Nat>(pl, mid);
        case "merge" ignore PureList.merge<Nat>(mergeL, mergeR, Nat.compare);
        case "find" ignore PureList.find<Nat>(pl, func x = x == key);
        case "contains" ignore PureList.contains<Nat>(pl, Nat.equal, key);
        case "equal" ignore PureList.equal<Nat>(pl, plEq, Nat.equal);
        case "zip" ignore PureList.zip<Nat, Nat>(pl, plB);
        case "toArray" ignore PureList.toArray<Nat>(pl);
        case _ Runtime.unreachable()
      }
    });
    bench
  }
}