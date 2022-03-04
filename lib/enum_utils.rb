# frozen_string_literal: true

require 'set'
require_relative 'enum_utils/version'
require_relative 'enum_utils/exhaustible_iter'

module EnumUtils
  extend self

  # Given N consistently-sorted enums, return unique values that appear in at
  # least [degree] number of different enums, preserving the global order, until
  # all enums are depleted. By default a value must appear in all of them.
  #
  # Examples:
  #
  #   ## 3 ascending enums:
  #
  #   EnumUtils.sorted_intersection(
  #     [1,2].each,
  #     [2,3].each,
  #     [1,2,5].each
  #   ).to_a # => [2]
  #
  #   ## 3 descending enums:
  #
  #   EnumUtils.sorted_intersection(
  #     [2,1].each,
  #     [3,2].each,
  #     [5,2,1].each,
  #     compare: -> a, b { b <=> a } # reverse order comparison
  #   ).to_a # => [2]
  #
  #   ## 3 ascending enums with degree 2:
  #
  #   EnumUtils.sorted_intersection(
  #     [1,2].each,
  #     [2,3].each,
  #     [1,2,5].each,
  #     degree: 2
  #   ).to_a # => [1, 2]
  def sorted_intersection *enums,
    compare: -> a, b { a <=> b },
    degree: enums.size

    unless block_given?
      return enum_for(__method__, *enums, compare: compare, degree: degree)
    end

    active  = prepare_enums(enums)
    compare = compare_with_error_handling(compare)
    last_v  = []
    seen_i  = Set[]

    while active.size >= (degree - seen_i.size)
      (min_iter, min_iter_i), pos = pick_min(active, compare, demote: seen_i)
      value = min_iter.next

      if last_v.empty? || compare.(last_v[0], value) != 0
        last_v.replace [value]
        seen_i.replace [min_iter_i]
      else
        seen_i << min_iter_i
      end

      if seen_i.size == degree
        yield(value)
        last_v.replace []
        seen_i.replace []
      end

      active.delete_at(pos) if min_iter.exhausted?
    end
  end

  # Given N consistently-sorted enums, return all their unique values while
  # preserving their global order. If `with_index: true` is given, also return
  # index of the enum in which the corresponding value was first seen.
  #
  # Examples:
  #
  #   ## 3 ascending enums:
  #
  #   EnumUtils.sorted_union(
  #     [1,2].each,
  #     [2,3].each,
  #     [1,2,5].each
  #   ).to_a # => [1,2,3,5]
  #
  #   ## 3 descending enums:
  #
  #   EnumUtils.sorted_union(
  #     [2,1].each,
  #     [3,2].each,
  #     [5,2,1].each,
  #     compare: -> a, b { b <=> a } # reverse order comparison
  #   ).to_a # => [5,3,2,1]
  #
  #   ## 3 ascending enums with index:
  #
  #   EnumUtils.sorted_union(
  #     [1,2].each,
  #     [2,3].each,
  #     [1,2,5].each,
  #     with_index: true
  #   ).to_a # => [[1,0], [2,0], [3,1], [5,2]]
  def sorted_union(*enums, compare: -> a, b { a <=> b }, with_index: false)
    unless block_given?
      return \
        enum_for(__method__, *enums, compare: compare, with_index: with_index)
    end

    unless with_index
      return sorted_union(*enums, compare: compare, with_index: true) { |v, _|
        yield v
      }
    end

    last_v = []

    sorted_merge(*enums, compare: compare, with_index: with_index).each { |v, i|
      if last_v.empty? || v != last_v[0]
        yield(v, i)
        last_v.replace([v])
      end
    }
  end

  # Given N consistently-sorted enums, return all their values while preserving
  # the global order. If `with_index: true` is given, also return index in the
  # enum that originated the value.
  #
  # Examples:
  #
  #   ## 3 ascending enums:
  #
  #   EnumUtils.sorted_merge(
  #     [1,2].each,
  #     [2,3].each,
  #     [1,2,5].each
  #   ).to_a # => [1,1,2,2,2,3,5]
  #
  #   ## 3 descending enums:
  #
  #   EnumUtils.sorted_merge(
  #     [2,1].each,
  #     [3,2].each,
  #     [5,2,1].each,
  #     compare: -> a, b { b <=> a } # reverse order comparison
  #   ).to_a # => [5,3,2,2,2,1,1]
  #
  #   ## 3 ascending enums with index:
  #
  #   EnumUtils.sorted_union(
  #     [1,2].each,
  #     [2,3].each,
  #     [1,2,5].each,
  #     with_index: true
  #   ).to_a # => [[1,0], [1,2], [2,0], [2,1], [2,2], [3,1], [5,2]]
  def sorted_merge(*enums, compare: -> a, b { a <=> b }, with_index: false)
    unless block_given?
      return \
        enum_for(__method__, *enums, compare: compare, with_index: with_index)
    end

    unless with_index
      return sorted_merge(*enums, compare: compare, with_index: true) { |v, _|
        yield v
      }
    end

    active  = prepare_enums(enums)
    compare = compare_with_error_handling(compare)

    while active.any?
      (min_iter, min_iter_i), pos = pick_min(active, compare)
      yield(min_iter.next, min_iter_i)
      active.delete_at(pos) if min_iter.exhausted?
    end
  end

  # Given N enums, return all their values by taking one value from each enum in
  # turn, until all are exhausted. If `with_index: true` is given, also return
  # index of the enum that originated the value.
  #
  # Examples:
  #
  #   ## 3 enums:
  #
  #   EnumUtils.round_robin(
  #     [3,2].each,
  #     [1,3].each,
  #     [5,3,4].each
  #   ).to_a # => [3,1,5,2,3,3,4]
  #
  #   ## 3 enums with index:
  #
  #   EnumUtils.round_robin(
  #     [3,2].each,
  #     [1,3].each,
  #     [5,3,4].each,
  #     with_index: true
  #   ).to_a # => [[3,0], [1,1], [5,2], [2,0], [3,1], [3,2], [4,2]]
  def round_robin(*enums, with_index: false)
    unless block_given?
      return enum_for(__method__, *enums, with_index: with_index)
    end

    unless with_index
      return round_robin(*enums, with_index: true) { |v, _| yield v }
    end

    active = prepare_enums(enums)

    while active.any?
      pos = 0

      while pos < active.size
        iter, i = active[pos]
        yield(iter.next, i)
        iter.exhausted? ? active.delete_at(pos) : pos += 1
      end
    end
  end

  # Given N enums, return a new enum which lazily exhausts every enum.
  def concat(*enums)
    return enum_for(__method__, *enums) unless block_given?

    enums
      .lazy
      .flat_map(&:lazy)
      .to_enum { enums.sum(&:size) if enums.all?(&:size) }.each do |v|
        yield(v)
      end
  end

  private

  def pick_min(indexed_enums, compare, demote: Set[])
    indexed_enums.each.with_index.min { |((a_enum, ai), _), ((b_enum, bi), _)|
      result = compare.(a_enum.buff_value, b_enum.buff_value)

      if result.nonzero?
        result
      elsif demote.include?(bi)
        -1
      elsif demote.include?(ai)
        1
      else
        result
      end
    }
  end

  def compare_with_error_handling(compare)
    -> a, b {
      result = compare.(a, b)
      return result unless result.nil?
      raise ArgumentError, "comparison of #{a.class} with #{b.class} failed"
    }
  end

  def prepare_enums(enums)
    enums
      .map
      .with_index { |e, i| [ExhaustibleIter.new(e), i] }
      .reject { |e, _| e.exhausted? }
  end
end
