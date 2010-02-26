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
	class alacasts_options{
		public	$nice;
		public	$debug;
		public	$quiet;
		public	$logging;
		public	$playlist;
		public	$update;
		public	$leave_trails;
		public	$clean_trails;
		public	$interactive;
		public	$keep_original;
		
		public	$download_dir;
		public	$save_to_dir;
		public	$playlist_dir;
		
		private	$player;
		public	$bad_chars;
		
		public function __construct(&$alacast_config){
			$default_options_type="";
			if(
				(count($_SERVER['argv'])==1)
				||
				$default_options_type=\alacast_helper::preg_match_array($_SERVER['argv'], "/^\-\-with\-defaults[=]?(.*)/", "$1")
			)
				$this->load_options($alacast_config, $default_options_type);
			unset($default_options_type);
			
			$this->update=FALSE;
			$this->nice=0;
			$this->logging=FALSE;
			$this->quiet=FALSE;
			$this->leave_trails=FALSE;
			$this->clean_trails=FALSE;
			$this->titles_append_pubdate=FALSE;
			$this->titles_prefix_podcast_name=FALSE;
			$this->verbose=FALSE;
			$this->debug=FALSE;
			$this->keep_original=FALSE;
			$this->interactive=FALSE;
			$this->bad_chars=NULL;
			$this->playlist=NULL;
			$this->player=NULL;
			
			$this->download_dir=NULL;
			$this->save_to_dir=NULL;
			$this->playlist_dir=NULL;
			
			$this->parse_argv();
			
			if($this->player)
				$this->set_characters_to_strip_from_titles();
			
			if($this->playlist)
				$this->set_playlist();
			
			$this->parse_alacast_ini_paths($alacast_config);
			
			/*if(\alacast_helper::preg_match_array($_SERVER['argv'], "/\-\-$/"))
				$this->=TRUE;
			else
				$this->=FALSE;*/
			
		}//__construct
		
		
		
		private function parse_argv(){
			foreach($_SERVER['argv'] as $index=>$argv_value){
				$option=preg_replace("/^[\-]{1,2}([^=]*)[=]?['\"]?([^'\"]*)['\"]?$/", "$1", $argv_value);
				$value=preg_replace("/^[\-]{1,2}([^=]*)[=]?['\"]?([^'\"]*)['\"]?$/", "$2", $argv_value);
				switch($option){
					case "update":
						if($value)
							$this->update=$value;
						break;
					
					case "nice":
						if(!($value && preg_match("/^[0-9]+$/", $value)))
							break;
						
						if($value <= 0)
							$this->nice=5;
						else
							$this->nice=$value;
						break;
						
					case "interactive":
						$this->interactive=TRUE;
						break;
					
					case "logging":
						$this->logging=TRUE;
						break;
					
					case "quiet":
						$this->quiet=TRUE;
						break;
					
					case "leave-trails":
						$this->leave_trails=TRUE;
						break;
					
					case "clean-trails":
						$this->clean_trails=TRUE;
						break;
					
					case "titles-append-pubdate":
						$this->titles_append_pubdate=TRUE;
						break;
					
					case "titles-prefix-podcast-name":
						$this->titles_prefix_podcast_name=TRUE;
						break;
					
					case "verbose":
						$this->verbose=TRUE;
						break;
					
					case "debug":
						$this->debug=TRUE;
						break;
					
					case "strip-characters":
						if($value)
							$this->bad_chars=$value;
						break;
					
					case "player":
						$this->player=sprintf("%s%s%s", $option, ($value ?"=" :""), $value);
						break;
					
					case "playlist":
						$this->playlist=sprintf("%s%s%s", $option, ($value ?"=" :""), $value);
						break;
					
					case "keep-original":
						$this->keep_original=TRUE;
						break;
			
					/*
					
					case "":
						$this->=TRUE;
						break;
					*/
				}
			}
		}/*parse_argv();*/
		

		
		private function parse_alacast_ini_paths(&$alacast_config){
			$this->save_to_dir=preg_replace("/.*save_to_dir=\"([^\"]+)\".*/", "$1", $alacast_config);
			if(!preg_match("/^\//", $this->save_to_dir))
				$this->save_to_dir=sprintf("/%s", $this->save_to_dir);
			if(!($this->save_to_dir && is_dir($this->save_to_dir))){
				$this->save_to_dir=NULL;
				return FALSE;
			}
			
			$this->download_dir=preg_replace("/.*download_dir=\"([^\"]+)\".*/", "$1", $alacast_config);
			if(!preg_match("/^\//", $this->download_dir))
				$this->download_dir=sprintf("/%s", $this->download_dir);
			if(!($this->download_dir && is_dir($this->download_dir))){
				$this->download_dir=NULL;
				return FALSE;
			}
			
			$playlist_dir=preg_replace("/.*playlist_dir=\"([^\"]+)\".*/", "$1", $alacast_config);
			if(!preg_match("/^\//", $playlist_dir))
				$playlist_dir=sprintf("/%s", $playlist_dir);
			
			switch($this->playlist){
				case "m3u":
					$playlist_dir_m3u=preg_replace("/.*playlist_dir:m3u=\"([^\"]+)\".*/", "$1", $alacast_config);
					if(preg_match("/\{playlist_dir\}/", $playlist_dir_m3u))
						$playlist_dir_m3u=preg_replace("/\{playlist_dir\}/", "{$playlist_dir}", $playlist_dir_m3u);
					if(!preg_match("/^\//", $playlist_dir_m3u))
						$playlist_dir_m3u=sprintf("/%s", $playlist_dir_m3u);
					$this->playlist_dir=$playlist_dir_m3u;
					unset($playlist_dir_m3u);
					break;
				
				case "toxine":
					$playlist_dir_tox=preg_replace("/.*playlist_dir:tox=\"([^\"]+)\".*/", "$1", $alacast_config);
					if(preg_match("/\{playlist_dir\}/", $playlist_dir_tox))
						$playlist_dir_tox=preg_replace("/\{playlist_dir\}/", "{$playlist_dir}", $playlist_dir_tox);
					if(!preg_match("/^\//", $playlist_dir_tox))
						$playlist_dir_tox=sprintf("/%s", $playlist_dir_tox);
					
					$this->playlist_dir=$playlist_dir_tox;
					unset($playlist_dir_tox);
					break;
				
				case "pls":
					$playlist_dir_pls=preg_replace("/.*playlist_dir:pls=\"([^\"]+)\".*/", "$1", $alacast_config);
					if(preg_match("/\{playlist_dir\}/", $playlist_dir_pls))
						$playlist_dir_pls=preg_replace("/\{playlist_dir\}/", "{$playlist_dir}", $playlist_dir_pls);
					if(!preg_match("/^\//", $playlist_dir_pls))
						$playlist_dir_pls=sprintf("/%s", $playlist_dir_pls);
					
					$this->playlist_dir=$playlist_dir_pls;
					unset($playlist_dir_pls);
					break;
				
				default:
					$this->playlist_dir=$playlist_dir;
					break;
			}
			
			unset($playlist_dir);
		}/*$this->parse_alacast_ini_paths($alacast_config);*/
		
		
		
		private function load_alacasts_default_options(&$alacast_config, $which_options="default"){
			if($options=(preg_replace( "/.*options.$which_options=\"([^\"]+)\".*/", "$1", $alacast_config))){
				$_SERVER['argv']=array_merge(
					$_SERVER['argv'],
					preg_split(
						"/\ /", $options, -1,
						PREG_SPLIT_NO_EMPTY
					)
				);
				unset($options);
			}
		}/*load_alacasts_default_options($alacast_config, "defaults|update|sync");*/
		
		
		
		private function load_options(&$alacast_config, $default_options_type){
			$options=NULL;
			if(($options=getenv("ALACASTS_OPTIONS"))){
				$_SERVER['argv']=array_merge(
					$_SERVER['argv'],
					preg_split(
						"/\ /", $options, -1,
						PREG_SPLIT_NO_EMPTY
					)
				);
				unset($options);
			}
			
			if(($options=getenv("ALACAST_OPTIONS"))){
				$_SERVER['argv']=array_merge(
					$_SERVER['argv'],
					preg_split(
						"/\ /", $options, -1,
						PREG_SPLIT_NO_EMPTY
					)
				);
				unset($options);
			}
			
			switch($default_options_type){
				case "update":
				case "sync":
					$this->load_alacasts_default_options($alacast_config, $default_options_type);
			
					if(\alacast_helper::preg_match_array($_SERVER['argv'], "/^\-\-with\-defaults$/"))
						$this->load_alacasts_default_options($alacast_config);
					break;
				
				default:
					$this->load_alacasts_default_options($alacast_config);
					break;
			}
		}/*load_options($alacast_config, $default_options_type);*/
		
		
		
		private function set_characters_to_strip_from_titles(){
			switch($this->player){
				case "player=gstreamer":
					return ($this->bad_chars=sprintf("%s#", $this->bad_chars));
				case "player=vlc":
					return ($this->bad_chars=sprintf("%s:", $this->bad_chars));
				case "player=xine":
					return ($this->bad_chars=sprintf("%s;#", $this->bad_chars));
				case "player":
					return ($this->bad_chars=sprintf("%s#:;", $this->bad_chars));
			}
			return $this->bad_chars;
		}
		
		
		
		private function set_playlist(){
			switch(alacast_helper::preg_match_array($_SERVER['argv'], "/^\-\-(playlist)([=]?)(.*)/", "$1$2$3")){
				case "playlist=pls":
					$this->playlist="pls";
					break;
				case "playlist=toxine":
				case "playlist=tox":
					$this->playlist="toxine";
					break;
				case "playlist=m3u":
				case "playlist":
					$this->playlist="m3u";
					break;
				case FALSE:
					$this->playlist=FALSE;
					return FALSE;
			}
			return TRUE;
		}
		
		
		
		public function __destruct(){
			
		}//__destruct
		
	}
?>
