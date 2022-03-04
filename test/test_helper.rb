# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require 'enum_utils'
require 'minitest/autorun'

class EnumUtilsTest < Minitest::Test
  def make_lazy_enum(init_note, *pairs)
    note = init_note.dup
    enum = Enumerator.new { |y|
      pairs.each do |item, item_note|
        note.replace(item_note)
        y << item
      end
    }
    [enum.lazy, note]
  end
end
