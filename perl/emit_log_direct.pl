#!/usr/bin/perl
use strict;
use feature qw(say);
use Net::RabbitMQ;

my $mq = Net::RabbitMQ->new();
$mq->connect( "localhost", { user => "guest", password => "guest" } );
$mq->channel_open(1);
$mq->exchange_declare( 1, 'direct_logs', { exchange_type => 'direct', auto_delete => 0  } );

my $severity = @ARGV > 1 ? shift @ARGV : 'info';
my $message = join( ' ', @ARGV ) || 'Hello World!';

$mq->publish( 1, $severity, $message, { exchange => 'direct_logs', } );

say " [x] Sent $severity:$message";

$mq->disconnect();
__END__
