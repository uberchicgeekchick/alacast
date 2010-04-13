<?php
	namespace alacast;
	
	class ini{
		public	$path;
		public	$profiles_path;
		private	$ini;
		
		public	$download_dir;
		public	$save_to_dir;
		public	$playlist;
		public	$playlist_dir;
		
		
		public function __construct($path){
			$this->init();
			$this->path=$path;
			$this->load();
		}/*new \alacast\ini();*/
		
		private function init(){
			$this->path=NULL;
			$this->profiles_path=NULL;
			$this->ini=NULL;
			
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
			
			if(!( $this->ini && $alacast_config_fp=fopen( $this->ini, "r")))
				return $this->error(sprintf("%s is not readable", $this->ini));//exit(-1);
			
			if(!file_exists("{$HOME}/.config/gpodder/gpodder.conf")){
				if(!is_dir("{$HOME}/.config/gpodder"))
					mkdir("{$HOME}/.config/gpodder", 0644, TRUE);
				
				copy($this->ini, "{$HOME}/.config/gpodder/gpodder.conf");
			}
			unset($HOME);
			unset($USER);
			
			$alacast_config=NULL;
			$alacast_config=preg_replace("/[\r\n]+/m", "\t", preg_replace("/^;.*$/m", "", fread( $alacast_config_fp, (filesize($this->ini)))));
			fclose($alacast_config_fp);
			
			$default_options_type="";
			if(
				(count($_SERVER['argv'])==1)
				||
				$default_options_type=helper::preg_match_array($_SERVER['argv'], "/^\-\-with\-defaults[=]?(.*)/", "$1")
			)
				$this->load_options($alacast_config, $default_options_type);
			unset($default_options_type);
			
			if(!$this->find_paths($alacast_config)){
				$this->error("I couldn't load either alacast's:\n\t\t'download_dir': <".$this->download_dir.">, 'save_to_dir': <".$this->save_to_dir.">, or 'playlist_dir: <".$this->playlist_dir.">.\n");
				unset($this->ini);
				unset($alacast_config);
				return FALSE;
			}
			
			if(!(
				$this->save_to_dir
				&&
				is_dir($this->save_to_dir)
				&&
				$this->download_dir
				&&
				is_dir($this->download_dir)
				&&
				$this->playlist_dir
			)){
				$this->error("I couldn't load either alacast's:\n\t\t'download_dir': <".$this->download_dir.">, 'save_to_dir': <".$this->save_to_dir.">, or 'playlist_dir: <".$this->playlist_dir.">.\n");
				unset($this->ini);
				unset($alacast_config);
				return FALSE;
			}
			
			chdir(dirname( $this->download_dir));
			
			unset($this->ini);
			unset($alacast_config);
			return TRUE;
		}/*\alacast\ini\load();*/
		
		
		
		private function find_paths(&$alacast_config){
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
			
			if(!($this->set_playlist($alacast_config, helper::preg_match_array($_SERVER['argv'], "/^\-\-playlist[=]?(.*)/", "$1")) ))
				return FALSE;
			return TRUE;
		}/*$this->find_paths($alacast_config);*/
			
		private function set_playlist(&$alacast_config, $playlist){
			$playlist_dir=preg_replace("/.*playlist_dir=\"([^\"]+)\".*/", "$1", $alacast_config);
			
			$this->playlist=$playlist;
			$playlist_type=$playlist;
			switch($this->playlist){
				case "tox":
					$playlist_type="toxine";
				case "m3u":
				case "pls":
					$this_playlist_dir=preg_replace("/.*playlist_dir:{$playlist_type}=\"([^\"]+)\".*/", "$1", $alacast_config);
					if(preg_match("/\{playlist_dir\}/", $this_playlist_dir))
						$this_playlist_dir=preg_replace("/\{playlist_dir\}/", "{$playlist_dir}", $this_playlist_dir);
					
					$this->playlist_dir=$this_playlist_dir;
					unset($this_playlist_dir);
					break;
				
				default:
					$this->playlist_dir=$playlist_dir;
					break;
			}
			if(!preg_match("/^\//", $this->playlist_dir))
				$this->playlist_dir=sprintf("/%s", $this->playlist_dir);
			unset($playlist_type);
			unset($playlist_dir);
			return TRUE;
		}/*$this->set_playlist($alacast_config);*/
		
		
		
		private function load_default_options(&$alacast_config, $which_options="default"){
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
		}/*load_default_options($alacast_config, "defaults|update|sync");*/
		
		
		
		private function load_options(&$alacast_config, $default_options_type){
			switch($default_options_type){
				case "update":
				case "sync":
					$this->load_default_options($alacast_config, $default_options_type);
			
					if(!(helper::preg_match_array($_SERVER['argv'], "/^\-\-with\-defaults$/")))
						break;
				
				default:
					$this->load_default_options($alacast_config);
					break;
			}
		}/*load_options($alacast_config, $default_options_type);*/
		
		
		
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
			return FALSE;
		}//end:function error("something\'s gone wrong.");
		
	}/*\alacast\ini();*/
?>
