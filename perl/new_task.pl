#!/usr/bin/env perl
use strict;
use Net::RabbitMQ;

my $mq = Net::RabbitMQ->new();
$mq->connect( "localhost", { user => "guest", password => "guest" } );
$mq->channel_open(1);
$mq->queue_declare( 1, 'task_queue', { durable => 1, auto_delete => 0  } );

my $message = join( ' ', @ARGV ) || 'Hello World!';

$mq->publish(
    ( 1, 'task_queue', $message, {} ) => {
        delivery_mode => 2,    # make message persistent
    },
);

print " [x] Sent $message";
$mq->disconnect();

__END__
