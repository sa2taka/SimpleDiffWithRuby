# frozen_string_literal: false

require './formatDiff.rb'

a = File.read('./testdata/1.txt').split("\n")
b = File.read('./testdata/2.txt').split("\n")



puts Diff.format(a, b)
