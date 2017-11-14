json.array!(@offer_data_details) do |offer_data_detail|
  json.extract! offer_data_detail, :id, :offer_title, :offerdesc, :offerdatum_id
  json.url offer_data_detail_url(offer_data_detail, format: :json)
end
