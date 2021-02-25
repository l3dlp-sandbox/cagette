#!/usr/bin/perl

use strict;
# blow up if a variable is not set
use warnings FATAL => qw/uninitialized/;

use XML::Twig;
use utf8::all;

my $url = "mysql://$ENV{DB_USER}:$ENV{DB_USER_PW}\@$ENV{DB_HOST}/$ENV{DB_NAME}";

my $twig = XML::Twig->new(
    pretty_print => 'nsgmls' # to pretty print attributes
);

$twig->parsefile( $ARGV[0] );

my $config = $twig->root;
$config->set_att(
    database           => $url,
    # cagette_api        => "http://localhost:3010"
    cagette_bridge_api => "http://$ENV{NEST_HOST}:3010"
);

$twig->print_to_file( $ARGV[1] ); # output the twig

