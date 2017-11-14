#url = 'https://www.proactiv.com/on/demandware.store/Sites-ProactivPlus-Site/default/COCart-AddProduct?grcid=core&mmcore.gm=2&currentSelection=PA-formula-PAplus-compare-ps|PA-kit-3StepKit-main-inline-ps|PA-gift-spm-rtt-main-inline-ps|PA-supply-30day-3StepKit-inline-ps'
url = 'http://wen.com'
#url = 'https://www.digicert.com/ssl.htm'
require "net/http"
require "uri"

### Find SEO tag
def find_canonical(can_present, canonical_tag)
  begin
    if @browser.find(canonical_tag, :visible => false).nil?
      return can_present == 'N'
    else
      if @browser.current_url.include? (@browser.find(canonical_tag, :visible => false)['href'])
        return can_present == 'Y'
      else
        return can_present == 'N'
      end
    end
  rescue
    return can_present == 'N'
  end
end

def find_robots(rob_present, robots_tag)
  begin
    if @browser.find(robots_tag, :visible => false).nil?
      return rob_present == 'N'
    else
      return rob_present != 'N'
    end
  rescue
    return rob_present == 'N'
  end 
end

def find_tags()
  realm = TestUrl.where(url: @browser.current_url).first.realm
  core = TestUrl.where(url: @browser.current_url).first.is_core
  page = TestUrl.where(url: @browser.current_url).first.page_type

  if page.downcase.include?('landing')
    page = 'Home'
  elsif page.downcase.include?('sas')
    page = 'SAS'
  elsif page.downcase.include?('cart')
    page = 'Cart'
  elsif page.downcase.include?('confirmation')
    page = 'Confirmation'
  end

  can_present = SeoValidation.where(realm: realm, is_core: core, page_name: page, validation_type: 'canonical').first.present
  canonical_tag = SeoValidation.where(realm: realm, is_core: core, page_name: page, validation_type: 'canonical').first.value
  rob_present = SeoValidation.where(realm: realm, is_core: core, page_name: page, validation_type: 'robots').first.value
  robots_tag = SeoValidation.where(realm: realm, is_core: core, page_name: page, validation_type: 'robots').first.value

  canonical = find_canonical(can_present, canonical_tag)
  robots = find_robots(rob_present, robots_tag)

  if realm == 'Realm1'
    if core == true
      core_one_tags(page, canonical, robots)
    else
      other_one_tags(page, canonical, robots)
    end
  elsif realm == 'Realm2'
    if core == true
      core_two_tags(page, canonical, robots)
    else
      other_two_tags(page, canonical, robots)
    end
  end
end

def core_one_tags(page, canonical, robots)
  if page == 'Home'
    if robots == false and canonical == true
      return true
    else
      return false
    end
  elsif page == 'SAS'
    if robots == false and canonical == false
      return true
    else
      return false
    end
  elsif page == 'Cart'
    if robots == true and canonical == false
      return true
    else
      return false
    end
  elsif page == 'Confirmation'
    if robots == false and canonical == false
      return true
    else
      return false
    end
  end
end

def other_one_tags(page, canonical, robots)
  if page == 'Home'
    if robots == true and canonical == false
      return true
    else
      return false
    end
  elsif page == 'SAS'
    if robots == true and canonical == false
      return true
    else
      return false
    end
  elsif page == 'Cart'
    if robots == true and canonical == false
      return true
    else
      return false
    end
  elsif page == 'Confirmation'
    if robots == false and canonical == false
      return true
    else
      return false
    end
  end
end

def core_two_tags(page, canonical, robots)
  if page == 'Home'
    if robots == false and canonical == true
      return true
    else
      return false
    end
  elsif page == 'SAS'
    if robots == false and canonical == true
      return true
    else
      return false
    end
  elsif page == 'Cart'
    if robots == false and canonical == true
      return true
    else
      return false
    end
  elsif page == 'Confirmation'
    if robots == false and canonical == true
      return true
    else
      return false
    end
  end
end

def other_two_tags(page, canonical, robots)
  if page == 'Home'
    if robots == false and canonical == true
      return true
    else
      return false
    end
  elsif page == 'SAS'
    if robots == false and canonical == true
      return true
    else
      return false
    end
  elsif page == 'Cart'
    if robots == false and canonical == true
      return true
    else
      return false
    end
  elsif page == 'Confirmation'
    if robots == false and canonical == true
      return true
    else
      return false
    end
  end
end