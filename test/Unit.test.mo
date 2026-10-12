import Unit "../src/Unit";
import Array "../src/Array";
import Nat "../src/Nat";
import { Tuple2 } "../src/Tuples";
import { suite; test } "mo:test";

suite(
  "Unit",
  func() {
    test(
      "toText",
      func() {
        assert ().toText() == "()"
      }
    );

    test(
      "equal and compare",
      func() {
        assert Unit.equal((), ());
        assert Unit.compare((), ()) == #equal
      }
    );

    test(
      "derived for tuples with a unit element",
      func() {
        let pairs = [(2, ()), (1, ())];
        assert pairs.toText() == "[(2, ()), (1, ())]";
        assert pairs.equal([(2, ()), (1, ())]);
        assert not pairs.equal([(1, ()), (2, ())]);
        assert pairs.sort().toText() == "[(1, ()), (2, ())]"
      }
    )
  }
)
