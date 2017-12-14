import { CeleryNode, isCeleryScript, Sequence } from "farmbot";
import { Heap } from "./heap";

export const flatten =
  (s: CeleryNode): string => doFlatten(new Heap(), s).dump();

function doFlatten(h: Heap, s: CeleryNode): Heap {
  allocate(h, s, 0);
  return h;
}

function allocate(h: Heap, s: CeleryNode, parentAddr: number) {
  const addr = h.allot(s.kind);
  h.put(addr, "$parent", JSON.stringify(parentAddr));
  // Body must always come BEFORE args or $child will be wrong
  iterateOverBody(h, s, addr);
  iterateOverArgs(h, s, addr);
  return addr;
}

function iterateOverArgs(h: Heap, s: CeleryNode, parentAddr: number) {
  Object
    .keys(s.args)
    .map((key: string) => {
      const v = s.args[key];
      if (isCeleryScript(v)) {
        h.put(parentAddr, "$" + key, JSON.stringify(allocate(h, v, parentAddr)));
      } else {
        h.put(parentAddr, key, JSON.stringify(v));
      }
    });
}

function iterateOverBody(heap: Heap, s: CeleryNode, parentAddr: number) {
  heap.put(parentAddr, "$body", "" + (parentAddr + 1));
  const body = s.body || [] as CeleryNode[];
  recurseIntoBody(heap, 0, parentAddr, body);
}

function recurseIntoBody(heap: Heap,
  index: number,
  parent: number,
  list: CeleryNode[]) {
  if (list[index]) {
    const me = allocate(heap, list[index], parent);
    recurseIntoBody(heap, index + 1, me, list);
  } else {
    return;
  }
}
