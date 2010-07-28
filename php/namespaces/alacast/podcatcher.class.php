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
		public	$priority;
		public	$debug;
		
		
		public function __construct( $update_type, $priority, $debug ){
			if(!preg_match("/^[0-9]+$/", $priority))
				$this->priority=5;
			else
				$this->priority=$priority;
			
			if($debug!=TRUE)
				$this->debug=FALSE;
			else
				$this->debug=TRUE;
			
			if($update_type!="detailed")
				$this->detailed=FALSE;
			else
				$this->detailed=TRUE;
		}/*new \alacast\update();*/
	}/*\alacasts\update*/
	
	class podcatcher {
		private $alacast;
		
		
		private $starting_dir;
		private $working_dir;
		
		private $profiles_path;
		
		private	$path;
		private	$script;
		private	$command_line;
		
		private	$update;
		
		public $status;
		
		public function __construct(&$alacast, $alacasts_path, $profiles_path, $update_type, $priority, $debug){
			$this->alacast=&$alacast;
			
			
			$this->profiles_path=$profiles_path;
			$this->starting_dir=exec( "pwd" );
			chdir( dirname( $_SERVER['argv'][0] ) );
			$this->working_dir=exec( "pwd" );
			chdir( $this->starting_dir );
			
			$this->path=NULL;
			$this->script=NULL;
			
			$this->status="waiting";
			
			$this->update=new update($update_type, $priority, $debug);
			
			$this->prepare_command_line($alacasts_path);
		}//method:public function __construct( ALACASTS_PATH, 1-20, $profiles_path="~/.config/gpodder/gpodder.conf" );

		
		
		private function prepare_command_line(&$alacasts_path){
			$this->path=sprintf("%s/helpers/gpodder-0.11.3-hacked/bin", $alacasts_path);
			$this->script="gpodder-0.11.3-hacked";
			
			if(!(
				(chdir($this->path))
				&&
				is_executable("./{$this->script}")
			)){
				$this->script=NULL;
				return $this->alacast->output("\n\tI can't try to download any new podcasts because I can't find alacast.\n", TRUE);
			}
			
			if(!$this->alacast->ini->proxy)
				$this->command_line="if [ \"\$http_proxy\" == \"\" ]; then unset http_proxy; fi;";
			else
				$this->command_line="export http_proxy=\"{$this->alacast->ini->proxy}\";";
			
			$this->command_line.=" cd \"{$this->path}\"; ";
			if($this->update->priority && $this->update->priority < 20 && $this->update->priority > -21){
				if($this->update->priority < 0)
					$this->command_line.="sudo ";
				
				$this->command_line.="nice --adjustment={$this->update->priority} ";
			}
			
			$this->command_line.="./{$this->script} --local --run";
			
			
			if(!$this->update->detailed)
				$this->command_line.=" > /dev/null";
			else
				$this->command_line.=" > /dev/tty";
			
			if(!$this->update->debug)
				$this->command_line.=" 2> /dev/null";
			else
				$this->command_line.=" 2> /dev/stderr";
		}/*$this->prepare_command_line();*/
		
		
		
		public function download(&$error_log_file){
			$this->set_status( TRUE, TRUE );
			
			if($this->update->debug)
				$this->alacast->output("\n\tRunning:\n\t\t\`{$this->command_line}\`\n");
			
			$lastLine="";
			if(!$this->update->detailed)
				$lastLine=exec($this->command_line);
			else
				$lastLine=system($this->command_line);
			
			/*if($this->update->detailed){
				$alacast_Output=array();
				$lastLine=exec("{$this->command}", $alacast_Output);
				
				if($this->update->detailed)
					$this->alacast->output((helper::array_to_string( $alacast_Output, "\n\t")), "", TRUE);
				
				if((preg_match("/^D/", (ltrim($lastLine)))))
					log_alacast_downloadss($alacast_Output);
			}*/
			
			$this->set_status( TRUE, FALSE );
			
			if(!( (preg_match("/^D/", (ltrim($lastLine)))))){
				unset($lastline);
				return FALSE;
			}
			unset($lastline);
			
			/*
			 * alacast 0.10.0 need a lot longer than 5 seconds.
			 * So I've moved it to 31 seconds just to be okay.
			 */
			$this->alacast->output("\n\tPlease wait while alacast finishes downloading your podcasts new episodes.\n");
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
					$this->alacast->output("\n\tAnother process appears to be {$this->status} podcasts already\nPlease wait a moment.\n");
				}else{
					if(!$downloading)
						$this->status="syncronizing";
					else
						$this->status="downloading ";
					touch("{$this->profiles_path}/.status.{$this->status}");
				}
			}
			
			$this->alacast->output(
				sprintf(
					"\n~*~*~* I've %s %s new podcasts @ %s *~*~*~\n",
					( $starting
						?" started"
						:"finished"
					),
					$this->status,
					date( "c" )
				)
			);
			
			if(!$starting)
				$this->status="waiting";
		}//method:public function set_status( $action="running", $finished=false );
		
		public function destruct() {
			chdir( $this->starting_dir );
		}//method:public function destruct();
	}//namespace: uberChicGeekChicks::gPodder; class: exec.
?>
