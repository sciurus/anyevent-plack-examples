#!/usr/bin/env perl

use strict;
use warnings;
use v5.10.0;

use AnyEvent::Twitter::Stream;

my $user = $ARGV[0];
my $password = $ARGV[1];

my $elapsed_time = 0;
my $tweets_seen = 0;

my $condition = AnyEvent->condvar;

my $twitter = AnyEvent::Twitter::Stream->new(
    username => $user,
    password => $password,
    method   => "filter",
    track    => "Perl,Athens",
    on_tweet => sub {
        my $tweet = shift;
        $tweets_seen++;
        say $tweet->{text};
    },
);

my $timer = AnyEvent->timer(
    after    => 1,
    interval => 1,
    cb       => sub {
        $elapsed_time++;
        say $elapsed_time;
    },
);

# signal handlers take function name
# instead of being references to functions
sub unloop {
    say "\nSaw $tweets_seen tweets in $elapsed_time seconds";
    $condition->send;
}
$SIG{INT} = 'unloop';

# start the event loop
$condition->recv;
