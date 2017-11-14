json.array!(@error_codes) do |error_code|
  json.extract! error_code, :id, :human_name, :errorcode
  json.url error_code_url(error_code, format: :json)
end
