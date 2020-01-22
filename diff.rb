# frozen_string_literal: true

require './cordinate.rb'

class Diff
  class << self
    # @params a Array
    # @params b Array
    def diff(a, b)
      init(a, b)
      ed = edit_distance
      {
        edit_distance: ed,
        ses: ses
      }
    end

    private

    def init(a, b)
      if a.length < b.length
        @a = a
        @b = b
        @m = a.length
        @n = b.length
        @swapped = false
      else
        @a = b
        @b = a
        @m = b.length
        @n = a.length
        @swapped = true
      end
      @offset = @m + 1
      @delta = @n - @m
      @path_numbers = Array.new(@m + @n + 3, -1)
      @fp = Array.new(@m + @n + 3, -1)
      @path_count = 0
      @cordinates = []
    end

    def edit_distance
      q = 0

      loop do
        (-q).upto(@delta - 1) do |k|
          @fp[k + @offset] = snake(k, @fp[k - 1 + @offset] + 1, @fp[k + 1 + @offset])
        end

        (@delta + q).downto(@delta + 1) do |k|
          @fp[k + @offset] = snake(k, @fp[k - 1 + @offset] + 1, @fp[k + 1 + @offset])
        end

        @fp[@delta + @offset] = snake(@delta, @fp[@delta - 1 + @offset] + 1, @fp[@delta + 1 + @offset])

        return @delta + 2 * q if @fp[@delta + @offset] == @n

        q += 1
      end
    end

    def max(x, y)
      x > y ? x : y
    end

    # k上の最遠点yを求める
    def snake(k, above_y, below_y)
      y = max(above_y, below_y)
      x = y - k
      r = above_y > below_y ? @path_numbers[k - 1 + @offset] : @path_numbers[k + 1 + @offset]
      while x < @m && y < @n && @a[x] == @b[y]
        x += 1
        y += 1
      end

      @path_numbers[k + @offset] = @path_count
      @path_count += 1
      @cordinates.push(Cordinate.new(x, y, r))
      y
    end

    def ses
      edit = Struct.new(:string, :operation, :before, :after)
      x = 0
      y = 0
      a_idx = 0
      b_idx = 0
      ses = []

      k = @path_numbers[@delta + @offset]
      edit_path_cordinates = []

      while k != -1
        edit_path_cordinates.push(Cordinate.new(@cordinates[k].x, @cordinates[k].y, k))
        k = @cordinates[k].k
      end

      edit_path_cordinates.reverse.each do |c|
        while x < c.x || y < c.y
          if c.y - c.x > y - x
            ses.push(@swapped ? edit.new(@b[b_idx], :delete, y, nil) : edit.new(@b[b_idx], :add, nil, y))
            y += 1
            b_idx += 1
          elsif c.y - c.x < y - x
            ses.push(@swapped ? edit.new(@a[a_idx], :add, nil, x) : edit.new(@a[a_idx], :delete, x, nil))
            x += 1
            a_idx += 1
          else
            ses.push(@swapped ? edit.new(@b[b_idx], :none, y, x) : edit.new(@a[a_idx], :none, x, y))
            x += 1
            y += 1
            a_idx += 1
            b_idx += 1
          end
        end
      end
      ses
    end
  end
end
