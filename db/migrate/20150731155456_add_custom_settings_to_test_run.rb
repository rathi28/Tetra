class AddCustomSettingsToTestRun < ActiveRecord::Migration
  def change
    add_column :test_runs, :custom_settings, :text
  end
end
