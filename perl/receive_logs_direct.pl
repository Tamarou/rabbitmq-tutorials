#!/usr/bin/env perl
use strict;
use feature qw(say);
use Net::RabbitMQ;

my $mq = Net::RabbitMQ->new();
$mq->connect( "localhost", { user => "guest", password => "guest" } );
$mq->channel_open(1);
$mq->exchange_declare( 1, 'direct_logs', { exchange_type => 'direct', auto_delete => 0  } );

my @severities = @ARGV;

die "Usage: $0 [info] [warning] [error]" unless @severities;

my $queue_name = $mq->queue_declare( 1, '', { exclusive => 1 } );
for my $severity (@severities) {
    $mq->queue_bind( 1, $queue_name, 'direct_logs', $severity );
}

say ' [*] Waiting for logs. To exit press CTRL+C';

my $msg;
do {
    $msg = $mq->get( 1, $queue_name, { exchange => 'direct_logs' } );
} until ( defined $msg );

say " [x] $msg->{routing_key} $msg->{body}";

$mq->disconnect();
__END__
