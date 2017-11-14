class TestSuites < ActiveRecord::Base
  # maps to Testsuites table in database
  has_many :test_runs, dependent: :destroy
  has_many :testruns, dependent: :destroy

  # setup filter methods for sorting Test Suite information. shortcut to creating WHERE statements in controller
  scope :suitetype, -> (suitetype) { where('SuiteType' => suitetype) }
  scope :status, -> (status) { where('Status' => status) }
end