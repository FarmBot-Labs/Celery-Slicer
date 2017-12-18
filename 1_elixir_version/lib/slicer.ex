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

  def allocate(heap, sequence, parnt_addr) do
    {:ok, addr} = CSHeap.allot(heap, sequence["kind"])
    CSHeap.put(heap, addr, "🔗parent", parnt_addr)
    iterateOverBody(heap, sequence, addr) # *ALWAYS* before iterate_over_args
    iterate_over_args(heap, sequence, addr)
    addr
  end

  def iterate_over_args(heap, node, parnt_addr) do
    args = node["args"]
    keys = Map.keys(args)
    mapper = fn key ->
        v = args[key]
        if is_celery(v) do
          CSHeap.put(heap, parnt_addr, "🔗" <> key, allocate(heap, v, parnt_addr))
        else
          CSHeap.put(heap, parnt_addr, key, v)
        end
      end
    Enum.map(keys, mapper)
  end

  def iterateOverBody(heap, s, parnt_addr) do
    body = s["body"] || []
    (length(body) > 0) && CSHeap.put(heap, parnt_addr, "🔗body", parnt_addr + 1)
    recurse_into_body(heap, 0, parnt_addr, body)
  end

  def recurse_into_body(heap, index, parent, list) do
    item = Enum.at(list, index)
    if(item) do
      me = allocate(heap, item, parent)
      recurse_into_body(heap, index + 1, me, list)
    end
  end

  @compile {:inline, is_celery: 1}
  def is_celery(%{"kind" => _kind, "args" => _args}), do: true
  def is_celery(_), do: false
end
