#!/usr/bin/env perl
use strict;

my $scripts_path = `dirname "$0"`;
$scripts_path =~ s/[\r\n]+//;
my $scripts_exec = `basename "$0"`;
$scripts_exec =~ s/[\r\n]+//;
my $libraries_path = "$scripts_path/../data/xml/opml";
my @libraries = ( "ip.tv", "library", "podcasts", "vodcasts", "radiocasts", "music", "templates" );


sub search_library{
	my $library=shift;
	
	my $find_command=sprintf("/usr/bin/find %s%s/%s%s -iname '*.opml'", '"', $libraries_path, $library, '"' );
	foreach my $opml( `$find_command` ){
		ex -E -X -n --noplugin '+1,$s/\v([\ \t]+\<\!\-\-).*type\="link".*$/\1outline title\="\<\!\[CDATA\[\]\]\>" xmlUrl\="" type="rss" text\="\<\!\[CDATA\[\]\]\>" htmlUrl\="" description\="\<\!\[CDATA\[\]\]\>" \/>\-\-\>/' '+1,$s/\v^.*type\="link".*[\n]//' '+1,$s/\v\&#[0]{1,2}39;/\&apos;/g' '+1,$s/\v(\.\ ])([^\ ])/\1\ \2/g' '+wq!' "$opml_file";
	}
}#search_library


sub search_libraries{
	foreach my $library ( @libraries ) {
		search_library( $library );
	}
}#search_libraries

search_libraries();

