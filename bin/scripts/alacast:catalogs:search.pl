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
my $output = "";
my $be_verbose=0;#False

sub print_usage{
	printf( "Usage:\n\t %s [--title|(default)xmlUrl|htmlUrl|text|description]=]search_term or path to file containing search terms(one per line.) [--output=attribute-to-display. default: xmlUrl]\n\t\tBoth of these options may be repeated multiple times together or only multiple uses of the first argument.  Lastly multiple terms, or files using terms \n", $scripts_exec );
	exit(-1);
}

sub search_catalog{
	my $catalog=shift;
	my $grep_command = sprintf("/usr/bin/grep --binary-files=without-match --with-filename -ri --perl-regex -e '^[\ \t]+<outline.*%s=[\"\'\\\'\'][^\"\'\\\'\']*%s[^\"\'\\\'\']\*[\"\'\\\'\']' '%s/%s'", $attrib, $value, $opml_files_path, $catalog );
	
	foreach my $opml_and_outline ( `$grep_command` ) {
		$opml_and_outline =~ s/[\r\n]+//g;
		my $opml_file = $opml_and_outline;
		#$opml_file =~ s/^$opml_files_path\///;
		$opml_file =~ s/^(.*):[0-9]+:\t.*$/\1/;

		my $opml_attribute = $opml_and_outline;
		$opml_attribute =~ s/.*$output=["']([^"']+)["'].*/\1/;
		$opml_attribute =~ s/<!\[CDATA\[(.+)\]\]>/\1/;

		printf( "%s @ %s\n", $opml_attribute, $opml_file );
		
		if($be_verbose){printf($opml_and_outline);}
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

my $i=0;
if("$ARGV[0]" eq "--verbose"){$i++; $be_verbose=$i;}#$i==1 eq True

for ( ; $i<@ARGV; $i++ ) {
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
	
	$output=$ARGV[$i+1];
	if("$output"eq"--output=title"||"$output"eq"--output=htmlUrl"||"$output"eq"--output=text"||"$output"eq"--output=description"||"$output"eq"--output=xmlUrl"){
		$i++;
		$output=~s/\-\-([^=]+)=(.*)/\2/g;
	} else {$output="xmlUrl";}
	
	search_catalogs();
}
