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
	namespace alacast;
	
	class options{
		public	$nice;
		public	$debug;
		public	$diagnostic_mode;
		public	$quiet;
		public	$logging;
		public	$update;
		public	$leave_trails;
		public	$clean_trails;
		public	$interactive;
		public	$update_delay;
		public	$verbose;
		public	$keep_original;
		
		public	$titles_append_pubdate;
		public	$titles_prefix_podcast_name;
		public	$titles_reformat_numerical;
		
		public	$playlist;
		
		private	$player;
		public	$bad_chars;
		
		public function __construct(){
			$this->init();
			
			$this->parse_argv();
			
			if($this->player)
				$this->set_characters_to_strip_from_titles();
			
			if($this->playlist)
				$this->set_playlist();
			
			/*if(helper::preg_match_array($_SERVER['argv'], "/\-\-$/"))
				$this->=TRUE;
			else
				$this->=FALSE;*/
			
		}//__construct
		
		
		
		private function init(){
			$this->update_delay=0;
			$this->interactive=FALSE;
			$this->verbose=FALSE;
			
			$this->nice=0;
			$this->debug=FALSE;
			$this->diagnostic_mode=FALSE;
			$this->quiet=FALSE;
			$this->logging=FALSE;
			$this->update=FALSE;
			$this->leave_trails=FALSE;
			$this->clean_trails=FALSE;
			$this->keep_original=FALSE;
			
			$this->titles_append_pubdate=FALSE;
			$this->titles_prefix_podcast_name=FALSE;
			$this->titles_reformat_numerical=FALSE;
			
			$this->playlist=FALSE;
			
			$this->player=NULL;
			$this->bad_chars=NULL;
		}/*$this->init();*/
		
		
		private function parse_argv(){
			foreach($_SERVER['argv'] as $index=>$argv_value){
				$option=preg_replace("/^[\-]{1,2}([^=]*)[=]?['\"]?([^'\"]*)['\"]?$/", "$1", $argv_value);
				$value=preg_replace("/^[\-]{1,2}([^=]*)[=]?['\"]?([^'\"]*)['\"]?$/", "$2", $argv_value);
				switch($option){
					case "verbose":
						if(!$this->verbose)
							$this->verbose=TRUE;
						break;
					
					case "debug":
						if(!$this->debug)
							$this->debug=TRUE;
						break;
					
					case "diagnosis":
					case "diagnostic":
						if(!$this->diagnostic_mode)
							$this->diagnostic_mode=TRUE;
						break;
					
					case "interactive":
						if(!$this->interactive)
							$this->interactive=TRUE;
						break;
					
					case "logging":
						if(!$this->logging)
							$this->logging=TRUE;
						break;
					
					case "quiet":
						if(!$this->quiet)
							$this->quiet=TRUE;
						break;
					
					case "leave-trails":
						if(!$this->leave_trails)
							$this->leave_trails=TRUE;
						break;
					
					case "clean-trails":
						if(!$this->clean_trails)
							$this->clean_trails=TRUE;
						break;
					
					case "titles-append-pubdate":
						if(!$this->titles_append_pubdate)
							$this->titles_append_pubdate=TRUE;
						break;
					
					case "titles-prefix-podcast-name":
						if(!$this->titles_prefix_podcast_name)
							$this->titles_prefix_podcast_name=TRUE;
						break;
					
					case "titles-reformat-numerical":
						if(!$this->titles_reformat_numerical)
							$this->titles_reformat_numerical=TRUE;
						break;
					
					case "keep-original":
						if(!$this->keep_original)
							$this->keep_original=TRUE;
						break;
					
					case "update":
						if($value)
							$this->update=$value;
						break;
					
					case "update-delay":
						if(!($value && preg_match("/^[0-9]+$/", $value)))
							$this->update_delay=10000000; /* 10 seconds */
						else
							$this->update_delay=$value*1000000;
						break;
					
					case "nice":
						if(!($value && preg_match("/^[0-9]+$/", $value))){
							$this->nice=5;
							break;
						}
						
						if($value <= 0)
							$this->nice=5;
						else
							$this->nice=$value;
						break;
					
					case "strip-characters":
						if($value)
							$this->bad_chars=$value;
						break;
					
					case "player":
						$this->player=sprintf("%s%s%s", $option, ($value ?"=" :""), $value);
						break;
					
					case "playlist":
						if(!($this->playlist=sprintf("%s%s%s", $option, ($value ?"=" :""), $value) ))
							$this->playlist=FALSE;
						break;
			
					/*
					
					case "":
						$this->=TRUE;
						break;
					*/
				}
			}
		}/*parse_argv();*/
		
		
		
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
			switch($this->playlist){
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
