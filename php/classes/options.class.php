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
		public $nice;
		public $debug;
		public $logging;
		public $update;
		public $bad_chars;
		public $leave_trails;
		public $clean_trails;
		
		
		public function __construct(&$alacast_config){
			$default_options_type="";
			if(
				(count($_SERVER['argv'])==1)
				||
				$default_options_type=\alacast_helper::preg_match_array($_SERVER['argv'], "/^\-\-with\-defaults[=]?(.*)/", "$1")
			)
				$this->load_options($alacast_config, $default_options_type);
			unset($default_options_type);
			
			$this->update=\alacast_helper::preg_match_array($_SERVER['argv'], "/^\-\-update[=]?(.*)$/", "$1");
			$this->nice=\alacast_helper::preg_match_array($_SERVER['argv'], "/^\-\-nice[=]?([0-9]*)/", "$1");
			
			if(\alacast_helper::preg_match_array($_SERVER['argv'], "/\-\-logging$/"))
				$this->logging=TRUE;
			else
				$this->logging=FALSE;
			
			if(\alacast_helper::preg_match_array($_SERVER['argv'], "/\-\-leave\-trails$/"))
				$this->leave_trails=TRUE;
			else
				$this->leave_trails=FALSE;
			
			if(\alacast_helper::preg_match_array($_SERVER['argv'], "/\-\-clean\-trails$/"))
				$this->clean_trails=TRUE;
			else
				$this->clean_trails=FALSE;
			
			if(\alacast_helper::preg_match_array($_SERVER['argv'], "/\-\-titles\-append\-pubdate$/"))
				$this->titles_append_pubdate=TRUE;
			else
				$this->titles_append_pubdate=FALSE;
			
			if(\alacast_helper::preg_match_array($_SERVER['argv'], "/\-\-titles\-prefix\-podcast\-name$/"))
				$this->titles_prefix_podcast_name=TRUE;
			else
				$this->titles_prefix_podcast_name=FALSE;
			
			if(\alacast_helper::preg_match_array($_SERVER['argv'], "/\-\-verbose$/"))
				$this->verbose=TRUE;
			else
				$this->verbose=FALSE;
			
			$this->get_characters_to_strip_from_titles();
			
			/*if(\alacast_helper::preg_match_array($_SERVER['argv'], "/\-\-$/"))
				$this->=TRUE;
			else
				$this->=FALSE;*/
			
		}//__construct
		
		
		
		private function get_characters_to_strip_from_titles(){
			if(!($this->bad_chars=alacast_helper::preg_match_array($_SERVER['argv'], "/^\-\-strip\-characters=['\"]?([^'\"]*)['\"]?$/", "$1"))) $this->bad_chars="";
			if(!(alacast_helper::preg_match_array($_SERVER['argv'], "/^\-\-player[=]?(.*)/") )) return (isset($this->bad_chars) ? $this->bad_chars : ($this->bad_chars=""));
			switch(($player=alacast_helper::preg_match_array($_SERVER['argv'], "/^\-\-player[=]?(.*)/", "$1"))){
				case "gstreamer":
					return ($this->bad_chars=sprintf("%s#", $this->bad_chars));
				case "vlc":
					return ($this->bad_chars=sprintf("%s:", $this->bad_chars));
				case "xine":
					return ($this->bad_chars=sprintf("%s;#", $this->bad_chars));
				case "":
					return ($this->bad_chars=sprintf("%s#:;", $this->bad_chars));
			}
			return (isset($this->bad_chars) ?$this->bad_chars :($this->bad_chars="") );
		}
		
		
		private function load_alacasts_default_options($alacast_config, $which_options="default"){
			if($options=(preg_replace( "/.*options.$which_options=\"([^\"]+)\".*/", "$1", $alacast_config )) ){
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
		
		
		
		private function load_options($alacast_config, $default_options_type){
			$options=NULL;
			if( ($options=getenv("ALACASTS_OPTIONS")) ){
				$_SERVER['argv']=array_merge(
					$_SERVER['argv'],
					preg_split(
						"/\ /", $options, -1,
						PREG_SPLIT_NO_EMPTY
					)
				);
				unset($options);
			}
			
			if( ($options=getenv("ALACAST_OPTIONS")) ){
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
		
		public function __destruct(){
			
		}//__destruct
		
	}
?>
