# frozen_string_literal: true

require './cordinate.rb'

class Diff
  @fp = Array.new(0)
  @cordinates = []

  class << self
    # @params a file path1
    # @params b file path2
    def diff(a, b)
      init(a, b)
      edit_distance
      ses
    end

    private

    def init(_a, _b)
      a = File.read(_a)
      b = File.read(_b)
      # b must be greater than a
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
      @path_counts = Array.new(@m + @n + 3, -1)
      @fp = Array.new(@m + @n + 3, -1)
    end

    def edit_distance
      q = 0

      loop do
        (-q).upto(@delta - 1) do |k|
          @fp[k + @offset] = snake(k, max(@fp[k - 1 + @offset] + 1, @fp[k + 1 + @offset]))
        end

        (@delta + q).downto(@delta + 1) do |k|
          @fp[k + @offset] = snake(k, max(@fp[k - 1 + @offset] + 1, @fp[k + 1 + @offset]))
        end

        @fp[@delta + @offset] = snake(@delta, max(@fp[@delta - 1 + @offset] + 1, @fp[@delta + 1 + @offset]))

        return @delta + 2 * q if @fp[@delta + @offset] == @n

        q += 1
      end
    end

    def max(x, y)
      x > y ? x : y
    end

    # k上の最遠点yを求める
    def snake(k, y)
      x = y - k
      r = @path_counts[y]
      while x < @m && y < @n && @a[x] == @b[y]
        x += 1
        y += 1
      end

      @path_counts[k + @offset] = @cordinates.length
      @cordinates.push(Cordinate.new(x, y, r))
      y
    end

    def ses
      edit = Struct.new(:string, :operation, :before, :after)
      x = 0
      y = 0
      ses = []

      k = @path_counts[@delta + @offset]
      edit_path_cordinates = []

      while k != -1
        edit_path_cordinates.push(Cordinate.new(@cordinates[k].x, @cordinates[k].y, k))
        k = @cordinates[k].k
      end

      edit_path_cordinates.reverse.each do |c|
        while x < c.x || y < c.y
          if c.y - c.x > y - x
            ses.push(@swapped ? edit.new(@a[y], :delete, y, nil) : edit.new(@b[y], :add, nil, y))
            ses.push(@swapped ? edit.new(@b[y], :add, nil, y) : edit.new(@b[y], :delete, y, nil))
            y += 1
          elsif c.y - c.x < y - x
            ses.push(@swapped ? edit.new(@a[x], :delete, x, nil) : edit.new(@b[x], :add, nil, x))
            ses.push(@swapped ? edit.new(@b[x], :add, nil, x) : edit.new(@a[x], :delete, x, nil))
            x += 1
          else
            ses.push(@swapped ? edit.new(@b[x], :none, y, x) : edit.new(@b[y], :none, x, y))
            x += 1
            y += 1
          end
        end
      end
      ses
    end
  end
end
