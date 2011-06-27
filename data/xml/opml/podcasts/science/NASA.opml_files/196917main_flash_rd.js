var swf=false;
var swfAllow=(window.location.search.indexOf('flash=0')+1) ? false : true;

// User Preferences code begins

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

function checkFlashPref() {
  // session preference overrides persistent user preference
  if (getCookie("sessionpref") == 1) {
    swfAllow=false;
    return;
  }
}

checkFlashPref();

// User Preferences code ends

function hasFlash(ver) {
  if(!swfAllow) return false;
  if(!ver) ver=0;
	var n=navigator;
  if(n.plugins && n.plugins.length > 0) {
    var m,t,d,v;
    m=n.mimeTypes;
    t='application/x-shockwave-flash';
    if(m && m[t] && m[t].enabledPlugin && m[t].enabledPlugin.description) {
      d=m[t].enabledPlugin.description;
      v=d.charAt(d.indexOf('.')-1);
	 
	 /*modified to be able to detect all versions*/
	  var descArray=d.split(" ");
	  var tempArrayMajor=descArray[2].split(".");		
	  var versionMajor=tempArrayMajor[0];
	  var versionMinor=tempArrayMajor[1];
	  var versionRevision=descArray[3];

		swf=(versionMajor >= ver) ? true : false;
    }
  } else if(n.appVersion.indexOf("Mac") == -1 && window.execScript) {
    for(var i=ver; i<=7&&i!=1&&swf!=true; i++) {
      execScript('on error resume next: swf=IsObject(CreateObject("ShockwaveFlash.ShockwaveFlash'+((i==0)?'':'.'+i)+'"))','VBScript');
    }
	} else {
	  swf=false;
	}
	return swf;
}

function switchFlash() {
  var val=(swfAllow) ? '0' : '1';
	var s=window.location.href.split('#')[0];
  if(window.location.search) {
	  if(s.indexOf('flash=')+1) {
		  s=s.replace('flash='+s.split('flash=')[1].split('&')[0],'flash='+val);
		} else {
		  s += '&flash='+val;
		}
	} else {
	  s += '?flash='+val;
	}
	window.location.href=s;
}

function allowFlash() {
  if((!hasFlash(5)) && (swfAllow)) return '';
  var s='<span class="flashClass">&rsaquo;&nbsp;<a href="#" onclick="switchFlash(); return false;">';
	s += (swfAllow) ? 'Non-Flash Version' : 'Flash Version' ;
	s += '</a><br/></span>';
	return s;
}

function newAllowFlash() {
  if((!hasFlash(5)) && (swfAllow)) return '';
  var s='<span class="flashClass">&rsaquo;&nbsp;<a href="#" onclick="switchFlash(); return false;">';
	s += (swfAllow) ? 'Non-Flash Version' : 'Flash Version' ;
	s += '</a><br/></span>';
	return s;
}

function moveFocus(id) {
  var o=document.getElementById(id);
	if(o) o.focus();
}

function showEmbeddedFlash(filename, widthValue, heightValue, bgcolorValue, nameValue, alignValue) {
     var fstrs='';
	 var wmode='transparent'
     fstrs+='<object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,29,0" ';
     fstrs+='width="' + widthValue + '" height="' + heightValue +'">';
     fstrs+='<param name="movie" value="' + filename +'">'; //Flash Filename
     fstrs+='<param name="quality" value="high">';
	 fstrs+='<param name="wmode" value="' + wmode + '">';
     fstrs+='<param name="bgcolor" value="'+ bgcolorValue + '">';
     fstrs+='<embed src="' + filename +'" quality="high" bgcolor="' + bgcolorValue +'" pluginspage="http://www.macromedia.com/go/getflashplayer" type="application/x-shockwave-flash" ';
     fstrs+='width="'+ widthValue + '" height="' + heightValue + '" name="' + nameValue + '" align="' + alignValue +'" wmode="' + wmode + '"></embed>';
     fstrs+='</object>'; //Flash Filename
     with(document) { open('text/html'); write(fstrs); close(); }
}



function showEmbeddedFlash(filename, widthValue, heightValue, bgcolorValue, nameValue, alignValue, version) {
     var fstrs='';
     fstrs+='<object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version="' + version + '" ';
     fstrs+='width="' + widthValue + '" height="' + heightValue + '" id="' + nameValue +'">';
     fstrs+='<param name="movie" value="' + filename +'">'; //Flash Filename
     fstrs+='<param name="quality" value="high">';
	 fstrs+='<param name="wmode" value="transparent">';
     fstrs+='<param name="bgcolor" value="'+ bgcolorValue + '">';
     fstrs+='<embed src="' + filename +'" quality="high" bgcolor="' + bgcolorValue +'" pluginspage="http://www.macromedia.com/go/getflashplayer" type="application/x-shockwave-flash" ';
     fstrs+='width="'+ widthValue + '" height="' + heightValue + '" name="' + nameValue + '" align="' + alignValue +'" wmode="transparent"></embed>';
     fstrs+='</object>';  
     with(document) { open('text/html'); write(fstrs); close(); }
}

function showEmbeddedFlash(filename, widthValue, heightValue, bgcolorValue, nameValue, alignValue, wmode, version, scale, scriptAccess) {
     var fstrs='';
     fstrs+='<object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version="' + version + '" ';
     fstrs+='width="' + widthValue + '" height="' + heightValue + '" id="' + nameValue +'">';
     fstrs+='<param name="movie" value="' + filename +'">'; //Flash Filename
     fstrs+='<param name="quality" value="high">';
     fstrs+='<param name="bgcolor" value="'+ bgcolorValue + '">';
     fstrs+='<param name="wmode" value="' + wmode + '">';
     fstrs+='<param name="allowScriptAccess=" value="' + scriptAccess + '">';
     fstrs+='<embed src="' + filename +'" quality="high" bgcolor="' + bgcolorValue +'"';
     fstrs+='allowScriptAccess="' + scriptAccess + '" scale="' + scale + '" wmode="' + wmode + '" pluginspage="http://www.macromedia.com/go/getflashplayer" type="application/x-shockwave-flash" ';
     fstrs+='width="'+ widthValue + '" height="' + heightValue + '" name="' + nameValue + '" align="' + alignValue +'"></embed>';
     fstrs+='</object>';
     with(document) { open('text/html'); write(fstrs); close(); }
}

function showEmbeddedFlashForKids(filename, widthValue, heightValue, bgcolorValue, nameValue, alignValue, version) {
    var fstrs='';
    fstrs+='<table width="1" border="0" cellspacing="0" cellpadding="0">';			
    fstrs+='<tr>';
    fstrs+='<td height="5"><img border="0" alt="" height="5" width="1" src="/templateimages/common/spacer.gif"></td>';	
    fstrs+='</tr>';
    fstrs+='</table>';
    fstrs+='<object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version="' + version + '" ';
    fstrs+='width="' + widthValue + '" height="' + heightValue + '" id="' + nameValue +'">';
    fstrs+='<param name="movie" value="' + filename +'">'; //Flash Filename
    fstrs+='<param name="quality" value="high">';
	fstrs+='<param name="wmode" value="transparent">';
    fstrs+='<param name="bgcolor" value="'+ bgcolorValue + '">';
    fstrs+='<embed src="' + filename +'" quality="high" bgcolor="' + bgcolorValue +'" pluginspage="http://www.macromedia.com/go/getflashplayer" type="application/x-shockwave-flash" ';
    fstrs+='width="'+ widthValue + '" height="' + heightValue + '" name="' + nameValue + '" align="' + alignValue +'" wmode="transparent"></embed>';
    fstrs+='</object>'; //Flash Filename
    with(document) { open('text/html'); write(fstrs); close(); }
    
}

function showEmbeddedApplet(classfile, filename, widthValue, heightValue) {
  
    var fstrs='';
    fstrs +='<applet code="' + classfile + '" archive="' + filename + '" align="middle" width="'+ widthValue + '" height="' + heightValue + '"></applet>';
    with(document) { open('text/html'); write(fstrs); close();  }
}


function showEmbeddedApplet(classfile, filename, widthValue, heightValue, alignValue) {
  
    var fstrs='';
    fstrs +='<applet code="' + classfile + '" archive="' + filename + '" align="' + alignValue + '" width="'+ widthValue + '" height="' + heightValue + '"></applet>';
    with(document) { open('text/html'); write(fstrs); close();  }
}








