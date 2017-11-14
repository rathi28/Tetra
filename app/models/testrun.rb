class Testrun < ActiveRecord::Base
  self.locking_column = :lock_test
  # maps to Testrun table in database
  has_one :error_message, dependent: :destroy
  # requires test_suites_id for test run creation
  validates :test_suites_id, presence: true


  # setup filter methods for sorting Testrun information. shortcut to creating WHERE statements in controller
  scope :brand, -> (brand) { where brand: brand }
  scope :campaign, -> (campaign) { where 'Campaign' => campaign }
  scope :platform, -> (platform) { where platform: platform }
  scope :browser, -> (browser) {  where("browser like ?", "#{browser}%") }
  scope :offercode, -> (offercode) { where :expectedoffercode => offercode }
  scope :runby, -> (runby) { where runby: runby }
  scope :env, -> (env) { where("Env like ?", "#{env}%") }

  ##
  # The list of testruns without a schedule date
  def self.test_ondemand_to_be_run
    Testrun.where(:status => "Not Started", :workerassigned => nil, :scheduledate => nil)
  end

  ##
  # The list of testruns scheduled to be run in the future
  def self.scheduled_tests
    self.where('scheduledate > ?', Time.now.strftime("%F %T"))
  end

  ##
  # The list of test runs that need to be run now
  def self.test_scheduled_to_be_run
    self.where('scheduledate < ?', Time.now.strftime("%F %T")).where(:workerassigned => nil, :status => "Not Started")
  end
end