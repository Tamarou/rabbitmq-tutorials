#!/usr/bin/perl
use strict;
use feature qw(say);
use Net::RabbitMQ;

my $mq = Net::RabbitMQ->new();
$mq->connect( "localhost", { user => "guest", password => "guest" } );
$mq->channel_open(1);
$mq->exchange_declare( 1, 'logs', { exchange_type => 'fanout', auto_delete => 0 } );

my $message = join( ' ', @ARGV ) || 'info: Hello World!';

$mq->publish( 1, '', $message, { exchange => 'logs' } );
say " [x] Sent $message";

$mq->disconnect();
__END__
