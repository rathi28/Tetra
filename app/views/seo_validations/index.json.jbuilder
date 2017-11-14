json.array!(@seo_validations) do |seo_validation|
  json.extract! seo_validation, :id, :realm, :is_core, :page_name, :validation_type, :value, :present
  json.url seo_validation_url(seo_validation, format: :json)
end
