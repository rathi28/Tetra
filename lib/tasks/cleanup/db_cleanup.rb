require 'csv'
class DbCleanup < ActiveRecord::Base
  def self.userdata
	 #call all methods here eg: DbCleanup.delete_brandurldata(data_to_delete)
	 @brands_to_exclude = ['Wen', 'WenHaircare', 'Sheercover', 'ReclaimBotanical', 'ITCosmetics', 'CrepeErase', 'PrincipalSecret', 'MeaningfulBeauty', 'Perricone', 'BeautyBioscience', 'Lumipearl']    
	 @brands_to_include = ['ProactivPlus', 'Xout', 'DrDenese', 'Supersmile', 'Proactiv', 'HandPerfection']
   @brand_to_remove = Brand.where('Brandname not in (?)', @brands_to_exclude)   
   @brands_excluded_selection_workarounds_to_remove = BrandsExcludedSelectionWorkaround.where('brand not in (?)', @brands_to_exclude)
   @brandurldata_to_remove = Brandurldata.where('brand not in (?)', @brands_to_exclude)
   @campaign_to_remove = Campaign.where('Brand not in (?)', @brands_to_exclude)
   @campaigns_to_remove=[]
   @campaign_to_remove.each do |campaign|
     @campaigns_to_remove << "#{campaign.id}"
   end   
	 @locatorbrands_to_remove = Locator.where('brand in (?)', @brands_to_include)      
   testsuite_brands_to_remove = TestSuites.where('Brand in (?)', @brands_to_include)   
   @testrun_to_remove = Testrun.where('Brand in (?)', @brands_to_include)  
   @testsuite_brands_to_remove=[]
   testsuite_brands_to_remove.each do |brand|
     @testsuite_brands_to_remove << "#{brand.id}"
   end   
     delete_brandurldata(@brandurldata_to_remove)
     delete_brands_excluded_selection_workarounds(@brands_excluded_selection_workarounds_to_remove)         
     delete_offer_data_detail(@campaigns_to_remove)
     delete_offerdatum(@campaigns_to_remove)
     delete_campaigns(@campaigns_to_remove)
     delete_locators(@locatorbrands_to_remove)
     delete_test_steps(@testsuite_brands_to_remove)
     delete_test_runs(@testsuite_brands_to_remove)
     delete_testrun(@testrun_to_remove)
     delete_test_suites(@testsuite_brands_to_remove)
     delete_test_urls(@brands_to_include)
     delete_brands(@brand_to_remove)
  end

  def self.delete_brands(data)
    brand_id = data
    @brand_id=[]
    brand_id.each do |brand|
      @brand_id << "#{brand.idBrands}"
    end
    @brands_to_remove = Brand.where('idBrands in (?)',@brand_id)    
    brands_to_delete_backup=[]
    @brands_to_remove.each do |brand|
      brands_to_delete_backup << "#{brand.idBrands},#{brand.Brandname}"
      Brand.delete(brand.idBrands)
    end

  	f = File.open('brands_entries.txt', 'w')
    f.puts brands_to_delete_backup
    f.close
  end

  def self.delete_brands_excluded_selection_workarounds(data)
    brand_id = data
    @brand_id=[]
    brand_id.each do |brand|
      @brand_id << "#{brand.id}"
    end
    @brands_to_remove = BrandsExcludedSelectionWorkaround.where('id in (?)',@brand_id)
    brands_excluded_selection_workaround=[]
    brands_excluded_selection_workaround_to_delete_backup=[]
    @brands_to_remove.each do |brand|
      brands_excluded_selection_workaround_to_delete_backup << "#{brand.id},#{brand.brand},#{brand.created_at},#{brand.updated_at}"
      BrandsExcludedSelectionWorkaround.delete(brand.id)
    end

    f = File.open('brands_excluded_selection_workaround_entries.txt', 'w')
    f.puts brands_excluded_selection_workaround_to_delete_backup
    f.close
  end

  def self.delete_brandurldata(data)
    brand_id = data
    @brand_id=[]
    brand_id.each do |brand|
      @brand_id << "#{brand.id}"
    end
    @brands_to_remove = Brandurldata.where('id in (?)',@brand_id)
    brandurldata_workaround=[]
    brandurldata_workaround_to_delete_backup=[]
    @brands_to_remove.each do |brand|
      brandurldata_workaround_to_delete_backup << "#{brand.id},#{brand.brand},#{brand.development},#{brand.qa},#{brand.prod},#{brand.test_env},#{brand.stg}"
      Brandurldata.delete(brand.id)
    end  

    f = File.open('brandurldata_workaround_entries.txt', 'w')
    f.puts brandurldata_workaround_to_delete_backup
    f.close
  end

  def self.delete_offer_data_detail(data)
    brand_id = data
    @brand_to_remove = Offerdatum.where('campaign_id is not null and campaign_id in (?)',brand_id)
    @brands_to_remove=[]
    @brand_to_remove.each do |brand|
      @brands_to_remove << "#{brand.id}"
    end
    @offerdatadetail_to_remove=[]
    offerdatadetail_workaround=[]
    offerdatadetail_workaround_to_delete_backup=[]
    @offerdatadetail_to_remove = OfferDataDetail.where('offerdatum_id in (?)', @brands_to_remove) 
    @offerdatadetail_to_remove.each do |brand|
      offerdatadetail_workaround_to_delete_backup << "#{brand.id},#{brand.offer_title},#{brand.offerdesc},#{brand.offerdatum_id},#{brand.created_at},#{brand.updated_at}"
      OfferDataDetail.delete(brand.id)
    end
    
    f = File.open('offerdatadetail_workaround_entries.txt', 'w')
    f.puts offerdatadetail_workaround_to_delete_backup
    f.close   
  end

  def self.delete_offerdatum(data)
    brand_id = data
    @brands_to_remove = Offerdatum.where('campaign_id is not null and campaign_id in (?)',brand_id)
    offerdatum_workaround=[]
    offerdatum_workaround_to_delete_backup=[]
    @brands_to_remove.each do |brand|
      offerdatum_workaround_to_delete_backup << "#{brand.id},#{brand.OfferCode},#{brand.SupplySize},#{brand.PieceCount},#{brand.Bonus},#{brand.Offer},#{brand.ExtraStep},#{brand.Entry},#{brand.Continuity},#{brand.StartSH},#{brand.ContinuitySH},#{brand.Rush},#{brand.OND},#{brand.grcid},#{brand.Brand},#{brand.qa},#{brand.prod},#{brand.desktop},#{brand.mobile},#{brand.isvitamin},#{brand.cart_description},#{brand.product},#{brand.stg},#{brand.campaign_id}"
      Offerdatum.delete(brand.id)
    end

    f = File.open('offerdatum_workaround_entries.txt', 'w')
    f.puts offerdatum_workaround_to_delete_backup
    f.close  
  end

  def self.delete_campaigns(data)
    brand_id = data
    @brands_to_remove = Campaign.where('id in (?)',brand_id)
    campaigns_workaround=[]
    campaigns_workaround_to_delete_backup=[]
    @brands_to_remove.each do |brand|
      campaigns_workaround_to_delete_backup << "#{brand.id},#{brand.Brand},#{brand.grcid},#{brand.campaignname},#{brand.core},#{brand.Active},#{brand.DesktopBuyflow},#{brand.DesktopHomePageTemplate},#{brand.DesktopSASTemplate},#{brand.DesktopSASPagePattern},#{brand.DesktopCartPageTemplate},#{brand.MobileBuyflow},#{brand.MobileHomepageTemplate},#{brand.MobileSASTemplate},#{brand.MobileSASPagePattern},#{brand.MobileCartPageTemplate},#{brand.UCI},#{brand.default_offercode},#{brand.environment},#{brand.testenabled},#{brand.experience},#{brand.comments},#{brand.produrl},#{brand.qaurl},#{brand.expectedvitamin},#{brand.realm},#{brand.is_test_panel}"
      Campaign.delete(brand.id)
    end

    f = File.open('campaign_workaround_entries.txt', 'w')
    f.puts campaigns_workaround_to_delete_backup
    f.close
  end

  def self.delete_locators(data)
    brand_id = data
    @brand_id=[]
    brand_id.each do |brand|
      @brand_id << "#{brand.id}"
    end    
    @brands_to_remove = Locator.where('id in (?)',@brand_id)
    locator_workaround=[]
    locator_workaround_to_delete_backup=[]
    @brands_to_remove.each do |brand|
      locator_workaround_to_delete_backup << "#{brand.id},#{brand.css},#{brand.brand},#{brand.step},#{brand.offer}"
      Locator.delete(brand.id)
    end

    f = File.open('locator_workaround_entries.txt', 'w')
    f.puts locator_workaround_to_delete_backup
    f.close
  end  

  def self.delete_test_steps(data)    
    @testsuite_brands_to_remove = data   
    @brand_to_remove = TestRun.where('test_suites_id in (?)',@testsuite_brands_to_remove)
    @brands_to_remove=[]
    @brand_to_remove.each do |brand|
      @brands_to_remove << "#{brand.id}"
    end
    @test_steps_to_remove = TestStep.where('test_run_id in (?)', @brands_to_remove)
    test_steps_excluded_selection_workaround=[]
    test_steps_excluded_selection_workaround_to_delete_backup=[]    
    @test_steps_to_remove.each do |brand|
      test_steps_excluded_selection_workaround_to_delete_backup << "#{brand.id},#{brand.testrunid},#{brand.expected},#{brand.actual},#{brand.result},#{brand.errorcode},#{brand.created_at},#{brand.updated_at},#{brand.step_name},#{brand.test_run_id}"
      TestStep.delete(brand.id)
    end

    f = File.open('test_steps_excluded_selection_workaround_entries.txt', 'w')
    f.puts test_steps_excluded_selection_workaround_to_delete_backup
    f.close
  end

  def self.delete_test_runs(data)
    brand_id = data     
    @brands_to_remove = TestRun.where('test_suites_id in (?)',brand_id)
    test_runs_excluded_selection_workaround=[]
    test_runs_excluded_selection_workaround_to_delete_backup=[]
    @brands_to_remove.each do |brand|
      test_runs_excluded_selection_workaround_to_delete_backup << "#{brand.id},#{brand.testtype},#{brand.url},#{brand.remote_url},#{brand.runby},#{brand.runtime},#{brand.result},#{brand.brand},#{brand.campaign},#{brand.platform},#{brand.browser},#{brand.env},#{brand.scripterror},#{brand.lock_test},#{brand.workerassigned},#{brand.driver},#{brand.driverplatform},#{brand.test_suites_id},#{brand.datetime},#{brand.comments},#{brand.scheduledate},#{brand.created_at},#{brand.updated_at},#{brand.status},#{brand.custom_settings},#{brand.Notes},#{brand.isolated},#{brand.order_id},#{brand.offercode},#{brand.realm},#{brand.custom_data}"
      TestRun.delete(brand.id)
    end

    f = File.open('test_runs_excluded_selection_workaround_entries.txt', 'w')
    f.puts test_runs_excluded_selection_workaround_to_delete_backup
    f.close
  end

  def self.delete_testrun(data)
    @brands_to_remove = data    
    testrun_excluded_selection_workaround=[]
    testrun_excluded_selection_workaround_to_delete_backup=[]
    @testrun_blank_brands_to_remove = Testrun.where('LENGTH(Brand)=0') 
    @testrun_blank_expectedoffercode_to_remove = Testrun.where('LENGTH(ExpectedOffercode)=0')
    @brands_to_remove.each do |brand|
      testrun_excluded_selection_workaround_to_delete_backup << "#{brand.id},#{brand['test name']},#{brand.runby},#{brand.runtime},#{brand.result},#{brand.Brand},#{brand.Campaign},#{brand.Platform},#{brand.Browser},#{brand.Env},#{brand.ExpectedOffercode},#{brand.ActualOffercode},#{brand['Expected UCI']},#{brand['UCI HP']},#{brand['UCI OP']},#{brand['UCI CP']},#{brand.ConfirmationNum},#{brand.DateTime},#{brand.test_suites_id},#{brand.Notes},#{brand.Driver},#{brand.DriverPlatform},#{brand.status},#{brand.url},#{brand.testtype},#{brand.expectedcampaign},#{brand.Backtrace},#{brand.workerassigned},#{brand.scheduledate},#{brand.lock_test},#{brand.comments},#{brand.remote_url},#{brand.price_a},#{brand.price_e},#{brand.confoffercode},#{brand.vitamincode},#{brand.vitaminexpected},#{brand.vitamin_pricing},#{brand.cart_language},#{brand.cart_title},#{brand.total_pricing},#{brand.subtotal_price},#{brand.saspricing},#{brand.billname},#{brand.billemail},#{brand.shipaddress},#{brand.billaddress},#{brand.Standard},#{brand.Rush},#{brand.Overnight},#{brand.continuitysh},#{brand.sas_kit_name},#{brand.cart_quantity},#{brand.vitamin_title},#{brand.vitamin_description},#{brand.conf_kit_name},#{brand.conf_vitamin_name},#{brand.confvitaminpricing},#{brand.confpricing},#{brand.shipping_conf},#{brand.dummyboolean},#{brand.uci_sas},#{brand.shipping_conf_val},#{brand.selected_shipping},#{brand.kitnames},#{brand.sasprices},#{brand.lastpagefound},#{brand.billing_shipping_hash},#{brand.isolated},#{brand.realm}"
      Testrun.delete(brand.id)
    end
    @testrun_blank_brands_to_remove.each do |brand|
      testrun_excluded_selection_workaround_to_delete_backup << "#{brand.id},#{brand['test name']},#{brand.runby},#{brand.runtime},#{brand.result},,#{brand.Campaign},#{brand.Platform},#{brand.Browser},#{brand.Env},#{brand.ExpectedOffercode},#{brand.ActualOffercode},#{brand['Expected UCI']},#{brand['UCI HP']},#{brand['UCI OP']},#{brand['UCI CP']},#{brand.ConfirmationNum},#{brand.DateTime},#{brand.test_suites_id},#{brand.Notes},#{brand.Driver},#{brand.DriverPlatform},#{brand.status},#{brand.url},#{brand.testtype},#{brand.expectedcampaign},#{brand.Backtrace},#{brand.workerassigned},#{brand.scheduledate},#{brand.lock_test},#{brand.comments},#{brand.remote_url},#{brand.price_a},#{brand.price_e},#{brand.confoffercode},#{brand.vitamincode},#{brand.vitaminexpected},#{brand.vitamin_pricing},#{brand.cart_language},#{brand.cart_title},#{brand.total_pricing},#{brand.subtotal_price},#{brand.saspricing},#{brand.billname},#{brand.billemail},#{brand.shipaddress},#{brand.billaddress},#{brand.Standard},#{brand.Rush},#{brand.Overnight},#{brand.continuitysh},#{brand.sas_kit_name},#{brand.cart_quantity},#{brand.vitamin_title},#{brand.vitamin_description},#{brand.conf_kit_name},#{brand.conf_vitamin_name},#{brand.confvitaminpricing},#{brand.confpricing},#{brand.shipping_conf},#{brand.dummyboolean},#{brand.uci_sas},#{brand.shipping_conf_val},#{brand.selected_shipping},#{brand.kitnames},#{brand.sasprices},#{brand.lastpagefound},#{brand.billing_shipping_hash},#{brand.isolated},#{brand.realm}"
      Testrun.delete(brand.id)
    end
    @testrun_blank_expectedoffercode_to_remove.each do |brand|
      testrun_excluded_selection_workaround_to_delete_backup << "#{brand.id},#{brand['test name']},#{brand.runby},#{brand.runtime},#{brand.result},,#{brand.Campaign},#{brand.Platform},#{brand.Browser},#{brand.Env},#{brand.ExpectedOffercode},#{brand.ActualOffercode},#{brand['Expected UCI']},#{brand['UCI HP']},#{brand['UCI OP']},#{brand['UCI CP']},#{brand.ConfirmationNum},#{brand.DateTime},#{brand.test_suites_id},#{brand.Notes},#{brand.Driver},#{brand.DriverPlatform},#{brand.status},#{brand.url},#{brand.testtype},#{brand.expectedcampaign},#{brand.Backtrace},#{brand.workerassigned},#{brand.scheduledate},#{brand.lock_test},#{brand.comments},#{brand.remote_url},#{brand.price_a},#{brand.price_e},#{brand.confoffercode},#{brand.vitamincode},#{brand.vitaminexpected},#{brand.vitamin_pricing},#{brand.cart_language},#{brand.cart_title},#{brand.total_pricing},#{brand.subtotal_price},#{brand.saspricing},#{brand.billname},#{brand.billemail},#{brand.shipaddress},#{brand.billaddress},#{brand.Standard},#{brand.Rush},#{brand.Overnight},#{brand.continuitysh},#{brand.sas_kit_name},#{brand.cart_quantity},#{brand.vitamin_title},#{brand.vitamin_description},#{brand.conf_kit_name},#{brand.conf_vitamin_name},#{brand.confvitaminpricing},#{brand.confpricing},#{brand.shipping_conf},#{brand.dummyboolean},#{brand.uci_sas},#{brand.shipping_conf_val},#{brand.selected_shipping},#{brand.kitnames},#{brand.sasprices},#{brand.lastpagefound},#{brand.billing_shipping_hash},#{brand.isolated},#{brand.realm}"
      Testrun.delete(brand.id)
    end
    f = File.open('testrun_excluded_selection_workaround_entries.txt', 'w')
    f.puts testrun_excluded_selection_workaround_to_delete_backup
    f.close
  end

  def self.delete_test_suites(data)
    brand_id = data     
    @brands_to_remove = TestSuites.where('id in (?)',brand_id)
    testsuites_excluded_selection_workaround=[]
    testsuites_excluded_selection_workaround_to_delete_backup=[]
    @brands_to_remove.each do |brand|
      testsuites_excluded_selection_workaround_to_delete_backup << "#{brand.id},#{brand['Ran By']},#{brand.DateTime},#{brand['Test Suite Name']},#{brand.Runtime},#{brand.Pass},#{brand.Fail},#{brand.TotalTests},#{brand.Status},#{brand.SuiteType},#{brand.Campaign},#{brand.Brand},#{brand.Browser},#{brand.Platform},#{brand.URL},#{brand.offercode},#{brand.Environment},#{brand.emailnotification},#{brand.scheduledate},#{brand.scheduleid},#{brand.realm},#{brand.email_random}"
      TestSuites.delete(brand.id)
    end

    f = File.open('testsuites_excluded_selection_workaround_entries.txt', 'w')
    f.puts testsuites_excluded_selection_workaround_to_delete_backup
    f.close
  end

  def self.delete_test_urls(data)
    brands_not_used = data.map!(&:downcase)
    @brands_to_remove = TestUrl.all
    test_urls_excluded_selection_workaround=[]
    test_urls_excluded_selection_workaround_to_delete_backup=[]
    @brands_to_remove.each do |brand|
      if brands_not_used.any? {|selected_brand| brand.url.include?(selected_brand)}
        test_urls_excluded_selection_workaround_to_delete_backup << "#{brand.id},#{brand.url},#{brand.appendstring},#{brand.mode},#{brand.testdata_id},#{brand.page_type},#{brand.created_at},#{brand.updated_at},#{brand.mmtest},#{brand.vanity_uci_suite_id},#{brand.pixel_test_id},#{brand.uci},#{brand.offercode},#{brand.campaign},#{brand.realm},#{brand.is_core}"
        TestUrl.delete(brand.id)
      end
    end
    f = File.open('test_urls_excluded_selection_workaround_entries.txt', 'w')
    f.puts test_urls_excluded_selection_workaround_to_delete_backup
    f.close
  end
end