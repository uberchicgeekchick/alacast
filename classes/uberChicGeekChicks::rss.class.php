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
	namespace uberChicGeekChicks;
	
	class rss extends uberChicGeekChicks::podcatcher{
		
		public function __construct(){
			
		}//__construct
		
		
		function paint_links(&$channel, &$podcasts, &$subscribe) {
			$sub2all="";
			$i=0;
			ob_start();
			print("\n\t\t\t\t\t<label for='{$channel}'>{$channel} podcasts</label><br/>");
			print("\n\t\t\t\t\t<div class='close'>\n\t\t\t\t\t\t[<a href='./?subscribe={$_GET['subscribe']}&amp;export='{$_GET['format']}'>close</a>]\n\t\t\t\t\t</div>\n\t\t\t\t\t<hr size='1'/><br/>");
			foreach($podcasts as $podcast => $links) {
				if(!(
					$podcast
					&&
					($links['rss'] || $links['www'] )
				))
					continue;
				
				$this->paint_www($links['www'], $podcast);
				$i+=$this->paint_subscribe($links['rss'], $subscribe, $sub2all);
			}
			if( ! $i ) {
				ob_end_clean();
				return;
			}
			
			ob_end_flush();
			
			print("\n\t\t\t\t\t</ul>\n\t\t\t\t\t");
			
			if($subscribe['count'])
				print("<div class='close'>\n\t\t\t\t\t\t<a href='{$subscribe['uri']}?{$sub2all}' target='subscribe'>subscribe to all {$channel} podcasts</a>\n\t\t\t\t\t<1/div>");

			print("<div class='close'>\n\t\t\t\t\t\t[<a class='close' href='./?subscribe={$_GET['subscribe']}&amp;export='{$_GET['format']}'>close</a>]\n\t\t\t\t\t</div>\n\t\t\t\t\t<hr size='1'/><br/>");
			
		}//end 'paintSubscribeLinks' function.
		
		private function paint_www(&$www, &$podcast){
			if( !$www ) return;
			
			print("<a href='{$www}' target='subscribe'>".( wordwrap($podcast, 34, "</a>\n\t\t\t\t\t\t<br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href='{$www}' target='subscribe'>", false) )."</a>");
		}//paint_www
		
		private function paint_subscribe(array &$rss, array &$subscribe, &$sub2all){
			static $i;
			
			if(!(isset($i)))
				$i=0;
			
			if(!($total_feeds=count($rss)))
				return;
			
			foreach($rss as $title=>$link ) {
				if(!$link)
					continue;
				
				$link2=rawurlencode( ((binary)$link) );
				$link3=base64_encode( ((binary)$link) );
				if( $i > 1 )
					$sub2all .= "&amp;";
				$sub2all .= "{$subscribe['get']}{$i}={$link2}";
				
				print("\n\t\t\t\t\t\t"
					."<div class='subscribe'>"
					."<input type='checkbox' name='selectedPodcasts[]' value='{$link3}'"
					.($subscribe['count']
						?""
						:" style='visibility:hidden;' disabled"
					)
					."/>{$title} feed:</div>"
					."<div class='subscribe'>"
					."[<a href='{$subscribe['uri']}?{$subscribe['get']}"
					.( $subscribe['count']
						?"1"
						:""
					)
					."={$link2}' target='subscribe'>subscribe</a>] - [<a href='{$link}' target='subscribe'>view rss</a>]"
					."</div>"
				);
			}
			print("<hr/><br/>");
			
			return 1;
		}//paint_subscribe
		
		public function paint_raw(array &$links){
			$channels=::getPodcasts();
			$podcastsStarted=0;
			foreach($channels as $channel)
				foreach((require_once("{$GLOBALS['podcastsDir']}{$channel['podcastsPHP']}")) as $podcast => $links)
					if((count($links['rss'])))
						$this->paint_rss($links['rss']);
		}//paint_raw
		
		private function paint_rss(array &$feeds ){
			static $podcastsStarted=0;
			
			foreach($feeds as $title=>$rss ){
				if(!($rss))
					continue;
				
				if(!($podcastsStarted))
					$podcastsStarted=1;
				
				printf("%s%s", ($podcastsStarted ? $spacer : ""), $rss);
			}
		}//paint_rss
		
		public function paint_opml_items($podcast, $a_or_an, $Valid_XML, $category, array &$links){
			if(!( $podcast && (count($links['rss'])) ))
				return;
				
			$podcast=htmlentities($podcast, ENT_QUOTES);
			$links['www']=::my_uri_encoder($links['www']);
			
			foreach($links['rss'] as $title=>$rss){
				if(!$rss)
					continue;
				
				$rss=::my_uri_encoder($rss, $Valid_XML);
				
				printf("\t\t<outline title=\"<![CDATA[%s&#039; %s feed]]!>\" text=\"<![CDATA[&quot;%s&quot; is %s %s podcast]]!>\" type=\"rss\" xmlUrl=\"%s\" htmlUrl=\"%s\"/>\n", $podcast, $title, $podcast, $a_or_an, $category, $rss, $links['www']);
			}
		}//paint_opml_items
		
		public function __destruct(){
			
		}//__destruct
		
	}
?>
