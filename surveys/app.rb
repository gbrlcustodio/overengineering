# frozen_string_literal: true
# Surveys

require 'kafka'
require 'json'
require 'securerandom'

kafka = Kafka.new(%w[kafka:9092], client_id: 'surveys')

# Consumers with the same group id will form a Consumer Group together.
consumer = kafka.consumer(group_id: 'surveys')

# It's possible to subscribe to multiple topics by calling `subscribe`
# repeatedly.
consumer.subscribe('touchpoints')

# Stop the consumer when the SIGTERM signal is sent to the process.
# It's better to shut down gracefully than to kill the process.
trap('TERM') { consumer.stop }

# Configures survey
survey = {
  triggers: %w[REVIEW ON_SITE_SALE],
  channels: %w[email phone],
  delay: 24 * 1_000 * 60 * 60
}

# This will loop indefinitely, yielding each message in turn.
consumer.each_message do |message|
  puts "Found touchpoint #{message.value} at #{message.topic} topic"

  touchpoint = JSON.parse(message.value)

  # Simulates trigger
  next unless survey[:triggers].include?(touchpoint['type'])

  happening = Time.at(touchpoint['timestamp'])

  notification = {
    uuid: SecureRandom.uuid,
    timestamp: Time.now.to_i,
    desired_delivery: happening + survey[:delay],
    customer: touchpoint['customer'],
    channel: survey[:channels].sample
  }

  puts ">>> Scheduling notification #{notification}"

  kafka.deliver_message(notification.to_json, topic: 'schedulings')
end
