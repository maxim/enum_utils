# frozen_string_literal: true

require 'test_helper'

class RoundRobinTest < EnumUtilsTest
  def subject(*arrays, **kwargs)
    EnumUtils.round_robin(*arrays.map(&:each), **kwargs)
  end

  def test_lazy
    enum1, tracker1 = make_lazy_enum('init', [1, 'a'], [2, 'b'])
    enum2, tracker2 = make_lazy_enum('init', [3, 'a'], [4, 'b'])

    enum = subject(enum1, enum2)
    assert_equal(%w[init init], [tracker1, tracker2])

    assert_equal(1, enum.next)
    assert_equal(%w[b a], [tracker1, tracker2])

    assert_equal(3, enum.next)
    assert_equal(%w[b b], [tracker1, tracker2])

    assert_equal(2, enum.next)
    assert_equal(%w[b b], [tracker1, tracker2])

    assert_equal(4, enum.next)
    assert_equal(%w[b b], [tracker1, tracker2])

    assert_raises(StopIteration) { enum.next }
  end

  def test_empty
    assert_equal [], subject([]).to_a
  end

  def test_enums_without_index
    assert_equal [7,3,5,1,3,4], subject([7,1], [3], [5,3,4]).to_a
  end

  def test_enums_without_index2
    assert_equal [2,1,1], subject([], [2,1], [1], []).to_a
  end

  def test_enums_with_index
    assert_equal \
      [[7,0], [3,1], [5,2], [1,0], [3,2], [4,2]],
      subject([7,1], [3], [5,3,4], with_index: true).to_a
  end

  def test_enums_with_index2
    assert_equal \
      [[2,1], [1,2], [1,1]],
      subject([], [2,1], [1], [], with_index: true).to_a
  end
end
