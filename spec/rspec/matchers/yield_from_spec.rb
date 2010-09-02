require 'spec_helper'

module RSpec
  module Matchers
    describe 'should yield_from(method)' do

      context 'method containing yield' do
        subject do
          Class.new do
            def initialize
              yield
            end
          end
        end

        it('passes') { should yield_from(:new) }

        it 'provides a failure message for should_not' do
          expect { should_not yield_from(:new) }.to fail_with(/expected #<Class.*>.new to not yield/)
        end
      end

      context 'method not containing yield' do
        subject do
          Class.new do
            def initialize
            end
          end
        end

        it('fails') { should_not yield_from(:new) }

        it 'provides a failure message for should' do
          expect { should yield_from(:new) }.to fail_with(/expected #<Class.*>.new to yield/)
        end
      end

    end

    describe 'should yield_from(method).with(object)' do

      context 'method that yields one object' do
        subject do
          Class.new do
            def initialize
              yield 'yielded object'
            end
          end
        end

        it('passes') { should yield_from(:new).with('yielded object') }
      end

      context 'method that yields two objects' do
        subject do
          Class.new do
            def initialize
              yield 'yielded object 1', 'yielded object 2'
            end
          end
        end

        it('passes') { should yield_from(:new).with('yielded object 1', 'yielded object 2') }

        it 'provides a failure message for should' do
          expect {
            should yield_from(:new).with('foo')
          }.to fail_with(/expected #<Class.*>.new to yield "foo" not "yielded object 1, yielded object 2"/)
        end

        it 'provides a failure message for should_not' do
          expect {
            should_not yield_from(:new).with('yielded object 1', 'yielded object 2')
          }.to fail_with(/expected #<Class.*>.new to not yield "yielded object 1, yielded object 2"/)
        end
      end

    end
  end
end