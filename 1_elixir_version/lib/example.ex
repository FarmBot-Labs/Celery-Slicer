defmodule SlicerExample do
  def load do
    {:ok, raw} = File.read("../unsliced_examples.json")
    {:ok, json} = Poison.decode(raw)
    json
  end
end
