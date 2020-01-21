# frozen_string_literal: true

require './diff.rb'

pp Diff.diff('./b.txt', './a.txt')
