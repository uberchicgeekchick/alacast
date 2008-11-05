#!/usr/bin/php
<?php
	/*
	 * (c) 2007-Present Kathryn G. Bohmont <uberChicGeekChick.Com -at- uberChicGeekChick.Com>
	 * 	http://uberChicGeekChick.Com/
	 * Writen by an uberChick, other uberChicks please meet me & others @:
	 * 	http://uberChicks.Net/
	 *I'm also disabled; living with Generalized Dystonia.
	 * Specifically: DYT1+/Early-Onset Generalized Dystonia.
	 * 	http://Dystonia-DREAMS.Org/
	 */

	/*
	 * Unless explicitly acquired and licensed from Licensor under another
	 * license, the contents of this file are subject to the Reciprocal Public
	 * License ("RPL") Version 1.5, or subsequent versions as allowed by the RPL,
	 * and You may not copy or use this file in either source code or executable
	 * form, except in compliance with the terms and conditions of the RPL.
	 *
	 * All software distributed under the RPL is provided strictly on an "AS
	 * IS" basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND
	 * LICENSOR HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT
	 * LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
	 * PURPOSE, QUIET ENJOYMENT, OR NON-INFRINGEMENT. See the RPL for specific
	 * language governing rights and limitations under the RPL.
	 *
	 * ---------------------------------------------------------------------------------
	 * |	A copy of the RPL 1.5 may be found with this project or online at	|
	 * |		http://opensource.org/licenses/rpl1.5.txt					|
	 * ---------------------------------------------------------------------------------
	 */
	
	/*
	 * ALWAYS PROGRAM FOR ENJOYMENT &PLEASURE!!!
	 * Feel comfortable takeing baby steps.  Every moment is another step; step by step; there are only baby steps.
	 * Being verbose in comments, variables, functions, methods, &anything else IS GOOD!
	 * If I forget ANY OF THIS than READ:
	 * 	"Paul Graham's: Hackers &Painters"
	 * 	&& ||
	 * 	"The Mentor's Last Words: The Hackers Manifesto"
	 */
	ini_set( "display_errors", true );
	ini_set( "error_reporting", E_ALL | E_STRICT );
	ini_set( "default_charset", "utf-8" );
	ini_set( "date.timezone", "America/Denver" );


	chdir( (dirname( $_SERVER['argv'][0] )) );
	
	require_once( "../classes/uberChicGeekChicks::logger.class.php" );
	require_once( "../classes/uberChicGeekChicks::helper.class.php" );
	
	require_once( "../classes/playlist.class.php" );
	require_once( "../classes/playlists/m3u.class.php" );
	
	require_once( "../classes/podcatcher/program.class.php" );

	//here's where my progie uberChicGeekChick's Podcast Syncronizer actually starts.
	if( (in_array("--help", $_SERVER['argv']) ))
		help();//this exits uberChicGeekChick's Podcast Syncronizer
	
	function help() {
		print( "Usage: uberChicGeekChicks-Podcast-Syncronizer.php [options]..."
			."\n\tOptions:"
			."\n"
			."\n"
			."\nUpdate options (i.e., gpodder --run):"
			."\n----------------------------------------------"
			."\n\t--use-gpodder=gpodder_exec"
			."\n\t						Runs gpodder_exec instead of using /usr/bin/gpodder or gpodder"
			."\n\t						that's found in your path."
			."\n"
			."\n\t--update				runs `gpodder --run` automatically before moving podcasts."
			."\n"
			."\n\t--nice[=priority]			Runs gPodder with the specified priority (default: +19)."
			."\n"
			."\n\t--update=detailed			Displays the output from: `gpodder --run`."
			."\n\t						This is usually the URIs of your subscribed podcasts"
			."\n\t						and any new epidodes."
			."\n"
			."\n\t--interactive			Prompts before quiting/continuing."
			."\n"
			."\n"
			."\nOutput options:"
			."\n--------------------"
			."\n\t--quiet"
			."\n\t				This keeps any output from being output to the terminal."
			."\n\t				This is useful when ran as a cron job."
			."\n\t--verbose"
			."\n\t				These effect how much information is displayed about what"
			."\n\t				I'm doing.  These are mostly messages useful for debugging."
			."\n"
			."\n\t--logging"
			."\n\t				This writes all regular, &`--update output to this script's log file."
			."\n"
			."\n"
			."\nSymlink options:"
			."\n-------------------------"
			."\n\t--leave-trails		Leave [GUID].trail symlinks to gPodder's GUID folder."
			."\n"
			."\n\t--clean-trails		This just removes any symlinks that may have been created by"
			."\n\t				previously using the`--leave-trails` option."
			."\n"
			."\n"
			."\nSyncing options:"
			."\n-------------------"
			."\n\t--keep-original		keeps gPodders GUID based named files while making copies of all"
			."\n\t					podcasts with easier to understand directories &filenames."
			."\n"
			."\n\t--player[ = vlc|xine]		different players have issues with different charaters"
			."\n\t				in the path's of podcast's files.  known issues are:"
			."\n\t				- vlc won't play files with colons(:) in their path."
			."\n\t				- xine won't play files with octothorps(#) in their path."
			."\n\t				so adding this option strips these characters from podcasts'"
			."\n\t				sub-directory and file names."
			."\n\t				if --player is alone all characters that might cause problems"
			."\n\t				are removed.  if a value for player is set than just the"
			."\n\t				character(s) known to cause issues with that player will be"
			."\n\t				removed."
			."\n"
			."\n"
			."\n\t--help			displays this screen."
			."\n"
			."\n"
			."\n\t		*wink* &remember uberChicGeekChicks-Podcast-Suncronizer.php is written in PHP;"
			."\n\t		so its super easy to customize.  just remember to share ^_~"
			."\n"
			."\n"
		);
		
		exit( 0 );
		
	}//end:function help();



	function load_settings() {
		/*	here's where i setup and check all the directories i need
			to use, find, &rename/move all of my podcasts and their
			names and etc.
		*/
		static $i;
		if(!( (isset( $i )) ))
			$i = 0;
		else if( ($i++) > 10 )
			exit( "-10: I got stuck in my setup loop." );
			/* load_settings calls setup which might call
			   load_settings so just in case something weird goes on.
			*/
		
		if(!( $gPodder_config_fp = fopen( (sprintf("%s/.config/gpodder/gpodder.conf", (getenv( "HOME" )) )), "r" ) ))
			return gPodder_Config_Error( "gpodder.conf is not readable" );//exit(-1);
		
		$gPodder_config = preg_replace( "/[\r\n]+/m", "\t", fread( $gPodder_config_fp, (filesize( (sprintf("%s/.config/gpodder/gpodder.conf", (getenv( "HOME" )) )) )) ) );
		fclose( $gPodder_config_fp );
		
		if(!(
			(define( "GPODDER_SYNC_DIR", (preg_replace( "/.*mp3_player_folder = ([^\t]*).*/", "$1", $gPodder_config )) ))
			&&
			(define( "GPODDER_DL_DIR", (preg_replace( "/.*download_dir = ([^\t]*).*/", "$1", $gPodder_config )) ))
			&&
			(is_dir( GPODDER_DL_DIR ))
			&&
			( is_dir( GPODDER_SYNC_DIR ) )
		))
			return gPodder_Config_Error( "I couldn't load either gPodder's:\n\t\t'download_dir'(".GPODDER_DL_DIR.") or it's 'mp3_player_folder'(".GPODDER_SYNC_DIR.".\n\tPlease check gPodder's settings." );
		
		chdir( dirname( GPODDER_DL_DIR ) );
		
		return true;
	}//end:function load_settings();
	
	
	
	function gPodder_Config_Error( $details = "" ) {
		$GLOBALS['uberChicGeekChicks_logger']->output(
			"I couldn't load gPodder's settings from: '"
			.(getenv( "HOME" ))
			."/.config/gpodder/gpodder.conf''"
			.( $details
				? "\n\tDetails: {$details}"
				: ""
			)
			."\n\tWhich basically means I'm done; please fix this by: `Starting gPodder`->`Selecting Podcasts file menu`->`Preferences` and setting it's `Download Directory` & `MP3 Player`.\n",
			true
		);
		exit( -1 );
	}//end:function gPodder_Config_Error();



	Function log_gPodders_downloads( &$gPodders_Output ) {
		//Logs' the URLs that where downloaded by the recently ran `gpodder --run`
		//TODO
	}//end function: log_gPodders_downloads();



	function run_gpodder_and_download_podcasts() {
		if(!(
			(
				(is_executable( ($gPoddersProgie = uberChicGeekChicks::helper::preg_match_array( "/^\-\-use\-gpodder=(.*)$/", $_SERVER['argv'], "$1" )) ))
				&&
				(chdir( (dirname( $gPoddersProgie )) ))
				&&
				($gPoddersProgie="./".(basename( $gPoddersProgie ))." --local")
			)
			||
			(is_executable( ($gPoddersProgie = "/usr/bin/gpodder") ))
			||
			(is_executable( ($gPoddersProgie = exec( "which gpodder" )) ))
		))
			return $GLOBALS['uberChicGeekChicks_logger']->output( "I can't try to download any new podcasts because I can't find gPodder.", true );
		
		if( (in_array("--nice", $_SERVER['argv'])) )
			$gPoddersProgie = "/usr/bin/nice --adjustment = 19 {$gPoddersProgie}";
		
		$GLOBALS['uberChicGeekChicks_logger']->output( ($GLOBALS['podcatcher']->set_status( "downloading new podcasts" )) );
		if( ($gPoddersExec = uberChicGeekChicks::helper::preg_match_array( "/\-\-use\-gpodder=(.*)$/", $_SERVER['argv'], "$1" )) )
			$GLOBALS['uberChicGeekChicks_logger']->output( "~*~*~* Using {$gPoddersExec} *~*~*~\n" );
		
		$lastLine = "";
		switch( TRUE ) {
			/*case in_array("--logging", $_SERVER['argv']) :
				$gPodders_Output = array();
				$lastLine = exec("{$gPoddersProgie} --run", $gPodders_Output);
				
				if( (in_array("--update = detailed", $_SERVER['argv'])) )
					$GLOBALS['uberChicGeekChicks_logger']->output( (uberChicGeekChicks::helper::array_to_string( $gPodders_Output, "\n" )), "", true );
				
				if( (preg_match("/^D/", (ltrim($lastLine)) )) )
					log_gPodders_downloadss( $gPodders_Output );
			break;
			*/
			case in_array("--update=detailed", $_SERVER['argv']) :
				$lastLine = system("{$gPoddersProgie} --run");
			break;
			
			default:
				$lastLine = exec("{$gPoddersProgie} --run");
			break;
		}
		
		$GLOBALS['uberChicGeekChicks_logger']->output( ($GLOBALS['podcatcher']->set_status( "downloading new podcasts", false )) );
		
		if(!( (preg_match("/^D/", (ltrim($lastLine)) )) ))
			return false;
		
		/*
		   gPodder 0.10.0 need a lot longer than 5 seconds.
		   So I've moved it to 31 seconds just to be okay.
		*/
		print( "\nPlease wait while gPodder finishes downloading your podcasts new episodes" );
		for($i = 0; $i<33; $i++) {
			if(!($i%3))
				print( "." );
			
			usleep(500000); // waits for one half second.
		}
		print( "\n" );
		
		return true;
		
	}//end:function run_gpodder_and_download_podcasts();



	function check_player() {
		switch( TRUE ) {
			case (in_array("--player", $_SERVER['argv'])) :
				return "#:";
			break;
			
			case (in_array("--player=vlc", $_SERVER['argv'])) :
				return ":";
			break;
			
			case (in_array("--player=xine", $_SERVER['argv'])) :
				return "#";
			break;
			
			default:
				return NULL;
			break;
		}
	}//end:function check_player();
	
	
	function leave_symlink_trail( &$podcastsGUID, &$podcastsName ) {
		$podcastsTrailSymlink = (sprintf( "%s/%s/%s.trail", GPODDER_DL_DIR, $podcastsName, $podcastsGUID ));
		if( 
			(in_array( "--leave-trails", $_SERVER['argv'] ))
			&&
			(!( (file_exists( $podcastsTrailSymlink )) ))
		)
			return symlink(
				(sprintf( "%s/%s", GPODDER_DL_DIR, $podcastsGUID )),
				$podcastsTrailSymlink
			);
		
		if( 
			(in_array( "--clean-trails", $_SERVER['argv'] ))
			&&
			(file_exists( $podcastsTrailSymlink ))
		)
			return unlink( $podcastsTrailSymlink );
	}//end funtion: leave_symlink_trail();.
	
	
	
	function generate_podcasts_info( &$podcastsInfo, $totalPodcasts, $start = 1 ) {
		static $untitled_podcasts;
		if(!( (isset( $untitled_podcasts )) ))
			$untitled_podcasts = 1;
		
		if(!(
			(isset( $podcastsInfo[0] ))
			&&
			$podcastsInfo[0]
		)) {
			$podcastsInfo[0] = "Untitled podcast(s)";
			$untitled_podcasts +=  $start;
		}
		
		for($i = $start; $i<$totalPodcasts; $i++ )
			if(!(
				(isset( $podcastsInfo[$i] ))
				&&
				$podcastsInfo[$i]
			))
				$podcastsInfo[$i]=sprintf(
					"%s'%s episode %d from %s",
					$podcastsInfo[0],
					(
						(preg_match( "/s$/", $podcastsInfo[0] ))
						? ""
						: "s"
					),
					$untitled_podcasts++,
					(date( "c" ))
				);
	}//end:function generate_podcasts_info()



	function get_episode_titles( &$podcastsInfo, $podcastsXML_filename ) {
		
		if(!( (filesize($podcastsXML_filename)) ))
			return false;
			
		$podcastsTempInfo = array();
		$podcastsXML_fp = fopen( $podcastsXML_filename, 'r' );
		$podcastsTempInfo = fread( $podcastsXML_fp, (filesize($podcastsXML_filename)) );
		fclose($podcastsXML_fp);
		
		$podcastsTempInfo = preg_split(
					"/(<title>[^<]*<\/title>)/m", $podcastsTempInfo, -1,
					PREG_SPLIT_NO_EMPTY | PREG_SPLIT_DELIM_CAPTURE
		);
		
		if(!( (isset( $podcastsTempInfo[0] )) ))
			return false;
		
		if($podcastsTempInfo[0] == $podcastsTempInfo[1])
			array_shift($podcastsTempInfo);
		
		$podcastsTempInfo['total'] = count($podcastsTempInfo);
		
		for( $i = 0; $i<$podcastsTempInfo['total']; $i++ )
			if( (preg_match("/^<title>([^<]*)<\/title>$/", $podcastsTempInfo[$i])) )
				$podcastsInfo[ $podcastsInfo['total']++ ] = html_entity_decode(preg_replace("/<title>([^<]*)<\/title>/", "$1", $podcastsTempInfo[$i]));
		
		if( (in_array( "--verbose", $_SERVER['argv'] )) )
			$GLOBALS['uberChicGeekChicks_logger']->output(
				(sprintf(
					"\n*DEBUG*: I searched for %s'%s titles in %s.\nI've found titles for %d new episodes.",
					$podcastsInfo[0],
					(
						(preg_match( "/s$/", $podcastsInfo[0] ))
							?"s"
							:""
					),
					$podcastsXML_filename,
					( $podcastsInfo['total']-1 )
				))
			);
		
		return true;
	}//end:function get_episode_titles()


	function clean_podcasts_info( &$podcastsInfo ) {
		static $bad_characters;
		if(!( (isset( $bad_characters )) ))
			$bad_characters = check_player();
		
		/*
		   replaces forward slashes with hyphens &removes leading dots('.').
		   both for obvious(linux) reasons.
		   $badCharacters than replaces any charaters that some media players don't like.
		   e.g., like xine &vlc.
		*/
		for($i = 0; $i<$podcastsInfo['total']; $i++)
			$podcastsInfo[$i] = preg_replace("/^\.+(.*)\.+$/", "$1",
						(preg_replace(
							(sprintf(
								"/[\/%s]+/",
								($bad_characters
									?$bad_characters
									:""
								)
							)),
							"",
							(trim($podcastsInfo[$i]))
						))
					);
		
		$podcastsInfo[0] = preg_replace( "/^(the)\s+(.*)$/i", "$2, $1", $podcastsInfo[0] );
	}//end:function clean_podcasts_info()



	function get_podcasts_info( &$podcastsXML_filename, &$podcastsInfo, &$podcastsGUID, &$totalPodcasts ) {
		//Tries to get episode titles for podcast's episode.
		get_episode_titles( $podcastsInfo, $podcastsXML_filename );
		
		clean_podcasts_info( $podcastsInfo );
		
		generate_podcasts_info( $podcastsInfo, $totalPodcasts, $podcastsInfo['total'] );
	}//end:function get_podcasts_info();



	function set_podcasts_new_episodes_filename( $podcastsName, $podcastsEpisode, $podcastsExtension ) {
		$podcastsExtra = "";
		do {
			$Podcasts_New_Filename = sprintf(
				"%s/%s/%s%s.%s",
				GPODDER_SYNC_DIR,
				$podcastsName,
				$podcastsEpisode,
				$podcastsExtra,
				$podcastsExtension
			);
			
			$podcastsExtra = sprintf(
				"(copy from %s)",
				(date( "c" ))
			);
			
			sleep( 1 );
		} while( (file_exists( $Podcasts_New_Filename )) );

		return $Podcasts_New_Filename;
	}//end:function set_podcasts_new_episodes_filename()



	function do_I_need_to_run_gPodder() {
		static $do_I_update;
		if(!( (isset($do_I_update)) ))
			$do_I_update = uberChicGeekChicks::helper::preg_match_array( "/^\-\-update/", $_SERVER['argv'] );
		
		
		if( $do_I_update )
			run_gpodder_and_download_podcasts();
	}//end:function do_I_need_to_run_gPodder();



	function move_gPodders_Podcasts() {
		
		do_I_need_to_run_gPodder();
		
		$GLOBALS['uberChicGeekChicks_logger']->output( ($GLOBALS['podcatcher']->set_status( "syncronizing podcasts" )) );
		
		$totalMovedPodcasts=0;
		$gPoddersPodcastDir = opendir(GPODDER_DL_DIR);
		while($podcastsGUID = readdir($gPoddersPodcastDir)) {
			if(!(
				(is_dir( (sprintf( "%s/%s", GPODDER_DL_DIR, $podcastsGUID )) ))
				&&
				(preg_match("/^[^.]+/", $podcastsGUID))
				&&
				(file_exists( ($podcastsXML_filename=(sprintf( "%s/%s/index.xml", GPODDER_DL_DIR, $podcastsGUID )) ) ))
			))
				continue;
			
			exec("touch {$podcastsXML_filename}");
			
			if( (isset( $podcastsFiles )) )
				unset( $podcastsFiles );
			$podcastsFiles=array();
			exec( (sprintf( "/bin/ls -t --width=1 %s/%s/*.*", GPODDER_DL_DIR, $podcastsGUID )), $podcastsFiles );
			if( ( ($podcastsFiles['total'] = (count($podcastsFiles)) ) <= 1 ) )
				continue;
			
			if( (isset( $podcastsInfo )) )
				unset( $podcastsInfo );
			$podcastsInfo = array( 'total'  => 0 );
			get_podcasts_info( $podcastsXML_filename, $podcastsInfo, $podcastsGUID, $podcastsFiles['total'] );
			
			if(!(
				(is_dir(GPODDER_SYNC_DIR."/".$podcastsInfo[0]))
				||
				(mkdir(GPODDER_SYNC_DIR."/".$podcastsInfo[0], 0774, TRUE))
			)) {
				$GLOBALS['uberChicGeekChicks_logger']->output( "\n\tI've had to skip {$podcastsInfo[0]} because I couldn't create it's directory.\n\t\tPlease edit '{$podcastsXML_filename}' to fix this issue.", true );//*wink*, it just kinda felt like a printf moment :P
				continue;
			}
			
			$GLOBALS['uberChicGeekChicks_logger']->output(
				(wordwrap(
					(
						"\n\n\t*w00t*! {$podcastsInfo[0]} has "
						.( $podcastsFiles['total']-1 )
						." new episode"
						.( ($podcastsFiles['total']>2)
							? "s!  They're"
							: "!  Its"
						)
						.":"
					),
					72,
					"\n\t\t"
				))
			);
			
			leave_symlink_trail( $podcastsGUID, $podcastsInfo[0] );
			
			$totalMovedPodcasts += move_podcasts_episodes( $podcastsGUID, $podcastsFiles, $podcastsInfo );
			
		}
		closedir($gPoddersPodcastDir);
		
		$GLOBALS['uberChicGeekChicks_logger']->output(  "\n\n\t"  );
		
		if( $totalMovedPodcasts )
			$GLOBALS['uberChicGeekChicks_logger']->output(  "^_^ *w00t*, you have {$totalMovedPodcasts} new podcasts!"  );
		else
			$GLOBALS['uberChicGeekChicks_logger']->output(  "^_^ There are no new podcasts."  );
		
		$GLOBALS['uberChicGeekChicks_logger']->output(
			"  Have fun! ^_^\n\n"
			. ($GLOBALS['podcatcher']->set_status( "syncronizing podcasts", false ))
		);
		
		return true;
	}// end 'move_gPodders_Podcasts' function.



	function get_filenames_extension( &$podcastsFilename ) {
		switch( ($ext = preg_replace(
			"/^.*\.([a-zA-Z0-9]{2,7})$/",
			"$1",
			(rtrim( $podcastsFilename ))
		)) ) {
			case "xml": case "html":
				return null;
			
			/*case "pdf":
				return null;*/
			
			case "m4v": case "mov":
				return "mp4";
			
			case "divx": case "xvid":
				return "avi";
			
			case "torrent":
				/*TODO: implement torent download.
				 * 1st - vby forking a program.
				 *soon I'd like to write a PECL torrent extension.
				*/
				return "torrent";
			
			default:
				return $ext;
		}//switch( $ext );
	}//function: function get_filenames_extension( &$podcastsFilename );



	function move_podcasts_episodes( &$podcastsGUID, &$podcastsFiles, &$podcastsInfo ) {
		$movedPodcasts=0;
		
		for($i = 1, $z = ($podcastsInfo['total']-1); $i<$podcastsFiles['total']; $i++, $z--) {
			if(!( ($ext = get_filenames_extension( $podcastsFiles[$i] )) ))
				continue;
			
			$Podcasts_New_Filename
			=
			set_podcasts_new_episodes_filename( $podcastsInfo[0], $podcastsInfo[$z], $ext );
			
			if( (in_array("--verbose", $_SERVER['argv'])) )
				$GLOBALS['uberChicGeekChicks_logger']->output(
					(sprintf(
						"\n\t*DEBUG*: I'm moving:\n\t%s\n\t\t-to\n\t%s",
						$podcastsFiles[$i],
						$Podcasts_New_Filename
					))
				);
			
			if(
				(in_array( "--keep-original", $_SERVER['argv'] ))
				&&
				( (file_exists( $Podcasts_New_Filename )) )
			)
				continue;
			
			if(
				(file_exists( $podcastsFiles[$i] ))
				&&
				( (link(
					$podcastsFiles[$i],
					$Podcasts_New_Filename
				)) )
			) {
				$movedPodcasts++;
				
				//Prints the new episodes name:
				$GLOBALS['uberChicGeekChicks_logger']->output( "\n\t\t" . (wordwrap( $podcastsInfo[$i], 72, "\n\t\t\t" )) );
				
				if(!( (in_array( "--keep-original", $_SERVER['argv'] )) ))
					unlink($podcastsFiles[$i]);
			}
		}
		return $movedPodcasts;
	}//end:function move_podcasts_episodes();
	
	// Program == `uberChicGeekChicks-Podcast-Syncronizer.php` starts here.
	
	if(!( (load_settings()) ))
		exit( -1 );

	$uberChicGeekChicks_logger = new uberChicGeekChicks::logger(
		GPODDER_SYNC_DIR,
		"uberChicGeekChick's Syncronizer",
		(in_array( "--logging", $_SERVER['argv'] )),
		(in_array( "--quiet", $_SERVER['argv'] ))
	);
	
	$podcatcher = new uberChicGeekChicks::podcatcher::program();

	while( (move_gPodders_Podcasts()) ) {
		if(!( (in_array("--interactive", $_SERVER['argv'])) ))
			break;
		
		print( "\nPlease press [enter] to continue; [enter] 'q' to quit: " );
		if( (trim( (fgetc( STDIN )) ))  ==  'q' )
			break;
	}//while( (move_gPodders_Podcasts( )) );

?>
