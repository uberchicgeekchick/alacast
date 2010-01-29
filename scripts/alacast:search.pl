#!/usr/bin/perl
use strict;

if ( @ARGV < 0 || "$ARGV[0]" eq "-h"  || "$ARGV[0]" eq "--help" ) { print_usage(); }

my $scripts_path = `dirname "$0"`;
$scripts_path =~ s/[\r\n]+//;
my $scripts_exec = `basename "$0"`;
$scripts_exec =~ s/[\r\n]+//;
my $catalogs_path = "$scripts_path/../data/xml/opml";
my @catalogs = ( "ip.tv", "library", "podcasts", "vodcasts", "radiocasts", "music" );

my $be_verbose=0;#False
my $debug_mode=0;#FALSE
my $opml_uri=0;#FALSE
my $edit_opml=0;#FALSE

my @xmlUrls_parsed=();
my $previous_xmlUrl_parser="";#NULL
my $xmlUrl_parser="";#NULL

my $attribute;
my $value;
my $searching_list="";
my $output = "\(xml\)Url";

sub print_usage{
	printf( "Usage:\n\t %s [options...]\n\t[--(enable|disable)-(feature)\n\t\tfeature may include any of the following:\n", $scripts_exec);
	printf( "\t\tverbose|debug\t\tControls how much addition & descriptive information is output.\n");
	printf( "\t\topml-uri\t\t\n" );
	printf( "xmlUrl-parser)] [--title|(default)xmlUrl|htmlUrl|text|description]=]search_term or path to file containing search terms(one per line.) [--output=attribute-to-display. default: xmlUrl]\n\t\tAll of of these options may be repeated multiple times together or only multiple uses of the first argument.  Lastly multiple terms, or files using terms \n", );
	exit(-1);
}

sub search_catalog{
	my $catalog=shift;
	my $results_found=0;
	my $find_command=sprintf("/usr/bin/find %s%s/%s%s -iname '*.opml'", '"', $catalogs_path, $catalog, '"' );
	if( $debug_mode==1 ){ printf("Catalog search command: %s.", $find_command ); }
	
	foreach my $opml_file ( `$find_command` ){
		chomp($opml_file);
		if( "$opml_file" eq "" ) { next; }
		$opml_file=~s/'/\'/g;
		my $grep_command=sprintf("/usr/bin/grep --binary-files=without-match --with-filename -i --perl-regex -e '.*%s=[\"\'\\\'\'][^\"\'\\\'\']\*%s[^\"\'\\\'\']\*[\"\'\\\'\']' %s%s%s", $attribute, $value, '"', $opml_file, '"' );
		if( $debug_mode==1 ) { printf("Search command: %s\n\n", $grep_command); }
		foreach my $opml_and_outline ( `$grep_command` ){
			$opml_and_outline=~s/[\r\n]+//g;
			if( $opml_and_outline=~/^.*\<!\-\-.*\-\-\>$/ ){ next; }
			if( $opml_and_outline!~/.*$output=["'][^'"]+["'].*/i ){
				if( $debug_mode==1 ) { printf("Output: [%s] not found. Skipping: [%s]\n", $output, $opml_and_outline); }
				next;
			}
			
			if(!$results_found){
				if($be_verbose==1) { printf("[%s catalog]>\n", $catalog); }
			}
			$results_found++;
			
			while($opml_and_outline=~/\.\.\//){
				$opml_and_outline =~ s/[^\/]+\/\.\.\///g;
			}

			my $opml_file=$opml_and_outline;
			$opml_file=~s/^([^:]*):.*$/\1/;
			
			my $opml_attribute=$opml_and_outline;
			$opml_attribute=~s/.*$output=["']([^"']+)["'].*/\2/i;
			$opml_attribute=~s/<!\[CDATA\[(.+)\]\]>/\1/;
			
			printf("%s>%s>%s%s\n", $output, $opml_attribute, ($opml_uri==1?"file://":""), $opml_file);
			if($edit_opml){
				exec("vi '$opml_file'");
			}
			if("$xmlUrl_parser"ne""){
				my $xmlUrl_attribute=$opml_and_outline;
				$xmlUrl_attribute=~s/.*xmlUrl=["']([^"']+)["'].*/\1/i;
				my $already_parsed=0;
				for(my $i=0; $i<@xmlUrls_parsed && $already_parsed==0; $i++){
					if($xmlUrls_parsed[$i]==$xmlUrl_attribute){$already_parsed=1;}
				}
				if(!$already_parsed){
					$xmlUrls_parsed[@xmlUrls_parsed]=$xmlUrl_attribute;
					my $xmlUrl_parser_exec="tcsh -f -c '($xmlUrl_parser\"$xmlUrl_attribute\" > /dev/tty) >& /dev/null'";
					printf("Running:\n\t%s\n", $xmlUrl_parser_exec); 
					exec($xmlUrl_parser_exec);
				}
			}
			
			if($be_verbose==1 || $debug_mode==1){printf("\t\tegrep's output:%s\n", $opml_and_outline);}
		}
	}
}#search_catalog

sub search_catalogs{
	foreach my $catalog ( @catalogs ) {
		if ("$searching_list"eq""){ search_catalog( $catalog ); }
		else {
			if( $debug_mode==1 ) { printf( "\nSearching catalogs listed in:\n\t%s\n", $searching_list); }
			foreach my $value ( `cat '$searching_list'` ) {
				search_catalog( $value );
			}
		}
	}
}#search_catalogs

sub parse_option{
	my $option=shift;
	
	if("$option"=~/^(\-\-output=.*)$/){
		return parse_output($option);
	}
	
	my $action=$option;
	$action=~s/^\-\-([^\-=]+)[\-=]?(.*)$/\1/g;
	
	if($action=~/(xml|html)?Url/i||"$action"eq"title"||"$action"eq"text"||"$action"eq"description"||"$action"eq"type"){
		return parse_attribute($option);
	}
	
	if("$action"!~/^(en|dis)able$/){
		return 0;
	}
	
	parse_setting($option);
}#parse_option
	
sub parse_setting{
	my $option=shift;
	
	my $action=$option;
	$action=~s/^\-\-([^\-=]+)[\-=]?(.*)$/\1/g;
	
	my $setting=$option;
	$setting=~s/^\-\-([^\-=]*)[\-=]?(.*)$/\2/g;
	
	if("$setting"eq"editing"){
		printf("VI editing\t\t\t\t\t\t[%sd]:\n", $action);
		if("$action"eq"enable"){ $edit_opml=1; }
		if("$action"eq"disable"){ $edit_opml=0; }
		return 1;
	}
	
	if("$setting"eq"debug"){
		printf("Debug mode\t\t\t\t\t\t[%sd]:\n", $action);
		if("$action"eq"enable" && $debug_mode==0){ $debug_mode=1; }
		if("$action"eq"disable" && $debug_mode==1){ $debug_mode=0; }
		return 1;
	}
	
	if("$setting"eq"verbose"){
		printf("Verbose search output\t\t\t\t\t\t[%sd]:\n", $action);
		if("$action"eq"enable" && $be_verbose==0){ $be_verbose=1; }
		if("$action"eq"disable" && $be_verbose==1){ $be_verbose=0; }
		return 1;
	}
	
	if("$setting"eq"opml-uri"){
		printf("OPML files formatted as URI instead of paths\t\t\t\t\t\t[%sd]:\n", $action);
		if("$action"eq"enable" && $opml_uri==0){ $opml_uri=1; }
		if("$action"eq"disable" && $opml_uri==1){ $opml_uri=0; }
		return 1;
	}
	
	if($setting=~/^xmlUrl\-parser=.+/){
		if( "$action"eq"enable" ){
			$xmlUrl_parser=$setting;
			$xmlUrl_parser=~s/^xmlUrl\-parser=(.*)/\1/g;
			if("$previous_xmlUrl_parser"ne"" && "$previous_xmlUrl_parser"ne"$xmlUrl_parser"){
				@xmlUrls_parsed=();
			}
			
			printf("Further xmlUrls will be passed to\t\t[%s]\n", $xmlUrl_parser);
		}
		if( "$action"eq"disable" && $xmlUrl_parser!=""){
			$xmlUrl_parser="";
			printf("Further xmlUrls will not be passed to any parser/handler");
		}
		return 1;
	}
}#parse_option

sub parse_attribute{
	my $arg=shift;
	$attribute=$arg;
	$attribute=~s/^\-\-([^=]+)=["']*([^"']*)["']*$/\1/g;
	$value=$arg;
	$value=~s/^\-\-([^=]+)=["']*([^"']*)["']*$/\2/g;
	$value=~s/(['"])/\1\\\1\1/g;
	
	$searching_list="";
	
	if( $debug_mode==1 ) { printf("Search details for this loop:\n\tAttribute: [%s]\n\tValue: [%s]\n", $attribute, $value); }
	
	if(!($attribute=~/(xml|html)?Url/i||"$attribute"eq"title"||"$attribute"eq"text"||"$attribute"eq"description"||"$attribute"eq"type")) {
		$attribute="title";
	}
	if($attribute=~/(xml|html)?Url/i){
		$attribute=~s/(xml|html)(Url)/\(xml\|html\)\?\2/i;
	}elsif("$attribute"eq"title"){
		$attribute="\(title\|text\)";
	}
	if ( -f $value ) {$searching_list=$value;}
}#parse_attribute

sub parse_output{
	$output=shift;
	$output=~s/^\-\-output=['"]*([^"']*)['"]*$/\1/g;
	if( $debug_mode==1 ) { printf("Output details for this loop:\n\tOutput Attribute: [%s]\n", $output); }
	if(!($output=~/(xml|html)?Url/i||"$output"eq"title"||"$output"eq"text"||"$output"eq"description")){
		$output="\(xml\)Url";
		return 0;
	}
	
	$output=~s/^(.*)$/\($1\)/;
	return 1;
}#parse_output

sub main{
	for ( my $i=0; $i<@ARGV; $i++ ){ parse_option($ARGV[$i]); }
	search_catalogs();
}#main

main();
