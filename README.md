# Device Readings Server

### Overview and Project Structure

An application providing a HTTP+JSON API for receiving reading counts and associated timestamps from generic devices, storing them in memory, and reporting associated statistics.

- Implemented as a thread-safe Sinatra Ruby application.
- Works correctly even if multiple identical requests are received nearly simultaneously.
- Stores all device history in memory, within single class variable.
- Validates input and returns 400 status if data is invalid.
- Currently, the test suite has a single happy-path system test.
- Two classes do most of the work:
  - DeviceHistoryStore
    - a singleton class, a single instance of which is stored in a class variable by the server. This instance and its components are thread-safe.
    - stores an instance of DeviceHistory for each distinct device id
  - DeviceHistory
    - Stores statistics associated with the readings for a particular device

The server uses the following gems:

- `sinatra` and `puma` for processing requests using Ruby threads.
- `concurrent-ruby` - for exclusive locks used to avoid race conditions due to near-simultaneous requests
- `uuid` for generating and validating uuids
- `minitest` and `rack-test` for testing

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
   Parameters:

   ```
   {
      "id": ":id",
      "readings": [
         {"timestamp":":timestamp1","count":count1},
         {"timestamp":":timestamp2","count":count2},
         ...
      ]
   }

   ```

   where

   - ":id" is the source device id
   - ":timestamp1"/":timestamp2"/... is the timestamp for reading 1/2/.., in ISO8601 format
   - ":count1"/":count2"/... is the count for reading 1/2/...

   Example:

   ```
   curl -H "Content-Type: application/json" -d '{"id":"36d5658a-6908-479e-887e-a949ec199272","readings":[{"timestamp":"2021-09-29T16:08:15+01:00","count":2},{"timestamp":"2021-09-29T16:09:15+01:00","count":15}]}' http://localhost:3000/readings
   ```

2. GET /:id/latest-timestamp (where ":id" is the desired device id)  
   Example:

   ```
   curl http://localhost:3000/36d5658a-6908-479e-887e-a949ec199272/latest_timestamp
   ```

3. GET /:id/cumulative-count (where ":id" is the desired device id)  
   Example:
   ```
   curl http://localhost:3000/36d5658a-6908-479e-887e-a949ec199272/latest_timestamp
   ```

### Running system test

```
ruby test/application_test.rb
```

### Possible Improvements

- improve validation to report on cause of 400 errors due to invalid data
- add unit tests for DeviceHistoryStore
  - test happy path for public methods `ingest_readings`, `latest_time`, `cumulative_count`
  - add test to ensure `ingest_payload` works correctly with multiple concurrent requests to add reading for device id that has not yet been stored in memory
- add unit tests for DeviceHistory
  - test happy path for public method `add_reading`
  - ensure `add_reading` works correctly with multiple concurrent identical requests
- extend to allow multiple workers on same server
- extend to allow multiple servers (possibly using a queue for processing by a master server)
