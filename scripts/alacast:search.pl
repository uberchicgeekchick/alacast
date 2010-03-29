#!/usr/bin/perl
use strict;

if ( @ARGV < 0 || "$ARGV[0]" eq "-h"  || "$ARGV[0]" eq "--help" ) { usage(); }

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

my @xmlUrls_found=();
my $previous_xmlUrl_parser="";#NULL
my $xmlUrl_parser="";#NULL

my $global_search_attribute;
my $global_search_attributes_value;
my $searching_list="";
my @alacast_catalog_search_outputs=();

sub usage{
	printf( "Usage:\n\t %s [options...]\n\t[--(enable|disable)-(feature)\n\t\tfeature may include any of the following:\n", $scripts_exec);
	printf( "\t\tverbose|debug\t\tControls how much addition & descriptive information is output.\n");
	printf( "\t\topml-uri\t\t\n" );
	printf( "xmlUrl-parser)] [--title|(default)xmlUrl|htmlUrl|text|description]=]search_term or path to file containing search terms(one per line.) [--output=attribute-to-display. default: xmlUrl]\n\t\tAll of of these options may be repeated multiple times together or only multiple uses of the first argument.  Lastly multiple terms, or files using terms \n", );
	exit(-1);
}#usage();

sub search_catalog{
	my $catalog=shift;
	my $results_found=0;
	my $find_command=sprintf("/usr/bin/find %s%s/%s%s -iname '*.opml'", '"', $catalogs_path, $catalog, '"' );
	if($be_verbose==1 && $debug_mode==1){ printf("Catalog search command: %s.", $find_command ); }
	
	my @opml_files_to_edit=();
	
	foreach my $opml_file ( `$find_command` ){
		chomp($opml_file);
		if( "$opml_file" eq "" ) { next; }
		$opml_file=~s/'/\'/g;
		my $grep_command=sprintf("/bin/grep --binary-files=without-match --with-filename --perl-regex -i '.*%s=[\"][^\"]\*%s[^\"]\*[\"]' %s%s%s", $global_search_attribute, $global_search_attributes_value, '"', $opml_file, '"' );
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
			
			my $opml_outline=$opml_and_outline;
			$opml_outline=~s/^([^:]*):(.*)$/\2/;
			
			my $results_displayed=0;
			printf("<%s%s>:", ($opml_uri==1 ?"file://" :""), $opml_file);
			if(!( $results_displayed=display_outputs($opml_outline, $grep_command) )) { next; }
			if( $be_verbose==1 ){
				printf("\n\tOPML Outline:\n\t%s\n", "$opml_outline");
			}
			
			if($results_displayed>0){ printf("\n"); }
			
			if($be_verbose==1 && $debug_mode==1){printf("\t\tegrep's output:%s\n", $opml_and_outline);}
			
			if($global_edit_opml==1){
				my $already_editing_opml=0;#false
				for(my $i=0; $i<@opml_files_to_edit && $already_editing_opml==0; $i++){
					if("$opml_files_to_edit[$i]"ne"\"$opml_file\""){ next; }
					$already_editing_opml=1;#true
				}
				if($already_editing_opml==0) { $opml_files_to_edit[@opml_files_to_edit]="\"$opml_file\""; }
			}
			
			if("$xmlUrl_parser"ne""){
				my $xmlUrl_attribute=$opml_outline;
				$xmlUrl_attribute=~s/.*xmlUrl=["]([^"]+)["].*/\1/i;
				my $already_parsed=0;
				for(my $i=0; $i<@xmlUrls_found && $already_parsed==0; $i++){
					if("$xmlUrls_found[$i]"eq"$xmlUrl_attribute"){$already_parsed=1;}
				}
				if($already_parsed==0){
					$xmlUrls_found[@xmlUrls_found]="$xmlUrl_attribute";
				}
			}
		}
	}
	
	if( @xmlUrls_found > 0 ){
		for(my $i=0; $i<@xmlUrls_found; $i++){
			my $xmlUrl_parser_exec="tcsh -f -c '";
			if($xmlUrl_parser!~/.*\$xmlUrl.*/){
				$xmlUrl_parser_exec.="$xmlUrl_parser\"$xmlUrls_found[$i]\";";
			}else{
				$xmlUrl_parser_exec.="set xmlUrl=\"$xmlUrls_found[$i]\"; $xmlUrl_parser; unset xmlUrl;";
			}
			$xmlUrl_parser_exec.="'";
			printf("Running:\n\t%s\n", $xmlUrl_parser_exec); 
			exec($xmlUrl_parser_exec);
		}
	}
	
	if( @opml_files_to_edit > 0){
		my $editor_exec="tcsh -f -c 'vim-enhanced -p @opml_files_to_edit'";
		printf("Running:\n\t%s\n", $editor_exec); 
		exec($editor_exec);
	}
}#search_catalog

sub display_outputs{
	my $opml_outline=shift;
	my $grep_command=shift;
	
	my $results_displayed=0;
	
	for(my $i=0; $i<@alacast_catalog_search_outputs; $i++ ){
		if("$alacast_catalog_search_outputs[$i]"eq""){
			next;
		}
		
		if( $debug_mode==1 ) {
			printf "Looking for:\n\t$alacast_catalog_search_outputs[$i]\n";
		}
		
		if("$alacast_catalog_search_outputs[$i]"eq"outline"){
			$results_displayed++;
			if( $debug_mode==1 ){
				printf("\n\nSearch command:\n\t%s%s%s\n", "`", $grep_command, "`");
			}
			printf("\n\t%s\n", "$opml_outline");
			next;
		}
		
		if( $opml_outline!~/.*$alacast_catalog_search_outputs[$i]=["][^"]+["].*/i ){
			next;
		}
		
		my $opml_attribute=$opml_outline;
		if("$alacast_catalog_search_outputs[$i]"eq"$global_search_attribute"){
			$opml_attribute=~s/.*$alacast_catalog_search_outputs[$i]=["]([^"]*$global_search_attributes_value[^"]*)["].*/\2/i;
		}else{
			$opml_attribute=~s/.*$alacast_catalog_search_outputs[$i]=["]([^"]+)["].*/\2/i;
		}
		$opml_attribute=~s/<!\[CDATA\[(.*)\]\]>/\1/;
		
		if("$opml_attribute"eq""){
			next;
		}
		
		$results_displayed++;
		if( $debug_mode==1 ){
			printf("\n\nSearch command:\n\t%s%s%s\n", "`", $grep_command, "`");
		}
		printf("\n\t%s=\"%s\"", $alacast_catalog_search_outputs[$i], $opml_attribute);
	}
	return $results_displayed;
}#display_outputs

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
	
	if($debug_mode==1){printf("Parsing option: [%s]%s\n", "$option", ("$value"eq"" ?"" :"=<$value>")); }
	if("$option"eq"output" && "$value" ne ""){
		if($debug_mode==1){ printf( "\tHandling output argument: [%s].\n", $value ); }
		return parse_output($value);
	}
	
	if("$option"=~/^(en|dis)able.*$/){
		if($debug_mode==1){ printf( "\t%sabling %s switch: [%s].\n", $option, $value ); }
		return parse_setting($option, $value);
	}
	
	if($option=~/^(xml|html)?Url$/i||"$option"eq"title"||"$option"eq"text"||"$option"eq"description"||"$option"eq"type"|| -f "$option"){
		if($debug_mode==1){ printf( "\tHandling opml search attribute: [%s].\n", $value ); }
		return parse_attribute($option, $value);
	}
	
	if($debug_mode==1){ printf( "\tHandling other argument: [%s%s%s].\n", $option, ("$value"eq"" ?"" :"="), $value ); }
	return parse_options_action($option, $value);
}#parse_option

sub parse_options_action{
	my $option=shift;
	my $value=shift;
	
	if("$option"eq"xmlUrl-parser"){
		return set_xmlUrl_parser("enable", $value);
	}
	
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
			@xmlUrls_found=();
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
	my $action=shift;
	my $value=shift;
	my $parameter=$value;
	
	if($value=~/^.*=.*$/){
		$value=~s/^([^=]+)=(.*)$/\1/;
	}
	$parameter=~s/^([^=]+)=(.*)$/\2/;
	
	if($debug_mode==1){printf("Attempting to %sable: %s=[%s]\n", ("$action"eq"disable" ?"dis" :"en"), $parameter, $value);}

	
	if("$value"eq"editing"||"$value"eq"edit-opml"){
		printf("VI editing\t\t\t\t\t\t[%sd]:\n", $action);
		if("$action"eq"enable"){ $global_edit_opml=1; }
		if("$action"eq"disable"){ $global_edit_opml=0; }
		return 1;
	}
	
	if("$value"eq"debug"){
		printf("Debug mode\t\t\t\t\t\t[%sd]:\n", $action);
		if("$action"eq"enable" && $debug_mode==0){ $debug_mode=1; }
		if("$action"eq"disable" && $debug_mode==1){ $debug_mode=0; }
		return 1;
	}
	
	if("$value"eq"verbose"){
		printf("Verbose search output\t\t\t\t\t\t[%sd]:\n", $action);
		if("$action"eq"enable" && $be_verbose==0){ $be_verbose=1; }
		if("$action"eq"disable" && $be_verbose==1){ $be_verbose=0; }
		return 1;
	}
	
	if("$value"eq"opml-uri"){
		printf("OPML files formatted as URI instead of paths\t\t\t\t\t\t[%sd]:\n", $action);
		if("$action"eq"enable" && $opml_uri==0){ $opml_uri=1; }
		if("$action"eq"disable" && $opml_uri==1){ $opml_uri=0; }
		return 1;
	}
	
	if("$value"eq"xmlUrl-parser"){
		return set_xmlUrl_parser($action, $parameter);
	}
	return 0;
}#parse_setting();

sub set_xmlUrl_parser{
	my $action=shift;
	my $parser=shift;
	
	if("$action"eq"disable"){
		if("$xmlUrl_parser"ne""){
			$previous_xmlUrl_parser=$xmlUrl_parser;
			$xmlUrl_parser="";
		}
		printf("Further xmlUrls will not be passed to any parser/handler");
		return 1;
	}
	
	if(!("$action"eq"enable" && "$parser"ne"")){ return 0; }
	
	$xmlUrl_parser=$parser;
	if("$previous_xmlUrl_parser"eq"" || "$previous_xmlUrl_parser"ne"$xmlUrl_parser"){
		@xmlUrls_found=();
	}
	
	printf("Further xmlUrls will be passed to\t\t[%s]\n", $xmlUrl_parser);
	
	return 1;
}#set_xmlUrl_parser("(enable|disable)", "$parameter);

sub parse_attribute{
	$global_search_attribute=shift;
	$global_search_attributes_value=shift;
	$global_search_attributes_value=~s/(['"])/\1\\\1\1/g;
	$global_search_attributes_value=~s/([\?\[])/\\\1/g;
	
	$searching_list="";
	
	if(!($global_search_attribute=~/(xml|html)?Url/i||"$global_search_attribute"eq"title"||"$global_search_attribute"eq"text"||"$global_search_attribute"eq"description"||"$global_search_attribute"eq"type")) {
		if ( -f $global_search_attributes_value ){
			$searching_list=$global_search_attributes_value;
			return 1;
		}
		$global_search_attribute="\(title\|text\)";
		return 0;
	}
	if($global_search_attribute=~/(xml|html)?Url/i){
		$global_search_attribute=~s/(xml|html)?(Url)/\(xml\|html\)\?\2/i;
	}elsif("$global_search_attribute"eq"title"){
		$global_search_attribute="\(title\|text\)";
	}
	return 1;
}#parse_attribute

sub parse_output{
	my $outputs=shift;
	$outputs.=",";
	chomp($outputs);
	my @outputs=split(",", $outputs);
	chomp(@outputs);
	my $x=@alacast_catalog_search_outputs;
	for(my $i=0; $i<@outputs; $i++){
		if( $debug_mode==1 ){ printf("Validating Output Attribute: [%s]\n", $outputs[$i]); }
		if("$outputs[$i]"eq""){
			next;
		}
		if(!($outputs[$i]=~/(xml|html)?Url/i||"$outputs[$i]"eq"title"||"$outputs[$i]"eq"text"||"$outputs[$i]"eq"description"||"$outputs[$i]"eq"type"||"$outputs[$i]"eq"outline"||"$outputs[$i]"eq"verbose")) {
			next;
		}
		if("$outputs[$i]"eq"outline"||"$outputs[$i]"eq"verbose"){
			$alacast_catalog_search_outputs[++$x]="outline";
		}elsif($outputs[$i]=~/^(xml|html)?Url$/){
			$alacast_catalog_search_outputs[++$x]="(xmlUrl)";
			$alacast_catalog_search_outputs[++$x]="(htmlUrl)";
		}elsif("$outputs[$i]"eq"title"||"$outputs[$i]"eq"text"){
			$alacast_catalog_search_outputs[++$x]="(title)";
			$alacast_catalog_search_outputs[++$x]="(text)";
		}else{
			$alacast_catalog_search_outputs[++$x]="($outputs[$i])";
		}
		#$alacast_catalog_search_outputs[++$x]="($outputs[$i])";
	}
	chomp(@alacast_catalog_search_outputs);
	if( $debug_mode==1 ){ printf("Output details for this loop:\n\tOutput Attributes:"); }
	
	if(@alacast_catalog_search_outputs == 0){
		@alacast_catalog_search_outputs=("(xmlUrl)", "(htmlUrl)");
		if( $debug_mode==1 ){ printf("[@alacast_catalog_search_outputs]\n"); }
		return 0;
	}
	if( $debug_mode==1 ){ printf("[@alacast_catalog_search_outputs]\n"); }
	return 1;
}#parse_output

sub main{
	@alacast_catalog_search_outputs=();
	for ( my $i=0; $i<@ARGV; $i++ ){ parse_option($ARGV[$i]); }
	if("$global_search_attributes_value"eq""){
		printf("\n\t**fatal error:** at least one valid search attribute must be specified.\n\n");
		usage();
	}
	if(@alacast_catalog_search_outputs == 0){
		@alacast_catalog_search_outputs=("(xmlUrl)", "(htmlUrl)");
		#@alacast_catalog_search_outputs=("(xml|html)Url");
	}
	search_catalogs();
}#main

main();
