class Slicer
  def isCeleryScript(node)
    node && node[:args] && node[:kind]
  end

  def flatten(node)
    heap = CSHeap.new()
    allocate(heap, node, CSHeap::NULL)
    heap.dump()
  end

  def allocate(h, s, parentAddr)
    addr = h.allot(s.kind)
    h.put(addr, "🔗parent", parentAddr.to_json)
    iterateOverBody(h, s, addr)
    iterateOverArgs(h, s, addr)
    addr
  end

  def iterateOverArgs(h, s, parentAddr)
    s[:args]
      .keys
      .map do |key|
        v = s[:args][key]
        if (isCeleryScript(v))
          k = "🔗" + key
          h.put(parentAddr, k, allocate(h, v, parentAddr).to_json)
        else
            h.put(parentAddr, key, v.to_json)
        end
      end
  end

  def iterateOverBody(heap, s, parentAddr)
    body = s[:body] || []
    body.length && heap.put(parentAddr, "🔗body", "" + (parentAddr + 1))
    recurse_into_body(heap, 0, parentAddr, body)
  end

  def recurse_into_body(heap, index, parent, list)
    if list[index]
      me           = allocate(heap, list[index], parent)
      next_index   = index + 1
      next_item    = list[next_index]
      next_address = (next_item) ? (me + 1) : 0
      heap.put(me, "🔗next", "" + next_address)
      recurse_into_body(heap, next_index, me, list)
    end
  end
end