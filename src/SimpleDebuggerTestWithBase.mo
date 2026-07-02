/// Commands:
/// bp set -n main
/// run
/// bt
/// list
/// thread step-in
/// thread step-in
/// thread step-in
/// thread step-out
/// thread step-out
/// thread step-out
/// thread step-in  Note: Wrong line
/// thread step-in  Note: Correct line
/// thread step-over
/// thread step-out
import List "List";
import Debug "Debug";
import BaseArray "mo:base/Array";

func main() {
  let baseArray = BaseArray.tabulate<Nat>(3, func i = i);
  let list = List.fromArray<Nat>(baseArray);
  List.addAll(list, [4, 5, 6].vals());
  Debug.print(debug_show (List.toArray(list)))
};

main()
