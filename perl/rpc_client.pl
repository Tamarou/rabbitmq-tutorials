#!/usr/bin/env perl
use strict;
use feature qw(say);
use Net::RabbitMQ;
use UUID::Tiny qw();
{

    package FibonacciRpcClient;
    use Moose;
    use namespace::autoclean;

    has connection => (
        isa     => 'Net::RabbitMQ',
        is      => 'ro',
        lazy    => 1,
        builder => '_build_connection',
        handles => [qw(queue_declare get publish)]
    );

    sub _build_connection {
        my $mq = Net::RabbitMQ->new();
        $mq->connect( "localhost", { user => "guest", password => "guest" } );
        $mq->channel_open(1);
        return $mq;
    }

    has callback_queue => (
        isa     => 'Str',
        is      => 'ro',
        lazy    => 1,
        builder => '_build_callback_queue',
    );

    sub _build_callback_queue {
        my $self = shift;
        $self->queue_declare( 1, '', { exclusive => 1, auto_delete => 0  } );
    }

    has corr_id => (
        isa => 'Str',
        is  => 'ro',
        default =>
            sub { UUID::Tiny::create_UUID_as_string(UUID::Tiny::UUID_V4) },
    );

    sub get_response {
        my ($s) = @_;
        my $msg;
        do {
            $msg = $s->get( 1, $s->callback_queue, {} );
        } until ( defined $msg );
        return $msg->{body} if $msg->{props}{correlation_id} eq $s->corr_id;
    }

    sub call {
        my ( $self, $n ) = @_;
        $self->publish(
            1 => 'rpc_queue' => $n => {} => {
                reply_to       => $self->callback_queue,
                correlation_id => $self->corr_id
            }
        );
        return $self->get_response();
    }
    __PACKAGE__->meta->make_immutable;
}

my $fibonacci_rpc = FibonacciRpcClient->new();
say " [x] Requesting fib(30)";
my $response = $fibonacci_rpc->call(30);
say " [.] got response $response";

__END__