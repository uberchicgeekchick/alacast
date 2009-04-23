#!/usr/bin/perl
use strict;

if ( @ARGV < 0 || "$ARGV[0]" eq "-h"  || "$ARGV[0]" eq "--help" ) { print_usage(); }

my $scripts_path = `dirname "$0"`;
$scripts_path =~ s/[\r\n]+//;
my $scripts_exec = `basename "$0"`;
$scripts_exec =~ s/[\r\n]+//;
my $opml_files_path = "$scripts_path/../data/xml/opml";
my @catalogs = ( "ip.tv", "library", "podcasts", "vodcasts", "radiocasts", "music" );

my $attribute;
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
	my $grep_command=sprintf("/usr/bin/grep --binary-files=without-match --with-filename -i --perl-regex -e '.*%s=[\"\'\\\'\'][^\"\'\\\'\']\*%s[^\"\'\\\'\']\*[\"\'\\\'\']' -r '%s/%s'", $attribute, $value, $opml_files_path, $catalog );
	
	foreach my $opml_and_outline ( `$grep_command` ) {
		$opml_and_outline=~s/[\r\n]+//g;
		if( $opml_and_outline!~/.*$output=["'][^'"]+["'].*/ ){ next; }
		my $opml_file=$opml_and_outline;
		$opml_file=~s/^([^:]*):.*$/\1/;
		while($opml_file=~/\.\.\//){
			$opml_file =~ s/[^\/]+\/\.\.\///g;
		}
		#$opml_file =~ s/^$opml_files_path\///;
		
		my $opml_attribute=$opml_and_outline;
		$opml_attribute=~s/.*$output=["']([^"']+)["'].*/\2/i;
		$opml_attribute=~s/<!\[CDATA\[(.+)\]\]>/\1/;

		printf( "\n\n%s=%s @ %s", $output, $opml_attribute, $opml_file );
		
		if($be_verbose==1){printf("\n\t\t%s", $opml_and_outline);}
	}
}

sub search_catalogs{
	foreach my $catalog ( @catalogs ) {
		if ("$searching_list"eq""){ search_catalog( $catalog ); }
		else {
			foreach $value ( `cat '$searching_list'` ) {
				search_catalog( $catalog );
			}
		}
	}
}

sub parse_attribute{
	my $arg=shift;
	$attribute=$arg;
	$attribute=~s/^\-\-([^=]+)=["']*([^"']*)["']*$/\1/g;
	$value=$arg;
	$value=~s/^\-\-([^=]+)=["']*([^"']*)["']*$/\2/g;
	$value=~s/(['"])/\1\\\1\1/g;
	
	$searching_list="";
	
	if(!("$attribute"=~/(xml|html)Url/||"$attribute"eq"title"||"$attribute"eq"text"||"$attribute"eq"description"||"$attribute"eq"type")) {
		$attribute="xmlUrl";
	}
	if("$attribute"=~/(xml|html)Url/){
		$attribute=~s/(xml|html)(Url)/\(xml\|html\)\?\2/i;
	}
	if ( -f $value ) {$searching_list=$value;}
}#parse_attribute

sub parse_output{
	$output=$_;
	$output=~s/^\-\-output=['"]*([^"']*)['"]*$/\2/g;
	if(!("$output"=~"/(xml|html)Url/"||"$output"eq"title"||"$output"eq"text"||"$output"eq"description")){
		$output="\(xml\)Url";
		return 0;
	}
	
	$output=~s/(.*)/\(\1\)/i;
	return 1;
}#parse_arg

sub main{
	for ( my $i=0; $i<@ARGV; $i++ ) {
		parse_attribute($ARGV[$i]);
		if( (parse_output( $ARGV[$i+1] )) ){ $i++; }
		search_catalogs();
	}
}#main

main();
