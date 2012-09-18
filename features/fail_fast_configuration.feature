Feature: Fail Fast Configuration

  In order to support multiple assertions per example, rspec-expectations
  supports can be configured to report all failing assertions, not just
  the first.

  Scenario: The first failure will exit the example by default
    Given a file named "fail_fast_spec.rb" with:
    """ruby
    describe "when failing on the first example" do
      it "should only report the first failed exception" do
        expect(1).to eq(2)
        expect(2).to eq(3)
      end
    end
    """
    When I run `rspec fail_fast_spec.rb`
    Then the output should contain "1 example, 1 failure"

  Scenario: The first failed assertion will exit the example when fail fast is enabled
    Given a file named "fail_fast_spec.rb" with:
    """ruby
    describe "when failing on the first example" do
      it "should only report the first failed exception" do
        expect(1).to eq(2)
        expect(2).to eq(3)
      end
    end
    """
    And a file named "fail_fast_enabled.rb" with:
    """ruby
    RSpec.configure do |rspec|
      rspec.expect_with :rspec do |c|
        c.fail_fast = true
      end
    end
    """
    When I run `rspec fail_fast_enabled.rb fail_fast_spec.rb`
    Then the output should contain "1 example, 1 failure"
