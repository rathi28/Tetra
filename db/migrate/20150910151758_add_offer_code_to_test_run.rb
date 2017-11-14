class AddOfferCodeToTestRun < ActiveRecord::Migration
  def change
    add_column :test_runs, :offercode, :string
  end
end
