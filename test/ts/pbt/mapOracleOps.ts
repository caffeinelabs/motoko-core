import { OracleNatTextMap } from "./references/oracleNatTextMap";

/** Serialized mutating operations for Motoko replay (no `get`). */
export type MapMutationOp =
  | { readonly kind: "add"; readonly key: number; readonly value: string }
  | { readonly kind: "remove"; readonly key: number };

export function applyMapMutationOps(
  ops: readonly MapMutationOp[],
): [number, string][] {
  const m = new OracleNatTextMap();
  for (const op of ops) {
    switch (op.kind) {
      case "add":
        m.add(op.key, op.value);
        break;
      case "remove":
        m.remove(op.key);
        break;
    }
  }
  return m.sortedEntries();
}
