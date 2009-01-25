#!/usr/bin/perl
use strict;

my $scripts_path = `dirname "$0"`;
$scripts_path =~ s/[\r\n]+//;
my $scripts_exec = `basename "$0"`;
$scripts_exec =~ s/[\r\n]+//;
my $opml_files_path = "$scripts_path/../../data/xml/opml";
my @catalogs = ( "IP.TV", "Library", "Podcasts", "Vodcasts", "Radiocasts", "Music" );

if ( @ARGV < 0 || "$ARGV[0]" eq "" ) { print_usage(); }

my $attrib;
my $value;
my $searching_list="";
my $show_attribute = "";

sub print_usage{
	printf( "Usage:\n\t %s [--title|(default)xmlUrl|htmlUrl|text|description]=]search_term or path to file containing search terms(one per line.) [--show=attribute-to-display. default: xmlUrl]\n\t\tBoth of these options may be repeated multiple times together or only multiple uses of the first argument.  Lastly multiple terms, or files using terms \n", $scripts_exec );
	exit(-1);
}

sub search_catalog{
	my $catalog=shift;
	my $last_opml_file="";
	my $grep_command = "/usr/bin/grep --binary-files=without-match --with-filename -ri --perl-regex -e '^[\ \t]+<outline.*$attrib=[\"\'\\\'\'].*$value.*[\"\'\\\'\']' '$opml_files_path/$catalog'";
	
	foreach my $opml_and_outline ( `$grep_command` ) {
		$opml_and_outline =~ s/[\r\n]+//g;
		my $opml_file = $opml_and_outline;
		$opml_file =~ s/^$opml_files_path\/(.*):\t.*$/\1/;

		my $opml_attribute = $opml_and_outline;
		$opml_attribute =~ s/.*$show_attribute=["']([^"']+)["'].*/\1/;
		$opml_attribute =~ s/<!\[CDATA\[(.+)\]\]>/\1/;

		if ( $opml_file ne $last_opml_file ) {
			$last_opml_file = $opml_file;
			printf( "%s contains:\n", $opml_file );
		}

		printf( "\t\t%s\n", $opml_attribute );
	}
}

sub search_catalogs{
	foreach my $catalog ( @catalogs ) {
		if ( $searching_list eq "" ) { search_catalog($catalog); }
		else {
			foreach $value ( `cat '$searching_list'` ) {
				search_catalog($catalog);
			}
		}
	}
}

for ( my $i=0; $i<@ARGV; $i++ ) {
	$attrib = $ARGV[$i];
	$attrib =~ s/^\-\-([^=]+)=(.*)$/\1/g;
	$value = $ARGV[$i];;
	$value =~ s/^\-\-([^=]+)=(.*)$/\2/g;
	$value =~ s/(['"])/\1\\\1\1/g;
	
	$searching_list = "";;
	
	if ( ! ( $attrib eq "title" || $attrib eq "xmlUrl" || $attrib eq "htmlUrl" || $attrib eq "text" || $attrib eq "description" ) ) {
		$attrib = "title";
		$value = $ARGV[$i];
	}
	if ( -e $value ) { $searching_list = $value; }
	
	$show_attribute = "";
	$i++;
	if ( $ARGV[$i] eq "--show=title" || $ARGV[$i] eq "--show=htmlUrl" || $ARGV[$i] eq "--show=text" || $ARGV[$i] eq "--show=description" ) {
		$show_attribute = $ARGV[$i];
		$show_attribute =~ s/\-\-([^=]+)=(.*)/\2/g;
	} else {
		$i--;
		$show_attribute = "xmlUrl";
	}
	
	search_catalogs();
}
