# frozen_string_literal: true
# Scheduler

require 'kafka'
require 'json'
require 'securerandom'

kafka = Kafka.new(%w[kafka:9092], client_id: 'scheduler')

# Consumers with the same group id will form a Consumer Group together.
consumer = kafka.consumer(group_id: 'scheduler')

# It's possible to subscribe to multiple topics by calling `subscribe`
# repeatedly.
consumer.subscribe('schedulings')

# Stop the consumer when the SIGTERM signal is sent to the process.
# It's better to shut down gracefully than to kill the process.
trap('TERM') { consumer.stop }

consumer.each_message do |message|
  puts "Found scheduling request #{message.value} at #{message.topic} topic"

  notification = JSON.parse(message.value)
  channel = notification['channel']

  delivery = {
    uuid: SecureRandom.uuid,
    timestamp: Time.now.to_i,
    channel: channel,
    destination: notification.dig('customer', channel),
    content: "Hello #{notification.dig('customer', 'name')}!",
    notification: notification
  }

  puts ">>> Delivering notification #{delivery}"

  kafka.deliver_message(delivery.to_json, topic: 'deliveries')
end
