class ErrorMessage < ActiveRecord::Base
  belongs_to :testrun
  belongs_to :test_run
end
