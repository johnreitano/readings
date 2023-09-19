# Device Readings Server

### Install and run

NOTE: This script has been tested with Ruby 3.2.2

```
git clone https://github.com/johnreitano/readings.git
cd readings
bundle install
puma config.ru -C puma.rb
```

### API endpoints

1. POST /readings
   P
   Example:
   '''
   curl -d '{"id":"36d5658a-6908-479e-887e-a949ec199272","readings":[{"timestamp":"2021-09-29T16:08:15+01:00","count":2},{"timestamp":"2021-09-29T16:09:15+01:00","count":15}]}' http://localhost:3000/readings
   '''

2. GET /:id/latest-timestamp (replace ":id" with the actual device id)
   Example:
   '''
   curl http://localhost:3000/36d5658a-6908-479e-887e-a949ec199272/latest_timestamp
   '''

3. GET /:id/cumulative-count (replace ":id" with the actual device id)
   Example:
   '''
   curl http://localhost:3000/36d5658a-6908-479e-887e-a949ec199272/latest_timestamp
   '''

### Running system test

```
ruby test/application_test.rb
```

### Project Structure

???

### Improvements

- add unit tests for DeviceHistoryStore
  - test happy path for public methods `ingest_readings`, `latest_time`, `cumulative_count`
  - ensure `ingest_payload` works correctly with multiple concurrent requests to add reading for device id that has not yet been stored in memory
- add unit tests for DeviceHistory
  - test happy path for public method `add_reading`
  - ensure `add_reading` works correctly with multiple concurrent identical requests
- extend to allow multiple workers on same server
- extend to allow multiple servers (possibly using a queue for processing by a master server)
