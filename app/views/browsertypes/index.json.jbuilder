json.array!(@browsertypes) do |browsertype|
  json.extract! browsertype, :id, :browser, :device_type, :remote, :human_name, :active
  json.url browsertype_url(browsertype, format: :json)
end
