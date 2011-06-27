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
		public $alacast;
		
		
		public $mode;
		public $priority;
		public $debug;
		public $diagnosis;
		public $quiet;
		public $logging;
		public $update;
		public $leave_trails;
		public $clean_trails;
		public $continuous;
		public $interactive;
		public $update_delay;
		public $verbose;
		public $keep_original;
		
		public $titles_append_pubdate;
		public $titles_prefix_podcast_name;
		public $titles_reformat_numerical;
		
		public $playlist;
		
		private $player;
		public $bad_chars;
		
		public function __construct(&$alacast){
			$this->alacast=&$alacast;
			
			$this->init();
			
			$this->parse();
			
			if($this->player)
				$this->set_characters_to_strip_from_titles();
			
			if($this->playlist)
				$this->set_playlist();
		}//__construct
		
		
		
		private function init(){
			$this->mode=NULL;
			
			$this->update_delay=0;
			$this->continuous=FALSE;
			$this->interactive=FALSE;
			$this->verbose=FALSE;
			
			$this->priority=0;
			$this->debug=FALSE;
			$this->diagnosis=FALSE;
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
		
		
		private function parse(){
			foreach($_SERVER['argv'] as $index=>$argv_value){
				$option=preg_replace("/^[\-]{1,2}([^=]*)[=]?['\"]?([^'\"]*)['\"]?$/", "$1", $argv_value);
				$value=preg_replace("/^[\-]{1,2}([^=]*)[=]?['\"]?([^'\"]*)['\"]?$/", "$2", $argv_value);
				switch($option){
					case "mode":
						$this->validate_mode($value);
						break;
					
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
						if(!$this->diagnosis)
							$this->diagnosis=TRUE;
						break;
					
					case "loop":
					case "delay":
					case "repeat":
					case "repetitive":
					case "update-delay":
					case "continuous":
						if(!($value && preg_match("/^[0-9]+$/", $value)))
							$this->update_delay=1000000; /* 10 seconds */
						else
							$this->update_delay=$value*1000000;
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
					
					case "nice":
					case "priority":
						if(!($value && preg_match("/^-?[1,2]?[0-9]$/", "{$value}") && $value < 20 && $value > -21)){
							$this->priority=5;
							break;
						}
						
						if($value <= 0)
							$this->priority=5;
						else
							$this->priority=$value;
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
			
			/*$this->alacast->output( sprintf("**notice:** mode: %s; interactive: %s; update_delay: %s.\n", $this->mode, ($this->interactive ?"TRUE" :"FALSE"), $this->update_delay) );*/
			
			if( (!$this->continuous) && ($this->interactive || $this->update_delay))
				$this->continuous=TRUE;
		}/*\alacast\options\parse();*/
		
		
		private function validate_mode($mode=NULL){
			switch($mode){
				case "diagnosis":
				case "diagnostic":
					$this->mode="update";
					if(!$this->diagnosis)
						$this->diagnosis=TRUE;
					break;
				
				case "sync":
				case "update":
				case "default":
					$this->mode="${mode}";
					break;
				
				case "":
				case FALSE:
					$this->mode=NULL;
					break;
				
				default:
					if($mode)
						$this->alacast->output("%s is an unsupported mode.  Valid modes are: 'default', 'update', and 'sync'.\n", "{$mode}", TRUE);
					$this->mode=NULL;
					break;
			}
		}/*$this->validate_mode($mode);*/
		
		
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
