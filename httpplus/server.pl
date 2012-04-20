#!/usr/bin/env perl

use strict;
use warnings;
use v5.10.0;

use Plack::Response;
use Twiggy::Server;

my $elapsed_time = 0;

my $server = Twiggy::Server->new(
    host => '127.0.0.1',
    port => 3000,
);

my $app = sub {
    my $response = Plack::Response->new(200);
    $response->content_type('text/html');
    $response->body("The server has now been up for $elapsed_time seconds");
    return $response->finalize();
};

$server->register_service($app);

say 'Server running on port 3000';

my $timer = AnyEvent->timer(
    after    => 1,
    interval => 1,
    cb       => sub { $elapsed_time++; },  
);

# shorthand to start watiting in event loop
AE::cv->recv;
