Feature: yield from

  Expect a method to yield, and optionally check its yielded object/s.

  Scenario: expect a method to yield
    Given a file named "method_that_yields_spec.rb" with:
      """
      describe "a method that yields" do
        subject do
          Class.new do
            def initialize
              yield
            end
          end
        end

        it "passes" do
          should yield_from(:new)
        end
      end
      """
    When I run "rspec method_that_yields_spec.rb"
    Then the output should contain "1 example, 0 failures"

  Scenario: expect a method to yield one object
    Given a file named "method_that_yields_one_object_spec.rb" with:
      """
      describe "a method that yields one object" do
        subject do
          Class.new do
            def initialize
              yield "yielded"
            end
          end
        end

        it "passes" do
          should yield_from(:new).with("yielded")
        end
      end
      """
    When I run "rspec method_that_yields_one_object_spec.rb"
    Then the output should contain "1 example, 0 failures"

  Scenario: expect a method to yield multiple objects
    Given a file named "method_that_yields_multiple_objects_spec.rb" with:
      """
      describe "a method that yields multiple objects" do
        subject do
          Class.new do
            def initialize
              yield "yielded", "yielded again"
            end
          end
        end

        it "passes" do
          should yield_from(:new).with("yielded", "yielded again")
        end
      end
      """
    When I run "rspec method_that_yields_multiple_objects_spec.rb"
    Then the output should contain "1 example, 0 failures"