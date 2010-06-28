#!/usr/bin/perl
use strict;
#use lib "`basename \"${0}\"`/scripts";
my $TRUE=1;
my $FALSE=0;

my $scripts_path=`dirname "$0"`;
$scripts_path=~s/\n//;
my $scripts_basename=`basename "$0"`;
$scripts_basename=~s/\n//;

if( @ARGV < 0 && ( "$ARGV[0]"eq"-h" || "$ARGV[0]"eq"--help" )) { usage(); }

my $catalogs_path="$scripts_path/../data/xml/opml";
my @catalogs=("podcasts", "library", "radiocasts",  "ip.tv", "vodcasts", "music", "unfiled.opml");
if( -e "$catalogs_path/../../profiles/$ENV{USER}/opml/subscriptions.opml" ){
	$catalogs[@catalogs]="../../profiles/$ENV{USER}/opml/subscriptions.opml";
}

my $be_verbose=0;#False
my $debug_mode=0;#FALSE
my @global_opml_lists=();

my $global_edit_opml=0;#FALSE
my @opml_files_to_edit=();

my @xmlUrls_to_parse=();
my $previous_xmlUrl_parser="";#NULL
my $xmlUrl_parser="";#NULL

my $start_with=0;
my $download_limit=0;

my $www_browser="";#NULL
my $previous_www_browser="";#NULL
my @websites_to_visit=();

my $global_search_attribute;
my $global_search_attributes_value;
my $searching_list="";
my @alacast_catalog_search_outputs=("title", "htmlUrl", "xmlUrl");

sub usage{
	printf( "Usage:\n\t %s [options...]\n\t[--(enable|disable)-(feature)\n\t\tfeature may include any of the following:\n", $scripts_basename);
	printf( "\t\tverbose|debug\t\tControls how much addition & descriptive information is output.\n");
	printf( "\t\txmlUrl-parser)] [--title|(default)xmlUrl|htmlUrl|text|description]=]search_term or path to file containing search terms(one per line.) [--output=attribute-to-display. default: xmlUrl]\n\t\tAll of of these options may be repeated multiple times together or only multiple uses of the first argument.  Lastly multiple terms, or files using terms \n", );
	exit(-1);
}#usage();

sub search_catalog{
	my $catalog=shift;
	my $results_found=0;
	if(! -e "$catalogs_path/$catalog" ){
		printf("I cannot search for podcasts in: <%s/%s>. Its either not a directory or doesn't exist.\n", "$catalogs_path", "$catalog");
		return $FALSE;
	}
	my $find_command=sprintf("/usr/bin/find \"%s/%s\" -iname '*.opml'", $catalogs_path, $catalog);
	if($be_verbose && $debug_mode){ printf("Catalog search command: %s.", $find_command ); }
	
	foreach my $opml_file ( `$find_command` ){
		chomp($opml_file);
		if( "$opml_file"eq"" ) { next; }
		$opml_file=~s/'/\'/g;
		my $grep_command=sprintf("grep --binary-files=without-match --with-filename --line-number --perl-regex -i '.*%s=[\"][^\"]\*%s[^\"]\*[\"]' %s%s%s", $global_search_attribute, $global_search_attributes_value, '"', $opml_file, '"' );
		foreach my $opml_and_outline ( `$grep_command` ){
			$opml_and_outline=~s/\n//g;
			if( $opml_and_outline=~/^.*\<!\-\-.*\-\-\>$/ ){ next; }
			
			if(!$results_found){
				if($be_verbose) { printf("[%s catalog]>\n", $catalog); }
			}
			$results_found++;
			
			while($opml_and_outline=~/\.\.\//){
				$opml_and_outline=~s/[^\/]+\/\.\.\///g;
			}
			
			my $opml_file=$opml_and_outline;
			$opml_file=~s/^(.*):([0-9]+):(.*)$/$1/;
			
			my $opml_outline=$opml_and_outline;
			$opml_file=~s/^(.*):([0-9]+):(.*)$/$3/;
			
			my $results_displayed=0;
			printf("<file://%s>:\n", $opml_file);
			if(!( $results_displayed=display_outputs($opml_outline, $grep_command) )) { next; }
			if( $be_verbose ){
				printf("\n\tOPML Outline:\n\t%s\n", "$opml_outline");
			}
			
			if($results_displayed>0){ printf("\n"); }
			
			if($be_verbose && $debug_mode){printf("\t\tegrep's output:%s\n", $opml_and_outline);}
			
			if($global_edit_opml){
				my $already_editing_opml=0;#false
				for(my $i=0; $i<@opml_files_to_edit && !$already_editing_opml; $i++){
					if("$opml_files_to_edit[$i]"ne"\"$opml_file\""){ next; }
					$already_editing_opml=1;#true
				}
				if(!$already_editing_opml) { $opml_files_to_edit[@opml_files_to_edit]="\"$opml_file\""; }
			}
			
			if("$xmlUrl_parser"ne""){
				if($opml_outline=~/.*xmlUrl="([^"]+)".*$/){
					my $xmlUrl_attribute=$opml_outline;
					$xmlUrl_attribute=~s/.*xmlUrl="([^"]+)".*/$1/i;
					$xmlUrl_attribute=~s/\&amp;/\&/ig;
					my $already_parsed=0;
					for(my $i=0; $i<@xmlUrls_to_parse && !$already_parsed; $i++){
						if("$xmlUrls_to_parse[$i]"eq"$xmlUrl_attribute"){$already_parsed=1;}
					}
					if(!$already_parsed){
						$xmlUrls_to_parse[@xmlUrls_to_parse]="$xmlUrl_attribute";
					}
				}
			}
			
			if("$www_browser"ne""){
				if($opml_outline=~/.*htmlUrl="([^"]+)".*$/){
					my $htmlUrl_attribute=$opml_outline;
					$htmlUrl_attribute=~s/.*htmlUrl="([^"]+)".*/$1/i;
					$htmlUrl_attribute=~s/\&amp;/\&/ig;
					my $already_visited=0;
					for(my $i=0; $i<@websites_to_visit && !$already_visited; $i++){
						if("$websites_to_visit[$i]"eq"$htmlUrl_attribute"){$already_visited=1;}
					}
					if(!$already_visited){
						$websites_to_visit[@websites_to_visit]="$htmlUrl_attribute";
					}
				}
			}
		}
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
		
		if( $debug_mode ) {
			printf "Looking for:\n\t$alacast_catalog_search_outputs[$i]\n";
		}
		
		if("$alacast_catalog_search_outputs[$i]"eq"outline"){
			$results_displayed++;
			if( $debug_mode ){
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
			$opml_attribute=~s/.*$alacast_catalog_search_outputs[$i]=["]([^"]*$global_search_attributes_value[^"]*)["].*/$1/i;
		}else{
			$opml_attribute=~s/.*$alacast_catalog_search_outputs[$i]=["]([^"]+)["].*/$1/i;
		}
		$opml_attribute=~s/\<\!\[CDATA\[(.*)\]\]\>/$1/g;
		
		if("$opml_attribute"eq""){
			next;
		}
		
		$opml_attribute=~s/\&amp;/\&/g;
		
		if( $debug_mode ){
			printf("\n\nSearch command:\n\t%s%s%s\n", "`", $grep_command, "`");
		}
		$results_displayed++;
		if( $results_displayed == 1 ) { printf("\t<outline"); }
		printf(" %s=\"%s\"", $alacast_catalog_search_outputs[$i], $opml_attribute);
	}
	if( $results_displayed > 0 ) { printf(" />\n"); }
	return $results_displayed;
}#display_outputs

sub search_catalogs{
	foreach my $catalog ( @catalogs ) {
		if( $debug_mode ){ printf("Searching: %s\n", $catalog); }
		if ("$searching_list"eq""){ search_catalog($catalog); }
		else {
			if($be_verbose &&  $debug_mode) { printf( "\nSearching catalogs listed in:\n\t%s\n", $searching_list); }
			foreach my $global_search_attributes_value( `cat '$searching_list'`) {
				search_catalog($catalog, $global_search_attributes_value);
			}
		}
	}
}#search_catalogs

sub visit_websites{
	if( @websites_to_visit <= 0 ){ return; }
	for(my $i=0; $i<@websites_to_visit; $i++){
		my $www_browser_exec="tcsh -f -c '$www_browser \"$websites_to_visit[$i]\";'";
		printf("Running:\n\t%s\n", $www_browser_exec); 
		system($www_browser_exec);
	}
	@websites_to_visit=();
}#visit_websites();

sub parse_xmlUrls{
	if( @xmlUrls_to_parse <= 0 ){ return; }
	for(my $i=0; $i<@xmlUrls_to_parse; $i++){
		my $xmlUrl_parser_exec_prefix="tcsh -f -c '";
		my $xmlUrl_parser_exec_suffix="";
		if( $xmlUrl_parser=~/.*\$xmlUrl.*/ || $xmlUrl_parser=~/.*\$\{xmlUrl\}.*/ ){
			$xmlUrl_parser_exec_prefix.="set xmlUrl=\"$xmlUrls_to_parse[$i]\"; ";
			$xmlUrl_parser_exec_suffix.=" unset xmlUrl;";
		}else{
			$xmlUrl_parser_exec_suffix.="\"$xmlUrls_to_parse[$i]\";";
		}
		if( $xmlUrl_parser=~/.*\$index.*/ || $xmlUrl_parser=~/.*\$\{index\}.*/ ){
			$xmlUrl_parser_exec_prefix.="@ index=$i; ";
			$xmlUrl_parser_exec_suffix.=" unset index;";
		}
		if( $xmlUrl_parser=~/.*\$feed_index.*/ || $xmlUrl_parser=~/.*\$\{feed_index\}.*/ ){
			$xmlUrl_parser_exec_prefix.="@ feed_index=$i; ";
			$xmlUrl_parser_exec_suffix.=" unset feed_index;";
		}
		if( $xmlUrl_parser=~/.*\$i.*/ || $xmlUrl_parser=~/.*\$\{i\}.*/ ){
			$xmlUrl_parser_exec_prefix.="@ i=$i; ";
			$xmlUrl_parser_exec_suffix.=" unset i;";
		}
		$xmlUrl_parser_exec_suffix.="';";
		printf("Running:\n\t%s%s%s%s\n", $xmlUrl_parser_exec_prefix, $xmlUrl_parser, $xmlUrl_parser_exec_suffix); 
		system($xmlUrl_parser_exec_prefix.$xmlUrl_parser.$xmlUrl_parser_exec_suffix); 
	}
	@xmlUrls_to_parse=();
}#process_xmlUrls();

sub edit_opml_files{
	if( @opml_files_to_edit <= 0 ){ return; }
	my @opml_files_editing=();
	for(my $x=0; $x<@opml_files_to_edit; ){
		for(my $i=0; $i<10 && $x < @opml_files_to_edit; $i++, $x++){
			$opml_files_editing[$i]=$opml_files_to_edit[$x];
		}
		if(@opml_files_editing > 0){
			my $editor_exec="tcsh -f -c 'vim-enhanced -p @opml_files_editing'";
			printf("Running:\n\t%s\n", $editor_exec); 
			system($editor_exec);
		}
		@opml_files_editing=();
	}
	@opml_files_to_edit=();
}#edit_opml_files();

sub parse_option{
	my $argv=shift;
	my $dashes=$argv;
	my $option=$argv;
	my $equals=$argv;
	my $value=$argv;
	$dashes=~s/^([\-]{1,2})([^=]+)([\=]?)(.*)$/$1/g;
	$option=~s/^([\-]{1,2})([^=]+)([\=]?)(.*)$/$2/g;
	$equals=~s/^([\-]{1,2})([^=]+)([\=]?)(.*)$/$3/g;
	$value=~s/^([\-]{1,2})([^=]+)([\=]?)(.*)$/$4/g;
	
	my $args_parsed=1;
	if("$equals"eq"" && "$value"eq""){
		$args_parsed++;
		$value=shift;
	}
	
	if($option=~/^(xml|html)?Url$/i||"$option"eq"title"||"$option"eq"text"||"$option"eq"description"||"$option"eq"type"|| -f "$option"){
		return $FALSE;
	}
	
	if($debug_mode){printf("Parsing option: [%s]%s\n", "$option", ("$value"eq"" ?"" :"=<$value>")); }
	if("$option"eq"output" && "$value"ne""){
		if($debug_mode){ printf( "\tHandling output argument: [%s].\n", $value ); }
		if( parse_output($option, $value) ){ return $args_parsed; }
	}
	
	if($option=~/^(download\-limit|start\-with)$/ && $value=~/^[0-9]+$/){
		if($debug_mode){ printf( "\tHandling download setting: [%s].\n", $value ); }
		if( "$option"eq"download-limit") {
			$download_limit=$value;
		}elsif( "$option"eq"start-with" ){
			$start_with=$value;
		}
		return $args_parsed;
	}
	
	if($option=~/^(en|dis)able.*$/){
		if($debug_mode){ printf( "\t%sabling %s switch: [%s].\n", $option, $value ); }
		if( parse_setting($option, $value) ){ return $args_parsed; }
	}
	
	if($debug_mode){ printf( "\tHandling other argument: [%s%s%s].\n", $option, ("$value"eq"" ?"" :"="), $value ); }
	if( parse_options_action($option, $value) ){
		if( ( "$option"eq"xmlUrl-parser" && "$value"ne"" ) || $option=~/^browser=.+/ ){
			return $args_parsed;
		}else{
			return 1;
		}
	}
	
	return $FALSE;
}#parse_option

sub parse_options_action{
	my $option=shift;
	my $value=shift;
	
	if("$option"eq"xmlUrl-parser" && "$value"ne"" ){
		return xmlUrl_parser_set("enable", $value);
	}
	
	if($option=~/^browse(r=)?.*/){
		return www_browser_set("enable", $value);
	}
	
	if("$option"eq"edit-opml"){
		if($global_edit_opml!=1){ $global_edit_opml=1; }
		return $TRUE;
	}
	
	if("$option"eq"debug"){
		if($debug_mode!=1){ $debug_mode=1; }
		return $TRUE;
	}
	
	if("$option"eq"verbose"){
		if($be_verbose!=1){ $be_verbose=1; }
		return $TRUE;
	}
	
	#if("$option"eq""){
	#	if($_!=1){ $_=1; }
	#}
	
	return $FALSE;
}#parse_options_action



sub parse_setting{
	my $action=shift;
	my $value=shift;
	my $parameter="";
	
	if($value=~/^.*=.*$/){
		$parameter=$value;
		$value=~s/^([^=]+)=(.*)$/$1/;
		$parameter=~s/^([^=]+)=(.*)$/$2/;
	}
	
	if($debug_mode){printf("Attempting to %sable: %s=[%s]\n", ("$action"eq"disable" ?"dis" :"en"), $parameter, $value);}

	
	if("$value"eq"editing"||"$value"eq"edit-opml"){
		printf("VI editing\t\t\t\t\t\t[%sd]:\n", $action);
		if("$action"eq"enable"){ $global_edit_opml=1; }
		if("$action"eq"disable"){ $global_edit_opml=0; }
		return $TRUE;
	}
	
	if("$value"eq"debug"){
		printf("Debug mode\t\t\t\t\t\t[%sd]:\n", $action);
		if("$action"eq"enable" && !$debug_mode){ $debug_mode=1; }
		if("$action"eq"disable" && $debug_mode){ $debug_mode=0; }
		return $TRUE;
	}
	
	if("$value"eq"verbose"){
		printf("Verbose search output\t\t\t\t\t\t[%sd]:\n", $action);
		if("$action"eq"enable" && !$be_verbose){ $be_verbose=1; }
		if("$action"eq"disable" && $be_verbose){ $be_verbose=0; }
		return $TRUE;
	}
	
	if("$value"eq"www-browser"){
		return www_browser_set($action, $parameter);
	}
	
	if("$value"eq"xmlUrl-parser" && "$parameter"ne"" ){
		return xmlUrl_parser_set($action, $parameter);
	}
	
	return $FALSE;
}#parse_setting();


sub www_browser_set{
	my $action=shift;
	my $browser=shift;
	
	if(!("$action"eq"enable"||"$action"eq"disable")){ return $FALSE; }
	
	if("$action"eq"disable"){
		if("$www_browser"ne""){
			$previous_www_browser="$www_browser";
			$www_browser="";
		}
		printf("Further websites will not be passed to any web browser.\n");
		return $TRUE;
	}
	
	my @browsers=("browser", "links", "firefox", "lynx");
	my $www_browser_found=$FALSE;
	for(my $i=0; $i<@browsers && !$www_browser_found; $i++){
		if("$browsers[$i]"eq"$browser"){
			$www_browser_found=$TRUE;
		}
	}
	if(!$www_browser_found){
		$browsers[@browsers]="$browser";
	}else{
		$www_browser_found=$FALSE;
	}
	my $browser_list=`mktemp --tmpdir -u alacast.browsers.XXXXXX`;
	chomp($browser_list);
	if($debug_mode){ printf("Searching for a valid browser among:: [%s]\n", "@browsers"); }
	for(my $i=0; $i<@browsers && !$www_browser_found; $i++){
		my $command="tcsh -f -c '(where \"$browsers[$i]\" >! $browser_list) >& /dev/null';";
		if($debug_mode){ printf("Searching for [%s] using:\n\t%s", $browsers[$i], $command); }
		system($command);
		my @browsers_found=`cat \"$browser_list\";`;
		for(my $x=0; $x<@browsers_found && !$www_browser_found; $x++){
			$browser=$browsers_found[$x];
			chomp($browser);
			if( -x "$browser" ){
				$www_browser="$browser";
				$www_browser_found=$TRUE;
			}
		}
	}
	system("rm \"$browser_list\";");
	if(!$www_browser_found){ return $TRUE; }
	
	if("$previous_www_browser"ne"" && "$previous_www_browser"ne"$www_browser"){
		@websites_to_visit=();
	}
	
	printf("Further websites will be passed to\t\t[%s]\n", $www_browser);
	return $TRUE;
}#www_browser_set();


sub xmlUrl_parser_set{
	my $action=shift;
	my $parser=shift;
	
	if(!(("$action"eq"enable"||"$action"eq"disable") && "$parser"ne"")){ return $FALSE; }
	
	if("$action"eq"disable"){
		if("$xmlUrl_parser"ne""){
			$previous_xmlUrl_parser="$xmlUrl_parser";
			$xmlUrl_parser="";
	}
		printf("Further xmlUrls will not be passed to any parser/handler.\n");
		return $TRUE;
	}
	
	$xmlUrl_parser=$parser;
	if("$previous_xmlUrl_parser"eq"" || "$previous_xmlUrl_parser"ne"$xmlUrl_parser"){
		@xmlUrls_to_parse=();
	}
	
	printf("Further xmlUrls will be passed to\t\t[%s]\n", $xmlUrl_parser);
	
	return $TRUE;
}#xmlUrl_parser_set("(enable|disable)", "$parameter");


sub parse_attribute{
	my $argv=shift;
	my $dashes=$argv;
	my $option=$argv;
	my $equals=$argv;
	my $value=$argv;
	$dashes=~s/^([\-]{1,2})([^=]+)([\=]?)(.*)$/$1/g;
	$option=~s/^([\-]{1,2})([^=]+)([\=]?)(.*)$/$2/g;
	$equals=~s/^([\-]{1,2})([^=]+)([\=]?)(.*)$/$3/g;
	$value=~s/^([\-]{1,2})([^=]+)([\=]?)(.*)$/$4/g;
	
	my $args_parsed=1;
	if("$equals"eq"" && "$value"eq""){
		$args_parsed++;
		$value=shift;
	}
	
	$global_search_attribute=$option;
	$global_search_attributes_value=$value;
	$global_search_attributes_value=~s/(['"])/$1\\$1$1/g;
	$global_search_attributes_value=~s/([\?\[\)\(\)\-])/\\$1/g;
	
	$searching_list="";
	
	if($debug_mode){ printf( "\tHandling OPML search attribute: [%s].\n", $value ); }
	
	if(!($global_search_attribute=~/(xml|html)?Url/i||"$global_search_attribute"eq"title"||"$global_search_attribute"eq"text"||"$global_search_attribute"eq"description"||"$global_search_attribute"eq"type")) {
		if ( -f $global_search_attributes_value ){
			$searching_list=$global_search_attributes_value;
			return $args_parsed;
		}
		$global_search_attribute="\(title\|text\)";
		return $FALSE;
	}
	if($global_search_attribute=~/(xml|html)?Url/i){
		$global_search_attribute=~s/(xml|html)?(Url)/\(xml\|html\)\?$2/i;
	}elsif("$global_search_attribute"eq"title"){
		$global_search_attribute="\(title\|text\)";
	}
	return $args_parsed;
}#parse_attribute

sub parse_output{
	my $outputs=shift;
	$outputs.=",";
	chomp($outputs);
	my @outputs=split(",", $outputs);
	chomp(@outputs);
	my $x=@alacast_catalog_search_outputs;
	for(my $i=0; $i<@outputs; $i++){
		if( $debug_mode ){ printf("Validating Output Attribute: [%s]\n", $outputs[$i]); }
		if("$outputs[$i]"eq""){
			next;
		}
		if(!($outputs[$i]=~/(xml|html)?Url/i||"$outputs[$i]"eq"title"||"$outputs[$i]"eq"text"||"$outputs[$i]"eq"description"||"$outputs[$i]"eq"type"||"$outputs[$i]"eq"outline"||"$outputs[$i]"eq"verbose")) {
			next;
		}
		if("$outputs[$i]"eq"outline"||"$outputs[$i]"eq"verbose"){
			@alacast_catalog_search_outputs=("outline");
		}elsif("$outputs[$i]"ne"title"||"$outputs[$i]"ne"htmlUrl"||"$outputs[$i]"ne"xmlUrl"){
			$alacast_catalog_search_outputs[++$x]="$outputs[$i]";
		}
		#$alacast_catalog_search_outputs[++$x]="($outputs[$i])";
	}
	chomp(@alacast_catalog_search_outputs);
	if( $debug_mode ){ printf("Output details for this loop:\n\tOutput Attributes:"); }
	
	if(@alacast_catalog_search_outputs == 0){ return $FALSE; }
	if( $debug_mode ){ printf("[@alacast_catalog_search_outputs]\n"); }
	return $TRUE;
}#parse_output

sub main{
	my $i=0;
	while( $i<@ARGV ){
		while(my $x=parse_option($ARGV[$i], ($i<@ARGV ?$ARGV[$i+1] :""))){
			if($debug_mode){
				printf("Parsed %d option%s: %s%s\n", $x, ($x>1 ?"s" :""), $ARGV[$i], ($x>1 ?$ARGV[$i+1] :"") );
			}
			$i+=$x;
		}
		
		while( my $x=parse_attribute($ARGV[$i], ($i<@ARGV ?$ARGV[$i+1] :"")) ) {
			if($debug_mode){
				printf("Parsed %d OPML attribute%s: %s%s\n", $x, ($x>1 ?"s" :""), $ARGV[$i], ($x>1 ?$ARGV[$i+1] :"") );
			}
			if("$global_search_attributes_value"eq""){
				printf("\n\t**error:** at least one valid search attribute must be specified.\n\n");
				#usage();
				next;
			}
			
			search_catalogs();
			$global_search_attribute="";
			$global_search_attributes_value="";
			$i+=$x;
		}
		
	}
	
	if( @websites_to_visit > 0 ){ visit_websites(); }
	if( @xmlUrls_to_parse > 0 ){ parse_xmlUrls(); }
	if( @opml_files_to_edit > 0 ){ edit_opml_files(); }
}#main

main();
