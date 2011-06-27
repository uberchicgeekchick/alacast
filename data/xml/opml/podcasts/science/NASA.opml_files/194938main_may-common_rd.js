function openUserPref(URL)
{
  userPrefWindow=window.open(URL, 'userprefs', 'toolbar=0,scrollbars=1,location=0,statusbar=0,menubar=0,resizable=0,width=600,height=600,left=372,top=200');
  userPrefWindow.focus();
}

function redirectURL(url) 
{
  window.location.href=url;
}

function UA(){
  var v=navigator.appVersion.toLowerCase(), u=navigator.userAgent.toLowerCase(), n=navigator.appName;
  this.mac=(v.indexOf("mac")+1);
  this.win=(v.indexOf("win")+1);
  this.nn=(n == "Netscape");
  this.ie=(n == "Microsoft Internet Explorer");
  this.aol=(u.indexOf("aol")+1);
  this.opera=(u.indexOf("opera")+1);
  this.ver=(this.ie) ? parseFloat(v.split('msie ')[1]) : parseFloat(v);
  this.major=this.ver.toString().split('.')[0];
	this.minor=this.ver.toString().split('.')[1];
	this.v4=(this.major == 4);
	this.os=(this.mac) ? 'mac' : (this.win) ? 'win' : navigator.platform;
  this.name=(this.nn) ? 'nn' : (this.ie) ? 'ie' : n;
  this.codeName=this.name +'_'+ parseInt(this.ver) + '_'+ this.os;
}
var ua=new UA();

var onloadHandlers=[];
function loadEvents() {
  for(var i=0; i<onloadHandlers.length; i++) {
    eval(onloadHandlers[i]);
  }
}
window.onload=loadEvents;

var onresizeHandlers=[];
function resizeEvents() {
  for(var i=0; i<onresizeHandlers.length;i++) {
    eval(onresizeHandlers[i]);
  }
}
window.onresize=resizeEvents;

function handleResize(init) {
  if(!(document.layers)) return;
  if(init==true) with (navigator) {
    document.pgW=innerWidth;
    document.pgH=innerHeight;
    onresizeHandlers[onresizeHandlers.length]='handleResize()';
  }
  else if (innerWidth!=document.pgW || innerHeight!=document.pgH) location.reload();
}
handleResize(true);

function getObjByName(name,doc) {
  var o=0;
  if(!doc) doc=document;
  if(doc[name]) o=doc[name];
  if(document.all && doc.all[name]) o=doc.all[name];
  if(o) {
    if(!o.getElementsByTagName) o.getElementsByTagName=getElementsArray;
    return o;
  }
  if(document.layers) {
    for(var i=0;i < doc.layers.length;i++){
      var lyrdoc=doc.layers[i].document;
      if(lyrdoc[name]) return lyrdoc[name];
      if(lyrdoc.layers.length > 0) {
        var o=getObjByName(name,lyrdoc);
        if(o) return o;
      }
    }
  }
  return 0;
}
if(!document.getElementById) document.getElementById=getObjByName;

function getElementsArray(el) {
  if(document.layers) {
    var doc=(this == document) ? document : this.document;
    switch(el) {
      case 'img' : return doc.images;
      case 'a' : return doc.links;
      case 'div' : return doc.layers;
      case 'form' : return doc.forms;
      default : return 0;
    }
  }
  if(document.all) return this.all.tags(el);
  return 0;
}
if(!document.getElementsByTagName) document.getElementsByTagName=getElementsArray;
if(document.layers) Layer.prototype.getElementsByTagName=getElementsArray;

function show(div){
  if(document.all) window.document.all[div].style.visibility='visible';
  else if(document.layers) getObjByName(div).visibility='show';
  else document.getElementById(div).style.visibility='visible';
}
function hide(div){
  if(document.all) window.document.all[div].style.visibility='hidden';
  else if(document.layers) getObjByName(div).visibility='hide';
  else document.getElementById(div).style.visibility='hidden';
}

function swapImg() {
  if(!document.images) return;
  var args=swapImg.arguments;
  for(var i=0;i < args.length;i+=2) {
    var imgSrc=(args[i + 1].indexOf('[') != -1) ? eval(args[i + 1] + '.src') : args[i + 1];
    if(getObjByName(args[i])) getObjByName(args[i]).src=imgSrc;
  }
}

function setCookie(name,value,expires) {
  document.cookie=escape(name)+'='+escape(value)+'; expires='+expires.toGMTString();
}

function getCookie(name) {
  var value,nl,cl,i,j,e;
  name+='=';
  value=0;
  nl=name.length;
  cl=document.cookie.length;
  i=0;
  while (i < cl) {
    j=i+nl;
    if(document.cookie.substring(i,j) == name) {
      e=document.cookie.indexOf(';',j);
      if(e == -1) e=document.cookie.length;
      value=unescape(document.cookie.substring(j,e));
      break;
    }
    i=document.cookie.indexOf(' ', i) + 1;
    if (i == 0) break;
  }  
  return value;
}

function detectBrowser_old(){
  var v=navigator.appVersion.toLowerCase(), u=navigator.userAgent.toLowerCase(), n=navigator.appName;
  this.mac=(v.indexOf("mac")+1);
  this.win=(v.indexOf("win")+1);
  this.nn=(n == "Netscape");
  this.ie=(n == "Microsoft Internet Explorer");
  this.aol=(u.indexOf("aol")+1);
  this.safari=(u.indexOf("safari")+1);
  this.opera=(u.indexOf("opera")+1);
  this.ver=(this.ie) ? parseFloat(v.split('msie ')[1]) : parseFloat(v);
  this.major=this.ver.toString().split('.')[0];
        this.minor=this.ver.toString().split('.')[1];
        this.v4=(this.major == 4);
        this.os=(this.mac) ? 'mac' : (this.win) ? 'win' : navigator.platform;
  this.name=(this.nn) ? 'nn' : (this.ie) ? 'ie' : n;
  this.codeName=this.name +'_'+ parseInt(this.ver) + '_'+ this.os;
}

function watchNASATV() {
        var ua=detectBrowser_old();
        w=737;
        h=430;
        myname='NASATV';
        if (((this.nn)&&(this.v4))||(this.safari))
        {
                mypage='/mediaplayer/index_safari.html';
        }else
        {
                mypage='/mediaplayer/index.html';
        }
        var winl=(screen.width - w) / 2;
        var wint=(screen.height - h) / 2;
        winprops='height='+h+',width='+w+',top='+wint+',left='+winl+',scrollbars=no,resizable=no';
        win=window.open(mypage, myname, winprops)
        //if (parseInt(navigator.appVersion) >= 4) { win.window.focus(); }
}

function watchNASALiveTV()
{
        w=737;
        h=450;
        myname='NASALiveTV';
        mypage='/multimedia/nasatv/live_tv.html';
        var winl=(screen.width - w) / 2;
        var wint=(screen.height - h) / 2;
        winprops='height='+h+',width='+w+',top='+wint+',left='+winl+',scrollbars=no,resizable=no';
        win=window.open(mypage, myname, winprops)
        //if (parseInt(navigator.appVersion) >= 4) { win.window.focus(); }
}


function watchNASAOnDemandTV(param1, param2, param3)
{      // alert('param '+param);
       // w=737;
       // h=450;
	    w=775;
        h=600;
        myname='NASAOnDemandTV';
		var param=param1;
		//alert('param '+param);
		if(  param2!='undefined' && param2!=eval('') && param2!=null && param2!='' )
	    { param+='|'+param2;
		}
	//	alert('param '+param);
		if( param3!='undefined' && param3!=eval('') && param3!=null && param3!='' )
	    { param+='|'+param3;
		}
//alert('param '+param);
        //mypage='/redesign/multimedia/nasatv/on_demand_video.html?param='+param;
		var mypage='http://www.nasa.gov/multimedia/nasatv/on_demand_video.html?param='+param;
		//alert(' mypage '+mypage);
        var winl=(screen.width - w) / 2;
        var wint=(screen.height - h) / 2;
        winprops='height='+h+',width='+w+',top='+wint+',left='+winl+',scrollbars=no,resizable=no';
        win=window.open(mypage, myname, winprops);
        //if (parseInt(navigator.appVersion) >= 4) { win.window.focus(); }
}



/* This function is used by On Demand Video - Redesign */
function watchNASAOnDemandVideo(param1, param2, param3,title,imageName, assetId)
{      
		var myname='NASAOnDemandTV';
	    var w=800;
        var h=550;

    	/*var param=param1;
		alert('param '+param);
		if(  param2!='undefined' && param2!=eval('') && param2!=null && param2!='' )
	    { param+='|'+param2;
		}
		alert('param '+param);
		if( param3!='undefined' && param3!=eval('') && param3!=null && param3!='' )
	    { param+='|'+param3;
		}*/

		var isparam1;
		var isparam2;
		var isparam3;
		
		if(  param1!='undefined' && param1!=eval('') && param1!=null && param1!='' )
			isparam1='true';
		if(  param2!='undefined' && param2!=eval('') && param2!=null && param2!='' )
			isparam2='true';
		if( param3!='undefined' && param3!=eval('') && param3!=null && param3!='' )
			isparam3='true';
		
		var param='';
		if (isparam1 == 'true')
		{
			param=param1;
		}

		if (isparam2 == 'true')
		{
			if (isparam1 == 'true')
				param+='|'+param2;
			else
				param=param2;
		}
    	
		if (isparam3 == 'true')
		{
			if (isparam1 == 'true' || isparam2 == 'true')
				param+='|'+param3;
			else
				param=param3;
		}


        //alert('param '+param);

		if(imageName == null || imageName ==eval('') || imageName == 'undefined' || imageName == 'null')
		{
			imageName='test.gif';
		}
		
		param += '&_id=' +  assetId;

		if(title != null || title != eval('') || title != 'undefined')
		{
			title=escape(title);
			param +='&_title=' + title;
		}

		if(imageName != null || imageName != eval('') || imageName != 'undefined')
	    {
			param +='&_tnimage=' + imageName;
		}
		// alert('param '+param);
		var mypage='http://www.nasa.gov/multimedia/nasatv/on_demand_video.html?param='+param;
		//alert(' mypage ' + mypage);
				
		var winl=(screen.width - w) / 2;
        var wint=(screen.height - h) / 2;
        winprops='height='+h+',width='+w+',top='+wint+',left='+winl+',scrollbars=no,resizable=no';
        win=window.open(mypage, myname, winprops);
}




/* This function is used by On Demand Video - Redesign-- This funtion was added to accomodate Flash Videos  */
function watchNASAOnDemandVideos(param1, param2, param3,param4,title,imageName, assetId,captions)
{      

		var myname='NASAOnDemandVideo';
	    var w=800;
        var h=550;

    	var isparam1;
		var isparam2;
		var isparam3;
		var isparam4;
		
		if(  param1!='undefined' && param1!=eval('') && param1!=null && param1!='' )
			isparam1='true';
		if(  param2!='undefined' && param2!=eval('') && param2!=null && param2!='' )
			isparam2='true';
		if( param3!='undefined' && param3!=eval('') && param3!=null && param3!='' )
			isparam3='true';
		if( param4!='undefined' && param4!=eval('') && param4!=null && param4!='' )
			isparam4='true';
			
		
		var param='';
		if (isparam1 == 'true')
		{
			param=param1;
		}

		if (isparam2 == 'true')
		{
			if (isparam1 == 'true')
				param+='|'+param2;
			else
				param=param2;
		}
    	
		if (isparam3 == 'true')
		{
			if (isparam1 == 'true' || isparam2 == 'true')
				param+='|'+param3;
			else
				param=param3;
		}

		if (isparam4 == 'true')
		{
			if (isparam1 == 'true' || isparam2 == 'true' || isparam3 == 'true' )
				param+='|'+param4;
			else
				param=param4;
		}

        //alert('param '+param);
   		if(captions != null && captions != '' && captions != eval('') && captions != 'undefined')
	    {
			param +='|' + captions;
		}
		
		

		if(imageName == null || imageName ==eval('') || imageName == 'undefined' || imageName == 'null')
		{
			imageName='test.gif';
		}
		
		param += '&_id=' +  assetId;

		if(title != null || title != eval('') || title != 'undefined')
		{
			title=escape(title);
			param +='&_title=' + title;
		}

		if(imageName != null || imageName != eval('') || imageName != 'undefined')
	    {
			param +='&_tnimage=' + imageName;
		}
		
		
		
		//alert('param '+param);
		var mypage='http://www.nasa.gov/multimedia/nasatv/on_demand_video.html?param='+param;
		//var mypage='http://staging.cms.nasa.gov/temp/on_demand_video.html?param='+param;
		//alert(' mypage ' + mypage);
				
		var winl=(screen.width - w) / 2;
        var wint=(screen.height - h) / 2;
        winprops='height='+h+',width='+w+',top='+wint+',left='+winl+',scrollbars=no,resizable=no';
        win=window.open(mypage, myname, winprops);
}




function openNASAWindow(url)
{
  if (url != "#")
  {
    var positionX=screen.width;
    var positionY=((screen.height)/2);

    var sizeX=720;
    var sizeY=640;
    
    var strWindowFeatures="";
    strWindowFeatures += 'menubar=yes,location=yes,toolbar=yes,directories=yes,scrollbars=yes,status=yes,resizable=yes,outerWidth='+720+',outerHeight='+640+',width='+720+'height='+640+',left='+80+',top='+60+'screenX='+80+',screenY='+60;
    winPopupWindow=window.open(url, "nasawindow", strWindowFeatures);
    winPopupWindow.focus();
  }
}

function openWorldBook(url)
{
  if (url != "#")
  {
    var strWindowFeatures="";
    strWindowFeatures += 'menubar=yes,location=yes,toolbar=yes,directories=yes,scrollbars=yes,status=yes,resizable=yes,outerWidth='+625+',outerHeight='+720+',width='+625+',height='+720+',left='+80+',top='+0+',screenX='+80+',screenY='+0;
    winPopupWindow=window.open(url, "worldbook", strWindowFeatures);
    winPopupWindow.focus();
  }
}

function openDeepImpactViewer(url)
{
  if (url != "#")
  {
    var strWindowFeatures="";
    strWindowFeatures += 'menubar=no,location=no,toolbar=no,directories=no,scrollbars=no,status=no,resizable=no,outerWidth='+746+',outerHeight='+600+',width='+746+',height='+600+',left='+100+',top='+100+',screenX='+100+',screenY='+100;
    winPopupWindow=window.open(url, "viewer", strWindowFeatures);
    winPopupWindow.focus();
  }
}

// This function from has been modified to take a single string of all images separated by commas
/*
function preLoad(a) {
  var o=[];
  for(var i=0; i<a.length; i++) {
    o[i]=new Image();
    o[i].src='/images/'+a[i]+'_1.gif';
  }
}
*/

function preLoad(str) {
  var a=str.split(',') ;
  var o=[];
  for(var i=0; i<a.length; i++) {
    o[i]=new Image();
    //o[i].src='/images/'+a[i]+'_1.gif';
    o[i].src=a[i]+'_1.gif';
  }
}

function preLoadTest(str) {
  var a=str.split(',') ;
  alert('a: ' + a);
  var o=[];
  for(var i=0; i<a.length; i++) {
    o[i]=new Image();
    //o[i].src='/images/'+a[i]+'_1.gif';
    o[i].src=a[i]+'_1.gif';
    alert('a[' + i + ']: ' + a[i]);
  }
}

function openPDF()
{
    var baseLink='/tvschedule/pdf/tvsked_';
    var pdfExt='.pdf';
    var linkURL=baseLink + pdfLink + pdfExt;
    window.location=linkURL; 
}

function openXLS()
{
    var baseLink='/tvschedule/xls/tvsked_';
    var xlsExt='.xls';
    var linkURL=baseLink + xlsLink + xlsExt;
    window.location=linkURL;
}

function NewWindow(mypage, myname, w, h, scroll) {
	var winl=(screen.width - w) / 2;
	var wint=(screen.height - h) / 2;
	winprops='height='+h+',width='+w+',top='+wint+',left='+winl+',scrollbars='+scroll+',resizable'
	win=window.open(mypage, myname, winprops)
	if (parseInt(navigator.appVersion) >= 4) { win.window.focus(); }
}

function popup(copyURL,newwidth,newheight)
{
       window.open(copyURL, 'theconfirmWin','top=0,left=0,toolbar=no,location=no,directories=no,status=no,scrollbars=no,menubar=no,width='+newwidth + ',height=' + newheight);
}
 
function popup2(copyURL,newwidth,newheight)
{
        window.open(copyURL, 'theconfirmWin','top=0,left=0,toolbar=no,location=no,directories=no,status=no,scrollbars=yes,menubar=no,width='+newwidth + ',height=' + newheight);
}

function openPopUpWindowNoMenubar(url)
{
  if (url != "#")
  {
    var positionX=screen.width;
    var positionY=((screen.height)/2);

    var sizeX=720;
    var sizeY=640;
    
    var strWindowFeatures="";
    strWindowFeatures += 'menubar=no,location=no,toolbar=no,directories=no,scrollbars=yes,status=no,resizable=yes,outerWidth='+720+',outerHeight='+640+',width='+720+'height='+640+',left='+80+',top='+60+'screenX='+80+',screenY='+60;
    winPopupWindow=window.open(url, "nasawindow", strWindowFeatures);
    winPopupWindow.focus();
  }
}

function submitPopUpEmail() {
     newwin=window.open("","myNewWin","menubar=no,location=no,toolbar=no,directories=no,scrollbars=yes,status=no,resizable=yes,width=720,height=640,toolbar=0"); 
     newwin.focus();
     var a=window.setTimeout("document.emailForm.submit();",500); 
}

function submitPopUpEmailWithMenuBar() {
     newwin=window.open("","myNewWin","menubar=yes,location=yes,toolbar=no,directories=no,scrollbars=yes,status=no,resizable=yes,width=720,height=640,toolbar=0"); 
     newwin.focus();
     var a=window.setTimeout("document.emailForm.submit();",500); 
}

function submitPopUpEmailWithoutMenuBar() {
     newwin=window.open("","myNewWin","menubar=no,location=no,toolbar=no,directories=no,scrollbars=yes,status=no,resizable=yes,width=720,height=640,toolbar=0"); 
     newwin.focus();
     document.emailForm.submit();
}

/*
preLoad('placeholder/navigation/topnav/nav_top_0','placeholder/navigation/topnav/nav_top_1','placeholder/navigation/topnav/nav_top_2','placeholder/navigation/topnav/nav_top_3','placeholder/navigation/topnav/nav_top_4','placeholder/navigation/topnav/nav_top_5');
*/

preLoad('/templateimages/navigation/topnav/nav_top_0,/templateimages/navigation/topnav/nav_top_1,/templateimages/navigation/topnav/nav_top_2,/templateimages/navigation/topnav/nav_top_3,/templateimages/navigation/topnav/nav_top_4,/templateimages/navigation/topnav/nav_top_5');

//-- Urchin Tracking Module 6.1 (UTM 6.1) $Revision: 1.24 $
//-- Copyright 2004 Urchin Software Corporation, All Rights Reserved.

//-- Urchin On Demand Settings ONLY
var _uacct="";			// set up the Urchin Account
//Changed By Nag
//var _userv=0;			// service mode (0=local,1=remote,2=both)
var _userv=1;			// service mode (0=local,1=remote,2=both)

//-- UTM User Settings
var _ufsc=1;			// set client info flag (1=on|0=off)
var _udn="auto";		// (auto|none|domain) set the domain name for cookies
var _uhash="on";		// (on|off) unique domain hash for cookies
var _utimeout="1800";   	// set the inactive session timeout in seconds
var _ugifpath="/__utm.gif";	// set the web path to the __utm.gif file

var _utsp="|";			// transaction field separator
var _uflash=1;			// set flash version detect option (1=on|0=off)
var _utitle=1;			// set the document title detect option (1=on|0=off)

//-- UTM Campaign Tracking Settings
var _uctm=1;			// set campaign tracking module (1=on|0=off)
var _ucto="15768000";		// set timeout in seconds (6 month default)
var _uccn="utm_campaign";	// name
var _ucmd="utm_medium";		// medium (cpc|cpm|link|email|organic)
var _ucsr="utm_source";		// source
var _uctr="utm_term";		// term/keyword
var _ucct="utm_content";	// content
var _ucid="utm_id";		// id number
var _ucno="utm_nooverride";	// don't override

//-- Auto/Organic Sources and Keywords
var _uOsr=new Array();
var _uOkw=new Array();
_uOsr[0]="google";	_uOkw[0]="q";
_uOsr[1]="yahoo";	_uOkw[1]="p";
_uOsr[2]="msn";		_uOkw[2]="q";
_uOsr[3]="aol";		_uOkw[3]="query";
_uOsr[4]="lycos";	_uOkw[4]="query";
_uOsr[5]="ask";		_uOkw[5]="q";
_uOsr[6]="altavista";	_uOkw[6]="q";
_uOsr[7]="search";	_uOkw[7]="q";
_uOsr[8]="netscape";	_uOkw[8]="query";
_uOsr[9]="earthlink";	_uOkw[9]="q";
_uOsr[10]="cnn";	_uOkw[10]="query";
_uOsr[11]="looksmart";	_uOkw[11]="key";
_uOsr[12]="about";	_uOkw[12]="terms";
_uOsr[13]="excite";	_uOkw[13]="qkw";
_uOsr[14]="mamma";	_uOkw[14]="query";
_uOsr[15]="alltheweb";	_uOkw[15]="q";
_uOsr[16]="gigablast";	_uOkw[16]="q";
_uOsr[17]="voila";	_uOkw[17]="kw";
_uOsr[18]="virgilio";	_uOkw[18]="qs";
_uOsr[19]="teoma";	_uOkw[19]="q";

//-- Auto/Organic Keywords to Ignore
var _uOno=new Array();
//_uOno[0]="urchin";
//_uOno[1]="urchin.com";
//_uOno[2]="www.urchin.com";

//-- Referral domains to Ignore
var _uRno=new Array();
//_uRno[0]=".urchin.com";

//-- **** Don't modify below this point ***
var _uff,_udh,_udt,_udo="",_uu,_ufns=0,_uns=0,_ur="-",_ufno=0,_ust=0,_ujv="-",_ubd=document,_udl=_ubd.location,_uwv="6.1";
//Changed by Nag
var _ugifpath2="http://log.www.nasa.gov/utm/__utm.gif";
if (_udl.protocol=="https:") _ugifpath2="http://log.www.nasa.gov/utm/__utm.gif";
//var _ugifpath2="http://service.urchin.com/__utm.gif";
//if (_udl.protocol=="https:") _ugifpath2="https://service.urchin.com/__utm.gif";

function urchinTracker(page) {
 if (_udl.protocol=="file:") return;
 if (_uff && (!page || page=="")) return;
 var a,b,c,v,x="",s="",f=0;
 var nx=" expires=Sun, 18 Jan 2038 00:00:00 GMT;";
 var dc=_ubd.cookie;
 _udh=_uDomain();
 _uu=Math.round(Math.random()*2147483647);
 _udt=new Date();
 _ust=Math.round(_udt.getTime()/1000);
 a=dc.indexOf("__utma="+_udh);
 b=dc.indexOf("__utmb="+_udh);
 c=dc.indexOf("__utmc="+_udh);
 if (_udn && _udn!="") { _udo=" domain="+_udn+";"; }
 if (_utimeout && _utimeout!="") {
  x=new Date(_udt.getTime()+(_utimeout*1000));
  x=" expires="+x.toGMTString()+";";
 }
 s=_udl.search;
 if(s && s!="" && s.indexOf("__utma=")>=0) {
  a=_uGC(s,"__utma=","&");
  b=_uGC(s,"__utmb=","&");
  c=_uGC(s,"__utmc=","&");
  if (a!="-" && b!="-" && c!="-") f=1;
  else if(a!="-") f=2;
 }
 if(f==1) {
  _ubd.cookie="__utma="+a+"; path=/;"+nx;
  _ubd.cookie="__utmb="+b+"; path=/;"+x;
  _ubd.cookie="__utmc="+c+"; path=/;";
 } else if (f==2) {
  a=_uFixA(s,"&",_ust);
  _ubd.cookie="__utma="+a+"; path=/;"+nx;
  _ubd.cookie="__utmb="+_udh+"; path=/;"+x;
  _ubd.cookie="__utmc="+_udh+"; path=/;";
  _ufns=1;
 } else if (a>=0 && b>=0 && c>=0) {
  _ubd.cookie="__utmb="+_udh+"; path=/;"+x+_udo;
 } else {
  if (a>=0) a=_uFixA(_ubd.cookie,";",_ust);
  else a=_udh+"."+_uu+"."+_ust+"."+_ust+"."+_ust+".1";
  _ubd.cookie="__utma="+a+"; path=/;"+nx+_udo;
  _ubd.cookie="__utmb="+_udh+"; path=/;"+x+_udo;
  _ubd.cookie="__utmc="+_udh+"; path=/;"+_udo;
  _ufns=1;
 }
 if (s && s!="" && s.indexOf("__utmv=")>=0) {
  if ((v=_uGC(s,"__utmv=","&"))!="-") {
   _ubd.cookie="__utmv="+unescape(v)+"; path=/;"+nx+_udo;
  }
 }
 _uInfo(page);
 _ufns=0;
 _ufno=0;
 _uff=1;
}
urchinTracker();
function _uInfo(page) {
 var p,s="",pg=_udl.pathname+_udl.search;
 if (page && page!="") pg=escape(page);
 _ur=_ubd.referrer;
 if (!_ur || _ur=="") { _ur="-"; }
 else {
  p=_ur.indexOf(_ubd.domain);
  if ((p>=0) && (p<=8)) { _ur="0"; }
  if (_ur.indexOf("[")==0 && _ur.lastIndexOf("]")==(_ur.length-1)) { _ur="-"; }
 }
 s+="&utmn="+_uu;
 if (_ufsc) s+=_uBInfo(page);
 if (_uctm && (!page || page=="")) s+=_uCInfo();
 if (_utitle && _ubd.title && _ubd.title!="") s+="&utmdt="+escape(_ubd.title);
 if (_udl.hostname && _udl.hostname!="") s+="&utmhn="+escape(_udl.hostname);
 if (!page || page=="") s+="&utmr="+_ur;
 s+="&utmp="+pg;
 if (_userv==0 || _userv==2) {
  var i=new Image(1,1);
  i.src=_ugifpath+"?"+"utmwv="+_uwv+s;
  i.onload=function() {_uVoid();}
 }
 if (_userv==1 || _userv==2) {
  var i2=new Image(1,1);
  i2.src=_ugifpath2+"?"+"utmwv="+_uwv+s+"&utmac="+_uacct+"&utmcc="+_uGCS();
  i2.onload=function() { _uVoid(); }
 }
 return;
}
function _uVoid() { return; }
function _uCInfo() {
 if (!_ucto || _ucto=="") { _ucto="15768000"; }
 var c="",t="-",t2="-",o=0,cs=0,cn=0;i=0;
 var s=_udl.search;
 var z=_uGC(s,"__utmz=","&");
 var x=new Date(_udt.getTime()+(_ucto*1000));
 var dc=_ubd.cookie;
 x=" expires="+x.toGMTString()+";";
 if (z!="-") { _ubd.cookie="__utmz="+unescape(z)+"; path=/;"+x+_udo; return ""; }
 z=dc.indexOf("__utmz="+_udh);
 if (z>-1) { z=_uGC(dc,"__utmz="+_udh,";"); }
 else { z="-"; }
 t=_uGC(s,_ucid+"=","&");
 t2=_uGC(s,_ucsr+"=","&");
 if ((t!="-" && t!="") || (t2!="-" && t2!="")) {
  if (t!="-" && t!="") { c+="utmcid="+_uEC(t); if (t2!="-" && t2!="") c+="|utmcsr="+_uEC(t2);
  } else { if (t2!="-" && t2!="") c+="utmcsr="+_uEC(t2); }
  t=_uGC(s,_uccn+"=","&");
  if (t!="-" && t!="") c+="|utmccn="+_uEC(t);
  else c+="|utmccn=(not+set)";
  t=_uGC(s,_ucmd+"=","&");
  if (t!="-" && t!="") c+="|utmcmd="+_uEC(t);
  else  c+="|utmcmd=(not+set)";
  t=_uGC(s,_uctr+"=","&");
  if (t!="-" && t!="") c+="|utmctr="+_uEC(t);
  else { t=_uOrg(1); if (t!="-" && t!="") c+="|utmctr="+_uEC(t); }
  t=_uGC(s,_ucct+"=","&");
  if (t!="-" && t!="") c+="|utmcct="+_uEC(t);
  t=_uGC(s,_ucno+"=","&");
  if (t=="1") o=1;
  if (z!="-" && o==1) return "";
 }
 if (c=="-" || c=="") { c=_uOrg(); if (z!="-" && _ufno==1)  return ""; }
 if (c=="-" || c=="") { if (_ufns==1)  c=_uRef(); if (z!="-" && _ufno==1)  return ""; }
 if (c=="-" || c=="") {
  if (z=="-" && _ufns==1) { c="utmccn=(direct)|utmcsr=(direct)|utmcmd=(none)"; }
  if (c=="-" || c=="") return "";
 }
 if (z!="-") {
  i=z.indexOf(".");
  if (i>-1) i=z.indexOf(".",i+1);
  if (i>-1) i=z.indexOf(".",i+1);
  if (i>-1) i=z.indexOf(".",i+1);
  t=z.substring(i+1,z.length);
  if (t.toLowerCase()==c.toLowerCase()) cs=1;
  t=z.substring(0,i);
  if ((i=t.lastIndexOf(".")) > -1) {
   t=t.substring(i+1,t.length);
   cn=(t*1);
  }
 }
 if (cs==0 || _ufns==1) {
  t=_uGC(dc,"__utma="+_udh,";");
  if ((i=t.lastIndexOf(".")) > 9) {
   _uns=t.substring(i+1,t.length);
   _uns=(_uns*1);
  }
  cn++;
  if (_uns==0) _uns=1;
  _ubd.cookie="__utmz="+_udh+"."+_ust+"."+_uns+"."+cn+"."+c+"; path=/; "+x+_udo;
 }
 if (cs==0 || _ufns==1) return "&utmcn=1";
 else return "&utmcr=1";
}
function _uRef() {
 if (_ur=="0" || _ur=="" || _ur=="-") return "";
 var i=0,h,k,n;
 if ((i=_ur.indexOf("://"))<0) return "";
 h=_ur.substring(i+3,_ur.length);
 if (h.indexOf("/") > -1) {
  k=h.substring(h.indexOf("/"),h.length);
  if (k.indexOf("?") > -1) k=k.substring(0,k.indexOf("?"));
  h=h.substring(0,h.indexOf("/"));
 }
 h=h.toLowerCase();
 n=h;
 if ((i=n.indexOf(":")) > -1) n=n.substring(0,i);
 for (var ii=0;ii<_uRno.length;ii++) {
  if ((i=n.indexOf(_uRno[ii].toLowerCase())) > -1 && n.length==(i+_uRno[ii].length)) { _ufno=1; break; }
 }
 if (h.indexOf("www.")==0) h=h.substring(4,h.length);
 return "utmccn=(referral)|utmcsr="+_uEC(h)+"|"+"utmcct="+_uEC(k)+"|utmcmd=referral";
}
function _uOrg(t) {
 if (_ur=="0" || _ur=="" || _ur=="-") return "";
 var i=0,h,k;
 if ((i=_ur.indexOf("://")) < 0) return "";
 h=_ur.substring(i+3,_ur.length);
 if (h.indexOf("/") > -1) {
  h=h.substring(0,h.indexOf("/"));
 }
 for (var ii=0;ii<_uOsr.length;ii++) {
  if (h.indexOf(_uOsr[ii]) > -1) {
   if ((i=_ur.indexOf("?"+_uOkw[ii]+"=")) > -1 || (i=_ur.indexOf("&"+_uOkw[ii]+"=")) > -1) {
    k=_ur.substring(i+_uOkw[ii].length+2,_ur.length);
    if ((i=k.indexOf("&")) > -1) k=k.substring(0,i);
    for (var yy=0;yy<_uOno.length;yy++) {
     if (_uOno[yy].toLowerCase()==k.toLowerCase()) { _ufno=1; break; }
    }
    if (t) return _uEC(k);
    else return "utmccn=(organic)|utmcsr="+_uEC(_uOsr[ii])+"|"+"utmctr="+_uEC(k)+"|utmcmd=organic";
   }
  }
 }
 return "";
}
function _uBInfo(page) {
 var sr="-",sc="-",ul="-",fl="-",je=1;
 var n=navigator;
 if (self.screen) {
  sr=screen.width+"x"+screen.height;
  sc=screen.colorDepth+"-bit";
 } else if (self.java) {
  var j=java.awt.Toolkit.getDefaultToolkit();
  var s=j.getScreenSize();
  sr=s.width+"x"+s.height;
 }
 if (_ujv=="-" && (!page || page=="")) {
  for (var i=5;i>=0;i--) {
   var t="<script language='JavaScript1."+i+"'>_ujv='1."+i+"';</script>";
   _ubd.write(t);
   if (_ujv!="-") break;
  }
 }
 if (n.language) { ul=n.language.toLowerCase(); }
 else if (n.browserLanguage) { ul=n.browserLanguage.toLowerCase(); }
 je=n.javaEnabled()?1:0;
 if (_uflash) fl=_uFlash();
 return "&utmsr="+sr+"&utmsc="+sc+"&utmul="+ul+"&utmje="+je+"&utmjv="+_ujv+"&utmfl="+fl;
}
function __utmSetTrans() {
 var e;
 if (_ubd.getElementById) e=_ubd.getElementById("utmtrans");
 else if (_ubd.utmform && _ubd.utmform.utmtrans) e=_ubd.utmform.utmtrans;
 if (!e) return;
 var l=e.value.split("UTM:");
 var i,i2,c;
 if (_userv==0 || _userv==2) i=new Array();
 if (_userv==1 || _userv==2) { i2=new Array(); c=_uGCS(); }

 for (var ii=0;ii<l.length;ii++) {
  l[ii]=_uTrim(l[ii]);
  if (l[ii].charAt(0)!='T' && l[ii].charAt(0)!='I') continue;
  var r=Math.round(Math.random()*2147483647);
  if (!_utsp || _utsp=="") _utsp="|";
  var f=l[ii].split(_utsp),s="";
  if (f[0].charAt(0)=='T') {
   s="&utmt=tran"+"&utmn="+r;
   f[1]=_uTrim(f[1]); if(f[1]&&f[1]!="") s+="&utmtid="+escape(f[1]);
   f[2]=_uTrim(f[2]); if(f[2]&&f[2]!="") s+="&utmtst="+escape(f[2]);
   f[3]=_uTrim(f[3]); if(f[3]&&f[3]!="") s+="&utmtto="+escape(f[3]);
   f[4]=_uTrim(f[4]); if(f[4]&&f[4]!="") s+="&utmttx="+escape(f[4]);
   f[5]=_uTrim(f[5]); if(f[5]&&f[5]!="") s+="&utmtsp="+escape(f[5]);
   f[6]=_uTrim(f[6]); if(f[6]&&f[6]!="") s+="&utmtci="+escape(f[6]);
   f[7]=_uTrim(f[7]); if(f[7]&&f[7]!="") s+="&utmtrg="+escape(f[7]);
   f[8]=_uTrim(f[8]); if(f[8]&&f[8]!="") s+="&utmtco="+escape(f[8]);
  } else {
   s="&utmt=item"+"&utmn="+r;
   f[1]=_uTrim(f[1]); if(f[1]&&f[1]!="") s+="&utmtid="+escape(f[1]);
   f[2]=_uTrim(f[2]); if(f[2]&&f[2]!="") s+="&utmipc="+escape(f[2]);
   f[3]=_uTrim(f[3]); if(f[3]&&f[3]!="") s+="&utmipn="+escape(f[3]);
   f[4]=_uTrim(f[4]); if(f[4]&&f[4]!="") s+="&utmiva="+escape(f[4]);
   f[5]=_uTrim(f[5]); if(f[5]&&f[5]!="") s+="&utmipr="+escape(f[5]);
   f[6]=_uTrim(f[6]); if(f[6]&&f[6]!="") s+="&utmiqt="+escape(f[6]);
  }
  if (_userv==0 || _userv==2) {
   i[ii]=new Image(1,1);
   i[ii].src=_ugifpath+"?"+"utmwv="+_uwv+s;
   i[ii].onload=function() { _uVoid(); }
  }
  if (_userv==1 || _userv==2) {
   i2[ii]=new Image(1,1);
   i2[ii].src=_ugifpath2+"?"+"utmwv="+_uwv+s+"&utmac="+_uacct+"&utmcc="+c;
   i2[ii].onload=function() { _uVoid(); }
  }
 }
 return;
}
function _uFlash() {
 var f="-",n=navigator;
 if (n.plugins && n.plugins.length) {
  for (var ii=0;ii<n.plugins.length;ii++) {
   if (n.plugins[ii].name.indexOf('Shockwave Flash')!=-1) {
    f=n.plugins[ii].description.split('Shockwave Flash ')[1];
    break;
   }
  }
 } else if (window.ActiveXObject) {
  for (var ii=10;ii>=2;ii--) {
   try {
    var fl=eval("new ActiveXObject('ShockwaveFlash.ShockwaveFlash."+ii+"');");
    if (fl) { f=ii + '.0'; break; }
   }
   catch(e) {}
  }
 }
 return f;
}
function __utmLinker(l) {
 var p,a="-",b="-",c="-",z="-",v="-";
 var dc=_ubd.cookie;
 if (l && l!="") {
  if (dc) {
   a=_uGC(dc,"__utma="+_udh,";");
   b=_uGC(dc,"__utmb="+_udh,";");
   c=_uGC(dc,"__utmc="+_udh,";");
   z=_uGC(dc,"__utmz="+_udh,";");
   v=_uGC(dc,"__utmv="+_udh,";");
   p="__utma="+a+"&__utmb="+b+"&__utmc="+c+"&__utmz="+escape(z)+"&__utmv="+escape(v);
  }
  if (p) {
   if (l.indexOf("?")<=-1) { document.location=l+"?"+p; }
   else { document.location=l+"&"+p; }
  } else { document.location=l; }
 }
}
function __utmLinkPost(f) {
 var p,a="-",b="-",c="-",z="-",v="-";
 var dc=_ubd.cookie;
 if (!f || !f.action) return;
 if (dc) {
  a=_uGC(dc,"__utma="+_udh,";");
  b=_uGC(dc,"__utmb="+_udh,";");
  c=_uGC(dc,"__utmc="+_udh,";");
  z=_uGC(dc,"__utmz="+_udh,";");
  v=_uGC(dc,"__utmv="+_udh,";");
  p="__utma="+a+"&__utmb="+b+"&__utmc="+c+"&__utmz="+escape(z)+"&__utmv="+escape(v);
 }
 if (p) {
  if (f.action.indexOf("?")<=-1) f.action+="?"+p;
  else f.action+="&"+p;
 }
 return;
}
function __utmSetVar(v) {
 if (!v || v=="") return;
 var r=Math.round(Math.random() * 2147483647);
 _ubd.cookie="__utmv="+_udh+"."+escape(v)+"; path=/; expires=Sun, 18 Jan 2038 00:00:00 GMT;"+_udo;
 var s="&utmt=var&utmn="+r;
 if (_userv==0 || _userv==2) {
  var i=new Image(1,1);
  i.src=_ugifpath+"?"+"utmwv="+_uwv+s;
  i.onload=function() { _uVoid(); }
 }
 if (_userv==1 || _userv==2) {
  var i2=new Image(1,1);
  i2.src=_ugifpath2+"?"+"utmwv="+_uwv+s+"&utmac="+_uacct+"&utmcc="+_uGCS();
  i2.onload=function() { _uVoid(); }
 }
}
function _uGCS() {
 var t,c="",dc=_ubd.cookie;
 if ((t=_uGC(dc,"__utma="+_udh,";"))!="-") c+=escape("__utma="+t+";+");
 if ((t=_uGC(dc,"__utmb="+_udh,";"))!="-") c+=escape("__utmb="+t+";+");
 if ((t=_uGC(dc,"__utmc="+_udh,";"))!="-") c+=escape("__utmc="+t+";+");
 if ((t=_uGC(dc,"__utmz="+_udh,";"))!="-") c+=escape("__utmz="+t+";+");
 if ((t=_uGC(dc,"__utmv="+_udh,";"))!="-") c+=escape("__utmv="+t+";");
 if (c.charAt(c.length-1)=="+") c=c.substring(0,c.length-1);
 return c;
}
function _uGC(l,n,s) {
 if (!l || l=="" || !n || n=="" || !s || s=="") return "-";
 var i,i2,i3,c="-";
 i=l.indexOf(n);
 i3=n.indexOf("=")+1;
 if (i > -1) {
  i2=l.indexOf(s,i); if (i2 < 0) { i2=l.length; }
  c=l.substring((i+i3),i2);
 }
 return c;
}
function _uDomain() {
 if (!_udn || _udn=="" || _udn=="none") { _udn=""; return 1; }
 if (_udn=="auto") {
  var d=_ubd.domain;
  if (d.substring(0,4)=="www.") {
   d=d.substring(4,d.length);
  }
  _udn=d;
 }
 if (_uhash=="off") return 1;
 return _uHash(_udn);
}
function _uHash(d) {
 if (!d || d=="") return 1;
 var h=0,g=0;
 for (var i=d.length-1;i>=0;i--) {
  var c=parseInt(d.charCodeAt(i));
  h=((h << 6) & 0xfffffff) + c + (c << 14);
  if ((g=h & 0xfe00000)!=0) h=(h ^ (g >> 21));
 }
 return h;
}
function _uFixA(c,s,t) {
 if (!c || c=="" || !s || s=="" || !t || t=="") return "-";
 var a=_uGC(c,"__utma="+_udh,s);
 var lt=0,i=0;
 if ((i=a.lastIndexOf(".")) > 9) {
  _uns=a.substring(i+1,a.length);
  _uns=(_uns*1)+1;
  a=a.substring(0,i);
  if ((i=a.lastIndexOf(".")) > 7) {
   lt=a.substring(i+1,a.length);
   a=a.substring(0,i);
  }
  if ((i=a.lastIndexOf(".")) > 5) {
   a=a.substring(0,i);
  }
  a+="."+lt+"."+t+"."+_uns;
 }
 return a;
}
function _uTrim(s) {
  if (!s || s=="") return "";
  while ((s.charAt(0)==' ') || (s.charAt(0)=='\n') || (s.charAt(0,1)=='\r')) s=s.substring(1,s.length);
  while ((s.charAt(s.length-1)==' ') || (s.charAt(s.length-1)=='\n') || (s.charAt(s.length-1)=='\r')) s=s.substring(0,s.length-1);
  return s;
}

function _uEC(s) {
  var n="";
  if (!s || s=="") return "";
  for (var i=0;i<s.length;i++) {if (s.charAt(i)==" ") n+="+"; else n+=s.charAt(i);}
  return n;
}

function __utmVisitorCode() {
 var r=0,t=0,i=0,i2=0,m=31;
 var a=_uGC(_ubd.cookie,"__utma="+_udh,";");
 if ((i=a.indexOf(".",0))<0) return;
 if ((i2=a.indexOf(".",i+1))>0) r=a.substring(i+1,i2); else return "";  
 if ((i=a.indexOf(".",i2+1))>0) t=a.substring(i2+1,i); else return "";  
 var c=new Array('A','B','C','D','E','F','G','H','J','K','L','M','N','P','R','S','T','U','V','W','X','Y','Z','1','2','3','4','5','6','7','8','9');
 return c[r>>28&m]+c[r>>23&m]+c[r>>18&m]+c[r>>13&m]+"-"+c[r>>8&m]+c[r>>3&m]+c[((r&7)<<2)+(t>>30&3)]+c[t>>25&m]+c[t>>20&m]+"-"+c[t>>15&m]+c[t>>10&m]+c[t>>5&m]+c[t&m];
}

 
function printThis() {
  var agt=navigator.userAgent.toLowerCase();
  if (window.print) {
     window.print();
  }
  else if (agt.indexOf("mac") != -1) {
     alert("Press 'Cmd+p' on your keyboard to print article. ");
  }
  else {
     alert("Press 'Ctrl+p' on your keyboard to print article. ");
  }
  
}

function closeThis() {
    var agt=navigator.userAgent.toLowerCase();
    var is_major=parseInt(navigator.appVersion);

    var is_ie    =((agt.indexOf("msie") != -1) && (agt.indexOf("opera") == -1));
	var is_ie3   =(is_ie && (is_major < 4));
	var is_ie4   =(is_ie && (is_major == 4) && (agt.indexOf("msie 4")!=-1) );
	var is_ie5up =(is_ie && !is_ie3 && !is_ie4);

    if (window.open && !window.closed) {
        if (agt.indexOf("mac") != -1 && is_ie5up ) {
            window.close();
        }
        else if (agt.indexOf("mac") != -1) {
           // alert("Press 'Cmd+w' on your keyboard to close window. ");
		   window.close();
        }
        else {
            window.close();
        }
    }
}

// User Preferences code begins

redirectToPref();

function setCookie(name, value, expires, path, domain, secure)
{
  var curCookie=name + "=" + escape(value) +
          ((expires) ? "; expires=" + expires.toGMTString() : "") +
          ((path) ? "; path=" + path : "") +
          ((domain) ? "; domain=" + domain : "") +
          ((secure) ? "; secure" : "");
  document.cookie=curCookie;
}

function getCookie(name)
{
  var dc=document.cookie;
  var prefix=name + "=";
  var begin=dc.indexOf("; " + prefix);
  if (begin == -1) {
        begin=dc.indexOf(prefix);
        if (begin != 0) return null;
  } else
        begin += 2;
  var end=document.cookie.indexOf(";", begin);
  if (end == -1)
        end=dc.length;
  return unescape(dc.substring(begin + prefix.length, end));
}

function updateSessionPref()
{
  var sessionCk=getCookie("sessionpref");
  if (sessionCk == null) {
    return;
  }

  var prevSessionCk=parseInt(sessionCk);
  var url=document.location.href;

  var lb_idx=url.indexOf("/lb/");
  var nonflash_idx=url.indexOf("flash=0");
  var para_idx=url.indexOf("flash=");

  if(lb_idx != -1) {
    setCookie("sessionpref", 2, null, "/", null, null);
  } else if((nonflash_idx != -1) || ((para_idx == -1)&&(prevSessionCk == 1))) {
    setCookie("sessionpref", 1, null, "/", null, null);
  } else {
    setCookie("sessionpref", 0, null, "/", null, null);
  }
}

function redirectToPref()
{
  updateSessionPref();
  var sessionCk=getCookie("sessionpref");
  if (sessionCk != null) {
    return;
  }
  var siteVersion=parseInt(getCookie("viewsite"));

  switch(siteVersion) {
    case 0:
    case 1:
      var url=document.location.href;
      var idx=url.indexOf("/lb/");
      if (idx != -1) {
        newurl=url.substring(0, idx) + "/" + url.substring(idx + "/lb/".length, url.length);
        url=newurl;
        document.write("Redirecting to user preferences...");
		window.location=url;
      }
      break;
    case 2:
      var url=document.location.href;
      var textval=url.indexOf("/lb/");
      if(textval == -1) {
        var url_except_http=url.substring("http://".length, url.length);
        var idx=url_except_http.indexOf("/");
        var url_domain=url_except_http.substring(0, idx);
        var lb_url="http://" + url_domain + "/lb/" + url_except_http.substring(idx+1, url_except_http.length);
        document.write("Redirecting to user preferences...");
        window.location=lb_url;
      }
      break;
  }

  setCookie("sessionpref", siteVersion, null, "/", null, null);
}

// User Preferences code ends

function watchNASALiveTVRedesign(channel)
{
        
		if(  channel!='undefined' && channel!=eval('') && channel!=null && channel!='' )
	    { 
		window.location='/multimedia/nasatv/index.html?param='+channel;
		}
 
}

// added for the gov delivery rss feed form */
function govdelivery_subscribe() {
	window.location="http://service.govdelivery.com/service/subscribe.html?code=" + document.govdelivery.folder.value +"&login=" + document.govdelivery.textinput.value + "&origin=" + window.location.href;
}

function govdelivery_quicksubscribe() {
	window.location="http://service.govdelivery.com/service/multi_subscribe.html?code=" + document.govdelivery.folder.value +"&login=" + document.govdelivery.textinput.value + "&origin=" + window.location.href;
}
// end of the gov delivery rss feed form */















































