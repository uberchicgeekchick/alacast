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
	
	class titles{
		public $regular_expression;
		
		public function __construct(){
			$this->regular_expression=NULL;
			/*$this->load_renumbering_regexp();*/
		}//__construct
		
		
		
		private function load_renumbering_regexp(){
			if(!$this->regular_expression)
				$this->regular_expression=require_once(ALACASTS_PATH."/php/settings/reordering.inc.php");
		}//load_renumbering_regular_expressions
		

		
		public function reorder_titles(&$podcasts_info, $reformat_numbers=TRUE){
			if(!$this->regular_expression)
				$this->load_renumbering_regexp();
			
			static $limit;
			if(!isset($limit))
				if(!$reformat_numbers)
					$limit=1;
				else
					$limit=$this->regular_expression['total'];
			
			for($i=0; $i<$podcasts_info['total']; $i++)
				for( $a=0; $a<$limit; $a++ )
					for( $n=0; $n<$this->regular_expression[$a]['total']; $n++ )
						while( (preg_match(
							$this->regular_expression[$a][$n][0],
							$podcasts_info[$i]
						)) ){
							/*printf("\nRenaming: [%s]\n\tusing using regular_expression[%d][%d]: %s %s\n", $podcasts_info[$i], $a, $n,$this->regular_expression[$a][$n][0],$this->regular_expression[$a][$n][1]);*/
							$podcasts_info[$i] = preg_replace(
								$this->regular_expression[$a][$n][0],
								$this->regular_expression[$a][$n][1],
								$podcasts_info[$i],
								-1
							);
							/*printf("\tRenamed to: %s\n", $podcasts_info[$i]);*/
						}
		}/*reorder_titles*/
		
		
		
		public function get_numbers_suffix( $number ){
			switch( $number ){
				case preg_match("/^[0-9]*1$/", $number):
					return "st";
				case preg_match("/^[0-9]*2$/", $number):
					return "nd";
				case preg_match("/^[0-9]*3$/", $number):
					return "rd";
				case preg_match("/^[0-9]*[4-9]$/", $number):
					return "th";
			}
		}//get_numbered_suffix
		
		
		
		public function set_episode_prefix( $podcasts_title, $prefix_title ){
			if(!$prefix_title) return "";
			return sprintf( "%s' episode: ", $podcasts_title );
		}/*set_episode_prefix( $podcasts_title );*/
		
		
		
		public function prefix_episope_titles_with_podcasts_title( &$podcasts_info ) {
			for( $i=1; $i<$podcasts_info['total']; $i++ )
				if( !(preg_match( "/^{$podcasts_info[0]}/", $podcastInfo[$i] )) )
					$podcasts_info[$i] = "{$podcasts_info[0]} - "
					.(preg_replace(
						"/{$podcasts_info[0]}/",
						"",
						$podcasts_info[$i]
					));
		}//prefix_episopes_titles( $podcasts_info );
		
		function __deconstruct(){
			if($this->regular_expression)
				unset($this->regular_expression);
		}/*deconstruct*/
		
	}//alacast::titles
?>

