defmodule Slicer do
  # Entry point. Converts tree shaped CeleryScript to a flat structure
  def flatten(node) do
    {:ok, heap} = CSHeap.new()
    allocate(heap, node, 0)
    CSHeap.dump(heap)
  end

  # /** Recurses through a CeleryScript tree and allocates new nodes into the heap */
  # function allocate(h, s, parentAddr) {
  #     var addr = h.allot(s.kind);
  #     h.put(addr, "$parent", JSON.stringify(parentAddr));
  #     // Body must always come BEFORE args or $child will be wrong
  #     iterateOverBody(h, s, addr); // SEE NOTE ABOVE DANGER DANGER
  #     iterateOverArgs(h, s, addr);
  #     return addr;
  # }
  def allocate(heap, sequence, parentAddr) do
    {:ok, addr} = CSHeap.allot(heap, sequence["kind"])
    CSHeap.put(addr, "$parent", parentAddr)
    iterateOverBody(heap, sequence, addr) # *ALWAYS* before iterateOverArgs
    iterateOverArgs(heap, sequence, addr)
    addr
  end

  # function iterateOverArgs(h, s, parentAddr) {
  #     Object
  #         .keys(s.args)
  #         .map(function (key) {
  #         var v = s.args[key];
  #         if (isCeleryScript(v)) {
  #             h.put(parentAddr, "$" + key, JSON.stringify(allocate(h, v, parentAddr)));
  #         }
  #         else {
  #             h.put(parentAddr, key, JSON.stringify(v));
  #         }
  #     });
  # }
  def iterateOverArgs(heap, sequence, parentAddr) do
    argss = s["args"]
    keys = Map.keys()
    mapper = fn key ->
        v = args[key]
        if isCeleryScript(v) do
          IO.puts("TODO")
        else
          IO.puts("TODO")
        end
      end
    you_stopped_here
    Enum.map(keys, mapper)
  end
# function iterateOverBody(heap, s, parentAddr) {
#     var body = s.body || [];
#     body.length && heap.put(parentAddr, "$body", "" + (parentAddr + 1));
#     recurseIntoBody(heap, 0, parentAddr, body);
# }
# function recurseIntoBody(heap, index, parent, list) {
#     if (list[index]) {
#         var me = allocate(heap, list[index], parent);
#         recurseIntoBody(heap, index + 1, me, list);
#     }
#     else {
#         return;
#     }
# }

  def isCeleryScript(node = %{"kind" => _kind, "args" => _args}) do
    true
  end

  def isCeleryScript(_) do
    false
  end
end
