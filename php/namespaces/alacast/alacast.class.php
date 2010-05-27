<?php
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
	 */
	require_once(ALACASTS_PATH."/php/namespaces/alacast/ini.class.php");
	require_once(ALACASTS_PATH."/php/namespaces/alacast/titles.class.php");
	require_once(ALACASTS_PATH."/php/namespaces/alacast/logger.class.php");
	require_once(ALACASTS_PATH."/php/namespaces/alacast/playlist.class.php");
	require_once(ALACASTS_PATH."/php/namespaces/alacast/podcatcher.class.php");
	require_once(ALACASTS_PATH."/php/namespaces/alacast/options.class.php");
	
	class alacast{
		/* variables */
		public	$path;

		/* objects */
		public	$options;
		public	$logger;
		public	$podcatch;
		public	$ini;
		public	$playlist;
		
		public function __construct(){
			$this->path=preg_replace("/(.*)\/[^\/]+/", "$1", ( (dirname($_SERVER['argv'][0])!=".") ? (dirname( $_SERVER['argv'][0])) : $_SERVER['PWD']));
			$this->ini=new \alacast\ini($this->path);
			$this->options=new \alacast\options();
			$this->logger=new \alacast\logger(
						$this->ini->save_to_dir,
						"alacast",
						$this->options->logging,
						$this->options->quiet
			);
			$this->podcatcher=new \alacast\podcatcher( $this->path, $this->ini->profiles_path, $this->options->update, $this->options->nice, $this->options->debug, "" );
			$this->titles=new \alacast\titles();

			if(!$this->options->diagnosis)
				$this->playlist=NULL;
			else
				$this->playlist_open(TRUE);
		}//__construct

		
		public function output($string, $error=FALSE, $silent=FALSE){
			return $this->logger->output($string, $error, $silent);
		}/*$this->output();*/
		
		
		public function playlist_open($force=FALSE){
			if( !$this->options->playlist && !$force )
				return;
			
			$this->playlist=new \alacast\playlist(
				$this->ini->playlist_dir,
				"alacast",
				$this->options->playlist,
				$this->options->titles_append_pubdate
			);
		}/*\alacast\playlist_open();*/
		
		public function playlist_close(){
			if(!isset($this->playlist))
				return;
			
			unset($this->playlist);
			$this->playlist=NULL;
		}/*\alacast\playlist_close();*/
		
		public function __destruct(){
			$this->playlist_close();
		}//__destruct
		
	}
?>

