#!/usr/bin/env perl
use strict;
use feature qw(say);
use Net::RabbitMQ;

my $mq = Net::RabbitMQ->new();
$mq->connect( "localhost", { user => "guest", password => "guest" } );
$mq->channel_open(1);
$mq->queue_declare( 1, 'rpc_queue', {auto_delete => 0 } );

sub fib {
    my $n = shift;
    return 0 unless $n;
    return 1 if $n == 1;
    return fib( $n - 1 ) + fib( $n - 2 );
}

say " [x] Awaiting RPC requests";

$mq->basic_qos( 1, { prefetch_count => 1 } );

my $msg;
do {
    $msg = $mq->get( 1, 'rpc_queue', {} );
} until ( defined $msg );

my $n = int $msg->{body};
say " [.] fib($n)";
my $response = fib($n);
$mq->publish( 1, $msg->{props}{reply_to},
    $response, {}, { correlation_id => $msg->{props}{correlation_id} } );
$mq->ack( 1, $msg->{delivery_tag} );

__END__
