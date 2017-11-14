json.array!(@workers) do |worker|
  json.extract! worker, :id, :name, :pixel, :buyflow, :scheduled
  json.url worker_url(worker, format: :json)
end
