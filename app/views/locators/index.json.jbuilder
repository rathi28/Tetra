json.array!(@locators) do |locator|
  json.extract! locator, :id, :css, :brand, :step, :offer
  json.url locator_url(locator, format: :json)
end
