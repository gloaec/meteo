json.array!(@channels) do |channel|
  json.extract! channel, :id, :name, :queue_path, :error_path
  json.url channel_url(channel, format: :json)
end
