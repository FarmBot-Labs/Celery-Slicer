defmodule CSHeap do
  @null 0

  def new() do
    GenServer.start_link(__MODULE__, :ok, [])
  end

  def init(:ok) do
    {:ok, [here: @null, data: %{}]}
  end

  # Allocate a new object in the heap. At a minimum, it must have a __KIND__,
  # which is the same thing as node.kind in normal CeleryScript. */
  def allot(pid, kind) do
    GenServer.call(pid, {:allot, kind})
  end

  # Add a key/value pair to a particular address in the heap.
  # For simplicity, they must be stringified. This is how we "flatten"
  # node.args and also store references to `parent` and `body`.
  def put(pid, address, key, value) do
    GenServer.call(pid, {:put, address, key, value})
  end

  # Dump the heap so you can do stuff with it.
  def dump(pid) do
    GenServer.call(pid, {:dump})
  end

  def handle_call({:allot, kind}, _, state) do
    [{:here, here}, {:data, data}] = state

    next_here = here + 1
    next_data = data |> Map.put(next_here, %{:__KIND__ => kind})

    {:reply, {:ok, next_here}, [here: next_here, data: next_data]}
  end

  def handle_call({:put, address, key, value}, _, state) do
    [{:here, here}, {:data, data}] = state

    next_entry = Map.merge(data[address], %{ key => value} )
    next_data  = Map.put(data, address, next_entry)

    {:reply, {:ok}, [here: here, data: next_data]}
  end

  def handle_call({:dump}, _, state) do
    [_, {:data, data}] = state
    {:reply, {:ok, data}, state}
  end
end
