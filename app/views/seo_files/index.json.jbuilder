json.array!(@seo_files) do |seo_file|
  json.extract! seo_file, :id, :filename, :domain, :targeturl, :valid_content
  json.url seo_file_url(seo_file, format: :json)
end
