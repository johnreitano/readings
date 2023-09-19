require './app/device_history_store'

class Application < Sinatra::Base
  @@device_history_store = DeviceHistoryStore.new

  before do
    content_type :json
  end
  
  after do
    response.body = JSON.dump(response.body)
  end
  
  post '/readings' do
    payload = JSON.parse(request.body.read)
    if @@device_history_store.ingest_payload(payload)
      halt 200, { message: "ok" }
    else
      halt 400, { message: "invalid payload" }
    end
  end
  
  get '/:id/latest-timestamp' do
    { latest_timestamp: @@device_history_store.latest_time(params[:id])&.iso8601 }
  end

  get '/:id/cumulative-count' do
    { cumulative_count: @@device_history_store.cumulative_count(params[:id]) }
  end
end
