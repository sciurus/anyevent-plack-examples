#!/usr/bin/env perl

use strict;
use warnings;
use v5.10.0;

use AnyEvent;
use AnyEvent::Handle;
use AnyEvent::Socket;

sub echo {
    my ( $fh, $host, $port ) = @_;

    say 'accepted connection';

    my $handle = AnyEvent::Handle->new(
        fh       => $fh,
        on_error => sub {
            my ( $handle, $fatal, $message ) = @_;
            say "error occured, it was $message";
        },
        on_eof => sub {
            my $handle = shift;
            $handle->destroy();
            say 'connection closed';
        },
        on_read => sub {
            my $handle = shift;
            my $buffer = $handle->{rbuf};
            $handle->push_write($buffer);
            $handle->{rbuf} = '';
            say 'buffer written!';
        },
    );

}

my $guard = tcp_server( '127.0.0.1', 3000, \&echo );

say 'listening on port 3000';

AE::cv->recv();
