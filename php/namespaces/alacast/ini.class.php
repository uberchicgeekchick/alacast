<?php
	namespace alacast;
	
	class ini{
		public $path;
		public $profiles_path;
		
		private $ini;
		private $helper_config;

		public $media_dir;
		
		public $download_dir;
		public $save_to_dir;
		
		public $playlist;
		public $playlist_dir;
		
		
		public function __construct($path){
			$this->init();
			$this->path=$path;
			$this->load();
		}/*new \alacast\ini();*/
		
		private function init(){
			$this->path=NULL;
			$this->profiles_path=NULL;
			
			$this->ini=NULL;
			$this->helper_config=NULL;
			
			$this->media_dir=NULL;
			
			$this->download_dir=NULL;
			$this->save_to_dir=NULL;
			
			$this->playlist=NULL;
			$this->playlist_dir=NULL;
		}/*init();*/
		
		private function load(){
			$HOME=getenv("HOME");
			$USER=getenv("USER");
			if(file_exists("{$HOME}/.alacast/alacast.ini"))
				$this->ini=($this->profiles_path="{$HOME}/.alacast")."/alacast.ini";
			else if(file_exists("{$HOME}/.alacast/profiles/{$USER}")."/alacast.ini")
				$this->ini=($this->profiles_path="{$HOME}/.alacast/profiles/{$USER}")."/alacast.ini";
			else if(file_exists("{$this->path}/data/profiles/{$USER}")."/alacast.ini")
				$this->ini=($this->profiles_path="{$this->path}/data/profiles/${USER}")."/alacast.ini";
			else if(file_exists("{$this->path}/data/profiles/default")."/alacast.ini")
				$this->ini=($this->profiles_path="{$this->path}/data/profiles/default")."/alacast.ini";
			
			if(!( $this->ini && file_exists("{$this->ini}") && $alacast_config_fp=fopen( $this->ini, "r")))
				return $this->error(sprintf("%s is not readable", $this->ini));//exit(-1);
			
			if(!file_exists( ($this->helper_config="{$HOME}/.config/gpodder/gpodder.conf") )){
				if(!is_dir(dirname($this->helper_config)))
					mkdir(dirname($this->helper_config), 0644, TRUE);
				touch($this->helper_config);
				if(!($hc_fp=fopen($this->helper_config, "w+")))
					return $this->error(sprintf("%s could not be created", $this->helper_config));//exit(-1);
				fprintf($hc_fp, "[gpodder-conf-1]\nmp3_player_folder = %s\ndownload_dir = %s\n", $this->save_to_dir, $this->download_dir);
				
				fclose($this->helper_config);
			}
			
			$alacast_config=NULL;
			$alacast_config=preg_replace("/[\r\n]+/m", "\t", preg_replace("/^;.*$/m", "", fread( $alacast_config_fp, (filesize($this->ini)))));
			fclose($alacast_config_fp);
			
			$mode="";
			if(
				(count($_SERVER['argv'])<2)
				||
				$mode=helper::preg_match_array($_SERVER['argv'], "/^\-\-(with\-defaults|mode)[=]?(.*)/", "$2")
			){
				if(!$this->load_options($alacast_config, $mode)){
					$this->error("I couldn't load either alacast's ".($mode ? $mode :"default")." settings.\n");
					unset($mode);
					unset($alacast_config);
					return FALSE;
				}
			}
			unset($mode);
			
			if(!$this->find_paths($alacast_config)){
				$this->error("I couldn't load either alacast's:\n\t\t'download_dir': <".$this->download_dir.">, 'save_to_dir': <".$this->save_to_dir.">, or 'playlist_dir: <".$this->playlist_dir.">.\n");
				unset($alacast_config);
				return FALSE;
			}
			
			chdir(dirname( $this->download_dir));
			
			unset($alacast_config);
			unset($HOME);
			unset($USER);
			return TRUE;
		}/*\alacast\ini\load();*/
		
		
		
		private function find_paths(&$alacast_config){
			$this->media_dir=preg_replace("/.*media_dir=\"([^\"]+)\".*/", "$1", $alacast_config);
			if(!$this->escape_dir($this->media_dir))
				return FALSE;
			
			$this->save_to_dir=preg_replace("/.*save_to_dir=\"([^\"]+)\".*/", "$1", $alacast_config);
			if(!$this->escape_dir($this->save_to_dir))
				return FALSE;
			
			$this->download_dir=preg_replace("/.*download_dir=\"([^\"]+)\".*/", "$1", $alacast_config);
			if(!$this->escape_dir($this->download_dir))
				return FALSE;
			
			if(!($this->set_playlist($alacast_config, helper::preg_match_array($_SERVER['argv'], "/^\-\-playlist[=]?(.*)/", "$1")) ))
				return FALSE;
			return TRUE;
		}/*$this->find_paths($alacast_config);*/
			
		private function set_playlist(&$alacast_config, $playlist){
			$this->playlist_dir=preg_replace("/.*playlist_dir=\"([^\"]+)\".*/", "$1", $alacast_config);
			if(!$this->escape_dir($this->playlist_dir, FALSE))
				return FALSE;
			
			$this->playlist=$playlist;
			switch($this->playlist){
				case "tox":
					$this->playlist="toxine";
				case "m3u":
				case "pls":
					$playlist_dir=preg_replace("/.*playlist_dir:{$this->playlist}=\"([^\"]+)\".*/", "$1", $alacast_config);
					break;
			}
			if(!$this->escape_dir($playlist_dir, FALSE))
				return FALSE;
			
			$this->playlist_dir=$playlist_dir;
			
			return TRUE;
		}/*$this->set_playlist($alacast_config);*/
		
		
		private function escape_dir(&$directory, $dir_test=TRUE){
			static $escape_sequences;
			
			if(!isset($escape_sequences))
				$escape_sequences=array("media_dir", "playlist_dir", 'total'=>2);
			
			for($i=0; $i<$escape_sequences['total']; $i++){
				if(!preg_match("/\{".$escape_sequences[$i]."\}/", $directory))
					continue;

				$replace_with=NULL;
				switch($escape_sequences[$i]){
					case "media_dir":
						if(!$this->media_dir)
							break;
						$replace_with=$this->media_dir;
						break;
					
					case "playlist_dir":
						if(!$this->playlist_dir)
							break;
						$replace_with=$this->playlist_dir;
						break;
				}
				
				if(!$replace_with)
					continue;
				
				$directory=preg_replace("/\{".$escape_sequences[$i]."\}/", $replace_with, $directory);
				$i=0;
			}
			unset($replace_with);
			
			if(!preg_match("/^\//", $directory))
				$directory=sprintf("/%s", $directory);

			if(!$dir_test)
				return TRUE;
			
			if(!($directory && is_dir($directory)))
				return FALSE;
			
			return TRUE;
		}/*$this->escape_dir*/
		
		
		
		private function load_mode_parameters(&$alacast_config, $mode="default"){
			if(!($settings=(preg_replace( "/.*(options|mode).$mode=\"([^\"]+)\".*/", "$2", $alacast_config))))
				return FALSE;
			
			$_SERVER['argv']=array_merge(
				$_SERVER['argv'],
				preg_split(
					"/\ /", $settings, -1,
					PREG_SPLIT_NO_EMPTY
				)
			);
			unset($settings);
			return TRUE;
		}/*load_mode_parameters($alacast_config, "defaults|update|sync");*/
		
		
		
		private function load_options(&$alacast_config, $mode="default"){
			switch($mode){
				case "update":
				case "sync":
					if(!$this->load_mode_parameters($alacast_config, $mode))
						return FALSE;
					if(!(helper::preg_match_array($_SERVER['argv'], "/^\-\-with\-defaults$/")))
						return TRUE;
				break;
			}
			return $this->load_mode_parameters($alacast_config);
		}/*load_options($alacast_config, $mode);*/
		
		
		
		private function error($details="") {
			print(
				"I couldn't load alacast's settings from: '"
				.$this->ini
				.( $details
					? "\n\tDetails: {$details}"
					: ""
				)
				."\n\tSo, well yeah, I'm outta here.\n"
			);
			exit(-1);
		}//end:function error("something\'s gone wrong.");
		
	}/*\alacast\ini();*/
?>
