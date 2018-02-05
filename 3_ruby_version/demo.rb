require_relative "./slicer"
require "json"
require "pry"

input = JSON.parse(File.read("./unsliced_examples.json"), {symbolize_names: true}).first
slicer  = CeleryScript::Slicer.new
slicer.run!(input)
puts slicer.heap_values
