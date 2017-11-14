json.array!(@brands) do |brand|
  json.extract! brand, :id, :Brandname
  json.url brand_url(brand, format: :json)
end
