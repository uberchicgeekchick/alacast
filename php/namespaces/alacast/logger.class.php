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
	 * ---------------------------------------------------------------------------------
	 * |	A copy of the RPL 1.5 may be found with this project or online at	|
	 * |		http://opensource.org/licenses/rpl1.5.txt					|
	 * ---------------------------------------------------------------------------------
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
	namespace alacast;
	
	class logger {
		public $alacast;
		
		
		private $applications_title;
		
		private $enabled;
		private $silent;
		private $logs_path;
		
		private $year;
		private $month;
		private $day;
		
		private $current_hour;
		private $starting_hour;
		private $ending_hour;
		
		public $output_log_file;
		private $output_logs_fp;
		
		public $error_log_file;
		private $error_logs_fp;
		
		public function __construct(&$alacast, $logs_path=".", $applications_title="alacast", $enable=TRUE, $silent=FALSE) {
			$this->alacast=&$alacast;
			
			
			$this->applications_title=$applications_title;
			
			if(!$silent)
				$this->silent=FALSE;
			else
				$this->silent=TRUE;
			
			$this->output_log_file="";
			$this->error_log_file="";
			if(!( (is_dir( $logs_path))))
				$this->logs_path=".";
			else
				$this->logs_path=preg_replace("/\/$/", "", $logs_path);
			
			if(!$enable)
				return $this->disable();
			
			$this->enabled=TRUE;
			$this->init();
		}//method: public function __construct();
		
		private function disable() {
			$this->enabled=FALSE;
			
			$this->year=null;
			$this->month=null;
			$this->day=null;
			
			$this->current_hour=date("H");
			$this->starting_hour=null;
			
			$this->output_logs_fp=null;
		}//method: private function disable();
		
		private function init() {
			$this->year=date("Y");
			$this->month=date("m");
			$this->day=date("d");
			
			$this->current_hour=date("H");
			
			$this->starting_hour=$this->current_hour - ($this->current_hour % 6);
			$this->ending_hour=$this->starting_hour + 5;
		}//method: private function init();
		
		private function check($error=FALSE){
			$logs_fp=NULL;
			$log_file=NULL;
			if(!$error){
				$logs_fp=$this->output_logs_fp;
				$log_file=$this->output_log_file;
			}else{
				$logs_fp=$this->error_logs_fp;
				$log_file=$this->error_log_file;
			}
			if(!(
				(
					$log_file
					&&
					file_exists($log_file)
					&&
					$logs_fp
				)
				&&
				($this->current_hour=date( "H")) <= $this->ending_hour
				&&
				$this->current_hour > $this->starting_hour
			))
				return TRUE;
			
			return FALSE;
		}//method:private function check();
		
		private function rotate($error=FALSE){
			if(!($this->check($error)))
				return FALSE;
			
			$logs_fp=NULL;
			if(!$error)
				$logs_fp=$this->output_logs_fp;
			else
				$logs_fp=$this->error_logs_fp;
			
			if($logs_fp){
				fclose($logs_fp);
				$logs_fp=NULL;
			}
			
			$this->init();
			
			$log_file=sprintf("%s/%s's log for %s-%s-%s from %s%s:00 through %s%s:59.%s.log", $this->logs_path, $this->applications_title, $this->year, $this->month, $this->day, (($this->starting_hour<10) ?"0" :""), $this->starting_hour, (($this->ending_hour<10) ?"0" :""), $this->ending_hour, ($error ?"error" :"output"));
			if(!($logs_fp=fopen( $log_file, "a" ))){
				fprintf(STDERR, "I was unable to open the %s log file:\n\t\<%s>\n\t\tor for writing.\nLogging will be disabled.\n", ($error ?"error" :"output"), $log_file);
				$this->disable();
				return FALSE;
			}
			
			if(!$error){
				$this->output_logs_fp=$logs_fp;
				$this->output_log_file=$log_file;
			}else{
				$this->error_logs_fp=$logs_fp;
				$this->error_log_file=$log_file;
			}
			
			return TRUE;
		}/*$this->rotate();*/
		
		private function log_output(&$string, $error=FALSE){
			if(!$this->enabled)
				return FALSE;
			
			$this->rotate($error);
			
			if(!$error)
				fprintf($this->output_logs_fp, "%s", $string);
			else
				fprintf($this->error_logs_fp, "**%s error:** %s", $this->applications_title, $string);
			
			return TRUE;
		}//method: private function log_output();
		
		public function output($string, $wordwrap=FALSE, $error=FALSE, $silent=FALSE){
			if(!($string && "{$string}" != "" && preg_replace( "/^[\s\r\n\ \t]*(.*)[\s\r\n\ \t]*/", "$1", $string) != "")) return;
			
			if($this->enabled)
				$this->log_output($string, $error);
			
			if( $silent || $this->silent)
				return FALSE;
			
			if( $wordwrap ) {
				if( ($word_wrap_padding=preg_replace("/^\n*(\n\t*).*$/", "$1", $string)) != "$string" )
					$word_wrap_padding="{$word_wrap_padding}\t";
				else
					unset($word_wrap_padding);
			}
			
			if($error === TRUE){
				if( $wordwrap && isset($word_wrap_padding) )
					return fprintf(STDERR, "**%s error:** %s", $this->applications_title, wordwrap($string, 75, $word_wrap_padding, TRUE));
				else
					return fprintf(STDERR, "**%s error:** %s", $this->applications_title, $string);
			}
			
			if( $wordwrap && isset($word_wrap_padding) )
				return fprintf(STDOUT, "%s", wordwrap($string, 75, $word_wrap_padding, TRUE));
			else
				return fprintf(STDOUT, "%s", $string);
		}//method:public function output("mixed $value string", $error=FALSE);
		
		private function close_log() {
			if($this->output_logs_fp)
				fclose($this->output_logs_fp);
			if($this->error_logs_fp)
				fclose($this->error_logs_fp);
		}//method:private function close_log();
		
		public function __destruct() {
			$this->close_log();
		}//method: public function __destruct();
	}//namespace: uberChicGeekChick; class: helper

?>
