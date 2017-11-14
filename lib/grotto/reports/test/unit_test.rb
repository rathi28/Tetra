require_relative 'gr_reporting'

describe "Reporting" do
  specify "print basic report" do
    report              = GRReporting::Report.new()
    report.author       = "Unit Author"
    report.title        = "Reporting Unit Test"
    report.runtime      = "60"
    report.status       = "Pass"
    report.grcid        = "t4-summer"
    report.browser      = "chrome 32"
    report.os           =  "windows 8.1"
    report.environment  = "qa"
    Rails.logger.info report.to_s
  end

  specify "upload basic report" do
    report              = GRReporting::Report.new()
    report.author       = "Unit Author"
    report.title        = "Reporting Unit Test"
    report.runtime      = "60"
    report.status       = "Pass"
    report.grcid        = "t4-summer"
    report.browser      = "chrome 32"
    report.os           =  "windows 8.1"
    report.environment  = "qa"
    report.upload
  end

  specify "upload buyflow report" do

    report = GRReporting::Report.new()
    report.author                             = "Unit Author"
    report.title                              = "Reporting Unit Test"
    report.runtime                            = "60"
    report.status                             = "Pass"
    report.grcid                              = "t4-summer"
    report.browser                            = "Chrome"
    report.os                                 = "Windows 8.1"
    report.environment                        = "QA"
    report.datetime                           = GRReporting.get_pst()

    report.buyflow_report                     = GRReporting::BuyflowReport.new()
    report.buyflow_report.brand               = 'ProactivPlus'
    report.buyflow_report.expected_offer_code = 'D7FAKE'
    report.buyflow_report.offer_code          = 'D7FAKE'
    report.buyflow_report.vitamin_code        = 'D7FAKE'
    report.buyflow_report.confirmation_number = 'DWFAKECONF02'

    report.uci_report                         = GRReporting::UCIReport.new()
    report.uci_report.expected_uci            = 'US-Fake-UCI-12-12-12'
    report.uci_report.uci_mp                  = 'US-Fake-UCI-12-12-12'
    report.uci_report.uci_op                  = 'US-Fake-UCI-12-12-12'
    report.uci_report.uci_cp                  = 'US-Fake-UCI-12-12-12'

    report.upload
  end

end
