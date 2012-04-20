#!/usr/bin/env perl

use strict;
use warnings;
use v5.10.0;

use Plack::Response;
use Twiggy::Server;

my $server = Twiggy::Server->new(
    host => '127.0.0.1',
    port => 3000,
);

my $app = sub {
    my $response = Plack::Response->new(200);
    $response->content_type('text/html');
    $response->body("Hello from my http server. Perl is awesome!");
    return $response->finalize();
};

$server->register_service($app);

say 'Server running on port 3000';

# shorthand to start watiting in event loop
AE::cv->recv;
