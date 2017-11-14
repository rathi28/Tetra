class AddStepNameToTestSteps < ActiveRecord::Migration
  def change
    add_column :test_steps, :step_name, :string
  end
end
