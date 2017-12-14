export type Block = { __KIND__: string;[key: string]: string; };

/** This will be a GenServer when ported to Elixir.
 * Represents an expanding (never contracting) storage unit for CeleryScript
 * nodes that are numerically addressable. */
export class Heap {
  /** Starting address */
  static NULL = 0;
  /** Address of the last slot created. */
  private here: number;
  /** All entries, indexed by address. */
  private entries: { [addr: number]: (Block | undefined) };

  /** Start at Heap.NULL and put a `nothing` node in there. */
  constructor() {
    this.here = Heap.NULL;
    this.entries = { [this.here]: { __KIND__: "nothing" } };
  }

  /** Allocate a new object in the heap. At a minimum, it must have a __KIND__,
   * which is the same thing as node.kind in normal CeleryScript. */
  allot(__KIND__: string): number {
    this.entries[++this.here] = { __KIND__ };
    return this.here;
  }

  /** Add a key/value pair to a particular address in the heap.
   * For simplicity, they must be stringified. This is how we "flatten"
   * node.args and also store references to `parent` and `body`. */
  put(address: number, key: string, value: string) {
    const block = this.entries[address];
    if (block) {
      block[key] = value;
      return;
    }
    throw new Error("Bad node address: " + address);
  }

  /** Dump the heap as JSON. */
  dump(): string {
    return JSON.stringify(this.entries);
  }
}
