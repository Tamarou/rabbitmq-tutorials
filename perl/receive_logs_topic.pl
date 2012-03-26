#!/usr/bin/env perl
use strict;
use feature qw(say);
use Net::RabbitMQ;

my $mq = Net::RabbitMQ->new();
$mq->connect( "localhost", { user => "guest", password => "guest" } );
$mq->channel_open(1);
$mq->exchange_declare( 1, 'topic_logs', { exchange_type => 'topic', auto_delete => 0  } );
my $queue_name = $mq->queue_declare( 1, '', { exclusive => 1, auto_delete => 0  } );

my @binding_keys = @ARGV;

die "Usage: $0 [info] [warning] [error]" unless @binding_keys;

for my $binding_key (@binding_keys) {
    $mq->queue_bind( 1, $queue_name, 'topic_logs', $binding_key );
}

say ' [*] Waiting for logs. To exit press CTRL+C';

my $msg;
do {
    $msg = $mq->get( 1, $queue_name, { exchange => 'direct_logs' } );
} until ( defined $msg );

say " [x] $msg->{routing_key} $msg->{body}";

$mq->disconnect();
__END__
