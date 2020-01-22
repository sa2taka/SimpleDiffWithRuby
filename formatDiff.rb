# frozen_string_literal: true

require './diff.rb'

class Diff
  class << self
    def format(a, b)
      result = diff(a, b)
      format_diff(sort_diff(result[:ses]))
    end

    private 

    # 交互に混ざったdeleteとaddを並び変える
    def sort_diff(ses)
      work_array = []
      ses.reduce([]) do |result, edit|
        if edit.operation != :none
          work_array << edit
        else
          work_array.sort! do |a, b| 
            if a.before.nil? && b.before.nil?
              a.after <=> b.after
            elsif a.before.nil?
              1
            elsif b.before.nil?
              -1
            else
              a.before <=> b.before
            end
          end
          result.concat(work_array)
          work_array = []
          result << edit
        end
        result 
      end.concat(work_array)
    end

    def format_diff(diff)
      formated = ''
      diff.each do |edit|
        if edit.operation == :add
          formated += '+ '
        elsif edit.operation == :delete
          formated += '- '
        else
          formated += '  '
        end

        formated += edit.string + "\n"
      end
      formated
    end
  end
end