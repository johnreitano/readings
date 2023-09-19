require 'time'
require './app/device_history'

class DeviceHistoryStore
  def initialize
    @device_histories = {}
    @lock = Concurrent::ReentrantReadWriteLock.new
  end

  def latest_time(id)
    return nil unless @device_histories[id]
    @device_histories[id].latest_time
  end
  
  def cumulative_count(id)
    return 0 unless @device_histories[id]
    @device_histories[id].cumulative_count
  end

  def ingest_payload(payload)
    return false unless valid_payload?(payload)
    id, readings = payload["id"], payload["readings"]
    readings.each do |reading|
      timestamp, count = reading["timestamp"], reading["count"]
      time = Time.parse(timestamp)
      add_reading(id, time, count)
    end
    true
  end

  private

  def valid_payload?(payload)
    id, readings = payload["id"], payload["readings"]
    return false unless UUID.validate(id)
    return false unless readings.is_a?(Array)
    readings.each do |reading|
      return false unless reading.is_a?(Hash)
      timestamp, count = reading["timestamp"], reading["count"]
      return false unless valid_timestamp?(timestamp)
      return false unless count.is_a?(Integer)
    end
    true
  end

  def valid_timestamp?(timestamp)
    return false unless timestamp.is_a?(String)
    begin
      Time.parse(timestamp)
    rescue ArgumentError
      return false
    end
    true
  end

  def add_reading(id, time, count)
    ensure_device_history_exists(id)
    @device_histories[id].add_reading(time, count)
  end

  def reading_already_exists?(id, time)
    @device_histories.has_key?(id) && @device_histories[id].readings.has_key?(time)
  end

  def ensure_device_history_exists(id)
    @lock.with_write_lock do
      @device_histories[id] = DeviceHistory.new(id) unless @device_histories[id]
    end
  end
end
