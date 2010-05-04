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
	
	
	function leave_symlink_trail(&$podcastsGUID, &$podcastsName) {
		$podcastsTrailSymlink=(sprintf( "%s/%s/%s.trail", $GLOBALS['alacast']->ini->download_dir, $podcastsName, $podcastsGUID));
		if( 
			($GLOBALS['alacast']->options->leave_trails)
			&&
			(!( (file_exists( $podcastsTrailSymlink))))
		)
			return symlink(
				(sprintf( "%s/%s", $GLOBALS['alacast']->ini->download_dir, $podcastsGUID)),
				$podcastsTrailSymlink
			);
		
		if( 
			($GLOBALS['alacast']->options->clean_trails)
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
			(isset( $podcastsInfo[0]['title']))
			&&
			$podcastsInfo[0]['title']
		)) {
			$podcastsInfo[0]['title']="Untitled podcast(s)";
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
					$podcastsInfo[0]['title'],
					(
						(preg_match( "/s$/", $podcastsInfo[0]['title']))
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
		
		$podcastsPubDates;
		if($GLOBALS['alacast']->options->titles_append_pubdate)
			$podcastsPubDates=preg_split(
						"/(<pubDate>[^<]+<\/pubDate>)/m", $podcastsTempInfo, -1,
						PREG_SPLIT_NO_EMPTY | PREG_SPLIT_DELIM_CAPTURE
			);
		
		$podcastURIs=array();
		$podcastsURIs=preg_split(
					"/(<url>[^<]+<\/url>)/m", $podcastsTempInfo, -1,
					PREG_SPLIT_NO_EMPTY | PREG_SPLIT_DELIM_CAPTURE
		);
		
		unset($podcastsTempInfo);
		
		if(!( (isset( $podcastsTitles[0])))){
			unset($podcastsTitles);
			unset($podcastsURIs);
		
			if(isset($podcastsPubDates))
				unset($podcastsPubDates);
			return FALSE;
		}
		
		if($podcastsTitles[0] == $podcastsTitles[1])
			array_shift($podcastsTitles);
		
		$podcastsTitles['total']=count($podcastsTitles);
		
		/* formats podcast & episode titles. */
		for($i=1; $i<$podcastsTitles['total']; $i++){
			if(!( preg_match("/^<title>[^<]*<\/title>$/", $podcastsTitles[$i])))
				continue;
			
			$episode_title=trim(preg_replace("/<title>[\ \t]*([^<]+)<\/title>/", "$1", $podcastsTitles[$i]));
			if(!isset($podcastsInfo[0]['title'])){
				$podcastsInfo[ $podcastsInfo['total']++ ]['title']=html_entity_decode($episode_title);
				$episode_prefix=$GLOBALS['alacast']->titles->set_episode_prefix($podcastsInfo[0]['title'], $GLOBALS['alacast']->options->titles_prefix_podcast_name);
				continue;
			}
			
			$podcastsInfo[ $podcastsInfo['total'] ]=array();
			if(!($GLOBALS['alacast']->options->titles_append_pubdate))
				$podcastsInfo[ $podcastsInfo['total'] ]['title']=html_entity_decode(sprintf("%s%s", $episode_prefix, $episode_title));
			else
				$podcastsInfo[ $podcastsInfo['total'] ]['title']=html_entity_decode(sprintf("%s%s, released on: %s", $episode_prefix, $episode_title, preg_replace("/<pubDate>[\ \t]*([^<]+)[\ \t]*<\/pubDate>/", "$1", $podcastsPubDates[($i-2)])));
			$podcastsInfo[ $podcastsInfo['total'] ]['url']=preg_replace("/<url>([^<]+)<\/url>/", "$1", $podcastsURIs[($i-2)]);
			$podcastsInfo['total']++;
		}
		
		if($GLOBALS['alacast']->options->verbose){
			print("Found podcastTitles:\n");
			print_r($podcastsTitles);
			if(isset($podcastsPubDates)){
				print("\n\nFound podcastPubDates:\n");
				print_r($podcastsPubDates);
			}
			print("\n\nFound podcastsInfo:\n");
			print_r($podcastsInfo);
		
			$GLOBALS['alacast']->logger->output(
				(sprintf(
					"\n*DEBUG*: I searched for %s'%s titles in %s.\nI've found titles for %d new episodes.",
					$podcastsInfo[0]['title'],
					(
						(preg_match( "/s$/", $podcastsInfo[0]['title']))
							?"s"
							:""
					),
					$podcastsXML_filename,
					($podcastsInfo['total']-1)
				))
			);
		}
		
		unset($podcastsTitles);
		unset($podcastsURIs);
		
		if(isset($podcastsPubDates))
			unset($podcastsPubDates);
		
		return TRUE;
	}/*$this->get_episode_titles($podcasts_info, $podcastsXML_filename);*/
	
	function clean_podcasts_info(&$podcastsInfo) {
		/* replaces forward slashes with hyphens & strips leading dots('.').
		 * both for obvious(Linux) reasons. Other characters are stripped as well
		 * these are due to know issues that GStreamer, 
		*/
		for($i=0; $i<$podcastsInfo['total']; $i++){
			if($GLOBALS['alacast']->options->verbose)
				$GLOBALS['alacast']->logger->output(
					(sprintf("Cleaning podcastInfo %d.\n\tBefore cleaning: %s\n", $i, $podcastsInfo[$i]))
				);
			$podcastsInfo[$i]['title']=preg_replace( "/^[~\.]*(.*)[~\.]*$/", "$1",
						(preg_replace( "/\//", "-",
							(html_entity_decode(
								$podcastsInfo[$i]['title'],
								ENT_QUOTES,
								"UTF-8"
							))
						))
					);
			if($GLOBALS['alacast']->options->bad_chars)
				$podcastsInfo[$i]['title']=preg_replace((sprintf("/[%s]/", $GLOBALS['alacast']->options->bad_chars)), "", $podcastsInfo[$i]['title']);
			if($GLOBALS['alacast']->options->verbose)
				$GLOBALS['alacast']->logger->output(
					(sprintf("\tAfter cleaning: %s\n", $podcastsInfo[$i]['title']))
				);
		}//for($i<$podcastInfo['total'])
		
		$podcastsInfo[0]['title']=preg_replace("/^(the)\s+(.*)$/i", "$2, $1", $podcastsInfo[0]['title']);
	}//end:function clean_podcasts_info();
	
	
	function set_podcasts_info(&$podcastsXML_filename, &$podcasts_info, &$podcastsGUID, &$totalPodcasts) {
		get_episode_titles($podcasts_info, $podcastsXML_filename);
		clean_podcasts_info($podcasts_info);
		$GLOBALS['alacast']->titles->reorder_titles($podcasts_info, $GLOBALS['alacast']->options->titles_reformat_numerical);
		
		generate_podcasts_info($podcasts_info, $totalPodcasts, $podcasts_info['total']);
		if($GLOBALS['alacast']->options->titles_prefix_podcast_name)
			$GLOBALS['alacast']->titles->prefix_episope_titles_with_podcasts_title($podcasts_info);
	}//end:function set_podcasts_info();
	
	
	
	function set_podcasts_new_episodes_filename($podcastsName, &$podcastsEpisode, $podcastsExtension) {
		static $untitled_podcast_count;
		if(!(isset( $untitled_podcast_count)))
			$untitled_podcast_count=0;
		
		if(!$podcastsEpisode) {
			$podcastsEpisode=sprintf(
							"%d%s - %s",
								((++$untitled_podcast_count)),
								($GLOBALS['alacast']->titles->get_numbers_suffix( $untitled_podcast_count)),
								"untitled podcast(s)"
								
			);
		}
		
		static $SYNC_DIR_STRLEN;
		if(!isset($SYNC_DIR_STRLEN))
			$SYNC_DIR_STRLEN=strlen($GLOBALS['alacast']->ini->save_to_dir);
		
		$podcastsExtra="";
		$max_strlen=0;
		$podcasts_short_episode_name="";
		if(!$GLOBALS['alacast']->options->titles_append_pubdate)
			$max_strlen=255;
		else
			$max_strlen=175;
		
		do {
			$podcasts_max_strlen=$max_strlen-(strlen($podcastsExtra)+strlen($podcastsExtension));
			if($GLOBALS['alacast']->options->verbose)
				$GLOBALS['alacast']->logger->output(
					(sprintf(
						"\n\tSetting podcasts episode title.\n\t\$podcasts_max_strlen: %d\n\tOriginal \$podcastEpisode:%s\n",
						$podcasts_max_strlen,
						$podcastsEpisode
					))
				);
			
			if(!$GLOBALS['alacast']->options->titles_append_pubdate)
				$podcastsEpisode=preg_replace("/(.{1,{$podcasts_max_strlen}}).*/", "$1", $podcastsEpisode);
			else
				$podcastsEpisode=preg_replace("/^(.{1,{$podcasts_max_strlen}})(.*)(, released on.*)$/", "$1$3", $podcastsEpisode);
			
			if($GLOBALS['alacast']->options->verbose)
				$GLOBALS['alacast']->logger->output(
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
		} while((file_exists( sprintf("%s/%s/%s", $GLOBALS['alacast']->ini->save_to_dir, $podcastsName, $Podcasts_New_Filename))));
		
		return $Podcasts_New_Filename;
	}//end:function set_podcasts_new_episodes_filename()
	
	
	function move_podcasts() {
		if($GLOBALS['alacast']->options->update)
			$GLOBALS['alacast']->podcatcher->download($GLOBALS['alacast']->logger->error_log_file);
		
		$GLOBALS['alacast']->podcatcher->set_status( FALSE, TRUE );
		
		$GLOBALS['alacast']->playlist_open();
		
		$totalMovedPodcasts=0;
		$alacastsPodcastDir=opendir($GLOBALS['alacast']->ini->download_dir);
		while($podcastsGUID=readdir($alacastsPodcastDir)) {
			if(!(
				(is_dir( (sprintf( "%s/%s", $GLOBALS['alacast']->ini->download_dir, $podcastsGUID))))
				&&
				(preg_match("/^[^.]+/", $podcastsGUID))
				&&
				(file_exists( ($podcastsXML_filename=(sprintf( "%s/%s/index.xml", $GLOBALS['alacast']->ini->download_dir, $podcastsGUID)))))
			))
				continue;
			
			exec("touch {$podcastsXML_filename}");
			
			if((isset( $podcastsFiles)))
				unset($podcastsFiles);
			$podcastsFiles=array();
			exec((sprintf( "/bin/ls -t --width=1 --quoting-style=c %s/%s/*.*", $GLOBALS['alacast']->ini->download_dir, $podcastsGUID)), $podcastsFiles);
			
			if(( ($podcastsFiles['total']=(count($podcastsFiles))) <= 1)) continue;
			
			if((isset( $podcastsInfo))) unset( $podcastsInfo);
			$podcastsInfo=array('total'  => 0);
			set_podcasts_info($podcastsXML_filename, $podcastsInfo, $podcastsGUID, $podcastsFiles['total']);
			
			if(!(
				(is_dir($GLOBALS['alacast']->ini->save_to_dir."/".$podcastsInfo[0]['title']))
				||
				(mkdir($GLOBALS['alacast']->ini->save_to_dir."/".$podcastsInfo[0]['title'], 0774, TRUE))
			)) {
				$GLOBALS['alacast']->logger->output("\n\tI've had to skip {$podcastsInfo[0]['title']} because I couldn't create it's directory.\n\t\tPlease edit '{$podcastsXML_filename}' to fix this issue.", TRUE);//*wink*, it just kinda felt like a printf moment :P
				continue;
			}
			
			$GLOBALS['alacast']->logger->output(
				(wordwrap(
					(
						"\n\t*w00t*! {$podcastsInfo[0]['title']} has "
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
			
			leave_symlink_trail($podcastsGUID, $podcastsInfo[0]['title']);
			
			$totalMovedPodcasts+=move_podcasts_episodes($podcastsXML_filename, $podcastsGUID, $podcastsFiles, $podcastsInfo);
			
			unset($podcastsFiles);
			unset($podcastsInfo);
			unset($podcastsXML_filename);
		}
		closedir($alacastsPodcastDir);
		
		if($totalMovedPodcasts)
			$GLOBALS['alacast']->logger->output("\n\n\t^_^ *w00t*, you have {$totalMovedPodcasts} new podcasts!");
		else
			$GLOBALS['alacast']->logger->output("\n\t^_^ There are no new podcasts.");
		
		$GLOBALS['alacast']->logger->output("  Have fun! ^_^\n\n");
		$GLOBALS['alacast']->podcatcher->set_status( FALSE, FALSE );
		
		$GLOBALS['alacast']->playlist_close();
		
		return TRUE;
	}/*move_podcasts();*/
	
	
	
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
	
	
	
	function move_podcasts_episodes(&$podcastsXML_filename, &$podcastsGUID, &$podcastsFiles, &$podcastsInfo) {
		$movedPodcasts=0;
		
		if(!$podcastsInfo[0])
			$podcastsInfo[0]['title']="Untitled podcast(s)";
		
		for($i=1, $z=($podcastsInfo['total']-1); $i<$podcastsFiles['total']; $i++, $z--) {
			$podcastsFiles[$i]=preg_replace('/^"(.*)"$/', '$1', $podcastsFiles[$i]);
			if(!( ($ext=get_filenames_extension( $podcastsFiles[$i]))))
				continue;
			
			$Podcasts_New_Filename=set_podcasts_new_episodes_filename($podcastsInfo[0]['title'], $podcastsInfo[$z]['title'], $ext);
			
			if($GLOBALS['alacast']->options->verbose)
				$GLOBALS['alacast']->logger->output(
					(sprintf(
						"\n\t*DEBUG*: I'm moving:\n\t%s\n\t\t-to\n\t%s/%s/%s\n",
						$podcastsFiles[$i],
						$GLOBALS['alacast']->ini->save_to_dir, $podcastsInfo[0]['title'], $Podcasts_New_Filename
					))
				);
			
			if(
				($GLOBALS['alacast']->options->keep_original)
				&&
				(file_exists( sprintf("%s/%s/%s", $GLOBALS['alacast']->ini->save_to_dir, $podcastsInfo[0]['title'], $Podcasts_New_Filename)))
			)
				continue;
			
			if(!(file_exists($podcastsFiles[$i])))
				continue;

			$podcasts_new_file="";
			$cmd=sprintf("%s %s %s",
					(($GLOBALS['alacast']->options->keep_original) ?"cp" : "mv"),
					preg_replace('/([\ \r\n])/', '\\\$1', $podcastsFiles[$i]),
					escapeshellarg( ($podcasts_new_file=sprintf("%s/%s/%s", $GLOBALS['alacast']->ini->save_to_dir, $podcastsInfo[0]['title'], $Podcasts_New_Filename)) )
			);
			
			if(!$GLOBALS['alacast']->options->debug){
				$null_output=array();
				$link_check=-1;
				exec($cmd, $null_output, $link_check);
				if($link_check){
					$GLOBALS['alacast']->logger->output("\n\t\t" . (wordwrap( sprintf("\n\t\t**ERROR:** failed to move podcast.\n\t link used:%s\n\terrno:%d\n\terror:\n\t%s\n", $cmd, $link_check, $null_output))), TRUE);
					continue;
				}
			}
			
			if($GLOBALS['alacast']->options->playlist)
				$GLOBALS['alacast']->playlist->add_file($podcasts_new_file);
			
			$movedPodcasts++;
			
			//Prints the new episodes name:
			$GLOBALS['alacast']->logger->output("\n\t\t" . (wordwrap( $Podcasts_New_Filename, 72, "\n\t\t\t")) ."\n\t\tURI: ".$podcastsInfo[$z]['url']."\n");
		}
		return $movedPodcasts;
	}//end:function move_podcasts_episodes();
	
	/*alacast.php: main(); starts here.*/
	define("ALACASTS_PATH", (preg_replace("/(.*)\/[^\/]+/", "$1", ( (dirname($_SERVER['argv'][0])!=".") ? (dirname( $_SERVER['argv'][0])) : $_SERVER['PWD']))));
	require_once(ALACASTS_PATH."/php/namespaces/alacast/helper.class.php");
	
	//here's where alacast actually starts.
	if((\alacast\helper::preg_match_array($_SERVER['argv'], "/\-\-help$/")))
		\alacast\help();//displays usage and exits alacast
	
	/* Creates the
	 * 	$alacast_options global object
	 * 	it also define's configuration options.
	 */
	require_once(ALACASTS_PATH."/php/namespaces/alacast/alacast.class.php");
	if(!($alacast=new alacast()))
		exit(-1);
	
	if($alacast->options->diagnosis){
		fprintf(STDOUT, "\$alacast:\n");
		print_r($alacast);
		fprintf(STDOUT, "\n\n\$_SERVER['argv']:\n");
		print_r($_SERVER['argv']);
		fprintf(STDOUT, "\n\n");
		unset($alacast);
		exit(-1);
	}
	
	
	while((move_podcasts())) {
		if(!$alacast->options->interactive){
			if(!( $alacast->options->update_delay && $alacast->options->update_delay > 0 ))
				break;
			sleep( $alacast->options->update_delay );
			continue;
		}
		
		print("\nPlease press [enter] to continue; [enter] 'q' to quit: ");
		if( (trim( (fgetc( STDIN )) )) == 'q')
			break;
	}//while((move_podcasts()));
	
	unset($alacast);
?>
