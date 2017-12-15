defmodule SlicerExample do
  def load do
    {:ok, raw} = File.read("../unsliced_examples.json")
    {:ok, Poison.decode(raw)}
  end
end
