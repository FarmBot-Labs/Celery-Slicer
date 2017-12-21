import { CeleryNode, isCeleryScript, Sequence } from "farmbot";
import { Heap } from "./heap";

/** Entry point. Converts tree shaped CeleryScript to a flat structure */
export const flatten =
  (node: CeleryNode): string => {
    const heap = new Heap();
    allocate(heap, node, Heap.NULL);
    return heap.dump();
  };

/** Recurses through a CeleryScript tree and allocates new nodes into the heap */
function allocate(h: Heap, s: CeleryNode, parentAddr: number): number {
  const addr = h.allot(s.kind);
  h.put(addr, "🔗parent", JSON.stringify(parentAddr));
  // Body must always come BEFORE args or 🔗child will be wrong
  iterateOverBody(h, s, addr); // SEE NOTE ABOVE DANGER DANGER
  iterateOverArgs(h, s, addr);
  return addr;
}

function iterateOverArgs(h: Heap, s: CeleryNode, parentAddr: number) {
  Object
    .keys(s.args)
    .map((key: string) => {
      const v = s.args[key];
      if (isCeleryScript(v)) {
        h.put(parentAddr, "🔗" + key, JSON.stringify(allocate(h, v, parentAddr)));
      } else {
        h.put(parentAddr, key, JSON.stringify(v));
      }
    });
}

function iterateOverBody(heap: Heap, s: CeleryNode, parentAddr: number) {
  const body = s.body || [] as CeleryNode[];
  body.length && heap.put(parentAddr, "🔗body", "" + (parentAddr + 1));
  recurseIntoBody(heap, 0, parentAddr, body);
}

function recurseIntoBody(heap: Heap,
  index: number,
  parent: number,
  list: CeleryNode[]) {
  if (list[index]) {
    const me = allocate(heap, list[index], parent);
    const nextIndex = index + 1;
    const nextItem = list[nextIndex];
    const next_address = (nextItem) ? (me + 1) : 0
    heap.put(me, "🔗next", "" + next_address);
    recurseIntoBody(heap, nextIndex, me, list);
  } else {
    return;
  }

}
