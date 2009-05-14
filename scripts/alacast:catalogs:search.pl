#!/usr/bin/perl
use strict;

if ( @ARGV < 0 || "$ARGV[0]" eq "-h"  || "$ARGV[0]" eq "--help" ) { print_usage(); }

my $scripts_path = `dirname "$0"`;
$scripts_path =~ s/[\r\n]+//;
my $scripts_exec = `basename "$0"`;
$scripts_exec =~ s/[\r\n]+//;
my $opml_files_path = "$scripts_path/../data/xml/opml";
my @catalogs = ( "ip.tv", "library", "podcasts", "vodcasts", "radiocasts", "music" );

my $be_verbose=0;#False
my $debug_mode=0;#FALSE

my $attribute;
my $value;
my $searching_list="";
my $output = "";

sub print_usage{
	printf( "Usage:\n\t %s [--title|(default)xmlUrl|htmlUrl|text|description]=]search_term or path to file containing search terms(one per line.) [--output=attribute-to-display. default: xmlUrl]\n\t\tBoth of these options may be repeated multiple times together or only multiple uses of the first argument.  Lastly multiple terms, or files using terms \n", $scripts_exec );
	exit(-1);
}

sub search_catalog{
	my $catalog=shift;
	my $results_found=0;
	my $grep_command=sprintf("/usr/bin/grep --binary-files=without-match --with-filename -i --perl-regex -e '.*%s=[\"\'\\\'\'][^\"\'\\\'\']\*%s[^\"\'\\\'\']\*[\"\'\\\'\']' -r '%s/%s'", $attribute, $value, $opml_files_path, $catalog );
	
	if( $debug_mode ) { printf("Search command: %s\n\n", $grep_command); }
	foreach my $opml_and_outline ( `$grep_command` ) {
		$opml_and_outline=~s/[\r\n]+//g;
		if( $opml_and_outline!~/.*$output=["'][^'"]+["'].*/i ){
			if( $debug_mode ) {
				printf("Output: [%s] not found.\n\tSkipping: %s\n", $output, $opml_and_outline);
			}
			next;
		}
		
		if($results_found==0){
			printf("\n\nResults found in catalog/opml: %s\n", $catalog);
		}
		$results_found++;
		
		my $opml_file=$opml_and_outline;
		$opml_file=~s/^([^:]*):.*$/\1/;
		while($opml_file=~/\.\.\//){
			$opml_file =~ s/[^\/]+\/\.\.\///g;
		}
		
		my $opml_attribute=$opml_and_outline;
		$opml_attribute=~s/.*$output=["']([^"']+)["'].*/\2/i;
		$opml_attribute=~s/<!\[CDATA\[(.+)\]\]>/\1/;

		printf( "\t%s=%s @ %s\n", $output, $opml_attribute, $opml_file );
		
		if($be_verbose==1||$debug_mode==1){printf("\n\t\t%s\n", $opml_and_outline);}
	}
}#search_catalog

sub search_catalogs{
	foreach my $catalog ( @catalogs ) {
		if ("$searching_list"eq""){ search_catalog( $catalog ); }
		else {
			if( $debug_mode ) { printf( "\nSearching catalogs listed in:\n\t%s\n", $searching_list); }
			foreach my $value ( `cat '$searching_list'` ) {
				search_catalog( $value );
			}
		}
	}
}#search_catalogs

sub parse_option{
	my $option=shift;
	
	my $action=$option;
	$action=s/^\-\-(^[\-]*)\-?(.*)/\1/;
	if("$action"eq""){ $action="enable"; }
	if("$action"!~/(en|dis)able/){ return 0; }
	my $setting=$option;
	$setting=s/^\-\-([^\-]*)\-?(.*)/\2/;
	
	if("$setting"eq"debug"){
		printf("Debug mode:\t\t[%s]\n", $action);
		if("$action"eq"enable" && $debug_mode==0){ $debug_mode=1; }
		if("$action"eq"disable" && $debug_mode==1){ $debug_mode=0; }
		return 1;
	}
	
	if("$setting"eq"verbose"){
		printf("Verbose search output:\t\t[%s]\n", $action);
		if("$action"eq"enable" && $be_verbose==0){ $be_verbose=1; }
		if("$action"eq"disable" && $be_verbose==1){ $be_verbose=0; }
		return 1;
	}
	
	return 0;
}#parse_option

sub parse_attribute{
	my $arg=shift;
	$attribute=$arg;
	$attribute=~s/^\-\-([^=]+)=["']*([^"']*)["']*$/\1/g;
	$value=$arg;
	$value=~s/^\-\-([^=]+)=["']*([^"']*)["']*$/\2/g;
	$value=~s/(['"])/\1\\\1\1/g;
	
	$searching_list="";
	
	if( $debug_mode ) { printf("Search details for this loop:\n\tAttribute: [%s]\n\tValue: [%s]\n", $attribute, $value); }
	
	if(!("$attribute"eq"url"||"$attribute"=~/(xml|html)Url/||"$attribute"eq"title"||"$attribute"eq"text"||"$attribute"eq"description"||"$attribute"eq"type")) {
		$attribute="xmlUrl";
	}
	if("$attribute"=~/(xml|html)Url/i){
		$attribute=~s/(xml|html)(Url)/\(xml\|html\)\?\2/i;
	}
	if ( -f $value ) {$searching_list=$value;}
}#parse_attribute

sub parse_output{
	$output=shift;
	$output=~s/^\-\-output=['"]*([^"']*)['"]*$/\1/g;
	if( $debug_mode ) { printf("Output details for this loop:\n\tOutput Attribute: [%s]\n", $output); }
	if(!("$output"eq"url"||"$output"=~"/(xml|html)Url/"||"$output"eq"title"||"$output"eq"text"||"$output"eq"description")){
		$output="\(xml\)Url";
		return 0;
	}
	
	$output=~s/(.*)/\(\1\)/i;
	return 1;
}#parse_output

sub main{
	for ( my $i=0; $i<@ARGV; $i++ ) {
		if( parse_option($ARGV[$i]) ){ $i++; }
		parse_attribute($ARGV[$i]);
		if( (parse_output( $ARGV[$i+1] )) ){ $i++; }
		search_catalogs();
	}
}#main

main();
