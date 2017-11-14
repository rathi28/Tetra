class AddTestStepToTestRun < ActiveRecord::Migration
  def change
    add_reference :test_steps, :test_run, index: true
  end
end
