export type Block = { __KIND__: string;[key: string]: string; };

/** This will be a GenServer in elixir. */
export class Heap {
  static NULL = 0;
  private here: number;
  private entries: { [addr: number]: (Block | undefined) };

  constructor() {
    this.here = Heap.NULL;
    this.entries = { [this.here]: { __KIND__: "nothing" } };
  }

  /** Allocate a new object in the heap. */
  allot = (__KIND__: string): number => {
    this.entries[++this.here] = { __KIND__ };
    return this.here;
  }

  put = (address: number, key: string, value: string) => {
    const block = this.entries[address];
    if (block) {
      block[key] = value;
      return;
    }
    throw new Error("Bad node address: " + address);
  }

  dump = (): string => {
    return JSON.stringify(this.entries);
  }
}
