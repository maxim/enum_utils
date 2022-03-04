# frozen_string_literal: true

require 'test_helper'

class SortedMergeTest < EnumUtilsTest
  def subject(*arrays, **kwargs)
    EnumUtils.sorted_merge(*arrays.map(&:each), **kwargs)
  end

  def test_lazy
    enum1, tracker1 = make_lazy_enum('init', [1, 'a'], [2, 'b'])
    enum2, tracker2 = make_lazy_enum('init', [1, 'a'], [3, 'b'])

    enum = subject(enum1, enum2)
    assert_equal(%w[init init], [tracker1, tracker2])

    assert_equal(1, enum.next)
    assert_equal(%w[b a], [tracker1, tracker2])

    assert_equal(1, enum.next)
    assert_equal(%w[b b], [tracker1, tracker2])

    assert_equal(2, enum.next)
    assert_equal(%w[b b], [tracker1, tracker2])

    assert_equal(3, enum.next)
    assert_equal(%w[b b], [tracker1, tracker2])

    assert_raises(StopIteration) { enum.next }
  end

  def test_empty
    assert_equal [], subject([]).to_a
  end

  def test_enums_without_index
    assert_equal [1,1,2,2,2,3,5], subject([1,2], [2,3], [1,2,5]).to_a
  end

  def test_enums_with_index
    assert_equal \
      [[1,0], [1,2], [2,0], [2,1], [2,2], [3,1], [5,2]],
      subject([1,2], [2,3], [1,2,5], with_index: true).to_a
  end

  def test_enums_with_compare
    assert_equal \
      [5,3,2,2,2,1,1],
      subject([2,1], [3,2], [5,2,1], compare: -> a, b { b <=> a }).to_a
  end

  def test_compare_error
    err = assert_raises(ArgumentError) { subject([1], ['a']).to_a }
    assert_equal('comparison of String with Integer failed', err.message)
  end
end
