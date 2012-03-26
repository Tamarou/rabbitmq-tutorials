#!/usr/bin/perl
use strict;
use feature qw(say);
use Net::RabbitMQ;

my $mq = Net::RabbitMQ->new();
$mq->connect( "localhost", { user => "guest", password => "guest" } );
$mq->channel_open(1);
$mq->exchange_declare( 1, 'logs', { exchange_type => 'fanout', auto_delete => 0 } );

my $queue_name = $mq->queue_declare( 1, '', { exclusive => 1 } );

$mq->queue_bind( 1, $queue_name, 'logs', '' );

say ' [*] Waiting for logs. To exit press CTRL+C';

my $msg;
do {
    $msg = $mq->get( 1, $queue_name, { exchange => 'logs' } );
} until ( defined $msg );

say " [x $msg->{body}";
$mq->disconnect();
__END__
