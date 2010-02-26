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
my $global_edit_opml=0;#FALSE
my @global_opml_lists=();

my @xmlUrls_parsed=();
my $previous_xmlUrl_parser="";#NULL
my $xmlUrl_parser="";#NULL

my $global_search_attribute;
my $global_search_attributes_value;
my $searching_list="";
my @alacast_catalog_search_outputs=("xmlUrl");

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
	if($be_verbose==1 && $debug_mode==1){ printf("Catalog search command: %s.", $find_command ); }
	
	foreach my $opml_file ( `$find_command` ){
		chomp($opml_file);
		if( "$opml_file" eq "" ) { next; }
		$opml_file=~s/'/\'/g;
		my $grep_command=sprintf("/usr/bin/grep --binary-files=without-match --with-filename -i --perl-regex -e '.*%s=[\"\'\\\'\'][^\"\'\\\'\']\*%s[^\"\'\\\'\']\*[\"\'\\\'\']' %s%s%s", $global_search_attribute, $global_search_attributes_value, '"', $opml_file, '"' );
		if( $be_verbose==1 && $debug_mode==1 ) { printf("Search command: %s\n\n", $grep_command); }
		foreach my $opml_and_outline ( `$grep_command` ){
			$opml_and_outline=~s/[\r\n]+//g;
			if( $opml_and_outline=~/^.*\<!\-\-.*\-\-\>$/ ){ next; }
			
			if(!$results_found){
				if($be_verbose==1) { printf("[%s catalog]>\n", $catalog); }
			}
			$results_found++;
			
			while($opml_and_outline=~/\.\.\//){
				$opml_and_outline =~ s/[^\/]+\/\.\.\///g;
			}
			
			my $opml_file=$opml_and_outline;
			$opml_file=~s/^([^:]*):.*$/\1/;
			
			my $results_displayed=0;
			printf("<%s%s>:", ($opml_uri==1 ?"file://" :""), $opml_file);
			for(my $i=0; $i<@alacast_catalog_search_outputs; $i++ ){
				if("$alacast_catalog_search_outputs[$i]"eq""){
					if($debug_mode==1){ printf("Skipping empty output option #%d.\n", $i); }
					next;
				}
				if( $opml_and_outline!~/.*$alacast_catalog_search_outputs[$i]=["'][^'"]+["'].*/i ){
					if($debug_mode==1){ printf("Output: [%s] not found. Skipping: [%s]\n", $alacast_catalog_search_outputs[$i], $opml_and_outline); }
					next;
				}
				
				my $opml_attribute=$opml_and_outline;
				$opml_attribute=~s/.*$alacast_catalog_search_outputs[$i]=["']([^"']+)["'].*/\1/i;
				$opml_attribute=~s/<!\[CDATA\[(.+)\]\]>/\1/;
				
				if("$opml_attribute"eq""){
					if($debug_mode==1){ printf("<%s%s>'s %s attribute is empty.", ($opml_uri==1?"file://":""), $opml_file, $alacast_catalog_search_outputs[$i]); }
					next;
				}
				
				$results_displayed++;
				printf("\n\t%s=%s", $alacast_catalog_search_outputs[$i], $opml_attribute);
			}
			if($results_displayed>0){ printf("\n"); }
			
			if($global_edit_opml==1){
				exec("vi '$opml_file'");
				wait;
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
			
			if($be_verbose==1 && $debug_mode==1){printf("\t\tegrep's output:%s\n", $opml_and_outline);}
		}
	}
}#search_catalog

sub search_catalogs{
	foreach my $catalog ( @catalogs ) {
		if ("$searching_list"eq""){ search_catalog( $catalog ); }
		else {
			if($be_verbose==1 &&  $debug_mode==1) { printf( "\nSearching catalogs listed in:\n\t%s\n", $searching_list); }
			foreach my $global_search_attributes_value ( `cat '$searching_list'` ) {
				search_catalog( $global_search_attributes_value );
			}
		}
	}
}#search_catalogs

sub parse_option{
	my $argv=shift;
	my $dashes=$argv;
	my $value=$argv;
	my $option=$argv;
	$dashes=~s/^([\-]{1,2})([^=]+)[\-=]?(.*)$/\1/g;
	$option=~s/^([\-]{1,2})([^=]+)[\-=]?(.*)$/\2/g;
	$value=~s/^([\-]{1,2})([^=]+)[\-=]?(.*)$/\3/g;
	
	printf("Parsing option: [%s%s%s%s]\n", "$option", ("$value"eq"" ?"" :"="), "$value");
	if("$option"=~/^(\-\-output=.*)$/){
		return parse_output($value);
	}
	
	if("$option"=~/^(en|dis)able$/){
		return parse_setting($option, $value);
	}
	
	if($option=~/(xml|html)?Url/i||"$option"eq"title"||"$option"eq"text"||"$option"eq"description"||"$option"eq"type"){
		return parse_attribute($option, $value);
	}
	
	return parse_options_action($option, $value);
}#parse_option

sub parse_options_action{
	my $option=shift;
	my $value=shift;
	
	if("$option"eq"edit-opml"){
		if($global_edit_opml!=1){ $global_edit_opml=1; }
		return 1;
	}
	
	if("$option"eq"debug"){
		if($debug_mode!=1){ $debug_mode=1; }
		return 1;
	}
	
	if("$option"eq"verbose"){
		if($be_verbose!=1){ $be_verbose=1; }
		return 1;
	}
	
	if($option=~/^xmlUrl\-parser=.+/){
		$xmlUrl_parser=$option;
		$xmlUrl_parser=~s/^xmlUrl\-parser=(.*)/\1/g;
		if("$previous_xmlUrl_parser"ne"" && "$previous_xmlUrl_parser"ne"$xmlUrl_parser"){
			@xmlUrls_parsed=();
		}
		
		printf("Further xmlUrls will be passed to\t\t[%s]\n", $xmlUrl_parser);
		return 1;
	}
	
	#if("$option"eq""){
	#	if($_!=1){ $_=1; }
	#}
	
	return 0;
}#parse_options_action
	
sub parse_setting{
	my $option=shift;
	my $value=shift;
	
	if("$value"eq"editing"||"$value"eq"edit-opml"){
		printf("VI editing\t\t\t\t\t\t[%sd]:\n", $option);
		if("$option"eq"enable"){ $global_edit_opml=1; }
		if("$option"eq"disable"){ $global_edit_opml=0; }
		return 1;
	}
	
	if("$value"eq"debug"){
		printf("Debug mode\t\t\t\t\t\t[%sd]:\n", $option);
		if("$option"eq"enable" && $debug_mode==0){ $debug_mode=1; }
		if("$option"eq"disable" && $debug_mode==1){ $debug_mode=0; }
		return 1;
	}
	
	if("$value"eq"verbose"){
		printf("Verbose search output\t\t\t\t\t\t[%sd]:\n", $option);
		if("$option"eq"enable" && $be_verbose==0){ $be_verbose=1; }
		if("$option"eq"disable" && $be_verbose==1){ $be_verbose=0; }
		return 1;
	}
	
	if("$value"eq"opml-uri"){
		printf("OPML files formatted as URI instead of paths\t\t\t\t\t\t[%sd]:\n", $option);
		if("$option"eq"enable" && $opml_uri==0){ $opml_uri=1; }
		if("$option"eq"disable" && $opml_uri==1){ $opml_uri=0; }
		return 1;
	}
	
	if($value=~/^xmlUrl\-parser=.+/){
		if("$option"eq"enable"){
			$xmlUrl_parser=$value;
			$xmlUrl_parser=~s/^xmlUrl\-parser=(.*)/\1/g;
			if("$previous_xmlUrl_parser"ne"" && "$previous_xmlUrl_parser"ne"$xmlUrl_parser"){
				@xmlUrls_parsed=();
			}
			
			printf("Further xmlUrls will be passed to\t\t[%s]\n", $xmlUrl_parser);
		}
		if("$option"eq"disable" && $xmlUrl_parser!=""){
			$xmlUrl_parser="";
			printf("Further xmlUrls will not be passed to any parser/handler");
		}
		return 1;
	}
	return 0;
}#parse_option

sub parse_attribute{
	$global_search_attribute=shift;
	$global_search_attributes_value=shift;
	$global_search_attributes_value=~s/(['"])/\1\\\1\1/g;
	$global_search_attributes_value=~s/([\?\[])/\\\1/g;
	
	$searching_list="";
	
	if( $debug_mode==1 ) { printf("Search options for this loop:\n\tOption: [%s]\n\tValue: [%s]\n", $global_search_attribute, $global_search_attributes_value); }
	
	if(!($global_search_attribute=~/(xml|html)?Url/i||"$global_search_attribute"eq"title"||"$global_search_attribute"eq"text"||"$global_search_attribute"eq"description"||"$global_search_attribute"eq"type")) {
		$global_search_attribute="\(title\|text\)";
		return 0;
	}
	if($global_search_attribute=~/(xml|html)?Url/i){
		$global_search_attribute=~s/(xml|html)(Url)/\(xml\|html\)\?\2/i;
	}elsif("$global_search_attribute"eq"title"){
		$global_search_attribute="\(title\|text\)";
	}
	if ( -f $global_search_attributes_value ) {$searching_list=$global_search_attributes_value;}
	return 1;
}#parse_attribute

sub parse_output{
	my $outputs=shift;
	$outputs.=",";
	@alacast_catalog_search_outputs=();
	chomp($outputs);
	my @outputs=split(",", $outputs);
	chomp(@outputs);
	my $x=@outputs;
	for(my $i=0; $i<@outputs; $i++){
		if( $debug_mode==1 ){ printf("Validating Output Attribute: [%s]\n", $outputs[$i]); }
		if("$outputs[$i]"eq""){
			next;
		}
		if(!($outputs[$i]=~/^(xml|html)?Url$/||"$outputs[$i]"eq"title"||"$outputs[$i]"eq"text"||"$outputs[$i]"eq"description")){
			next;
		}
		$alacast_catalog_search_outputs[$x++]="$outputs[$i]";
	}
	chomp(@alacast_catalog_search_outputs);
	if( $debug_mode==1 ){ printf("Output details for this loop:\n\tOutput Attributes: [@alacast_catalog_search_outputs]\n"); }
	
	if(@alacast_catalog_search_outputs == 0){
		@alacast_catalog_search_outputs=("xmlUrl");
		return 0;
	}
	return 1;
}#parse_output

sub main{
	for ( my $i=0; $i<@ARGV; $i++ ){ parse_option($ARGV[$i]); }
	search_catalogs();
}#main

main();
