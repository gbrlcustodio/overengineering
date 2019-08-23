# frozen_string_literal: true
# Journey

require 'ffaker'
require 'json'
require 'kafka'

kafka = Kafka.new(%w[kafka:9092], client_id: 'journey')
touchpoints = %i[ON_SITE_SALE REVIEW CHECKIN CHECKOUT]

while true
  touchpoint = {
    type: touchpoints.sample,
    customer: {
      name: FFaker::Name.name,
      email: FFaker::Internet.email,
      phone: FFaker::PhoneNumber.phone_number
    },
    timestamp: Time.now.to_i
  }

  puts "Generating touchpoint #{touchpoint}"

  kafka.deliver_message(touchpoint.to_json, topic: 'touchpoints')

  sleep 10
end
