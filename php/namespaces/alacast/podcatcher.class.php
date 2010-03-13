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
	
	class update{
		public	$detailed;
		public	$nice;
		public	$debug;
		
		
		public function __construct( $update_type, $nice, $debug ){
			if(!preg_match("/^[0-9]+$/", $nice))
				$this->nice=5;
			else
				$this->nice=$nice;
			
			if($debug!=TRUE)
				$this->debug=FALSE;
			else
				$this->debug=TRUE;
			
			if($update_type!="detailed")
				$this->detailed=FALSE;
			else
				$this->detailed=TRUE;
		}/*new \alacast\podcatcher\update();*/
	}/*\alacasts\podcatcher\update*/
	
	class podcatcher {
		private $starting_dir;
		private $working_dir;
		
		private $profiles_path;
		
		private	$command;
		private	$podcatcher_path;
		private	$podcatcher;
		
		private	$update;
		
		public $status;
		
		public function __construct( $alacasts_path, $profiles_path, $update_type, $nice, $debug ) {
			$this->profiles_path=$profiles_path;
			$this->starting_dir = exec( "pwd" );
			$this->working_dir = dirname( $_SERVER['argv'][0] );
			
			$this->podcatcher_path=NULL;
			$this->podcatcher=NULL;
			
			$this->status="waiting";
			
			$this->update=new update( $update_type, $nice, $debug );
			
			$this->command=$this->set_podcatcher($alacasts_path);
		}//method:public function __construct( ALACASTS_PATH, 1-20, $profiles_path = "~/.config/gpodder/gpodder.conf" );

		
		
		private function set_podcatcher(&$alacasts_path){
			$this->podcatcher_path=sprintf("%s/helpers/gpodder-0.11.3-hacked/bin", $alacasts_path);
			$this->podcatcher=sprintf("%s/gpodder-0.11.3-hacked", $this->podcatcher_path);
			if(!(
				(
					(is_executable( ($this->podcatcher)))
					&&
					(chdir( (dirname( $this->podcatcher))))
				)
			)){
				$this->podcatcher=NULL;
				return $GLOBALS['alacast']->logger->output("I can't try to download any new podcasts because I can't find alacast.", TRUE);
			}
			
			$this->podcatcher="./".(basename($this->podcatcher))." --local";
			
			if($this->update->nice){
				if($this->update->nice > 0)
					$this->podcatcher="nice --adjustment={$this->update->nice} {$this->podcatcher}";
				else
					$this->podcatcher="nice --adjustment=5 {$this->podcatcher}";
			}
			
			$this->podcatcher="unset http_proxy; {$this->podcatcher}";
		}/*$this->set_podcatcher();*/
		
		
		
		public function download(&$error_log_file){
			$this->set_status( TRUE, TRUE );
			
			if(!$this->update->debug)
				$error_output=" 2> /dev/stderr";
			else{
				$GLOBALS['alacast']->logger->output("Running Podcatcher backend in debug mode.", TRUE);
				$error_output=" 2>> \"{$error_log_file}\"";
			}
			
			$lastLine="";
			/*if($GLOBALS['alacast']->podcatcher->update->update){
				$alacast_Output=array();
				$lastLine=exec("{$this->podcatcher} --run > /dev/tty{$error_output}", $alacast_Output);
				
				if($this->update->detailed)
					$GLOBALS['alacast']->logger->output((helper::array_to_string( $alacast_Output, "\n")), "", TRUE);
				
				if((preg_match("/^D/", (ltrim($lastLine)))))
					log_alacast_downloadss($alacast_Output);
			}else*/
			
			if(!$this->update->detailed)
				$lastLine=exec("{$this->podcatcher} --run > /dev/null{$error_output}");
			else
				$lastLine=system("{$this->podcatcher} --run > /dev/tty{$error_output}");
			
			$this->set_status( TRUE, FALSE );
			
			if(!( (preg_match("/^D/", (ltrim($lastLine))))))
				return FALSE;
			
			/*
			 * alacast 0.10.0 need a lot longer than 5 seconds.
			 * So I've moved it to 31 seconds just to be okay.
			 */
			$GLOBALS['alacast']->logger->output("\nPlease wait while alacast finishes downloading your podcasts new episodes");
			for($i=0; $i<33; $i++) {
				if(!($i%3))
					print(".");
				
				usleep(500000); // waits for one half second.
			}
			print("\n");
			
			return TRUE;
		}/*\alacast\podcatcher\download();*/
			
		
		public function set_status( $downloading, $starting ) {
			if(!$starting){
				if(file_exists("{$this->profiles_path}/.status.{$this->status}") && is_writable("{$this->profiles_path}/.status.{$this->status}") )
					unlink("{$this->profiles_path}/.status.{$this->status}");
			}else{
				if(file_exists("{$this->profiles_path}/.status.{$this->status}") && is_writable("{$this->profiles_path}/.status.{$this->status}") ){
					$GLOBALS['alacast']->logger->output("Another process appears to be {$this->status} podcasts already\nPlease wait a moment.\n");
				}else{
					if(!$downloading)
						$this->status = "syncronizing";
					else
						$this->status = "downloading";
					touch("{$this->profiles_path}/.status.{$this->status}");
				}
			}
			
			$GLOBALS['alacast']->logger->output(
				sprintf(
					"\n~*~*~* I've %s %s new podcasts @ %s *~*~*~\n",
					( $starting
						?"started"
						:"finished"
					),
					$this->status,
					date( "c" )
				)
			);
			if(!$starting)
				$this->status="waiting";
		}//method:public function set_status( $action = "running", $finished = false );
		
		public function destruct() {
			chdir( $this->starting_dir );
		}//method:public function destruct();
	}//namespace: uberChicGeekChicks::gPodder; class: exec.
?>
