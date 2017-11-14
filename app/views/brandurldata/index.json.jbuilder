json.array!(@brandurldata) do |brandurldatum|
  json.extract! brandurldatum, :id, :brand, :development, :stg, :qa, :prod, :test_env
  json.url brandurldatum_url(brandurldatum, format: :json)
end
