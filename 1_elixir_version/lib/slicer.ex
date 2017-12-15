defmodule Slicer do

  # Here's a function to load the example .json file.
  def test_things do
    flatten(Enum.at(SlicerExample.load, 0))
  end

  # Entry point. Converts tree shaped CeleryScript to a flat structure
  def flatten(node) do
    {:ok, heap} = CSHeap.new()
    allocate(heap, node, 0)
    CSHeap.dump(heap)
  end

  def allocate(heap, sequence, parentAddr) do
    {:ok, addr} = CSHeap.allot(heap, sequence["kind"])
    CSHeap.put(heap, addr, "🔗parent", parentAddr)
    iterateOverBody(heap, sequence, addr) # *ALWAYS* before iterateOverArgs
    iterateOverArgs(heap, sequence, addr)
    addr
  end

  def iterateOverArgs(heap, node, parentAddr) do
    args = node["args"]
    keys = Map.keys(args)
    mapper = fn key ->
        v = args[key]
        if isCeleryScript(v) do
          CSHeap.put(heap, parentAddr, "🔗" <> key, allocate(heap, v, parentAddr))
        else
          CSHeap.put(heap, parentAddr, key, v)
        end
      end
    Enum.map(keys, mapper)
  end

  def iterateOverBody(heap, s, parentAddr) do
    body = s["body"] || []
    (length(body) > 0) && CSHeap.put(heap, parentAddr, "🔗body", parentAddr + 1)
    recurseIntoBody(heap, 0, parentAddr, body)
  end

  def recurseIntoBody(heap, index, parent, list) do
    item = Enum.at(list, index)
    if(item) do
      me = allocate(heap, item, parent)
      recurseIntoBody(heap, index + 1, me, list)
    end
  end

  def isCeleryScript(node = %{"kind" => _kind, "args" => _args}) do
    !!node # Is _node ok?
  end

  def isCeleryScript(_) do
    false
  end
end
