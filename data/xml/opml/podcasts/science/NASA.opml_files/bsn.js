var auto_complete_flag = true;
var auto_complete_delay = 500;
var auto_complete_timeout = 2500;
var auto_complete_max_entries = 10;
var auto_complete_max_results = 201;

var ahCalls = {
	
	theReturnType:null,
	called:false,
	queryStr:null,
	counter:0,
	scriptTagCallBackFunction:null,
	scriptTagJsonType:null,
	
	createAhCall:function(httpType,url,returnType,callBackFunction,params,proxyPath)
	{
		if(!document.getElementById || !document.createTextNode){return;}
		this.theReturnType = returnType;
		
		if(httpType != 'scriptTag'){//is not using script tag
			this.queryStr = (!params) ? null : encodeURIComponent(params);
			var xmlHttp = ahCalls.createXmlHttpObject();
			if (xmlHttp.readyState == 4 || xmlHttp.readyState == 0){// proceed only if the xmlHttp object isn't busy
				
				xmlHttp.onreadystatechange = function(){// define the method to handle server responses
				
					switch(xmlHttp.readyState){
						case 1: if(!this.called){/*alert('waiting on server!');*/this.called = true} break;
						case 2: break;
						case 3: break;
						case 4:
							if ( xmlHttp.status == 200 ){// only if "OK"
								try{
									responseObj = ahCalls.parseXmlHttpResponse(xmlHttp);
									success = true;
								}catch(e){ 
									alert('Parsing Error: The value returned could not be evaluated.');
									success = false;
								}
								if(success) callBackFunction( responseObj ); //if all is good send the response to the callback function
							}else{ 
								alert("There was a problem retrieving the data:\n" + xmlHttp.statusText);
							}
							break;
					}
				}
				
				if(httpType == 'get' || httpType == 'post'){
					xmlHttp.open(httpType, ahCalls.noCache(url), true);
				}else{
					if(httpType == 'proxyGet'){
						xmlHttp.open('get', (proxyPath+'?path='+(encodeURIComponent(url))), true);
					};
					if(httpType == 'proxyPost'){
						xmlHttp.open('put', (proxyPath+'?path='+(encodeURIComponent(url))), true);
					};
				}
				
				if(params){xmlHttp.setRequestHeader("Content-Type","application/x-www-form-urlencoded; charset=UTF-8")};
				xmlHttp.send(this.queryStr);// make the server request and send queryStr or null as an argument
				
			}else{// if the connection is busy, try again after one second 
				setTimeout('ahCalls.createAhCall();', 1000);
			}
		}else{//using scriptTag
			this.scriptTagCallBackFunction = callBackFunction;
			//alert(callBackFunction);
			if(returnType == 'jsonObject' || returnType == 'jsonString'){//getting json return via script tag
			    //alert('jsonObject or jsonString');
				//ahCalls.JsonXmlScriptRequest(ahCalls.noCache(url+'&callback=ahCalls.JsonXmlScriptHandleRequest'));
				ahCalls.JsonXmlScriptRequest(url+'&callback=ahCalls.JsonXmlScriptHandleRequest');
			}else{//getting xml return via script tag
				var xmlPath = encodeURIComponent(url);
				ahCalls.JsonXmlScriptRequest(proxyPath+'?path='+xmlPath);
			}
		}	
	},
	
	createXmlHttpObject:function()
	{
		var ahCalls; // will store the reference to the XMLHttpRequest Object
		
		try{
			ahCalls = new XMLHttpRequest();// this should work for all browsers except IE6 and older
		}catch(e){
			var XmlHttpVersions = new Array('MSXML2.XMLHTTP.6.0','MSXML2.XMLHTTP.5.0','MSXML2.XMLHTTP.4.0','MSXML2.XMLHTTP.3.0','MSXML2.XMLHTTP','Microsoft.XMLHTTP');
			for (var i=0; i<XmlHttpVersions.length && !ahCalls; i++) {
				try { 
					// try to create XMLHttpRequest object
					ahCalls = new ActiveXObject(XmlHttpVersions[i]);
				}catch (e) {}
			}
		}
		
		if(!ahCalls){alert("Error creating the XMLHttpRequest Object.")}else{return ahCalls};// return the created object or display an error message		
	},
	
	JsonXmlScriptRequest:function(fullUrl)
	{
		//alert('Inside JsonXmlScriptRequest()');
		//alert(fullUrl);
		ahCalls.counter += 1;
		var scriptId = 'JscriptId' + ahCalls.counter;
		
		var scriptObj = document.createElement("script");// Create the script tag
		
    	scriptObj.setAttribute("type", "text/javascript");   // Add script object attributes
		scriptObj.setAttribute("charset", "utf-8");
		scriptObj.setAttribute("src", fullUrl);
		scriptObj.setAttribute("id", scriptId);
		var headLoc = document.getElementsByTagName("head").item(0);
		headLoc.appendChild(scriptObj);
	},
	
	JsonXmlScriptHandleRequest:function(jsonData)
	{
		//alert('Inside JsonXmlScriptHandleRequest()');
		switch(ahCalls.theReturnType) {
		case "xmlObject": var xmlDataObject = ahCalls.xmlTextToObject(jsonData); ahCalls.scriptTagCallBackFunction(xmlDataObject);break;
		case "xmlString": ahCalls.scriptTagCallBackFunction(jsonData); break;
		case "jsonObject": this.scriptTagCallBackFunction.processReqChange(jsonData) /*ahCalls.scriptTagCallBackFunction(jsonData)*/; break;
		case "jsonString": /*var jsonDataString = jsonData.toJSONString();ahCalls.scriptTagCallBackFunction(jsonDataString);*/ break;
		default: 
			// if there is no case "*" match, execute this code
			alert("error")
		};
		
		var scriptElement;
		for (var i = 1; i < 10; i++) {
			scriptElement = document.getElementById('JscriptId' + i);
			if(scriptElement){
			document.getElementsByTagName("head")[0].removeChild(scriptElement);
			}
		}
	},
	
	parseXmlHttpResponse:function(responseObject){
		var theType = ahCalls.theReturnType;
		if(theType != 'proxyPost' || theType != 'proxyGet'){//local xhr call
			switch(theType) {
			case "string": return responseObject.responseText; break;
			case "xmlObject": return responseObject.responseXML; break;
			case "xmlString": return responseObject.responseText; break;
			case "jsonObject": return responseObject.responseText.parseJSON();break;
			case "jsonString": return responseObject.responseText; break;
			default: 
				// if there is no case "*" match, execute this code
				alert("error")
			}
		}else{
			switch(theType) {//cross domain xhr to proxy and then back again
			case "xmlObject": return responseObject.responseXML; break;
			case "xmlString": return responseObject.responseText; break;
			case "jsonObject": return responseObject.responseText.parseJSON();break;
			case "jsonString": return responseObject.responseText; break;
			default: 
				// if there is no case "*" match, execute this code
				alert("error")
			}
		}
	},
	
	xmlTextToObject:function(text){
		if (typeof DOMParser != "undefined") {
		// Mozilla, Firefox, and related browsers
		return (new DOMParser()).parseFromString(text, "application/xml");
		}
		else if (typeof ActiveXObject != "undefined") {
			// Internet Explorer.
			var doc = new ActiveXObject("MSXML2.DOMDocument");  // Create an empty document
			doc.loadXML(text);            // Parse text into it
			return doc;                   // Return it
		}
		else {
			// As a last resort, try loading the document from a data: URL
			// This is supposed to work in Safari.
			var url = "data:text/xml;charset=utf-8," + encodeURIComponent(text);
			var request = new XMLHttpRequest();
			request.open("GET", url, false);
			request.send(null);
			return request.responseXML;
		}
	},
	
	noCache:function (url){
		//alert('Inside noCache()');
		var qs = new Array();
		var arr = url.split('?');
		var scr = arr[0];
		if(arr[1]) qs = arr[1].split('&');
		qs[qs.length]='nocache='+new Date().getTime();
		//alert(scr+'?'+qs.join('&'));
		return scr+'?'+qs.join('&');
	}

};
/************************************* end of ahCalls.js *******************************************************/



/**
* Author:		Timothy Groves - http://www.brandspankingnew.net
* version:	1.2 - 2006-11-17
*           1.3 - 2006-12-04
*           2.0 - 2007-02-07
*           2.1.1 - 2007-04-13
*           2.1.2 - 2007-07-07
*           2.1.3 - 2007-07-19
*
* This script is released under Creative Common License.  To know about this license
* please visit http://creativecommons.org/licenses/by-sa/2.5/
*
* This js has been modified from the original one:
*	-  "maxresultes" is added as an option with its default value(200) so that the query will 
*      return that number of results unless it is overwritten by the user's value.
*      However, "maxentries" detectes the # of items to be displayed from "maxresults" 
*      and the remaining enteries will be cached for subsequent use.
*
*   -  When cache is enable, the default "backspace" behaviour (sending a new query in each backspace pressed) is
*      also altered to use the caching data instead. 
*
*   -  Instead of using the eval() directly, evalJSON (prototype.js) is used to validate the JSON syntax before using eval().
*      For example.
*			<string>.evalJSON(validation);
*    		
*           where: "validation" is a boolean type; 
*/
var tempList=[]; //varibale for holding temp list.

if(typeof(bsn)=="undefined")
	_b=bsn={};
	
if(typeof(_b.Autosuggest)=="undefined")
	_b.Autosuggest={};
else 
	alert("Autosuggest is already set!");
	
_b.AutoSuggest=function(b,c){
	if(!document.getElementById)
		return 0;
	
	this.fld=_b.DOM.gE(b);
	if(!this.fld)
		return 0;
	
	this.sInp="";
	this.nInpC=0;
	this.aSug=[];
	this.iHigh=0;
	this.oP=c?c:{};
	var k,
	def={
			minchars:1,
			meth:"get",
			varname:"input",
			className:"autosuggest",
			timeout:auto_complete_timeout,
			delay:auto_complete_delay,
			offsety:-5,
			shownoresults:true,
			noresults:"No results!",
			maxheight:250,
			cache:true,
			maxentries:25,
			maxresults:200  //added option for a cache
		};
	
	for(k in def){
		if(typeof(this.oP[k])!=typeof(def[k]))
			this.oP[k]=def[k]
	}
	
	var p=this;
	this.fld.onkeypress=function(a){return p.onKeyPress(a)};
	this.fld.onkeyup=function(a){return p.onKeyUp(a)};
	this.fld.setAttribute("autocomplete","off")
	
};
	
_b.AutoSuggest.prototype.onKeyPress=function(a){
	var b=(window.event)?window.event.keyCode:a.keyCode;
	var c=13;
	var d=9;
	var e=27;
	var f=1;
		
	switch(b){
		case c:this.setHighlightedValue();
				f=0;
				break;
		case d:this.setHighlightedValue();
				f=0;
				break;
		case e:this.clearSuggestions();
				break
	}
	return f
};
	
_b.AutoSuggest.prototype.onKeyUp=function(a){
	var b=(window.event)?window.event.keyCode:a.keyCode;
	var c=38;
	var d=40;
	var e=1;
		
	switch(b){
		case c:this.changeHighlight(b);
				e=0;
				break;
		case d:this.changeHighlight(b);
				e=0;
				break;
		default:this.getSuggestions(this.fld.value)
	}
	return e
};

_b.AutoSuggest.prototype.getSuggestions=function(a){
	if(a==this.sInp)
		return 0;
			
	_b.DOM.remE(this.idAs);
	this.sInp=a;
		
	if(a.length<this.oP.minchars){
		this.aSug=[];
		this.nInpC=a.length;
		return 0
	}
		
	var b=this.nInpC;
	this.nInpC=a.length?a.length:0;
		
	var l=this.aSug.length;
	var c=[];
	tempList=[];
	//if(this.nInpC>b&&l&&this.oP.cache){ //backspace is not handle(i.e. backspace makes a fresh call)
	if(this.oP.cache){ //backspace is handle(i.e. it uses the cache data if cache is enabled.)

		 for(var i=0;i<l;i++){ //Cache all the data. 
			    if(this.aSug[i].value.substr(0,a.length).toLowerCase()==a.toLowerCase()) {
				     tempList.push(this.aSug[i])
				  }  
				  if(tempList.length == this.oP.maxentries)break; 
		 }

		 if(tempList.length > 0) {  //displaying only the matched data.
			  this.createList(tempList);
			  return false
		 }else{
		   if(l > 1) {
		      var initial=(this.aSug[0].value.length>1)?this.aSug[0].value.substr(0,1):this.aSug[0].value;
		      var temp = (a.length>1)?a.substr(0,1):a;
		      if(initial.toLowerCase()==temp.toLowerCase())
		         return false;	
		   }
		   //retrieve a new list
		   var d=this;
		   var r=this.retrieveNewList(d);
		}
	}else{
		//Since caching is disable, make a call to retrieve a new list . 
		var d=this;
		var r=this.retrieveNewList(d);
	}
	return false
};
	
_b.AutoSuggest.prototype.retrieveNewList=function(a){
	//Call to retrieve a new list.
	var e=this.sInp;
	clearTimeout(this.ajID);
	this.ajID=setTimeout(function(){a.doAjaxRequest(e)},this.oP.delay)
};
	
_b.AutoSuggest.prototype.doAjaxRequest=function(b){
	if(b!=this.fld.value)
		return false;
		
	var	initial=(b.length>1)?b.substr(0,1):b;	
	var c=this;
	if(typeof(this.oP.script)=="function")
		var d=this.oP.script(encodeURIComponent(this.sInp)+"&result="+encodeURIComponent(this.oP.maxresults));
	else 
		//var d=this.oP.script+this.oP.varname+"="+encodeURIComponent(this.sInp)+"&result="+encodeURIComponent(this.oP.maxresults);
		var d=this.oP.script+this.oP.varname+"="+encodeURIComponent(initial)+"&result="+encodeURIComponent(this.oP.maxresults);
		
	if(!d)
		return false;
		
	var e=this.oP.meth;
	var b=this.sInp;
	var f=function(a,sudata){c.setSuggestions(a,b,sudata)};
	var g=function(a){/*alert("AJAX error: "+a)*/};
	var h=new _b.Ajax();
	h.makeRequest(d,e,f,g)
};
	
_b.AutoSuggest.prototype.setSuggestions=function(a,b,sudata){
	if(b!=this.fld.value)
		return false;
	var temp=[];		
	tempList=[];
	this.aSug=[];
	if(this.oP.json){
	   try {   
		   //var c=a.responseText.evalJSON(true);
		   /*
		   alert('in suggest' + sudata);
			 var txt = '';  
			 for(var key in sudata) {  
				 txt += key + " = " + sudata[key];  
				 txt += "\n";  
			 }  
			 alert(txt);  
			*/
		   var c=sudata;

		  // alert(c.results.length);  
		   for(var i=0;i<c.results.length;i++){		//Caching the data       	       
			     this.aSug.push({
			       'id':c.results[i].id,
				     'value':c.results[i].value,
				     'info':c.results[i].info
			     })
		   }
	   } catch (e) {/*alert("Invalid Data");*/}
	}else{
		var d=a.responseXML;
		var e=d.getElementsByTagName('results')[0].childNodes;
		for(var i=0;i<e.length;i++){
			if(e[i].hasChildNodes())
				this.aSug.push({
				  'id':e[i].getAttribute('id'),
				  'value':e[i].childNodes[0].nodeValue,
				  'info':e[i].getAttribute('info')
				})
		}
	}
	if(this.aSug.length > 0) {  //displaying the matched data
		 for(var i=0;i<this.aSug.length;i++){
			   if(this.aSug[i].value.substr(0,b.length).toLowerCase()==b.toLowerCase())
				    //temp.push(this.aSug[i]);
					tempList.push(this.aSug[i]);
				    if(this.aSug.length == this.oP.maxentries)break;
		 }
	}
	this.idAs="as_"+this.fld.id;
	//this.createList(this.aSug)
	this.createList(tempList)
};
	
_b.AutoSuggest.prototype.createList=function(b){
	var c=this;
	_b.DOM.remE(this.idAs);
	this.killTimeout();
	if(b.length==0&&!this.oP.shownoresults)
		return false;
			
	var d=_b.DOM.cE("div",{id:this.idAs,className:this.oP.className});
	var e=_b.DOM.cE("div",{className:"as_corner"});
	var f=_b.DOM.cE("div",{className:"as_bar"});
	var g=_b.DOM.cE("div",{className:"as_header"});
	g.appendChild(e);
	g.appendChild(f);
	d.appendChild(g);
	var h=_b.DOM.cE("ul",{id:"as_ul"});
	var displaylen=this.oP.maxentries < b.length?this.oP.maxentries:b.length; 
	//alert("createList : length = "+displaylen);
	for(var i=0;i<displaylen;i++){
		var j=b[i].value;
		var k=j.toLowerCase().indexOf(this.sInp.toLowerCase());
		var l=j.substring(0,k)+"<span class='key'><em>"+j.substring(k,k+this.sInp.length)+"</em>"+j.substring(k+this.sInp.length)+"</span>";
		var m=_b.DOM.cE("span",{},l,true);
			
		if(b[i].info!=""){
			//var n=_b.DOM.cE("br",{});
			//m.appendChild(n);
			var o=_b.DOM.cE("span",{className:"info"},b[i].info);
			m.appendChild(o)
		}
			
		var a=_b.DOM.cE("a",{href:"#"});
		var p=_b.DOM.cE("span",{className:"tl"}," ");
		var q=_b.DOM.cE("span",{className:"tr"}," ");
		a.appendChild(p);
		a.appendChild(q);
		a.appendChild(m);
		a.name=i+1;
		a.onclick=function(){c.setHighlightedValue();return false};
		a.onmouseover=function(){c.setHighlight(this.name)};
			
		var r=_b.DOM.cE("li",{},a);
			
		h.appendChild(r)
	}
		
	if(b.length==0&&this.oP.shownoresults){
		var r=_b.DOM.cE("li",{className:"as_warning"},this.oP.noresults);
		h.appendChild(r)
	}
	d.appendChild(h);
	var s=_b.DOM.cE("div",{className:"as_corner"});
	var t=_b.DOM.cE("div",{className:"as_bar"});
	var u=_b.DOM.cE("div",{className:"as_footer"});
	u.appendChild(s);
	u.appendChild(t);
	d.appendChild(u);
	var v=_b.DOM.getPos(this.fld);
	d.style.left=v.x+"px";
	d.style.top=(v.y+this.fld.offsetHeight+this.oP.offsety)+"px";
	d.style.width=this.fld.offsetWidth+"px";
	d.onmouseover=function(){c.killTimeout()};
	d.onmouseout=function(){c.resetTimeout()};
	document.getElementsByTagName("body")[0].appendChild(d);
	this.iHigh=0;
	var c=this;
	this.toID=setTimeout(function(){c.clearSuggestions()},this.oP.timeout)
};
	
_b.AutoSuggest.prototype.changeHighlight=function(a){
	var b=_b.DOM.gE("as_ul");
	if(!b)return false;
		
	var n;
	if(a==40)
		n=this.iHigh+1;
	else 
		if(a==38)
			n=this.iHigh-1;
		if(n>b.childNodes.length)
			n=b.childNodes.length;
		if(n<1)
			n=1;

	this.setHighlight(n)
};
	
_b.AutoSuggest.prototype.setHighlight=function(n){
	var a=_b.DOM.gE("as_ul");
		
	if(!a)
		return false;
		
	if(this.iHigh>0)
		this.clearHighlight();
			
	this.iHigh=Number(n);
	a.childNodes[this.iHigh-1].className="as_highlight";
	this.killTimeout()
};
	
_b.AutoSuggest.prototype.clearHighlight=function(){
	var a=_b.DOM.gE("as_ul");
		
	if(!a)return false;
	if(this.iHigh>0){
		a.childNodes[this.iHigh-1].className="";
		this.iHigh=0
	}
};
		
_b.AutoSuggest.prototype.setHighlightedValue=function(){
	if(this.iHigh){
		this.sInp=this.fld.value=tempList[this.iHigh-1].value; //this.aSug[this.iHigh-1].value;
		this.fld.focus();
			
		if(this.fld.selectionStart)
			this.fld.setSelectionRange(this.sInp.length,this.sInp.length);
			
		this.clearSuggestions();
			
		if(typeof(this.oP.callback)=="function")
			this.oP.callback(this.aSug[this.iHigh-1])
	}
};
	
_b.AutoSuggest.prototype.killTimeout=function(){clearTimeout(this.toID)};
	
_b.AutoSuggest.prototype.resetTimeout=function(){
	clearTimeout(this.toID);
	var a=this;
	this.toID=setTimeout(function(){a.clearSuggestions()},1000)
};
	
_b.AutoSuggest.prototype.clearSuggestions=function(){
	this.killTimeout();
	var a=_b.DOM.gE(this.idAs);
	var b=this;
		
	if(a){
		var c=new _b.Fader(a,1,0,250,function(){_b.DOM.remE(b.idAs)})
	}
};
	
if(typeof(_b.Ajax)=="undefined")
	_b.Ajax={};
_b.Ajax=function(){
	this.req={};
	this.isIE=false
};
		
_b.Ajax.prototype.makeRequest=function(a,b,c,d){
	if(b!="POST")
		b="GET";
			
	this.onComplete=c;
	this.onError=d;
	var e=this;

	if(window.XMLHttpRequest){
		this.req=new XMLHttpRequest();
		//this.req.onreadystatechange=function(){e.processReqChange()};
		//this.req.open("GET",a,true);
		//this.req.send(null)
	}else 
		if(window.ActiveXObject){
			this.req=new ActiveXObject("Microsoft.XMLHTTP");
			/*
			if(this.req){
				this.req.onreadystatechange=function(){e.processReqChange()};
				this.req.open(b,a,true);
				this.req.send()
			}
			*/
		}

	 ahCalls.createAhCall('scriptTag',a,'jsonObject',this,false,false);
};
		
_b.Ajax.prototype.processReqChange=function(sudata){

			//alert('test1');
			
			this.onComplete(this.req,sudata)

/*
	if(this.req.readyState==4){
		if(this.req.status==200 || 301){
			alert('test2');
			this.req.responseText = suggData;
			this.onComplete(this.req)
		}else{
			this.onError(this.req.status)
		}
	}
	*/
};

		
if(typeof(_b.DOM)=="undefined")
	_b.DOM={};
	
_b.DOM.cE=function(b,c,d,e){
	var f=document.createElement(b);
	if(!f)return 0;
				
	for(var a in c)f[a]=c[a];
				
	var t=typeof(d);
	if(t=="string"&&!e)
		f.appendChild(document.createTextNode(d));
	else 
		if(t=="string"&&e)
			f.innerHTML=d;
		else 
			if(t=="object")
				f.appendChild(d);
	return f
};
			
_b.DOM.gE=function(e){
	var t=typeof(e);
				
	if(t=="undefined")
		return 0;
	else 
		if(t=="string"){
			var a=document.getElementById(e);
			if(!a)
				return 0;
			else 
				if(typeof(a.appendChild)!="undefined")
					return a;
				else 
					return 0
		}else 
			if(typeof(e.appendChild)!="undefined")
				return e;
			else 
				return 0
};
			
_b.DOM.remE=function(a){
	var e=this.gE(a);
	if(!e)
		return 0;
	else 
		if(e.parentNode.removeChild(e))
			return true;
		else 
			return 0
};
			
_b.DOM.getPos=function(e){
	var e=this.gE(e);
	var a=e;
	var b=0;
				
	if(a.offsetParent){
		while(a.offsetParent){
			b+=a.offsetLeft;
			a=a.offsetParent
		}
	}else 
		if(a.x)
			b+=a.x;
		var a=e;
		var c=0;
		if(a.offsetParent){
			while(a.offsetParent){
				c+=a.offsetTop;
				a=a.offsetParent
			}
		}else 
			if(a.y)
				c+=a.y;
	return{x:b,y:c}
};
			
if(typeof(_b.Fader)=="undefined")
	_b.Fader={};
				
_b.Fader=function(a,b,c,d,e){
	if(!a)
		return 0;
	this.e=a;
	this.from=b;
	this.to=c;
	this.cb=e;
	this.nDur=d;
	this.nInt=50;
	this.nTime=0;
	var p=this;
	this.nID=setInterval(function(){p._fade()},this.nInt)
};
				
_b.Fader.prototype._fade=function(){
	this.nTime+=this.nInt;
	var a=Math.round(this._tween(this.nTime,this.from,this.to,this.nDur)*100);
	var b=a/100;
	if(this.e.filters){
		try{
				this.e.filters.item("DXImageTransform.Microsoft.Alpha").opacity=a
		}catch(e){
			this.e.style.filter='progid:DXImageTransform.Microsoft.Alpha(opacity='+a+')'
		}
	}else{
		this.e.style.opacity=b
	}
					
	if(this.nTime==this.nDur){
		clearInterval(this.nID);
		if(this.cb!=undefined)this.cb()
	}
};
			
_b.Fader.prototype._tween=function(t,b,c,d){return b+((c-b)*(t/d))};

/******* Suggestive Search Implementation ********/
var hdr_options = {
	script:"http://search.nasa.gov/search/suggestiveSearch?",
	varname:"nasaInclude",
	json:true,
	shownoresults:false,
	maxentries:auto_complete_max_entries,
	maxresults:auto_complete_max_results
};

Event.observe(window, 'load', function() {
	if (auto_complete_flag && showPageLevel()){
		new bsn.AutoSuggest('nasaInclude', hdr_options);
	}
});


function showPageLevel() {
	if(typeof(enableSuggestiveSearch) !== 'undefined' && enableSuggestiveSearch != null) {
		return enableSuggestiveSearch;
	} else {
		return true;
	}
}
