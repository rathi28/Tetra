require 'erb'

class EmailBuilder
  attr_accessor :body
  attr_accessor :options
  attr_accessor :title
  attr_accessor :reciepient

  def initialize(to_mail)
    self.reciepient = to_mail
    self.body = ""
    self.title = "Default Email Title"
    self.options = {
        :address              => "smtp.gmail.com",
        :port                 => 587,
        :user_name            => 'autoreportsgr@gmail.com',
        :password             => 'dwsjevgenqdsagao',
        :authentication       => 'plain',
        :enable_starttls_auto => true
    }
  end

  # deprecated 
  def add_attachments(mail, key)
    screenshots = Dir["/debug/#{key}/*.png"]
    return mail if(screenshots.empty?)
    screenshots.each do |attachment|
      mail.add_file(attachment)
    end
    return mail
  end

  def create_buyflow_email_body(suite)
    report_body = "<body bgcolor='#E6E6E6' border: 1px solid blue;><font face='verdana'>"
    report_body += generate_header("Buyflow Test")
    report_body += generate_buyflow_links(suite)
    report_body += generate_buyflow_table(TestSuites.find(suite))
    report_body += '<br>' + suite.to_s
    report_body += "</font></body>"
  end

  # sends emails for new test run records
  # @note this is also used for Vanity and UCI tests
  def create_pixel_email(pixel_suite)
    @suite_obj = TestSuites.find(pixel_suite)
    @test_runs = TestRun.where(test_suites_id: pixel_suite)
    erb = ERB.new(File.open("#{__dir__}/pixel_email.html.erb").read).result(binding)
  end

  # functions that may be needed in future, but not right now
  
  # def generate_pixel_links(pixel_suite)

  # end

  # def generate_pixel_table(pixel_suite)

  # end

  def generate_buyflow_table(suite)
    results = suite.testruns
    sum = 0
    failErrorSummary = ''
    color_status = ''
    results.entries.each do |row|
        color_status = "#009900" if row["result"].upcase == "PASS"
        color_status = "#FF9900" if row["result"].upcase == "ERR"
        color_status = "#FF3300" if row["result"].upcase == "FAIL"
        failErrorSummary +="""
          <tr>
              <td style='background-color: #{color_status}; color:#FFFFFF; border: 1px solid black;' align='center'><strong><font face='verdana' size='1'>#{row["result"]}</font></strong></td>
              <td style='border: 1px solid black;' align='center'><font face='verdana' size='1'>#{row["Brand"]}</font></td>
              <td style='border: 1px solid black;' align='center'><font face='verdana' size='1'>#{row["Campaign"]}</font></td>
              <td style='border: 1px solid black;' align='center'><font face='verdana' size='1'>#{row["ExpectedOffercode"]}</font></td>
              <td style='border: 1px solid black;' align='center'><font face='verdana' size='1'>#{row["ActualOffercode"]}</font></td>
              <td style='border: 1px solid black;' align='center'><font face='verdana' size='1'>#{row["ConfirmationNum"]}</font></td>
          </tr>
          """
    end

    errorTable = ''
    unless failErrorSummary == ''
      errorTable = """
      <br />
      <br />
      <table border: 1px solid black; bgcolor='#000000' width='100%' color='#FFFFFF' cellpadding='10' cellspacing='0'>
        <tr>
            <td align='center'>
              <b><font face='verdana' size='3' color='#FFFFFF'>
                Test Run results
              </font></b>
            </td>
        </tr>
        </table>
        <table style='border: 1px solid black; table-layout: fixed;' cellpadding='5px' cellspacing='0' bgcolor='#FFFFFF' width='100%'>
          <tr style='text-align: center; color:#ffffff;' bgcolor='#4E5E66'>
              <td style='border: 1px solid black;'>
                <strong>
                  Status
                </strong>
              </td>
              <td width='20%' style='border: 1px solid black;'>
                <strong><font size='1' face='verdana'>Test Name</font></strong>
              </td>
              <td style='border: 1px solid black;'>
                <strong><font size='1' face='verdana'>Brand</font></strong>
              </td>
              <td style='border: 1px solid black;'>
                <strong><font size='1' face='verdana'>Expected Offercode</font></strong>
              </td>
              <td style='border: 1px solid black;'>
                <strong><font size='1' face='verdana'>Actual Offercode</font></strong>
              </td>
              <td style='border: 1px solid black;'>
                <strong><font size='1' face='verdana'>Conf #</font></strong>
              </td>
              <td style='border: 1px solid black;'>
                <strong><font size='1' face='verdana'>Notes</font></strong>
              </td>
          </tr>
          #{failErrorSummary}
        </table>
          """
    end
    return errorTable
  end

  def generate_header(title_of_email)
    return """
    <table width='100%' bgcolor='#4E5E66' cellspacing='0'>
    <td align='center' face='verdana'>
        <br /> <font face='verdana' size='4' color='#FFFFFF'><b>#{title_of_email} Complete</b></font>
        <br />
        <br />
    </td>
</table>
    """

  end


  def generate_summary_table(summary, current_line)
    pass_rate = current_line["Pass Rate"].to_i
    green_threshold   = 90
    yellow_threshold  = 50
    red_threshold     = 0

    pass_rate_color = "#990000" if(pass_rate >= red_threshold)
    pass_rate_color = "#FFCC00" if(pass_rate >= yellow_threshold)
    pass_rate_color = "#009933" if(pass_rate >= green_threshold)

    return """

    <table bgcolor='#000000' width='100%' color='#FFFFFF' cellpadding='10' cellspacing='0'>
    <tr>
        <td align='center'><b><font face='verdana' size='3' color='#FFFFFF'>Report Summary</font></b>
        </td>
    </tr>
</table>
    <table  bgcolor='#FFFFFF' width='100%' cellpadding='5' cellspacing='0'>
      <tr>
        <td><font face='verdana'>Ran by:</font></td>
        <td><font face='verdana'> #{current_line["Ran by"]}</font></td>
      </tr>
      <tr>
        <td><font face='verdana'>DateTime (PST):</font></td>
        <td><font face='verdana'>#{current_line["DateTime (PST)"]}</font></td>
      </tr>
      <tr>
        <td><font face='verdana'>Test Suite Name:</font></td>
        <td><font face='verdana'>#{current_line["Test Suite Name"]}</font></td>
      </tr>
      <tr>
        <td><font face='verdana'>Number of Pass:</font></td>
        <td bgcolor='#E6F5E6'>#{current_line["Pass"]}</font></td>
      </tr>
      <tr>
        <td><font face='verdana'>Number of Fail/Error:</font></td>
        <td bgcolor='#FFE6E6'>#{current_line["Fail/Error"]}</font></td>
      </tr>
      <tr>
        <td><font face='verdana'>Total test(s):</font></td>
        <td><font face='verdana'>#{current_line["Total Tests"]}</font></td>
      </tr>
      <tr>
        <td><font face='verdana'>Pass Rate:</font></td>
        <td bgcolor='#{pass_rate_color}'>
          <font size='4' color='#FFFFFF' face='verdana'>
            <strong>
              #{pass_rate.to_s}%
            </strong>
          </font>
        </td>
      </tr>
    </table>
    <br \\> <br \\>"""
  end

  def generate_uci_links(report)
    return """
    <table width='100%' cellspacing='1' cellpadding='10'>
      <tr>
          <td bgcolor='#4E5E66' align='center'>
            <a style='color:#FFFFFF; display:block; text-decoration: none;' href='#{report.spreadsheet.human_url}'>
              <strong>
                <font size='3' face='verdana'>
                  Go to Detailed Report
                </font>
              </strong>
            </a>
          </td>
      </tr>
    </table>
    """
  end

  def generate_buyflow_links(report)
    require 'uri'
    ENV['TETRA_BASE_URL'] = "https://www.grautomation.guthy-renker.com/" #Changed http to https to support the Secure url implementation
    suite_url = URI.parse(ENV['TETRA_BASE_URL'])
    suite_url.path = "/testsuites/#{report}"
    return """
    <table width='100%' cellspacing='1' cellpadding='10'>
      <tr>
          <td bgcolor='#4E5E66' align='center'>
            <a style='color:#FFFFFF; display:block; text-decoration: none;' href='#{suite_url.to_s}'>
              <strong>
                <font size='3' face='verdana'>
                  Go to Test Suite Page
                </font>
              </strong>
            </a>
          </td>
      </tr>
    </table>
    """
  end

  def deliver(key = nil)
    body_of_email = self.body
    options = self.options
    Mail.defaults do
      delivery_method :smtp, options
    end

    mail = Mail.new
    mail
    mail.from = 'autoreportsgr@gmail.com'
    mail.to = reciepient
    mail.subject = title
    mail = add_attachments(mail, key) if key
    html_part = Mail::Part.new
    html_part.content_type  =  'text/html; charset=UTF-8'
    html_part.body  = body_of_email

    mail.html_part = html_part

    mail.deliver!
  end
end
