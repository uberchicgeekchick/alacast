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
	 * TODO
	 *	Have fun with this project!
	 *	If not pick another or do something different.
	 *	Find joy!
	 */
	namespace Alacast::Cache;

	class URL_DiskCache extends Cache{
		private $CacheDir;
		private $Default_Expiration;
		
		public function __construct($CacheDir="/var/alacast/cache"){
			$this->CacheDir=$CacheDir;
			
			if(!(
				(is_dir($this->CacheDir))
				&&
				(is_writable($this->CacheDir))
			))
				$this->Setup();
		}//__constuct
		
		private function Setup(){
			mkdir($this->CacheDir, '0744', True);
		}//Setup
		
		public function Fetch_URI($URI, $Expiration=""){
			($Hostname, $Port, $Get, $Query_String)=$this->Parse_URI($URI);
			$URI_Socket=fsockopen($Hostname, $Port);
		}//Fetch_UR3
		
		private function Parse_URI(&$URI){
			$Hostname=preg_replace("/^([^:]+://[^\/:]+)?:[0-9]*\/[^\?]*\??.*$/", "$1", $URI);
			$Port=preg_replace("/^[^:]+://[^\/:]*?:([0-9]*)\/[^\?]*\??.*$/","$1",$URI);
			$Get=preg_replace("/^[^:]+://[^\/:]*?:[0-9]*\/([^\?]*)\??.*$/","$1",$URI);
			$Query_String=preg_replace("/^[^:]+://[^\/:]*?:[0-9]*\/[^\?]*\??(.*)$/","$1",$URI);
			return ($Hostname, $Port, $Get, $Query_String);
		}//Parse_URI
		
		public function __destruct(){
		}//__destruct
	}
?>