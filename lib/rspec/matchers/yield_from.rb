module RSpec
  module Matchers
    # :call-seq:
    #   should yield_from(method)
    #   should_not yield_from(method)
    #   should yield_from(method).with(object)
    #   should yield_from(method).with(object1, object2)
    #
    # Passes if method contains yield. You must call this
    # on an object that responds to the method that contains
    # the yield.
    #
    # == Example
    #
    #   class.should yield_from(:method_that_yields)
    #   class.should yield_from(:method_that_yields).with(an_object)
    def yield_from(method)
      Matcher.new :yield_from, method do |_method_|

        match do |method_caller|
          @method_caller = method_caller
          @method = _method_

          yielded? && objects_yielded?
        end

        chain :with do |*objects|
          objects_that_should_yield.push(*objects)
        end

        failure_message_for_should do |method_caller|
          unless yielded?
            "expected #{method_caller}.#{_method_} to yield"
          else
            "expected #{method_caller}.#{_method_} to yield #{objects_that_should_yield.join(', ').inspect} " \
            "not #{objects_yielded.join(', ').inspect}"
          end
        end

        failure_message_for_should_not do |method_caller|
          "expected #{method_caller}.#{_method_} to not yield #{objects_yielded.join(', ').inspect}"
        end

        def yielded?
          [].tap do |yielded|
            call_yieldable_method do
              yielded << true
            end
          end.any?
        end

        def objects_yielded?
          objects_yielded.should eq(objects_that_should_yield)
        end

        def objects_yielded
          [].tap do |objects_yielded|
            call_yieldable_method {|objects| objects_yielded.push(*objects) }
          end.compact
        end

        def objects_that_should_yield
          @objects_that_should_yield ||= []
        end

        def call_yieldable_method
          silence_warnings do
            @method_caller.__send__(@method) {|*objects| yield(objects) }
          end
        end

        def silence_warnings
          old_verbose, $VERBOSE = $VERBOSE, nil
          yield
        ensure
          $VERBOSE = old_verbose
        end
      end
    end
  end
end