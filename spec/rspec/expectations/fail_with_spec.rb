require 'spec_helper'

describe RSpec::Expectations do
  def self.turn_on_fail_fast
    before { RSpec::Matchers.configuration.fail_fast = false }
    after { RSpec::Matchers.configuration.fail_fast = true }
  end

  describe "#fail_with with diff" do
    let(:differ) { double("differ") }

    before(:each) do
      RSpec::Expectations.stub(:differ) { differ }
    end

    it "calls differ if expected/actual are not strings (or numbers or procs)" do
      differ.should_receive(:diff_as_object).and_return("diff")
      lambda {
        RSpec::Expectations.fail_with "the message", Object.new, Object.new
      }.should fail_with("the message\nDiff:diff")
    end

    context "with two strings" do
      context "and actual is multiline" do
        it "calls differ" do
          differ.should_receive(:diff_as_string).and_return("diff")
          lambda {
            RSpec::Expectations.fail_with "the message", "expected\nthis", "actual"
          }.should fail_with("the message\nDiff:diff")
        end
      end

      context "and expected is multiline" do
        it "calls differ" do
          differ.should_receive(:diff_as_string).and_return("diff")
          lambda {
            RSpec::Expectations.fail_with "the message", "expected", "actual\nthat"
          }.should fail_with("the message\nDiff:diff")
        end
      end

      context "and both are single line strings" do
        it "does not call differ" do
          differ.should_not_receive(:diff_as_string)
          lambda {
            RSpec::Expectations.fail_with("the message", "expected", "actual")
          }.should fail_with("the message")
        end
      end
    end

    it "does not call differ if no expected/actual" do
      lambda {
        RSpec::Expectations.fail_with "the message"
      }.should fail_with("the message")
    end

    it "does not call differ expected is Numeric" do
      lambda {
        RSpec::Expectations.fail_with "the message", 1, "1"
      }.should fail_with("the message")
    end

    it "does not call differ when actual is Numeric" do
      lambda {
        RSpec::Expectations.fail_with "the message", "1", 1
      }.should fail_with("the message")
    end

    it "does not call differ if expected or actual are procs" do
      lambda {
        RSpec::Expectations.fail_with "the message", lambda {}, lambda {}
      }.should fail_with("the message")
    end
  end

  describe "#expectation_not_met with message" do
    context "when fail fast mode is off" do
      turn_on_fail_fast
      it "does not raise the failure immediately" do
        lambda {
          RSpec::Expectations.expectation_not_met "the message"
        }.should_not fail
      end

      it "adds the message to the expectation collection" do
        RSpec::Expectations.should_receive(:add_to_failures)
        RSpec::Expectations.expectation_not_met "the message"
      end
    end

    context "when fail fast mode is on" do
      it "raises the failure immediately" do
        lambda {
          RSpec::Expectations.expectation_not_met "the message"
        }.should fail
      end
    end
  end

  describe "#raise_collected_failures" do
    turn_on_fail_fast

    it "raise an error" do
      RSpec::Expectations.add_to_failures "the message"
      lambda { RSpec::Expectations.raise_collected_failures }.should fail
    end

    it "clears out the failure messages" do
      RSpec::Expectations.add_to_failures "the message"
      lambda { RSpec::Expectations.raise_collected_failures }.should fail
      RSpec::Expectations.instance_variable_get(:@failure_messages).should be_empty
    end

    context "the error" do
      it "does have all the of the failure messages present" do
        RSpec::Expectations.add_to_failures "the message"
        RSpec::Expectations.add_to_failures "the other message"

        lambda {
          RSpec::Expectations.raise_collected_failures
        }.should fail_with("- the message\n- the other message")
      end
    end
  end
end
