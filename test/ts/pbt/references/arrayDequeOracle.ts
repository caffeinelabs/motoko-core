/**
 * Minimal double-ended queue used as the reference oracle for PBT.
 * Semantics match a logical deque: index 0 is the front, `length - 1` is the back.
 * (Implementation uses Array shift/pop — fine for test-scale sizes.)
 */
export class OracleDeque {
  private items: number[] = [];

  pushFront(value: number): void {
    this.items.unshift(value);
  }

  pushBack(value: number): void {
    this.items.push(value);
  }

  popFront(): number | undefined {
    return this.items.length === 0 ? undefined : this.items.shift();
  }

  popBack(): number | undefined {
    return this.items.length === 0 ? undefined : this.items.pop();
  }

  peekFront(): number | undefined {
    return this.items.length === 0 ? undefined : this.items[0];
  }

  peekBack(): number | undefined {
    return this.items.length === 0 ? undefined : this.items[this.items.length - 1];
  }

  get size(): number {
    return this.items.length;
  }

  isEmpty(): boolean {
    return this.items.length === 0;
  }

  /** Front-to-back order (same convention as `Queue.values` in Motoko). */
  toArray(): number[] {
    return [...this.items];
  }
}
