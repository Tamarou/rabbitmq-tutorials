#!/usr/bin/env perl
use strict;
use feature qw(say);
use Net::RabbitMQ;

my $mq = Net::RabbitMQ->new();
$mq->connect( "localhost", { user => "guest", password => "guest" } );
$mq->channel_open(1);
$mq->exchange_declare( 1, 'topic_logs', { exchange_type => 'topic', auto_delete => 0  } );

my $routing_key = @ARGV > 1 ? shift @ARGV : 'anonymous.info';
my $message = join( ' ', @ARGV ) || 'Hello World!';

$mq->publish( 1, $routing_key, $message, { exchange => 'topic_logs', } );

say " [x] Sent $routing_key:$message";

$mq->disconnect();

__END__
