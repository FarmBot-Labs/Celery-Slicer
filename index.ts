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
  h.put(addr, "parent", JSON.stringify(parentAddr));
  iterateOverArgs(h, s, addr);
  iterateOverBody(h, s, addr);
}

function iterateOverArgs(h: Heap, s: CeleryNode, parentAddr: number) {
  Object
    .keys(s.args)
    .map((key: string) => {
      const v = s.args[key];
      if (isCeleryScript(v)) {
        allocate(h, v, parentAddr);
      } else {
        h.put(parentAddr, key, JSON.stringify(v));
      }
    });
}

function iterateOverBody(heap: Heap, s: CeleryNode, parentAddr: number) {
  const y = s.body || [] as CeleryNode[];
  if (y) {
    y.map(x => allocate(heap, x, parentAddr));
  }
}
