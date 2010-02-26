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
	 * ------------------------------------------------------------------
	 * |	The RPL 1.5 may be found with this project or online at:    |
	 * |		http://opensource.org/licenses/rpl1.5.txt	    |
	 * ------------------------------------------------------------------
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
	ini_set("display_errors", TRUE);
	ini_set("error_reporting", E_ALL | E_STRICT);
	ini_set("default_charset", "utf-8");
	ini_set("date.timezone", "America/Denver");
	
	define("ALACASTS_PATH", (preg_replace("/(.*)\/[^\/]+/", "$1", ( (dirname($_SERVER['argv'][0])!=".") ? (dirname( $_SERVER['argv'][0])) : $_SERVER['PWD']))));
	
	require_once(ALACASTS_PATH."/php/classes/alacast.class.php");
	require_once(ALACASTS_PATH."/php/classes/titles.class.php");
	require_once(ALACASTS_PATH."/php/classes/logger.class.php");
	require_once(ALACASTS_PATH."/php/classes/helper.class.php");
	require_once(ALACASTS_PATH."/php/classes/playlist.class.php");
	require_once(ALACASTS_PATH."/php/classes/playlists/m3u.class.php");
	require_once(ALACASTS_PATH."/php/classes/podcatcher/program.class.php");
	require_once(ALACASTS_PATH."/php/classes/options.class.php");
	
	function help() {
		print( "Usage: alacast.php [options]..."
			."\n\tOptions:"
			."\n"
			."\n"
			."\nUpdate options:"
			."\n----------------------------------------------"
			."\n\t--update				runs `gpodder-11.3-hacked --local --run` automatically before moving podcasts."
			."\n"
			."\n\t--nice[=priority]			Runs alacast with the specified priority (default: +19)."
			."\n"
			."\n\t--update=detailed			Displays the output from: `gpodder-11.3-hacked --local --run`."
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
			."\n\t--leave-trails		Leave [GUID].trail symlinks to alacast's GUID folder."
			."\n"
			."\n\t--clean-trails		This just removes any symlinks that may have been created by"
			."\n\t				previously using the`--leave-trails` option."
			."\n"
			."\n"
			."\nSyncing options:"
			."\n-------------------"
			."\n\t--keep-original		keeps alacast GUID based named files while making copies of all"
			."\n\t					podcasts with easier to understand directories &filenames."
			."\n"
			."\n\t--player[=vlc|gstreamer|xine]		different players have issues with different charaters"
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
			."\nNaming/Title options:"
			."\n----------------------"
			."\n\t--titles-prefix-podcast-name"
			."\n\t--titles-append-pubdate"
			."\n"
			."\n"
			."\n\t--help			displays this screen."
			."\n"
			."\n"
			."\n\t		*wink* &remember alacast.php is written in PHP;"
			."\n\t		so its super easy to customize.  just remember to share ^_~"
			."\n"
			."\n"
		);
		
		exit(0);
		
	}//end:function help();
	
	
	
	function load_settings() {
		/*	here's where i setup and check all the directories i need
			to use, find, &rename/move all of my podcasts and their
			names and etc.
		*/
		$alacast_ini="";
		$HOME=getenv("HOME");
		$USER=getenv("USER");
		if(file_exists("{$HOME}/.alacast/alacast.ini"))
			$alacast_ini="{$HOME}/.alacast/alacast.ini";
		else if(file_exists("{$HOME}/.alacast/profiles/{$USER}/alacast.ini"))
			$alacast_ini="{$HOME}/.alacast/profiles/{$USER}/alacast.ini";
		else if(file_exists(ALACASTS_PATH."/data/profiles/{$USER}/alacast.ini"))
			$alacast_ini=ALACASTS_PATH."/data/profiles/${USER}/alacast.ini";
		else if(file_exists(ALACASTS_PATH."/data/profiles/default/alacast.ini"))
			$alacast_ini=ALACASTS_PATH."/data/profiles/default/alacast.ini";
		unset($HOME);
		unset($USER);
		
		if(!( $alacast_ini && $alacast_config_fp=fopen( $alacast_ini, "r")))
			return alacasts_Config_Error(sprintf("%s is not readable", $alacast_ini));//exit(-1);
		
		$alacast_config=preg_replace("/[\r\n]+/m", "\t", fread( $alacast_config_fp, (filesize($alacast_ini))));
		fclose($alacast_config_fp);
		
		$GLOBALS['alacasts_options']=new alacasts_options($alacast_config);
		
		if(!(
			$GLOBALS['alacasts_options']->save_to_dir
			&&
			is_dir($GLOBALS['alacasts_options']->save_to_dir)
			&&
			$GLOBALS['alacasts_options']->download_dir
			&&
			is_dir($GLOBALS['alacasts_options']->download_dir)
			&&
			$GLOBALS['alacasts_options']->playlist_dir
		)){
			alacasts_Config_Error($alacast_ini, "I couldn't load either alacast's:\n\t\t'download_dir': <".$GLOBALS['alacasts_options']->download_dir.">, 'save_to_dir': <".$GLOBALS['alacasts_options']->save_to_dir.">, or 'playlist_dir: <".$GLOBALS['alacasts_options']->playlist_dir.">.\n");
			unset($alacast_ini);
			unset($alacast_config);
			return FALSE;
		}
		
		chdir(dirname( $GLOBALS['alacasts_options']->download_dir));
		
		unset($alacast_ini);
		unset($alacast_config);
		return TRUE;
	}/*load_settings();*/
	
	
	
	function alacasts_Config_Error($alacast_ini="~/.alacast/alacast.ini", $details="") {
		print(
			"I couldn't load alacast's settings from: '"
			.$alacast_ini
			.( $details
				? "\n\tDetails: {$details}"
				: ""
			)
			."\n\tWhich basically means I'm done.\n"
		);
		return FALSE;
	}//end:function alacasts_Config_Error();
	
	
	
	Function log_alacast_downloads(&$alacast_Output) {
		//Logs' the URLs that where downloaded by the recently ran `gpodder --run`
		//TODO
	}//end function: log_alacast_downloads();
	
	
	
	function get_podcatcher(){
		if(!(
			(
				(is_executable( ($alacastsPodcatcher=ALACASTS_PATH."/helpers/gpodder-0.11.3-hacked/bin/gpodder-0.11.3-hacked")))
				&&
				(chdir( (dirname( $alacastsPodcatcher))))
				&&
				($alacastsPodcatcher="./".(basename( $alacastsPodcatcher))." --local")
			)
		))
			return $GLOBALS['alacasts_logger']->output("I can't try to download any new podcasts because I can't find alacast.", TRUE);
		
		if($GLOBALS['alacasts_options']->nice){
			if($GLOBALS['alacasts_options']->nice > 0)
				$alacastsPodcatcher="nice --adjustment={$GLOBALS['alacasts_options']->nice} {$alacastsPodcatcher}";
			else
				$alacastsPodcatcher="nice --adjustment=5 {$alacastsPodcatcher}";
		}
		
		return "unset http_proxy; {$alacastsPodcatcher}";
	}/*get_podcatcher();*/
	
	
	
	function exec_podcatcher() {
		static $alacastsPodcatcher;
		static $error_output;
		if(!isset($alacastsPodcatcher))
			$alacastsPodcatcher=get_podcatcher();
		
		$GLOBALS['alacasts_logger']->output(($GLOBALS['podcatcher']->set_status( "downloading new podcasts")));

		if(!isset($error_output))
			if(!$GLOBALS['alacasts_options']->debug)
				$error_output=" 2> /dev/stderr";
			else{
				$GLOBALS['alacasts_logger']->output("Running Podcatcher backend in debug mode.", TRUE);
				$error_output=" 2>> \"{$GLOBALS['alacasts_logger']->error_log_file}\"";
			}
		
		$lastLine="";
		/*if($GLOBALS['alacasts_options']->update=="detailed"){
			$alacast_Output=array();
			$lastLine=exec("{$alacastsPodcatcher} --run > /dev/tty{$error_output}", $alacast_Output);
			
			if($GLOBALS['alacasts_options']->update=="detailed")
				$GLOBALS['alacasts_logger']->output((alacast_helper::array_to_string( $alacast_Output, "\n")), "", TRUE);
			
			if((preg_match("/^D/", (ltrim($lastLine)))))
				log_alacast_downloadss($alacast_Output);
		}else*/
		
		if($GLOBALS['alacasts_options']->update=="detailed")
			$lastLine=system("{$alacastsPodcatcher} --run > /dev/tty{$error_output}");
		else
			$lastLine=exec("{$alacastsPodcatcher} --run > /dev/null{$error_output}");
		
		$GLOBALS['alacasts_logger']->output(($GLOBALS['podcatcher']->set_status( "downloading new podcasts", FALSE)));
		
		if(!( (preg_match("/^D/", (ltrim($lastLine))))))
			return FALSE;
		
		/*
		 * alacast 0.10.0 need a lot longer than 5 seconds.
		 * So I've moved it to 31 seconds just to be okay.
		 */
		$GLOBALS['alacasts_logger']->output("\nPlease wait while alacast finishes downloading your podcasts new episodes");
		for($i=0; $i<33; $i++) {
			if(!($i%3))
				print(".");
			
			usleep(500000); // waits for one half second.
		}
		print("\n");
		
		return TRUE;
	}//end:function exec_podcatcher();
	
	
	
	function leave_symlink_trail(&$podcastsGUID, &$podcastsName) {
		$podcastsTrailSymlink=(sprintf( "%s/%s/%s.trail", $GLOBALS['alacasts_options']->download_dir, $podcastsName, $podcastsGUID));
		if( 
			($GLOBALS['alacasts_options']->leave_trails)
			&&
			(!( (file_exists( $podcastsTrailSymlink))))
		)
			return symlink(
				(sprintf( "%s/%s", $GLOBALS['alacasts_options']->download_dir, $podcastsGUID)),
				$podcastsTrailSymlink
			);
		
		if( 
			($GLOBALS['alacasts_options']->clean_trails)
			&&
			(file_exists( $podcastsTrailSymlink))
		)
			return unlink($podcastsTrailSymlink);
	}//end funtion: leave_symlink_trail();.
	
	
	function generate_podcasts_info(&$podcastsInfo, $totalPodcasts, $start=1) {
		static $untitled_podcasts;
		if(!( (isset( $untitled_podcasts))))
			$untitled_podcasts=1;
		
		if(!(
			(isset( $podcastsInfo[0]))
			&&
			$podcastsInfo[0]
		)) {
			$podcastsInfo[0]="Untitled podcast(s)";
			$untitled_podcasts +=  $start;
		}
		
		for($i=$start; $i<$totalPodcasts; $i++)
			if(!(
				(isset( $podcastsInfo[$i]))
				&&
				$podcastsInfo[$i]
			))
				$podcastsInfo[$i]=sprintf(
					"%s'%s episode %d from %s",
					$podcastsInfo[0],
					(
						(preg_match( "/s$/", $podcastsInfo[0]))
						? ""
						: "s"
					),
					$untitled_podcasts++,
					(date( "r"))
				);
	}//end:function generate_podcasts_info()
	
	
	
	function get_episode_titles(&$podcastsInfo, $podcastsXML_filename) {
		if(!( (filesize($podcastsXML_filename))))
			return FALSE;
			
		$podcastsTempInfo=array();
		$podcastsXML_fp=fopen($podcastsXML_filename, 'r');
		$podcastsTempInfo=preg_replace("/[\r\n]+/m" , " - ",
					(fread(
						$podcastsXML_fp,
						(filesize($podcastsXML_filename))
					))
				);
		fclose($podcastsXML_fp);
		
		$podcastsTitles=preg_split(
					"/(<title>[^<]+<\/title>)/m", $podcastsTempInfo, -1,
					PREG_SPLIT_NO_EMPTY | PREG_SPLIT_DELIM_CAPTURE
		);
		
		if($GLOBALS['alacasts_options']->titles_append_pubdate)
			$podcastsPubDates=preg_split(
						"/(<pubDate>[^<]+<\/pubDate>)/m", $podcastsTempInfo, -1,
						PREG_SPLIT_NO_EMPTY | PREG_SPLIT_DELIM_CAPTURE
			);
		
		unset($podcastsTempInfo);
		
		if(!( (isset( $podcastsTitles[0]))))
			return FALSE;
		
		if($podcastsTitles[0] == $podcastsTitles[1])
			array_shift($podcastsTitles);
		
		$podcastsTitles['total']=count($podcastsTitles);
		
		/* formats podcast & episode titles. */
		for($i=1; $i<$podcastsTitles['total']; $i++){
			if(!( preg_match("/^<title>[^<]*<\/title>$/", $podcastsTitles[$i])))
				continue;
			
			$episode_title=trim(preg_replace("/<title>[\ \t]*([^<]+)<\/title>/", "$1", $podcastsTitles[$i]));
			if(!isset($podcastsInfo[0])){
				$podcastsInfo[ $podcastsInfo['total']++ ]=html_entity_decode($episode_title);
				$episode_prefix=$GLOBALS['alacasts_titles']->set_episode_prefix($podcastsInfo[0], $GLOBALS['alacasts_options']->titles_prefix_podcast_name);
				continue;
			}
			
			if(!($GLOBALS['alacasts_options']->titles_append_pubdate))
				$podcastsInfo[ $podcastsInfo['total']++ ]=html_entity_decode(sprintf("%s%s", $episode_prefix, $episode_title));
			else
				$podcastsInfo[ $podcastsInfo['total']++ ]=html_entity_decode(sprintf("%s%s, released on: %s", $episode_prefix, $episode_title, preg_replace("/<pubDate>[\ \t]*([^<]+)[\ \t]*<\/pubDate>/", "$1", $podcastsPubDates[($i-2)])));
		}
		
		if($GLOBALS['alacasts_options']->verbose){
			print("Found podcastTitles:\n");
			print_r($podcastsTitles);
			if(isset($podcastsPubDates)){
				print("\n\nFound podcastPubDates:\n");
				print_r($podcastsPubDates);
			}
			print("\n\nFound podcastsInfo:\n");
			print_r($podcastsInfo);
		
			$GLOBALS['alacasts_logger']->output(
				(sprintf(
					"\n*DEBUG*: I searched for %s'%s titles in %s.\nI've found titles for %d new episodes.",
					$podcastsInfo[0],
					(
						(preg_match( "/s$/", $podcastsInfo[0]))
							?"s"
							:""
					),
					$podcastsXML_filename,
					($podcastsInfo['total']-1)
				))
			);
		}
		unset($podcastsTitles);
		unset($podcastsPubDates);
		
		return TRUE;
	}//end:function get_episode_titles()
	
	function clean_podcasts_info(&$podcastsInfo) {
		/* replaces forward slashes with hyphens & strips leading dots('.').
		 * both for obvious(Linux) reasons. Other characters are stripped as well
		 * these are due to know issues that GStreamer, 
		*/
		for($i=0; $i<$podcastsInfo['total']; $i++){
			if($GLOBALS['alacasts_options']->verbose)
				$GLOBALS['alacasts_logger']->output(
					(sprintf("Cleaning podcastInfo %d.\n\tBefore cleaning: %s\n", $i, $podcastsInfo[$i]))
				);
			$podcastsInfo[$i]=preg_replace( "/^[~\.]*(.*)[~\.]*$/", "$1",
						(preg_replace( "/\//", "-",
							(html_entity_decode(
								$podcastsInfo[$i],
								ENT_QUOTES,
								"UTF-8"
							))
						))
					);
			if($GLOBALS['alacasts_options']->bad_chars)
				$podcastsInfo[$i]=preg_replace((sprintf("/[%s]/", $GLOBALS['alacasts_options']->bad_chars)), "", $podcastsInfo[$i]);
			if($GLOBALS['alacasts_options']->verbose)
				$GLOBALS['alacasts_logger']->output(
					(sprintf("\tAfter cleaning: %s\n", $podcastsInfo[$i]))
				);
		}//for($i<$podcastInfo['total'])
		
		$podcastsInfo[0]=preg_replace("/^(the)\s+(.*)$/i", "$2, $1", $podcastsInfo[0]);
	}//end:function clean_podcasts_info();
	
	
	
	function set_podcasts_info(&$podcastsXML_filename, &$podcasts_info, &$podcastsGUID, &$totalPodcasts) {
		get_episode_titles($podcasts_info, $podcastsXML_filename);
		clean_podcasts_info($podcasts_info);
		/* TODO: FIXME
		 * $GLOBALS['alacasts_titles']->reorder_titles($podcasts_info);
		 */
		generate_podcasts_info($podcasts_info, $totalPodcasts, $podcasts_info['total']);
		$GLOBALS['alacasts_titles']->prefix_episope_titles_with_podcasts_title($podcasts_info);
	}//end:function set_podcasts_info();
	
	
	
	function set_podcasts_new_episodes_filename($podcastsName, &$podcastsEpisode, $podcastsExtension) {
		static $untitled_podcast_count;
		if(!(isset( $untitled_podcast_count)))
			$untitled_podcast_count=0;
		
		if(!$podcastsEpisode) {
			$podcastsEpisode=sprintf(
							"%d%s - %s",
								((++$untitled_podcast_count)),
								($GLOBALS['alacasts_titles']->get_numbers_suffix( $untitled_podcast_count)),
								"untitled podcast(s)"
								
			);
		}
		
		static $SYNC_DIR_STRLEN;
		if(!isset($SYNC_DIR_STRLEN))
			$SYNC_DIR_STRLEN=strlen($GLOBALS['alacasts_options']->save_to_dir);
		
		$podcastsExtra="";
		$max_strlen=0;
		$podcasts_short_episode_name="";
		if(!$GLOBALS['alacasts_options']->titles_append_pubdate)
			$max_strlen=255;
		else
			$max_strlen=175;
		
		do {
			$podcasts_max_strlen=$max_strlen-(strlen($podcastsExtra)+strlen($podcastsExtension));
			if($GLOBALS['alacasts_options']->verbose)
				$GLOBALS['alacasts_logger']->output(
					(sprintf(
						"\n\tSetting podcasts episode title.\n\t\$podcasts_max_strlen: %d\n\tOriginal \$podcastEpisode:%s\n",
						$podcasts_max_strlen,
						$podcastsEpisode
					))
				);
			
			if(!$GLOBALS['alacasts_options']->titles_append_pubdate)
				$podcastsEpisode=preg_replace("/(.{1,{$podcasts_max_strlen}}).*/", "$1", $podcastsEpisode);
			else
				$podcastsEpisode=preg_replace("/^(.{1,{$podcasts_max_strlen}})(.*)(, released on.*)$/", "$1$3", $podcastsEpisode);
			
			if($GLOBALS['alacasts_options']->verbose)
				$GLOBALS['alacasts_logger']->output(
					(sprintf(
						"\tFormatted \$podcastEpisode:%s\n",
						$podcastsEpisode
					))
				);
			
			$Podcasts_New_Filename=sprintf(
				"%s%s.%s",
				$podcastsEpisode,
				$podcastsExtra,
				$podcastsExtension
			);
			
			$max_strlen-=38;
			$podcastsExtra=sprintf(
				"(copy from %s)",
				(date( "c"))
			);
			
			sleep(1);
		} while((file_exists( sprintf("%s/%s/%s", $GLOBALS['alacasts_options']->save_to_dir, $podcastsName, $Podcasts_New_Filename))));
		
		return $Podcasts_New_Filename;
	}//end:function set_podcasts_new_episodes_filename()
	
	
	
	function check_update() {
		if($GLOBALS['alacasts_options']->update)
			exec_podcatcher();
	}//end:function check_update();
	
	
	
	function move_alacasts_Podcasts() {
		
		check_update();
		
		$GLOBALS['alacasts_logger']->output(($GLOBALS['podcatcher']->set_status("syncronizing podcasts")));
		
		$GLOBALS['alacasts_playlist']=new alacasts_playlist(
			$GLOBALS['alacasts_options']->playlist_dir,
			"alacast",
			$GLOBALS['alacasts_options']->playlist
		);
		
		$totalMovedPodcasts=0;
		$alacastsPodcastDir=opendir($GLOBALS['alacasts_options']->download_dir);
		while($podcastsGUID=readdir($alacastsPodcastDir)) {
			if(!(
				(is_dir( (sprintf( "%s/%s", $GLOBALS['alacasts_options']->download_dir, $podcastsGUID))))
				&&
				(preg_match("/^[^.]+/", $podcastsGUID))
				&&
				(file_exists( ($podcastsXML_filename=(sprintf( "%s/%s/index.xml", $GLOBALS['alacasts_options']->download_dir, $podcastsGUID)))))
			))
				continue;
			
			exec("touch {$podcastsXML_filename}");
			
			if((isset( $podcastsFiles)))
				unset($podcastsFiles);
			$podcastsFiles=array();
			exec((sprintf( "/bin/ls -t --width=1 --quoting-style=c %s/%s/*.*", $GLOBALS['alacasts_options']->download_dir, $podcastsGUID)), $podcastsFiles);
			
			if(( ($podcastsFiles['total']=(count($podcastsFiles))) <= 1)) continue;
			
			if((isset( $podcastsInfo))) unset( $podcastsInfo);
			$podcastsInfo=array('total'  => 0);
			set_podcasts_info($podcastsXML_filename, $podcastsInfo, $podcastsGUID, $podcastsFiles['total']);
			
			if(!(
				(is_dir($GLOBALS['alacasts_options']->save_to_dir."/".$podcastsInfo[0]))
				||
				(mkdir($GLOBALS['alacasts_options']->save_to_dir."/".$podcastsInfo[0], 0774, TRUE))
			)) {
				$GLOBALS['alacasts_logger']->output("\n\tI've had to skip {$podcastsInfo[0]} because I couldn't create it's directory.\n\t\tPlease edit '{$podcastsXML_filename}' to fix this issue.", TRUE);//*wink*, it just kinda felt like a printf moment :P
				continue;
			}
			
			$GLOBALS['alacasts_logger']->output(
				(wordwrap(
					(
						"\n\t*w00t*! {$podcastsInfo[0]} has "
						.($podcastsFiles['total']-1)
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
			
			leave_symlink_trail($podcastsGUID, $podcastsInfo[0]);
			
			$totalMovedPodcasts+=move_podcasts_episodes($podcastsGUID, $podcastsFiles, $podcastsInfo);
			
			unset($podcastsFiles);
			unset($podcastsInfo);
		}
		closedir($alacastsPodcastDir);
		
		if($totalMovedPodcasts)
			$GLOBALS['alacasts_logger']->output("\n\n\t^_^ *w00t*, you have {$totalMovedPodcasts} new podcasts!");
		else
			$GLOBALS['alacasts_logger']->output("\n\t^_^ There are no new podcasts.");
		
		$GLOBALS['alacasts_logger']->output(
			"  Have fun! ^_^\n\n"
			. ($GLOBALS['podcatcher']->set_status( "syncronizing podcasts", FALSE))
		);
		
		unset($GLOBALS['alacasts_playlist']);
		
		return TRUE;
	}// end 'move_alacasts_Podcasts' function.
	
	
	
	function get_filenames_extension(&$podcastsFilename) {
		switch( ($ext=preg_replace(
			"/^.*\.([a-zA-Z0-9]{2,7})[\ ]*$/",
			"$1",
			(rtrim( $podcastsFilename))
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
		}//switch($ext);
	}//function: function get_filenames_extension(&$podcastsFilename);
	
	
	
	function move_podcasts_episodes(&$podcastsGUID, &$podcastsFiles, &$podcastsInfo) {
		$movedPodcasts=0;
		
		if(!$podcastsInfo[0]) $podcastsInfo[0]="Untitled podcast(s)";
		
		for($i=1, $z=($podcastsInfo['total']-1); $i<$podcastsFiles['total']; $i++, $z--) {
			$podcastsFiles[$i]=preg_replace('/^"(.*)"$/', '$1', $podcastsFiles[$i]);
			if(!( ($ext=get_filenames_extension( $podcastsFiles[$i]))))
				continue;
			
			$Podcasts_New_Filename=set_podcasts_new_episodes_filename($podcastsInfo[0], $podcastsInfo[$z], $ext);
			
			if($GLOBALS['alacasts_options']->verbose)
				$GLOBALS['alacasts_logger']->output(
					(sprintf(
						"\n\t*DEBUG*: I'm moving:\n\t%s\n\t\t-to\n\t%s/%s/%s\n",
						$podcastsFiles[$i],
						$GLOBALS['alacasts_options']->save_to_dir, $podcastsInfo[0], $Podcasts_New_Filename
					))
				);
			
			if(
				($GLOBALS['alacasts_options']->keep_original)
				&&
				(file_exists( sprintf("%s/%s/%s", $GLOBALS['alacasts_options']->save_to_dir, $podcastsInfo[0], $Podcasts_New_Filename)))
			)
				continue;
			
			if(!(file_exists($podcastsFiles[$i])))
				continue;

			$podcasts_new_file="";
			$cmd=sprintf("%s %s %s",
					(($GLOBALS['alacasts_options']->keep_original) ?"cp" : "mv"),
					preg_replace('/([\ \r\n])/', '\\\$1', $podcastsFiles[$i]),
					escapeshellarg( ($podcasts_new_file=sprintf("%s/%s/%s", $GLOBALS['alacasts_options']->save_to_dir, $podcastsInfo[0], $Podcasts_New_Filename)) )
			);
			
			if(!$GLOBALS['alacasts_options']->debug){
				$null_output=array();
				$link_check=-1;
				exec($cmd, $null_output, $link_check);
				if($link_check){
					$GLOBALS['alacasts_logger']->output("\n\t\t" . (wordwrap( sprintf("\n\t\t**ERROR:** failed to move podcast.\n\t link used:%s\n\terrno:%d\n\terror:\n\t%s\n", $cmd, $link_check, $null_output))), TRUE);
					continue;
				}
			}
			
			if($GLOBALS['alacasts_options']->playlist)
				$GLOBALS['alacasts_playlist']->add_file($podcasts_new_file);
			
			$movedPodcasts++;
			
			//Prints the new episodes name:
			$GLOBALS['alacasts_logger']->output("\n\t\t" . (wordwrap( $Podcasts_New_Filename, 72, "\n\t\t\t")) ."\n");
		}
		return $movedPodcasts;
	}//end:function move_podcasts_episodes();
	
	/*alacast.php: main(); starts here.*/
	
	//here's where alacast actually starts.
	if((alacast_helper::preg_match_array($_SERVER['argv'], "/\-\-help$/")))
		help();//displays usage and exits alacast
	
	/* load_settings(); creates the
	 * 	$alacast_options global object
	 * 	it also define's configuration options.
	 */
	if(!( (load_settings())))
		exit(-1);
	/*print_r($alacasts_options);
	exit;*/
	
	$podcatcher=new alacasts_podcatcher_program();
	$alacasts_titles=new alacasts_titles();
	
	$GLOBALS['alacasts_logger']=new alacasts_logger(
		$GLOBALS['alacasts_options']->save_to_dir,
		"alacast",
		$alacasts_options->logging,
		$alacasts_options->quiet
	);
	
	while((move_alacasts_Podcasts())) {
		if(!$alacasts_options->interactive)
			break;
		
		print("\nPlease press [enter] to continue; [enter] 'q' to quit: ");
		if((trim( (fgetc( STDIN))))  ==  'q')
			break;
	}//while((move_alacasts_Podcasts()));
	
?>
