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
	
	class playlist{
		private $enabled;
		
		private $path;
		private $prefix;
		private $playlist;
		private $type;
		private $append_pubdate;
		
		private $fp;
		private $created_dirs;
		
		private $total;
		
		public function __construct($path=".", $prefix="alacast", $type="m3u", $append_pubdate=FALSE){
			$this->prefix=$prefix;
			$this->path=$path;
			
			$this->append_pubdate=$append_pubdate;
			
			$this->total=0;
			$this->created_dirs=array( 'total'=>0 );
			$this->fp=NULL;

			$this->type=$type;
			if(!$this->validate())
				return FALSE;
			
			return TRUE;
		}/*__construct();*/
		
		
		private function validate(){
			switch($this->type){
				case FALSE;
					$this->type=NULL;
					$this->extension=NULL;
					$this->playlist=NULL;
					return ($this->enabled=FALSE);
				
				case "toxine":
				case "tox":
					$this->type="toxine";
					$this->extension="tox";
					break;
				
				case "pls":
					$this->type="pls";
					$this->extension="pls";
					break;
				
				case "m3u":
				default:
					if($this->type!="m3u")
						$GLOBALS['alacast']->logger->output(
							"{$this->type} is an unsupported playlist format.\nA m3u playlist will be used instead.",
							TRUE
						);
					$this->type="m3u";
					$this->extension="m3u";
					break;
			}
			$this->playlist=sprintf("%s/%s's %s playlist from: %s.%s", $this->path, $this->prefix, $this->type, date("Y:m:d @ H:i:s"), $this->extension);
			return ($this->enabled=TRUE);
		}/*$this->validate();*/

		public function add_file(&$filename){
			if(!$this->enabled)
				return FALSE;
			
			if(!($filename && file_exists($filename))){
				$GLOBALS['alacast']->logger->output("**error:** adding: <file://{$filename}> to playlist: <file://{$this->playlist}>\t[failed]\n\n\t<file://{$filename}> does not exists.\n", TRUE);
				return FALSE;
			}
			
			$this->create_path();
			
			if(!($this->playlist && file_exists($this->playlist) && $this->fp)){
				if(!$this->playlist){
					if(!$this->validate()){
						$this->clean_up_created_path();
						return ($this->enabled=FALSE);
					}
				}
				
				if(!($this->fp=fopen($this->playlist, "a"))){
					$this->clean_up_created_path();
					return ($this->enabled=FALSE);
				}
				
				if($this->total)
					$this->total=0;
			}
			
			$title=preg_replace("/^(.*\/)(.*)".($this->append_pubdate ?"(, released on[^.]+)" :"")."(\.[^.]+)$/", "$2", $filename);
			
			$this->total++;
			switch($this->type){
				case "toxine":
				case "tox":
					while(preg_match("/;/", $title))
						$title=preg_replace("/;/", "", $title);
					
					if($this->total==1)
						fprintf($this->fp, "#toxine playlist\n\n");
					
					fprintf($this->fp, "entry {\n\tidentifier = %s;\n\tmrl = %s;\n\tav_offset = 3600;\n};\n\n", $title, $filename);
					break;
				
				case "pls":
					while(preg_match("/=/", $title))
						$title=preg_replace("/=/", "", $title);
					
					fprintf($this->fp, "File%d=%s\nTitle%d=%s\n", $this->total, $filename, $this->total, $title);
					break;
				
				case "m3u":
					while(preg_match("/:/", $title))
						$title=preg_replace("/:/", "", $title);
					
					if($this->total==1)
						fprintf($this->fp, "#EXTM3U\n");
					
					fprintf($this->fp, "#EXTINF:,%s\n%s\n", $title, $filename);
					break;
			}
			unset($title);
			return TRUE;
		}/*add_file($podcasts_new_file);*/
		
		
		
		private function create_path(){
			if(is_dir($this->path))
				return;
			
			$dir=$this->path;
			while(!is_dir($dir) && $dir!="/"){
				$this->created_dirs[++$this->created_dirs['total']]=$dir;
				$dir=dirname($dir);
			}
			$dir=$this->created_dirs[$this->created_dirs['total']];
			$subdir_count=$this->created_dirs['total'];
			while($subdir_count){
				if(!is_dir($this->created_dirs[$subdir_count]))
					mkdir($this->created_dirs[$subdir_count--], 0744);
			}
		}/*$this->create_path();*/
		
		
		
		private function clean_up_created_path(){
			if(!$this->created_dirs['total'])
				return;
			
			$dir=$this->path;
			while($this->created_dirs['total'])
				rmdir($this->created_dirs[$this->created_dirs['total']--]);
		}/*$this->clean_up_create_path();*/
		
		
		
		public function __destruct(){
			if(!( $this->enabled && $this->total && $this->playlist && file_exists($this->playlist) && $this->fp)){
				$this->clean_up_created_path();
				return;
			}
			
			switch($this->type){
				case "toxine":
				case "tox":
					fprintf($this->fp, "#END\n");
					break;
				
				case "pls":
					fprintf($this->fp, "Version=2\n");
					
					fseek($this->fp, 0);
					fprintf($this->fp, "[playlist]\nnumberofentries=%d\n", $this->total);
					break;
			}
			
			if($this->fp)
				fclose($this->fp);
		}/*__destruct();*/
		
	}
?>
