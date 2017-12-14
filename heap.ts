export type Block = { __LABEL__: string;[key: string]: string; };

/** This will be a GenServer in elixir. */
export class Heap {
  static NULL = 0;
  private here: number;
  private entries: { [addr: number]: (Block | undefined) };

  constructor() {
    this.here = Heap.NULL;
    this.entries = {
      [this.here]: { __LABEL__: "NULL" }
    };
  }

  /** Allocate a new object in the heap. */
  allot = (__LABEL__: string): number => {
    this.entries[++this.here] = { __LABEL__ };
    return this.here;
  }

  put = (address: number, key: string, value: string) => {
    const block = this.entries[address];
    if (value[0] === "{") {
      throw new Error("NO!")
    }
    if (block) {
      block[key] = value;
    } else {
      throw new Error("Bad node address: " + address);
    }
  }

  dump = (): string => {
    return JSON.stringify(this.entries);
  }
}
