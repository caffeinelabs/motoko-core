import Time "../src/Time";
import Array "../src/Array";
import { test } "mo:test";

test(
  "compare - less than",
  func() {
    let x = 1000000000; // Earlier time
    let y = 2000000000; // Later time
    assert Time.compare(x, y) == #less
  }
);

test(
  "compare - equal",
  func() {
    let x = 1234567890;
    let y = 1234567890;
    assert Time.compare(x, y) == #equal
  }
);

test(
  "compare - greater than",
  func() {
    let x = 2000000000; // Later time
    let y = 1000000000; // Earlier time
    assert Time.compare(x, y) == #greater
  }
);

test(
  "compare - with zero",
  func() {
    assert Time.compare(0, 0) == #equal;
    assert Time.compare(0, 1) == #less;
    assert Time.compare(1, 0) == #greater
  }
);

test(
  "compare - sorting times",
  func() {
    let times = [1704067200000000000, 1672531200000000000, 1688169600000000000];
    let sorted = Array.sort(times, Time.compare);
    assert sorted == [1672531200000000000, 1688169600000000000, 1704067200000000000]
  }
);

test(
  "compare - negative times",
  func() {
    // Times before 1970-01-01 are negative
    let x = -1000000000;
    let y = -500000000;
    assert Time.compare(x, y) == #less;
    assert Time.compare(y, x) == #greater;
    assert Time.compare(x, x) == #equal
  }
);

test(
  "compare - across epoch",
  func() {
    let beforeEpoch = -1000000000;
    let afterEpoch = 1000000000;
    assert Time.compare(beforeEpoch, afterEpoch) == #less;
    assert Time.compare(afterEpoch, beforeEpoch) == #greater
  }
);

test(
  "toNanoseconds - days",
  func() {
    assert Time.toNanoseconds(#days(1)) == 86_400_000_000_000;
    assert Time.toNanoseconds(#days(2)) == 172_800_000_000_000
  }
);

test(
  "toNanoseconds - hours",
  func() {
    assert Time.toNanoseconds(#hours(1)) == 3_600_000_000_000;
    assert Time.toNanoseconds(#hours(24)) == 86_400_000_000_000
  }
);

test(
  "toNanoseconds - minutes",
  func() {
    assert Time.toNanoseconds(#minutes(1)) == 60_000_000_000;
    assert Time.toNanoseconds(#minutes(60)) == 3_600_000_000_000
  }
);

test(
  "toNanoseconds - seconds",
  func() {
    assert Time.toNanoseconds(#seconds(1)) == 1_000_000_000;
    assert Time.toNanoseconds(#seconds(60)) == 60_000_000_000
  }
);

test(
  "toNanoseconds - milliseconds",
  func() {
    assert Time.toNanoseconds(#milliseconds(1)) == 1_000_000;
    assert Time.toNanoseconds(#milliseconds(1000)) == 1_000_000_000
  }
);

test(
  "toNanoseconds - nanoseconds",
  func() {
    assert Time.toNanoseconds(#nanoseconds(1)) == 1;
    assert Time.toNanoseconds(#nanoseconds(1000000)) == 1000000
  }
);

test(
  "toNanoseconds - zero",
  func() {
    assert Time.toNanoseconds(#days(0)) == 0;
    assert Time.toNanoseconds(#hours(0)) == 0;
    assert Time.toNanoseconds(#minutes(0)) == 0;
    assert Time.toNanoseconds(#seconds(0)) == 0;
    assert Time.toNanoseconds(#milliseconds(0)) == 0;
    assert Time.toNanoseconds(#nanoseconds(0)) == 0
  }
);
