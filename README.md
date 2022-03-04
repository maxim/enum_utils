# EnumUtils

Functions for mixing and matching lazy, potentially infinite enumerables.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'enum_utils'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install enum_utils

## Usage

### EnumUtils.sorted_intersection

Given N consistently-sorted enums, return unique values that appear in at least
[degree] number of different enums, preserving the global order, until all enums
are depleted. By default a value must appear in all of them.

```ruby
# 3 ascending enums
EnumUtils.sorted_intersection(
  [1,2].each,
  [2,3].each,
  [1,2,5].each
).to_a # => [2]

# 3 descending enums
EnumUtils.sorted_intersection(
  [2,1].each,
  [3,2].each,
  [5,2,1].each,
  compare: -> a, b { b <=> a } # reverse order comparison
).to_a # => [2]

# 3 ascending enums with degree 2
EnumUtils.sorted_intersection(
  [1,2].each,
  [2,3].each,
  [1,2,5].each,
  degree: 2
).to_a # => [1, 2]
```

### EnumUtils.sorted_union

Given N consistently-sorted enums, return all their unique values while
preserving their global order. If `with_index: true` is given, also return index
of the enum in which the corresponding value was first seen.

```ruby
# 3 ascending enums
EnumUtils.sorted_union(
  [1,2].each,
  [2,3].each,
  [1,2,5].each
).to_a # => [1,2,3,5]

# 3 descending enums
EnumUtils.sorted_union(
  [2,1].each,
  [3,2].each,
  [5,2,1].each,
  compare: -> a, b { b <=> a } # reverse order comparison
).to_a # => [5,3,2,1]

# 3 ascending enums with index
EnumUtils.sorted_union(
  [1,2].each,
  [2,3].each,
  [1,2,5].each,
  with_index: true
).to_a # => [[1,0], [2,0], [3,1], [5,2]]
```

### EnumUtils.sorted_merge

Given N consistently-sorted enums, return all their values while preserving the
global order. If `with_index: true` is given, also return index in the enum that
originated the value.

```ruby
## 3 ascending enums
EnumUtils.sorted_merge(
  [1,2].each,
  [2,3].each,
  [1,2,5].each
).to_a # => [1,1,2,2,2,3,5]

## 3 descending enums
EnumUtils.sorted_merge(
  [2,1].each,
  [3,2].each,
  [5,2,1].each,
  compare: -> a, b { b <=> a } # reverse order comparison
).to_a # => [5,3,2,2,2,1,1]

## 3 ascending enums with index
EnumUtils.sorted_union(
  [1,2].each,
  [2,3].each,
  [1,2,5].each,
  with_index: true
).to_a # => [[1,0], [1,2], [2,0], [2,1], [2,2], [3,1], [5,2]]
```

### EnumUtils.round_robin

Given N enums, return all their values by taking one value from each enum in
turn, until all are exhausted. If `with_index: true` is given, also return index
of the enum that originated the value.

```ruby
## 3 enums
EnumUtils.round_robin(
  [3,2].each,
  [1,3].each,
  [5,3,4].each
).to_a # => [3,1,5,2,3,3,4]

## 3 enums with index
EnumUtils.round_robin(
  [3,2].each,
  [1,3].each,
  [5,3,4].each,
  with_index: true
).to_a # => [[3,0], [1,1], [5,2], [2,0], [3,1], [3,2], [4,2]]
```

### EnumUtils.concat

Given N enums, return a new enum which lazily exhausts every enum.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake test` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and the created tag, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/maxim/enum_utils. This project is intended to be a safe,
welcoming space for collaboration, and contributors are expected to adhere to
the [code of
conduct](https://github.com/maxim/enum_utils/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the EnumUtils project's codebases, issue trackers, chat
rooms and mailing lists is expected to follow the [code of
conduct](https://github.com/maxim/enum_utils/blob/master/CODE_OF_CONDUCT.md).
