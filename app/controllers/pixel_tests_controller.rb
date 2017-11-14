class PixelTestsController < ApplicationController
  include PixelsHelper
  include TestsuitesHelper

  def index

    admin_only do
      @suitetype = params[:suitetype]
      @pixelsuites = PixelTest.where(suitetype: @suitetype)
      filtering_params(params).each do |key, value|
          @pixelsuites = @pixelsuites.public_send(key, value) if value.present?
      end
      @url_count = {}
      @pixel_count = {}
      @pixelsuites.each do |pixeltest|
        testurls = pixeltest.test_urls
        @url_count[pixeltest.id] = testurls.count
        if(@suitetype.nil?)
          pixels = PixelData.where(test_url_id: testurls.first)
          @pixel_count[pixeltest.id] = pixels.count
        end
      end
    end
  end

  def show
    admin_only do
    wanted_suite = params[:id]
    @debug_vars = []
    @test = PixelTest.find(wanted_suite)
    
    @urls = @test.test_urls
    @checked_urls = []
    
    @url_validation = {}
    @pixels = {}
    @urls.each do |url_obj|
      @pixels[url_obj.id] = PixelData.where(test_url_id: url_obj.id)
      if(params[:validate_urls])
        begin
          @checked_urls.push(gen_url(url_obj.url, url_obj.appendstring, false))
          @url_validation[url_obj.id] = {
            status: 'passed'
          }
        rescue => e
          backtrace = e.backtrace if(e.backtrace)
          @url_validation[url_obj.id] = {
            backtrace: backtrace,
            status: 'failed',
            reason: e.message
          }
          flash.now[:danger] = "One or More URLs have errors in validation"
        end
      end
    end
    @debug_vars.push(@test)
    @debug_vars.push(@urls)
    @debug_vars.push(@pixels)
    @debug_vars.push(@url_validation)
    @debug_vars.push(@checked_urls)
    end
  end

  def new
    admin_only do
      @suitetype = params[:suitetype]
      @pixel = PixelTest.new()
    end
  end

  def duplicate
    admin_only do
      to_be_duplicated_suite = PixelTest.find(params[:pixelsuite])
      new_test = to_be_duplicated_suite.dup
      new_test.testname = new_test.testname + " copy"
      new_test.save!
      log_action('Duplicate', current_user ? current_user.username : 'Anonymous', params[:pixelsuite], 'PixelVanityUCITest Suite')
      log_action('Create', current_user ? current_user.username : 'Anonymous', new_test.id, 'PixelVanityUCITest Suite')

      test_urls = to_be_duplicated_suite.test_urls
      test_urls.each do |url|
        url_new = url.dup
        url_new.save!
        url_new.pixel_test_id = new_test.id
        pixel_collection = PixelData.where(test_url_id: url.id)
        pixel_collection.each do |pixel_item|
          pixel_new = pixel_item.dup
          pixel_new.save!
          pixel_new.test_url_id = url_new.id
          pixel_new.save!
        end
        url_new.save!
      end
      redirect_to "/pixel_tests?suitetype=#{to_be_duplicated_suite.suitetype}"
    end

  end

  def import
    admin_only do
      pixelsuite = PixelTest.find(params[:pixelsuite])
      log_action('Import Data', current_user ? current_user.username : 'Anonymous', params[:pixelsuite], 'PixelVanityUCITest Suite')
      
      case pixelsuite.suitetype
      when nil
        parse_imports(params)
      when 'seo'
        parse_imports_seo(params)
      else
        parse_imports_vanity_uci(params)
      end

      @urls.each_with_index do |url, urlindex|
        newurl = TestUrl.new(pixel_test_id: pixelsuite.id)
        newurl.url = url
        newurl.appendstring = @appendstrings[urlindex] if @appendstrings[urlindex]
        if(pixelsuite.suitetype != 'seo')
          if(@mmtest[urlindex])
            newurl.mmtest = @mmtest[urlindex].downcase.include?("y") ? 'yes' : 'no'
          else
            newurl.mmtest = 'no'
          end
          

          newurl.page_type = @type[urlindex] if @type[urlindex]
        end
        # Vanity and UCI imports
        if(pixelsuite.suitetype.nil? == false && pixelsuite.suitetype != 'seo')
          newurl.campaign   = @campaign[urlindex] ? @campaign[urlindex] : ''
          newurl.offercode  = @offercode[urlindex] ? @offercode[urlindex] : ''
          newurl.uci        = @uci[urlindex] ? @uci[urlindex] : ''
        end

        newurl.save!

        # only do this for pixel tests
        if(pixelsuite.suitetype.nil?)
          @pixel_flags.each_with_index do |pixel, pixelindex|
            newpixel = PixelData.new()
            newpixel.expected_state = @pixelstates[urlindex][pixelindex].to_i
            newpixel.pixel_name     = @pixels_titles[pixelindex]
            newpixel.pixel_handle   = pixel
            newpixel.test_url_id    = newurl.id
            newpixel.save!
          end
        end
      end
    

    redirect_to "/pixel_tests/#{pixelsuite.id}/edit"
    end
  end

  def previewimport
    admin_only do
      begin
        @pixelsuite = PixelTest.find(params[:pixelsuite])
        case @pixelsuite.suitetype
        when nil
          parse_imports(params)
        when 'seo'
          parse_imports_seo(params)
           render 'pixel_tests/preview_import_seo'
        else
          parse_imports_vanity_uci(params)
          render 'pixel_tests/preview_import_vanity'
        end
      rescue => e
        flash[:danger] = "Failed to parse data, check format and try again - Reason: #{e.message.to_s}"
        e.backtrace.each do |backtrace_item|
          Rails.logger.error backtrace_item
        end

        redirect_to action: :show, :id => params[:pixelsuite]
      end
    end
  end

  def create
    admin_only do
      @debug_vars = []
      @newtest = PixelTest.new(pixel_params)

      @newtest.suitetype = nil if @newtest.suitetype == ''
      
      if @newtest.save
        log_action('Create', current_user ? current_user.username : 'Anonymous', @newtest.id, 'PixelVanityUCITest Suite')
        redirect_to "/pixel_tests/#{@newtest.id}/edit"
      else
        @pixel = PixelTest.new()

        flash.now[:danger] = ""

        @newtest.errors.each do |key,value|
          flash.now[:danger] += "#{key} #{value}"
        end

        render '/pixel_tests/new'
      end
    end
  end

  def create_run
    logged_in_only do
      @suitetype = params[:suitetype].nil? ? 'pixels' : params[:suitetype]
      if(params['scheduletype'].nil?)
        params['scheduletype'] = 'one-time'
      end

      case params['scheduletype']
      when "weekly"
        schedule_create(@suitetype, 'weekly', params)
        redirect_to controller: 'schedule', action: "index"
      when "daily"
        schedule_create(@suitetype, 'daily', params)
        redirect_to controller: 'schedule', action: "index"
      else
        begin
          generate_pixel_test(params, current_user.username)
          redirect_to '/testsuites/' + @suitetype
        rescue => e
          flash[:danger] = "Failed to create Suite run: #{e.message}"
          redirect_to '/testsuites/' + @suitetype
        end
      end
    end
  end

  def edit
    admin_only do
      wanted_suite = params[:id]
      @debug_vars = []
      @test = PixelTest.find(wanted_suite)
      
      @urls = TestUrl.where(pixel_test_id: wanted_suite)

      @seo_validation_realms = SeoValidation.select(:realm).map(&:realm).uniq
      @url_validation = {}
      @pixels = {}
      @urls.each do |url_obj|
        @pixels[url_obj.id] = PixelData.where(test_url_id: url_obj.id)
        if(params[:validate_urls])
          begin
            gen_url(url_obj.url, url_obj.appendstring, false)
            @url_validation[url_obj.id] = {
              status: 'passed'
            }
          rescue => e
            backtrace = e.backtrace if(e.backtrace)
            @url_validation[url_obj.id] = {
              backtrace: backtrace,
              status: 'failed',
              reason: e.message
            }
            flash.now[:danger] = "One or More URLs have errors in validation"
          end
        end
      end
      @debug_vars.push(@test)
      @debug_vars.push(@urls)
      @debug_vars.push(@pixels)
      @debug_vars.push(@url_validation)
    end
  end

  def destroy
    @type = nil
    admin_only do
      @pixeltest = PixelTest.find(params[:id])
      @type = @pixeltest.suitetype
      @urls = TestUrl.where(pixel_test_id: @pixeltest.id)
      @pixels = []
      @urls.each do |url|
        @pixels.push PixelData.where(test_url_id: url.id)
      end
      @pixels.each do |pixel|
        pixel.destroy_all
      end
      @urls.destroy_all
      @pixeltest.destroy!
    end
    # case @type.downcase
    # when nil
    #   redirect_to "/pixel_tests?suitetype=#{@type}"
    # when "vanity"
    #   redirect_to "/pixel_tests?suitetype=#{@type}"
    # when "uci"
    #  redirect_to "/pixel_tests?suitetype=#{@type}"
    # when "seo"
    #   redirect_to "/pixel_tests?suitetype=#{@type}"
    # else
    #   redirect_to "/pixel_tests?suitetype=#{@type}"
    # end
     case @type
    when nil
      redirect_to "/pixel_tests", notice: 'Pixel testsuite was successfully destroyed.'  
    when "Vanity"      
      redirect_to "/test_config/vanity", notice: 'Vanity testsuite was successfully destroyed.'       
    when "UCI"     
      redirect_to "/test_config/uci", notice: 'UCI testsuite was successfully destroyed.'       
    when "seo"
      redirect_to "/test_config/seo", notice: 'Seo testsuite was successfully destroyed.'       
    else
      redirect_to "/pixel_tests?suitetype=#{@type}"
    end
  end

  def update
    admin_only do
      @pixeltest = PixelTest.find(params[:id])
      @pixeltest.update(pixel_params)
      @pixeltest.save!
      log_action('Update', current_user ? current_user.username : 'Anonymous', @pixeltest.id, 'PixelVanityUCITest Suite')
      redirect_to @pixeltest
    end
  end

  def url

  end
  

  private
    # Pixel Test filtering limiter
    def filtering_params(params)
      params.slice(:environment, :testtype)
    end

    ##
    # whitelist for pixel test creation/updating parameters
    def pixel_params
      params.require(:pixel_test).permit(
      :testtype, 
      :testname, 
      :environment,
      :mmtest,
      :suitetype
      )
    end

    ##
    # Parses imports for the Pixel tests
    def parse_imports(params)
      data = params[:rawdata]
      rows = data.split(/[\n\r]+/)
      rowsandcolumns = []
      rows.each do |row|
        columns = row.split("\t")
        rowsandcolumns.push columns
      end
      @data = rowsandcolumns
      
      # store titles row
      @pixels_titles = rowsandcolumns[0]

      # removing the url header sections
      @pixels_titles.delete_at(0)
      @pixels_titles.delete_at(0)
      @pixels_titles.delete_at(0)
      @pixels_titles.delete_at(0)
      
      # store the flags row
      @pixel_flags = rowsandcolumns[1]

      # removing the url header sections
      @pixel_flags.delete_at(0)
      @pixel_flags.delete_at(0)
      @pixel_flags.delete_at(0)
      @pixel_flags.delete_at(0)


      @type = []
      @urls = []
      @appendstrings = []
      @mmtest = []
      @pixelstates = []

      urldata = rowsandcolumns
      # remove headers and pixel labels
      urldata.delete_at(0) 
      # Remove url headers and pixel flags
      urldata.delete_at(0)
      
      urldata.each do |url|
        # store the page type
        @type.push(url[0])
        # store the url string
        @urls.push(url[1])
        # store the append value
        @appendstrings.push(url[2])
        # store the mmtest value
        @mmtest.push(url[3])
        # save the row for pixel state
        pixelstate = url
        pixelstate.delete_at(0)
        pixelstate.delete_at(0)
        pixelstate.delete_at(0)
        pixelstate.delete_at(0)
        @pixelstates.push(pixelstate)
      end
  end

  ##
  # Parses imports for the Vanity/URL tests
  def parse_imports_vanity_uci(params)
    data = params[:rawdata]
    rows = data.split(/[\n\r]+/)
    rowsandcolumns = []
    rows.each do |row|
      columns = row.split("\t")
      rowsandcolumns.push columns
    end
    @data = rowsandcolumns

    @type           = []
    @urls           = []
    @appendstrings  = []
    @mmtest         = []
    @campaign       = []
    @offercode      = []
    @uci            = []

    headers = {}
    urldata = rowsandcolumns
    urldata[0].each_with_index do |col_name, index|
      headers[col_name] = index
    end
    
    # Remove url headers
    urldata.delete_at(0)

    urldata.each do |url|
      if(headers['url'])
        # # store the page type
        @type.push(url[headers['Type']]) if headers['Type']
        @type.push(url[headers['Page Type']]) if headers['Page Type']
        # store the url string
        @urls.push(url[headers['url']])
        
        # store the UCI string
        if headers['UCI']
          @uci.push(url[headers['UCI']])
        end
        # store the Append string
        if headers['Appender']
          @appendstrings.push(url[headers['Appender']])
        end

        # store the mmtest value
        if headers['Is MMTest']
          @mmtest.push(url[headers['Is MMTest']]) if url[headers['Is MMTest']]
        end

        # store the campaign string
        if headers['Campaign']
          @campaign.push(url[headers['Campaign']]) if url[headers['Campaign']]
        end
        
        # store the offercode string
        if headers['Offercode']
          @offercode.push(url[headers['Offercode']]) if url[headers['Offercode']]
        end
      end
    end
  end

  ##
  # Parses imports for the Vanity/URL tests
  def parse_imports_seo(params)
    data = params[:rawdata]
    rows = data.split(/[\n\r]+/)
    rowsandcolumns = []
    rows.each do |row|
      columns = row.split("\t")
      rowsandcolumns.push columns
    end
    @data = rowsandcolumns

    # @type           = []
    @urls           = []
    @appendstrings  = []
    # @mmtest         = []
    # @campaign       = []
    # @offercode      = []
    # @uci            = []
    # @realm          = []
    # @is_core        = []

    headers = {}
    urldata = rowsandcolumns
    urldata[0].each_with_index do |col_name, index|
      headers[col_name] = index
    end
    
    # Remove url headers
    urldata.delete_at(0)
    
    urldata.each do |url|
      if(url[headers['url']])
        # # store the page type
        # @type.push(url[headers['Type']]) if headers['Type']
        # @type.push(url[headers['Page Type']]) if headers['Page Type']
        
        # store the url string
        @urls.push(url[headers['url']])

        # store the Append string
        if headers['Appender']
          @appendstrings.push(url[headers['Appender']])
        end
        
        # # store the UCI string
        # if headers['UCI']
        #   @uci.push(url[headers['UCI']])
        # end

        # # store the mmtest value
        # if headers['Is MMTest']
        #   @mmtest.push(url[headers['Is MMTest']]) if url[headers['Is MMTest']]
        # end

        # # store the campaign string
        # if headers['Campaign']
        #   @campaign.push(url[headers['Campaign']]) if url[headers['Campaign']]
        # end
        
        # # store the offercode string
        # if headers['Offercode']
        #   @offercode.push(url[headers['Offercode']]) if url[headers['Offercode']]
        # end
        # # store the offercode string
        # if headers['Realm']
        #   @realm.push(url[headers['Realm']]) if url[headers['Realm']]
        # end
        # # store the offercode string
        # if headers['Is_Core']
        #   @is_core.push(url[headers['Is_Core']]) if url[headers['Is_Core']]
        # end
      end
    end
  end
end
