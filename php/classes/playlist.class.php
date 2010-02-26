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
	
	class alacasts_playlist{
		private $enabled;
		
		private $path;
		private $created_dirs;
		private $prefix;
		private $playlist;
		private $type;
		
		private $fp;
		
		private $total;
		
		public function __construct($path=".", $prefix="uberChick's progam", $type="m3u"){
			$this->enabled=TRUE;
			$this->path=$path;
			$this->prefix=$prefix;
			$this->total=0;
			$this->created_dirs=array( 'total'=>0 );
			$this->fp=NULL;
			
			switch($type){
				case FALSE;
					$this->enabled=FALSE;
					break;
				case "toxine":
				case "tox":
					$this->type=$type;
					$this->extension="tox";
					break;
				
				case "pls":
					$this->type=$type;
					$this->extension=$type;
					break;
				
				case "m3u":
				default:
					if($type!="m3u")
						printf("%s is an unsupported playlist format.\nA m3u playlist will be used instead.", $type);
					$this->type="m3u";
					$this->extension="m3u";
					break;
			}
			
			$this->playlist=sprintf("%s/%s's playlist from: %s.%s", $this->path, $this->prefix, preg_replace("/(.*)\ [\+\-][0]{4}/", "$1", gmdate('r')), $this->extension);
		}/*__construct();*/

		public function add_file(&$filename){
			if(!$this->enabled)
				return FALSE;
			
			if(!($filename && file_exists($filename))){
				fprintf(STDERR, "**error**: adding file to playlist: it does not appear to exist.\n\tfilename: <%s>\n\tplaylist: <%s>\n", $filename, $this->playlist);
				return FALSE;
			}
			
			$this->create_path();
			
			if(!$this->fp)
				if(!($this->fp=fopen($this->playlist, "a"))){
					return ($this->enabled=FALSE);
				}
			
			switch($this->type){
				case "toxine":
				case "tox":
					if(!$this->total)
						fprintf($this->fp, "# toxine playlist\n");
					fprintf($this->fp, "\nentry {\n\tidentifier = %s;\n\tmrl = %s;\n};", basename($filename), $filename);
					break;

				case "pls":
					fprintf($this->fp, "File%d=%s\nTitle%d=%s\n", $this->total, $filename, $this->total, basename($filename));
					break;
				
				case "m3u":
					fprintf($this->fp, "%s\n", $filename);
					break;
			}
			$this->total++;
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
			if(!($this->enabled &&$this->total)){
				$this->clean_up_created_path();
				return;
			}
			
			switch($this->type){
				case "toxine":
				case "tox":
					fprintf($this->fp, "\n#END");
					break;
				
				case "pls":
					fprintf($this->fp, "Version=2");
					fseek($this->fp, 0);
					if($this->total)
						fprintf($this->fp, "[playlist]\nnumberofentries=%d\n", $this->total);
					break;
			}
			
			if($this->fp)
				fclose($this->fp);
		}/*__destruct();*/
		
	}
?>
