# frozen_string_literal: false

require './formatDiff.rb'

pp Diff.format_diff("Abcdefg", "abcdefgzz")
