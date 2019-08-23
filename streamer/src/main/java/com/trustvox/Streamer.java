package com.trustvox;

import org.apache.kafka.common.serialization.Serdes;
import org.apache.kafka.streams.KafkaStreams;
import org.apache.kafka.streams.StreamsBuilder;
import org.apache.kafka.streams.StreamsConfig;
import org.apache.kafka.streams.kstream.JoinWindows;
import org.apache.kafka.streams.kstream.Joined;
import org.apache.kafka.streams.kstream.KStream;
import org.apache.kafka.streams.kstream.Printed;

import java.time.Duration;
import java.util.Properties;

public class Streamer {
    public static void main(final String[] args) throws Exception {
        Properties props = new Properties();

        props.put(StreamsConfig.APPLICATION_ID_CONFIG, "streamer");
        props.put(StreamsConfig.BOOTSTRAP_SERVERS_CONFIG, "kafka:9092");
        props.put(StreamsConfig.DEFAULT_KEY_SERDE_CLASS_CONFIG, Serdes.String().getClass());
        props.put(StreamsConfig.DEFAULT_VALUE_SERDE_CLASS_CONFIG, Serdes.String().getClass());

        StreamsBuilder builder = new StreamsBuilder();
        KStream<String, String> left = builder.stream("deliveries");
        KStream<String, String> right = builder.stream("answers");

        KStream<String, String> joined = left.join(right,
                (leftValue, rightValue) -> "left=" + leftValue + ", right=" + rightValue,
                JoinWindows.of(Duration.ofMinutes(5)),
                Joined.with(Serdes.String(), Serdes.String(), Serdes.String())
        );

        Printed sysout = Printed.toSysOut().withLabel("answered-deliveries");

        joined.print(sysout);

        KafkaStreams streams = new KafkaStreams(builder.build(), props);
        streams.start();

        Runtime.getRuntime().addShutdownHook(new Thread(streams::close));
    }
}
