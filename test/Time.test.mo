import Time "../src/Time";
import { suite; test; expect } "mo:test";

suite(
  "comparison",
  func() {
    test(
      "equal - same times",
      func() {
        let time1 : Time.Time = 1_000_000_000;
        let time2 : Time.Time = 1_000_000_000;
        expect.bool(Time.equal(time1, time2)).equal(true)
      }
    );

    test(
      "equal - different times",
      func() {
        let time1 : Time.Time = 1_000_000_000;
        let time2 : Time.Time = 2_000_000_000;
        expect.bool(Time.equal(time1, time2)).equal(false)
      }
    );

    test(
      "equal - zero",
      func() {
        let time1 : Time.Time = 0;
        let time2 : Time.Time = 0;
        expect.bool(Time.equal(time1, time2)).equal(true)
      }
    );

    test(
      "equal - negative times",
      func() {
        let time1 : Time.Time = -1_000_000_000;
        let time2 : Time.Time = -1_000_000_000;
        expect.bool(Time.equal(time1, time2)).equal(true)
      }
    );

    test(
      "compare - equal",
      func() {
        let time1 : Time.Time = 1_000_000_000;
        let time2 : Time.Time = 1_000_000_000;
        expect.text(debug_show (Time.compare(time1, time2))).equal("#equal")
      }
    );

    test(
      "compare - less",
      func() {
        let time1 : Time.Time = 1_000_000_000;
        let time2 : Time.Time = 2_000_000_000;
        expect.text(debug_show (Time.compare(time1, time2))).equal("#less")
      }
    );

    test(
      "compare - greater",
      func() {
        let time1 : Time.Time = 2_000_000_000;
        let time2 : Time.Time = 1_000_000_000;
        expect.text(debug_show (Time.compare(time1, time2))).equal("#greater")
      }
    );

    test(
      "compare - zero",
      func() {
        let time1 : Time.Time = 0;
        let time2 : Time.Time = 0;
        expect.text(debug_show (Time.compare(time1, time2))).equal("#equal")
      }
    );

    test(
      "compare - negative times",
      func() {
        let time1 : Time.Time = -2_000_000_000;
        let time2 : Time.Time = -1_000_000_000;
        expect.text(debug_show (Time.compare(time1, time2))).equal("#less");
        expect.text(debug_show (Time.compare(time2, time1))).equal("#greater")
      }
    );

    test(
      "compare - negative vs positive",
      func() {
        let time1 : Time.Time = -1_000_000_000;
        let time2 : Time.Time = 1_000_000_000;
        expect.text(debug_show (Time.compare(time1, time2))).equal("#less");
        expect.text(debug_show (Time.compare(time2, time1))).equal("#greater")
      }
    )
  }
);

suite(
  "toNanoseconds",
  func() {
    test(
      "nanoseconds",
      func() {
        expect.nat(Time.toNanoseconds(#nanoseconds(1000))).equal(1000);
        expect.nat(Time.toNanoseconds(#nanoseconds(0))).equal(0)
      }
    );

    test(
      "milliseconds",
      func() {
        expect.nat(Time.toNanoseconds(#milliseconds(1))).equal(1_000_000);
        expect.nat(Time.toNanoseconds(#milliseconds(5))).equal(5_000_000)
      }
    );

    test(
      "seconds",
      func() {
        expect.nat(Time.toNanoseconds(#seconds(1))).equal(1_000_000_000);
        expect.nat(Time.toNanoseconds(#seconds(10))).equal(10_000_000_000)
      }
    );

    test(
      "minutes",
      func() {
        expect.nat(Time.toNanoseconds(#minutes(1))).equal(60_000_000_000);
        expect.nat(Time.toNanoseconds(#minutes(5))).equal(300_000_000_000)
      }
    );

    test(
      "hours",
      func() {
        expect.nat(Time.toNanoseconds(#hours(1))).equal(3_600_000_000_000);
        expect.nat(Time.toNanoseconds(#hours(24))).equal(86_400_000_000_000)
      }
    );

    test(
      "days",
      func() {
        expect.nat(Time.toNanoseconds(#days(1))).equal(86_400_000_000_000);
        expect.nat(Time.toNanoseconds(#days(7))).equal(604_800_000_000_000)
      }
    )
  }
)

