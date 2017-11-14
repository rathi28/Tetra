json.array!(@action_logs) do |action_log|
  json.extract! action_log, :id, :user, :action, :target, :time_of_action
  json.url action_log_url(action_log, format: :json)
end
