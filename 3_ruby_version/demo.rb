require_relative "./slicer"
require "json"
require "pry"

input  = JSON.parse(File.read("./unsliced_examples.json"), {symbolize_names: true})
slicer = CeleryScript::Slicer.new
output = {}

slicer.run!(input.first)

slicer.heap_values.each_with_index do |node, index|
  output[index.to_s] = node
end

puts output.to_json
