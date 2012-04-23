#!/usr/bin/env perl

use AnyEvent::Redis;
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

my $redis = AnyEvent::Redis->new(
    host     => '127.0.0.1',
    port     => 6379,
    encoding => 'utf8',
    on_error => sub { warn @_ },
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
        my @keyword_list =
          split( ',', $config->{'keywords.json'}->{'keywords'} );
        foreach my $word (@keyword_list) {
            if ( $tweet->{text} =~ /$word/ ) {
                $redis->incr($word);
            }
        }
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

get '/' => sub {
    my $self = shift;
    my @keyword_list = split( ',', $config->{'keywords.json'}->{'keywords'} );
    $redis->mget(
        @keyword_list,
        sub {
            # results are returned in an array reference
            my @wordcounts = @{ @_[0] };
            my %word_to_count;
            for ( my $i = 0 ; $i < @keyword_list ; $i++ ) {
                $word_to_count{ $keyword_list[$i] } = $wordcounts[$i];
            }
            $self->stash(
                elapsed_time  => $elapsed_time,
                tweets_seen   => $tweets_seen,
                word_to_count => \%word_to_count
            );
            $self->render('index');
        }
    );
};

app->start;
__DATA__

@@ index.html.ep
<html>
<head><title>Tweet Count</title></head>
<body>
<p>The server has been up for <%= $elapsed_time %> seconds.</p>
<p>The server has seen <%= $tweets_seen %> tweets.</p>
% foreach my $word (keys %{$word_to_count}) {
<p>Total <%= $word %>: <%= $word_to_count->{$word} %></p>
% }
</body>
</html>
