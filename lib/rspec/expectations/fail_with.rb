module RSpec
  module Expectations
    class << self
      # @private
      def differ
        @differ ||= Differ.new
      end

      # Raises an RSpec::Expectations::ExpectationNotMetError with message.
      # @param [String] message
      # @param [Object] expected
      # @param [Object] actual
      #
      # Adds a diff to the failure message when `expected` and `actual` are
      # both present.
      def fail_with(message, expected=nil, actual=nil)
        if !message
          raise ArgumentError, "Failure message is nil. Does your matcher define the " +
                               "appropriate failure_message_for_* method to return a string?"
        end

        if actual && expected
          if all_strings?(actual, expected)
            if any_multiline_strings?(actual, expected)
              expected = expected.join(',') if Array === expected
              message << "\nDiff:" << differ.diff_as_string(actual, expected)
            end
          elsif no_procs?(actual, expected) && no_numbers?(actual, expected)
            message << "\nDiff:" << differ.diff_as_object(actual, expected)
          end
        end

        RSpec::Expectations.expectation_not_met(message)
      end

      def expectation_not_met(message)
        if RSpec::Matchers.configuration.fail_fast?
          raise(RSpec::Expectations::ExpectationNotMetError.new(message))
        else
          RSpec::Expectations.add_to_failures(message)
        end
      end

      def add_to_failures(message)
        @failure_messages ||= []
        @failure_messages << message
      end

      def raise_collected_failures
        if @failure_messages.one?
          message = @failure_messages.first
        else
          message = @failure_messages.collect { |message| "- #{message}" }.join("\n")
        end
        @failure_messages = []
        raise(RSpec::Expectations::ExpectationNotMetError.new(message))
      end

    private

      def no_procs?(*args)
        args.flatten.none? {|a| Proc === a}
      end

      def all_strings?(*args)
        args.flatten.all? {|a| String === a}
      end

      def any_multiline_strings?(*args)
        all_strings?(*args) && args.any? {|a| a =~ /\n/}
      end

      def no_numbers?(*args)
        args.flatten.none? {|a| Numeric === a}
      end
    end
  end
end
