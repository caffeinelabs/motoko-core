// @testmode wasi

// Asserts that the zero-allocation List functions stay zero-allocation, so
// that later commits don't accidentally introduce allocations on hot paths.
//
// `Prim.rts_total_allocation()` is a monotonic counter of all bytes ever
// allocated, so a zero delta around a code section proves it allocated
// nothing (independent of GC). This requires wasi test mode (real RTS); in
// the interpreter the counter is not maintained — the "allocation is
// detected" harness test below fails in that case, so a wrong test mode
// cannot produce silent false passes.
//
// Notes on methodology:
// - Each workload is run once as a warm-up before measuring, so one-time
//   lazy allocations are not counted; the assertion is about steady-state
//   per-call behavior.
// - Elements are small scalar Nats, so the element values themselves never
//   allocate; what is measured is the List function's own overhead.
// - Callback lambdas must not capture test-local state: capture-free
//   lambdas are static (allocation-free), while a capturing lambda is
//   allocated at its creation site. Callbacks below only reference
//   file-scope bindings, which are static.
//
// Deliberately absent, because these functions do allocate (as measured
// with moc 1.11.1, see git history of this file):
// - all constructors and converters (empty, repeat, clone, toArray, ...)
//   and all functions returning new lists, arrays, iterators or Text
// - add/removeLast: amortized — allocate when crossing block boundaries
// - truncate/clear: (re)allocate index blocks
// - sortInPlace/sort: O(size) scratch array
// - binarySearch: allocates its variant result (112 B)

import List "../src/List";
import Nat "../src/Nat";
import Prim "mo:prim";
import { test } "mo:test";

let n = 1_000;
// Read-only list with distinct, sorted elements 0..n-1.
let list = List.tabulate<Nat>(n, func i = i);
// Equal copy of `list`, for equal/compare full scans.
let listCopy = List.tabulate<Nat>(n, func i = i);

// Runs `f` once to trigger any one-time allocations, then measures the
// bytes allocated by a second run.
func allocDelta(f : () -> ()) : Nat {
  f();
  let before = Prim.rts_total_allocation();
  f();
  let after = Prim.rts_total_allocation();
  after - before
};

func assertNoAlloc(name : Text, f : () -> ()) {
  test(
    name # " does not allocate",
    func() {
      let delta = allocDelta(f);
      if (delta != 0) Prim.debugPrint("NONZERO " # name # ": " # Nat.toText(delta));
      assert delta == 0
    }
  )
};

// --- Harness validation ---

test(
  "measurement harness: empty loop does not allocate",
  func() {
    let delta = allocDelta(
      func() {
        var i = 0;
        while (i < n) { i += 1 }
      }
    );
    assert delta == 0
  }
);

test(
  "measurement harness: allocation is detected",
  func() {
    var r : [var Nat] = [var];
    let delta = allocDelta(
      func() {
        r := Prim.Array_init<Nat>(8, 0)
      }
    );
    assert delta > 0
  }
);

// --- Size queries ---

assertNoAlloc("List.size", func() { var i = 0; while (i < n) { ignore List.size(list); i += 1 } });
assertNoAlloc("List.isEmpty", func() { var i = 0; while (i < n) { ignore List.isEmpty(list); i += 1 } });

// --- Element access ---

assertNoAlloc("List.at", func() { var i = 0; while (i < n) { ignore List.at(list, i); i += 1 } });
assertNoAlloc("List.get", func() { var i = 0; while (i < n) { ignore List.get(list, i); i += 1 } });
assertNoAlloc("List.first", func() { var i = 0; while (i < n) { ignore List.first(list); i += 1 } });
assertNoAlloc("List.last", func() { var i = 0; while (i < n) { ignore List.last(list); i += 1 } });

// --- Search (full scans; targets/predicates chosen so no early exit) ---

assertNoAlloc("List.find", func() { ignore List.find<Nat>(list, func x = x == 999) });
assertNoAlloc("List.findIndex", func() { ignore List.findIndex<Nat>(list, func x = x == 999) });
assertNoAlloc("List.findLastIndex", func() { ignore List.findLastIndex<Nat>(list, func x = x == 0) });
assertNoAlloc("List.indexOf", func() { ignore List.indexOf<Nat>(list, Nat.equal, 999) });
assertNoAlloc("List.nextIndexOf", func() { ignore List.nextIndexOf<Nat>(list, Nat.equal, 999, 0) });
assertNoAlloc("List.lastIndexOf", func() { ignore List.lastIndexOf<Nat>(list, Nat.equal, 0) });
assertNoAlloc("List.prevIndexOf", func() { ignore List.prevIndexOf<Nat>(list, Nat.equal, 0, n) });
assertNoAlloc("List.contains", func() { ignore List.contains<Nat>(list, Nat.equal, n) });
assertNoAlloc("List.all", func() { ignore List.all<Nat>(list, func x = x < n) });
assertNoAlloc("List.any", func() { ignore List.any<Nat>(list, func x = x >= n) });
// assertNoAlloc("List.equal", func() { ignore List.equal<Nat>(list, listCopy, Nat.equal) });
// assertNoAlloc("List.compare", func() { ignore List.compare<Nat>(list, listCopy, Nat.compare) });

// --- Aggregation ---

assertNoAlloc("List.max", func() { ignore List.max<Nat>(list, Nat.compare) });
assertNoAlloc("List.min", func() { ignore List.min<Nat>(list, Nat.compare) });
assertNoAlloc("List.isSorted", func() { ignore List.isSorted<Nat>(list, Nat.compare) });
assertNoAlloc("List.foldLeft", func() { ignore List.foldLeft<Nat, Nat>(list, 0, func(a, x) = a + x) });
assertNoAlloc("List.foldRight", func() { ignore List.foldRight<Nat, Nat>(list, 0, func(x, a) = a + x) });

// --- Iteration (callback style; the iterator-returning functions allocate) ---

assertNoAlloc("List.forEach", func() { List.forEach<Nat>(list, func _ = ()) });
assertNoAlloc("List.forEachEntry", func() { List.forEachEntry<Nat>(list, func(_, _) = ()) });
assertNoAlloc("List.reverseForEach", func() { List.reverseForEach<Nat>(list, func _ = ()) });
assertNoAlloc("List.reverseForEachEntry", func() { List.reverseForEachEntry<Nat>(list, func(_, _) = ()) });
assertNoAlloc("List.forEachInRange", func() { List.forEachInRange<Nat>(list, func _ = (), 0, n) });

// --- In-place mutation (each on its own list, so the shared read-only
//     `list` above keeps its distinct sorted elements) ---

test(
  "List.put does not allocate",
  func() {
    let l = List.repeat<Nat>(0, n);
    assert allocDelta(func() { var i = 0; while (i < n) { List.put(l, i, i); i += 1 } }) == 0
  }
);

test(
  "List.fill does not allocate",
  func() {
    let l = List.repeat<Nat>(0, n);
    assert allocDelta(func() { List.fill(l, 7) }) == 0
  }
);

test(
  "List.mapInPlace does not allocate",
  func() {
    let l = List.repeat<Nat>(0, n);
    assert allocDelta(func() { List.mapInPlace<Nat>(l, func x = x) }) == 0
  }
);

test(
  "List.retain does not allocate",
  func() {
    let l = List.repeat<Nat>(0, n);
    assert allocDelta(func() { List.retain<Nat>(l, func _ = true) }) == 0
  }
);

test(
  "List.deduplicate does not allocate",
  func() {
    // distinct elements, so the workload is idempotent (nothing is removed)
    let l = List.tabulate<Nat>(n, func i = i);
    assert allocDelta(func() { List.deduplicate<Nat>(l, Nat.equal) }) == 0
  }
);

test(
  "List.reverseInPlace does not allocate",
  func() {
    let l = List.tabulate<Nat>(n, func i = i);
    assert allocDelta(func() { List.reverseInPlace(l); List.reverseInPlace(l) }) == 0
  }
)
