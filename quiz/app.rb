# frozen_string_literal: true
# Quiz

require 'kafka'
require 'json'
require 'securerandom'

kafka = Kafka.new(%w[kafka:9092], client_id: 'quiz')

# Consumers with the same group id will form a Consumer Group together.
consumer = kafka.consumer(group_id: 'quiz')

# It's possible to subscribe to multiple topics by calling `subscribe`
# repeatedly.
consumer.subscribe('deliveries')

# Stop the consumer when the SIGTERM signal is sent to the process.
# It's better to shut down gracefully than to kill the process.
trap('TERM') { consumer.stop }

consumer.each_message do |message|
  puts "Notified about survey #{message.value} at #{message.topic} topic"

  delivery = JSON.parse(message.value)

  # The probability of answering a survey is of 20%
  next unless rand(100) < 20

  puts ">>> Answering survey #{delivery}"

  answer = {
    uuid: SecureRandom.uuid,
    timestamp: Time.now.to_i,
    notification: delivery['notification']
  }

  kafka.deliver_message(answer.to_json, topic: 'answers')
end
