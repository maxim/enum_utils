module EnumUtils
  # This is an enumerator wrapper that always caches 1 item in its buffer, and
  # provides the ability to check if underlying enumerator is exhausted.
  class ExhaustibleIter
    EXHAUSTED = Object.new

    attr_reader :buff_value

    def initialize(source); @source = source; pull        end
    def exhausted?;         @buff_value.equal?(EXHAUSTED) end
    def next;               @buff_value.tap { pull }      end

    private

    def pull
      @buff_value = @source.next
    rescue StopIteration
      @buff_value = EXHAUSTED
    end
  end
end
