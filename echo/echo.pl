#!/usr/bin/env perl

use strict;
use warnings;
use v5.10.0;

use AnyEvent;
use AnyEvent::Handle;
use AnyEvent::Socket;

my $guard = tcp_server(
    '127.0.0.1',
    3000,
    sub {
        my ( $fh, $host, $port ) = @_;

        say 'accepted connection';

        my $handle;
        $handle = AnyEvent::Handle->new(
            fh      => $fh,
            on_read => sub {
                my $buffer = $handle->{rbuf};
                $handle->push_write($buffer);
                $handle->{rbuf} = '';
                say 'buffer written!';
            },
            on_eof => sub {
                $handle->destroy();
                say 'connection closed';
            },
        );
    }
);

say 'listening on port 3000';

AE::cv->recv();
