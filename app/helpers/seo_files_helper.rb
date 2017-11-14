#module SeoFilesHelper
#end
module SeoFilesHelper
	def sitemap_xml_comparison(url)
		xml_content_from_url = Nokogiri::XML.parse(open("#{url.targeturl}"))
		xml_content_from_db = Nokogiri::XML.parse("#{url.valid_content}")
		xml_content_from_url = xml_content_from_url.to_xml
		xml_content_from_db = xml_content_from_db.to_xml.gsub("\r|\n","")
			if xml_content_from_url == xml_content_from_db
				pass_label.html_safe
			else
				fail_label.html_safe 
			end
	end
end