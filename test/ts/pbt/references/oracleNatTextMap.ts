/**
 * Reference ordered map: Nat keys, Text-like string values.
 * Equality for full-map checks uses entries sorted by key (same observable order as Motoko `Map.entries`).
 */
export class OracleNatTextMap {
  private readonly m = new Map<number, string>();

  add(key: number, value: string): void {
    this.m.set(key, value);
  }

  remove(key: number): void {
    this.m.delete(key);
  }

  get(key: number): string | undefined {
    return this.m.get(key);
  }

  /** Sorted by key ascending (Motoko `Map.entries` order for `Nat.compare`). */
  sortedEntries(): [number, string][] {
    return [...this.m.entries()].sort((a, b) => a[0] - b[0]);
  }
}
