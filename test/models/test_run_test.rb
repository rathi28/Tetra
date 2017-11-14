require 'test_helper'

class TestRunTest < ActiveSupport::TestCase
  test 'test run has test steps' do
  	testrun = TestRun.first()
  	assert testrun.test_steps
  end
end
