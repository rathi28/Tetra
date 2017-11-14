json.array!(@error_messages) do |error_message|
  json.extract! error_message, :id, :message, :backtrace, :class_name, :testrun_id, :test_run_id
  json.url error_message_url(error_message, format: :json)
end
