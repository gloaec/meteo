json.array!(@ftps) do |ftp|
  json.extract! ftp, :id, :host, :post, :user, :password_digest, :channel
  json.url ftp_url(ftp, format: :json)
end
