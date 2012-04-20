#!/usr/bin/env perl

use AnyEvent::Twitter::Stream;
use Mojolicious::Lite;
use Config::Any;

my $elapsed_time = 0;
my $tweets_seen  = 0;

my $config = Config::Any->load_files(
    {
        files           => [ 'credentials.json', 'keywords.json' ],
        use_ext         => 1,
        flatten_to_hash => 1,
    }
);

my $twitter = AnyEvent::Twitter::Stream->new(
    username => $config->{'credentials.json'}->{'username'},
    password => $config->{'credentials.json'}->{'password'},
    track    => $config->{'keywords.json'}->{'keywords'},
    method   => "filter",
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

# start the mojo magic

get '/' => sub {
    my $self = shift;
    $self->stash( elapsed_time => $elapsed_time, tweets_seen => $tweets_seen );
    $self->render('index');
};

app->start;
__DATA__

@@ index.html.ep
<html>
<head><title>Tweet Count</title></head>
<body>
<p>The server has been up for <%= $elapsed_time %> seconds.</p>
<p>The server has seen <%= $tweets_seen %> tweets.</p>
</body>
</html>
