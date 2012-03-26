#!/usr/bin/env perl
use strict;
use feature qw(say);
use Net::RabbitMQ;

my $mq = Net::RabbitMQ->new();
$mq->connect( "localhost", { user => "guest", password => "guest" } );
$mq->channel_open(1);
$mq->queue_declare( 1, 'hello', { auto_delete => 0 } );

say ' [*] Waiting for messages. To exit press CTRL+C';

my $msg;
do {
    $msg = $mq->get( 1, 'hello', {} );
} until ( defined $msg );

say " [x] Received $msg->{body}";

$mq->disconnect();

__END__
