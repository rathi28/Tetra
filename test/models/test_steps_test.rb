require 'test_helper'

class TestStepsTest < ActiveSupport::TestCase
  test 'test steps have test run owners' do
  	step = TestStep.first()
  	assert step.test_run
  end
end
