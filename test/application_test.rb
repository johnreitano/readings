ENV['RACK_ENV'] ='test'
require 'rubygems'
require 'bundler'
Bundler.require(:default, :test)

require 'minitest/autorun'

require './app/application'

# class AppForTest < Application

#   # Access to the name of the last template
#   def self.last_template
#     @@last_template
#   end

#   # Access to the last application instance
#   def self.last_app
#     @@last_app
#   end

#   # Alias so we can still access it
#   # if you use something other than erb
#   # have a look in Sinatra code to
#   # find the right method
#   alias :erb_old :erb

#   # Override the rendering method
#   # and register the values
#   def erb(template, options = {}, locals = {}, &block)
#     @@last_template = template
#     @@last_app = self
#     erb_old(template, options, locals, &block)
#   end
# end

class TestApp < Minitest::Test

  describe 'app' do

    # Make rack test methods like get available
    include Rack::Test::Methods

    # Check that the last response has the right status code
    # and return its body as json
    # @param status [Integer] the expected status code
    def check_last_code(status = 200)
      last_response.status.must_equal(
        status_code,
        "Code is #{last_response.status} instead of #{status}" +
          last_response.body
      )
    end

    # Check the last response has the right status code
    # and return its body as json
    # @param status [Integer] the expected status code
    # @return [Object]
    def json_body(status = 200)
      check_last_code(status)
      last_response.content_type.must_equal 'application/json'
      JSON.parse(last_response.body)
    end

    # Declare the app for rack test
    def app
      Application
    end

    # Test a json answer
    it "works for happy paths for customers 0 and 1" do
      (0..1).map do |customer_index|
        cumulative_count = 0
        id = UUID.generate
        payload = {
          id: id,
          readings: [
            {
              timestamp: "2021-09-29T16:08:15+01:00",
              count: 2 + customer_index
            },
            {
              timestamp: "2021-09-29T16:09:15+01:00",
              count: 15 + customer_index
            }
          ]
        }

        get "/#{id}/latest-timestamp"
        assert_equal 200, last_response.status
        expected_response = { latest_timestamp: nil }.to_json
        assert_equal expected_response, last_response.body

        get "/#{id}/cumulative-count"
        assert_equal 200, last_response.status
        expected_response = { cumulative_count: 0 }.to_json
        assert_equal expected_response, last_response.body

        original_latest_timestamp = payload[:readings][1][:timestamp]
        2.times do |loop_index| # 2nd time through should not change timestamp or increase cumulative_count
          post "/readings", payload.to_json
          assert_equal 200, last_response.status

          get "/#{id}/latest-timestamp"
          assert_equal 200, last_response.status
          expected_response = { latest_timestamp: original_latest_timestamp }.to_json
          assert_equal expected_response, last_response.body

          get "/#{id}/cumulative-count"
          assert_equal 200, last_response.status
          cumulative_count += 17 + 2 * customer_index if loop_index == 0
          expected_response = { cumulative_count: cumulative_count }.to_json
          assert_equal expected_response, last_response.body
        end

        # add data with earlier timestamps
        payload[:readings][0][:timestamp] = "2021-09-29T16:06:15+01:00"
        payload[:readings][1][:timestamp] = "2021-09-29T16:07:15+01:00"
        2.times do |loop_index| # 2nd time through should not change timestamp or increase cumulative_count
          post "/readings", payload.to_json
          assert_equal 200, last_response.status

          get "/#{id}/latest-timestamp"
          assert_equal 200, last_response.status
          expected_response = { latest_timestamp: original_latest_timestamp }.to_json
          assert_equal expected_response, last_response.body

          get "/#{id}/cumulative-count"
          assert_equal 200, last_response.status
          cumulative_count += 17 + 2 * customer_index if loop_index == 0
          expected_response = { cumulative_count: cumulative_count }.to_json
          assert_equal expected_response, last_response.body
        end
      end
    end
  end
end

