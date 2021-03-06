module HashExtras
  refine Hash do
    def except!(*keys)
      keys.each { |key| delete(key) }
      self
    end

    def except(*keys)
      dup.except!(*keys)
    end
  end
end
# A heap-ish data structure required when converting canonical CeleryScript AST
# nodes into the Flat IR form.
# This data strcutre is useful because it addresses each node in the
# CeleryScript tree via a unique numerical index, rather than using mutable
# references.
# MORE INFO: https://github.com/FarmBot-Labs/Celery-Slicer
module CeleryScript
  class CSHeap
    using HashExtras
    # A single node in the CeleryScript tree, as stored in the heap.
    # It's a collection of key/value pairs, a parent index, a body index and a
    # __KIND__ key.
    attr_accessor :entries

    # "here" represents the last item added to the heap and, often, the item that
    # is currently being edited.
    attr_accessor :here

    # Index 0 of the heap represents a null pointer of sorts. If a field points to
    # this address, it is considered empty.
    NULL    = 0

    # What you will find at index 0 of the heap:
    NOTHING = { __KIND__: "nothing" }

    # Set "here" to "null". Prepopulates "here" with an empty entry.
    def initialize
      @here    = CSHeap::NULL
      @entries = { @here => NOTHING }
    end

    # Grow the heap and fill it was a CS node of type `__KIND__`.
    # Returns the new value of `@here` after expansion.
    def allot(__KIND__)
      entries[@here += 1] = { __KIND__: __KIND__ }
      return @here
    end

    # augment a heap entry with a new key/value pair.
    # Throws an exception when given a bad heap index.
    def put(address, key, value)
      block = entries[address]
      if (block)
        block[key] = value
        return
      else
        raise ("Bad node address: " + address)
      end
    end

    def values
      entries.values
    end

    # Dump the heap as an easy-to-traverse JSON object.
    # We need this to reconstruct the node from its IR form to its canonical form.
    def dump
      return values
        .map do |input|
          output = {
            kind:   input[Slicer::KIND],
            parent: (input[Slicer::PARENT.to_s] || "0").to_i,
            body:   (input[Slicer::BODY.to_s ] || "0").to_i,
            next:   (input[Slicer::NEXT.to_s ] || "0").to_i,
            primary_nodes:    {},
            edge_nodes:       {}
          }
          input
          .except(*(Slicer::PRIMARY_FIELDS))
          .to_a
          .map do |node|
            key, value = *node
            is_primary = key.to_s.start_with?(Slicer::LINK)
            if is_primary
              clean_key = key.gsub(Slicer::LINK, "")
              output[:primary_nodes][clean_key] = JSON.parse(value)
            else
              output[:edge_nodes][key] = JSON.parse(value)
            end
          end
          output#.deep_symbolize_keys
        end
      end
    end
  end
