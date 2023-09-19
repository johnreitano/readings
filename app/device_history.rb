class DeviceHistory
  attr_reader :id, :latest_time, :readings, :cumulative_count

  def initialize(id)
    @id = id
    @latest_time = nil
    @readings = {}
    @cumulative_count = 0
    @lock = Concurrent::ReentrantReadWriteLock.new
  end

  def add_reading(time, count)
    @lock.with_write_lock do
      return if @readings.has_key?(time)
      @readings[time] = true
      @latest_time = time if @latest_time.nil? || time > @latest_time
      @cumulative_count += count
    end
  end
end
