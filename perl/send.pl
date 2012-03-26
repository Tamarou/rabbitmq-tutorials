#!/usr/bin/env perl
use strict;
use feature qw(say);
use Net::RabbitMQ;

my $mq = Net::RabbitMQ->new();
$mq->connect("localhost", { user => "guest", password => "guest" });
$mq->channel_open(1);
$mq->queue_declare(1, 'hello', { auto_delete => 0 } );
$mq->publish(1, 'hello', 'Hello World!');
$mq->disconnect();

say " [x] Sent 'Hello World!'";
__END__
