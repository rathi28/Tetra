json.array!(@page_identifiers) do |page_identifier|
  json.extract! page_identifier, :id, :page, :value
  json.url page_identifier_url(page_identifier, format: :json)
end
