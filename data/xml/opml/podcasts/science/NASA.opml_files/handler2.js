
function BNMessenger(){this.server=null;this.messageNum=0;this.msgLimit=2000;this.initialized=false;this.debug=false;}
BNMessenger.prototype.initialize=function(serverAddr,handlerAddr,customer,code,key,debug){this.server=serverAddr;this.customer=customer;this.code=code;this.key=key;this.handler=handlerAddr;if(this.handler.charAt(0)!="/")this.handler="/"+this.handler;this.debug=debug;this.initialized=true;}
BNMessenger.prototype.sendMessage=function(msg){var debugArg=(this.debug)?"&debug=true":"";var msgPrefix=this.server+"/baynote"+this.handler+"?customerId="+this.customer+"&code="+this.code;if(this.key)msgPrefix+="&key="+this.key;msgPrefix+="&msgId="+this.messageNum+debugArg+"&fmt=1&len="+msg.length+"&msg=";var fullMsg=msgPrefix+encodeURIComponent(msg);var spaceLeft=this.msgLimit-fullMsg.length;if(spaceLeft>=0){bnResourceManager.loadResource("Message"+this.messageNum,fullMsg,"img");this.messageNum++;}
return spaceLeft;}
var bnMessenger=new BNMessenger();function BNBehavior()
{this.numSamples=0;this.numMouseMoves=0;this.numScrolls=0;this.lastMousePos=new Object();this.lastMousePos.x=this.lastMousePos.y=0;this.curMousePos=new Object();this.curMousePos.x=this.curMousePos.y=0;this.lastScroll=new Object();this.lastScroll.x=this.lastScroll.y=0;this.curScroll=new Object();this.curScroll.x=this.curScroll.y=0;this.maxScrollPercent=0;}
BNBehavior.prototype.activityCheck=function()
{this.numSamples++;if(this.lastMousePos.x&&this.lastMousePos.x!=this.curMousePos.x)this.numMouseMoves++;else if(this.lastMousePos.y&&this.lastMousePos.y!=this.curMousePos.y)this.numMouseMoves++;this.lastMousePos.x=this.curMousePos.x;this.lastMousePos.y=this.curMousePos.y;if(bnIsIE)this.curScroll.y=document.body.scrollTop;else this.curScroll.y=window.pageYOffset;if(this.lastScroll.y&&this.lastScroll.y!=this.curScroll.y)this.numScrolls++;this.lastScroll.y=this.curScroll.y;var curScrollPercent=this.getScrollScope();if(curScrollPercent>this.maxScrollPercent)
this.maxScrollPercent=curScrollPercent;setTimeout("bnBehavior.activityCheck()",500);}
BNBehavior.prototype.getScrollTop=function()
{if(document.documentElement&&document.documentElement.scrollTop)
return document.documentElement.scrollTop;if(document.body)return document.body.scrollTop;return window.pageYOffset;}
BNBehavior.prototype.getScrollHeight=function()
{if(document.documentElement&&document.documentElement.scrollHeight)
return Math.max(document.documentElement.offsetHeight,document.documentElement.scrollHeight,document.body.scrollHeight);return document.body.scrollHeight;}
BNBehavior.prototype.getClientHeight=function()
{if(typeof(window.innerWidth)=='number')
return window.innerHeight;else if(document.documentElement&&(document.documentElement.clientWidth||document.documentElement.clientHeight))
return document.documentElement.clientHeight;else if(document.body&&(document.body.clientWidth||document.body.clientHeight))
return document.body.clientHeight;}
BNBehavior.prototype.getScrollScope=function()
{return Math.round((this.getScrollTop()+this.getClientHeight())*100/this.getScrollHeight());}
BNBehavior.prototype.mouseHandler=function(e)
{this.curMousePos.x=e.pageX;this.curMousePos.y=e.pageY;}
var bnBehavior=new BNBehavior();function BNObserver(){this.lingerCancelled=false;this.myType="baynoteObserver";this.myTag=null;this.startTime=new Date().getTime();}
BNObserver.prototype.createSearchBox=function(){var actionUrl=this.myTag.server+"/search/query2";var searchButtonHTML;var searchButtonImg=this.myTag.getParam("searchButtonImg",null);if(searchButtonImg){searchButtonHTML='<input type="image" alt="Search" id="bn_search_button" src="'+searchButtonImg+'">';searchImgParam='<input type="hidden" name="sbi" value='+searchButtonImg+'>';}
else{searchButtonHTML='<input type="submit" value="Search" id="bn_search_button" class="bn_sb_button">';searchImgParam='';}
var key=this.myTag.key?this.myTag.key:"";var searchboxHtml='\
        <table width="100%" class="bn_sb_table"><tr>\
         <td width="33%"></td>\
         <td width="34%" align="center" class="bn_sb_cell">\
          <form action="'+actionUrl+'" style="margin: 0" id="bn_search_form" class="bn_sb_form">\
           <input type="hidden" name="cn" value="'+this.myTag.customerId+'">\
           <input type="hidden" name="cc" value="'+this.myTag.code+'">\
     <input type="hidden" name="key" value="'+key+'">\
           <input type="hidden" name="u" value="'+bnUser.getUserId(this.myTag)+'">\
           <input type="hidden" name="e" value="1">'
+searchImgParam+'<input type="text"   name="q" size="15" maxlength="255" id="bn_search_query" class="bn_sb_query">'
+searchButtonHTML+'</form>\
         </td>\
         <td width="33%"></td>\
        </tr></table>\
        ';var searchboxDiv=document.createElement("div");searchboxDiv.innerHTML=searchboxHtml;return searchboxDiv;}
BNObserver.prototype.shouldSendEvent=function(){if(bnPolicy.get("baynoteObserver","so"))return true;if(bnPolicy.get("baynoteObserver","st")&&typeof(this.myTag.specialTarget)!="undefined"&&this.myTag.specialTarget)return true;return false;}
BNObserver.prototype.sendEvent=function(evJSON,override){if((typeof(override)!="undefined"&&!override)&&!this.shouldSendEvent())return;if(!bnMessenger.initialized){setTimeout("bnObserver.sendEvent('"+evJSON+"')",100);return;}
var result=bnMessenger.sendMessage(evJSON);if(result<0){var newEv=bnCommon.parseJSON(evJSON);if(newEv.de){delete newEv.de;evJSON=bnCommon.valueToJSON(newEv);result=bnMessenger.sendMessage(evJSON);}
if(result<0&&this.debug){alert("Event too long - result="+result+" msg="+evJSON);}}}
BNObserver.prototype.makeEvent=function(action){var ev=new Object();ev.a=action;ev.c=bnPolicy.get("inf","cd");ev.d=this.url;if(this.myTag.iFrame){ev.r=parent.document.referrer;ev.p=parent.location.href.split("#")[0];ev.p=bnCommon.getURL(ev.p);}else{ev.r=document.referrer;}
ev.t=new Date().getTime();ev.u=bnUser.getUserId(this.myTag);if(bnCommon.hasAnyProperty(this.myTag.attrs))ev.at=this.myTag.attrs;if(!bnPolicy.get("baynoteObserver","so")&&bnPolicy.get("baynoteObserver","st")&&typeof(this.myTag.specialTarget)!="undefined"&&this.myTag.specialTarget){if(!ev.at)ev.at=new Object();ev.at.st="true";}
return ev;}
BNObserver.prototype.makeDetails=function(){var de=new Object();if(bnPolicy.get("baynoteObserver","cds")){var summary=this.myTag.getParam("summary",null);if(summary&&summary.length>0)de.su=summary;}
if(bnPolicy.get("baynoteObserver","cdt")){var title=this.myTag.getParam("title",bnPageInfo.getTitle());if(title&&title.length>0)de.ti=title;}
de.nw=bnPageInfo.getWordCount();de.nl=bnPageInfo.getLinkCount();return de;}
BNObserver.prototype.makeBehavior=function(){var bi=new Object();if(typeof(bnBehavior)=="object"){bi.ps=bnBehavior.maxScrollPercent;bi.ma=bnBehavior.numMouseMoves;bi.sa=bnBehavior.numScrolls;}
else{return null;}
return bi;}
BNObserver.prototype.cancelLinger=function(){this.lingerCancelled=true;}
BNObserver.prototype.clickOccurred=function(clicked){var exitInfo=new Object();var result=false;if(typeof(this.myTag.exitConfirmation)=="function"){result=this.myTag.exitConfirmation(clicked,exitInfo);}else{result=this.defaultExitConfirmation(clicked,exitInfo);}
if(result)this.exitOccurred(exitInfo);}
BNObserver.prototype.defaultExitConfirmation=function(clicked,exitInfo){var target=clicked;while(target){if(target.tagName=="A")break;target=target.parentNode;}
if(!target)return false;exitInfo.dest=target.href;var gt=target.getAttribute("baynote_guide");if(typeof(gt)!="undefined"&&gt)exitInfo.baynote_guide=gt;var gr=target.getAttribute("baynote_req");if(typeof(gr)!="undefined"&&gr)exitInfo.baynote_req=gr;var bn=target.getAttribute("baynote_bnrank");if(typeof(bn)!="undefined"&&bn)exitInfo.baynote_bnrank=bn;var ir=target.getAttribute("baynote_irrank");if(typeof(ir)!="undefined"&&ir)exitInfo.baynote_irrank=ir;var lt=bnCommon.getInnerText(target);if(!lt&&bnPolicy.get("baynoteObserver","alt")){if(clicked&&clicked.tagName=="IMG"){lt=clicked.getAttribute("ALT");var src=clicked.getAttribute("SRC");if(lt&&(src.indexOf(lt)==(src.length-lt.length)))lt=null;}}
if(lt)exitInfo.link=lt;var attrs=this.myTag.attrs;if(typeof(attrs)=="object"&&bnCommon.hasAnyProperty(attrs)){exitInfo.attrs=bnCommon.copyObj(attrs);}
return true;}
BNObserver.prototype.exitOccurred=function(exitInfo){var override=false;var ev=this.makeEvent("c");var dd=exitInfo.dest;if(typeof(dd)!="undefined"&&dd)ev.dd=dd;else ev.dd="bn_ignore=t";var lt=exitInfo.link;if(typeof(lt)!="undefined"&&lt)ev.l=lt;var ea=exitInfo.attrs;if(typeof(ea)=="object"){ev.at=ea;}
var gt=exitInfo.baynote_guide;if(typeof(gt)!="undefined"&&gt)ev.gt=gt;var gr=exitInfo.baynote_req;if(typeof(gr)!="undefined"&&gr)ev.gr=gr;var bn=exitInfo.baynote_bnrank;if(typeof(bn)!="undefined"&&bn){ev.rb=bn;if(!bnPolicy.get("baynoteObserver","so")&&bnPolicy.get("baynoteObserver","st")){if(!ev.at)ev.at=new Object();ev.at.st="true";override=true;}}
var ir=exitInfo.baynote_irrank;if(typeof(ir)!="undefined"&&ir)ev.ri=ir;var gat=exitInfo.baynote_guide_target;if(typeof(gat)!="undefined"&&gat)ev.gat=gat;var iq=exitInfo.implicitQuery;if(typeof(iq)!="undefined"&&iq){if(!ev.at)ev.at=new Object();ev.at.implicitQuery=iq;}
if(!this.myTag.iFrame){var details=this.makeDetails();if(details!=null)ev.de=details;}
if(bnPolicy.get("baynoteObserver","ub")){var bi=this.makeBehavior();if(bi!=null)ev.bi=bi;}
if(!override&&!this.shouldSendEvent())return;var u=bnCommon.getCookieValue("bn_u");var sEvt=bnCommon.valueToJSON(ev);var fCookie=false;if(bnPolicy.get("baynoteObserver","ec")&&(typeof(u)!="undefined"&&u)&&bnPageInfo.cookiesAreEnabled){bnCommon.setCookie("bn_ec",sEvt,"/","SESSION");fCookie=true;}
if(!fCookie||(bnPolicy.get("baynoteObserver","eec"))){this.sendEvent(sEvt,override);this.exitPause();}}
BNObserver.prototype.lingerOccurred=function(ds){if(!this.shouldFireLinger())return;var ev=this.makeEvent("l");ev.du=ds;if(bnPolicy.get("baynoteObserver","sdl")){var details=this.makeDetails();if(details!=null)ev.de=details;}
this.sendEvent(bnCommon.valueToJSON(ev),false);}
BNObserver.prototype.visitOccurred=function(){if(bnPolicy.get("baynoteObserver","ec")){var sEvt=bnCommon.getCookieValue("bn_ec");if(typeof(sEvt)!="undefined"&&sEvt&&sEvt.length>0){this.sendEvent(sEvt,true);}
bnCommon.removeCookie("bn_ec");}
if(!this.shouldFireVisit())return;var ev=this.makeEvent("v");this.sendEvent(bnCommon.valueToJSON(ev),false);}
BNObserver.prototype.shouldFireLinger=function(){if(this.lingerCancelled)return false;if(this.myTag.iFrame)return false;return true;}
BNObserver.prototype.shouldFireVisit=function(){if(this.myTag.iFrame)return false;if(bnPolicy.get("baynoteObserver","sv"))return true;if(this.myTag.getParam("fireVisit"))return true;if(!this.myTag.attrs)return false;if(this.myTag.attrs.totalPurchases)return true;if(this.myTag.attrs.query)return true;if(this.myTag.attrs.pageStatus)return true;return false;}
BNObserver.prototype.openMedia=function(mediaURL,linkText){this.cancelLinger();var ev=this.makeEvent("c");ev.dd=mediaURL;if(linkText)ev.l=linkText;this.sendEvent(bnCommon.valueToJSON(ev),false);}
BNObserver.prototype.closeMedia=function(mediaURL){var ev=this.makeEvent("c");ev.r=ev.d;ev.dd=ev.d;ev.d=mediaURL;this.sendEvent(bnCommon.valueToJSON(ev),false);}
BNObserver.prototype.queryExitOccurred=function(query,dest){var ev=this.makeEvent("c");ev.dd=dest;var details=this.makeDetails();if(details!=null)ev.de=details;if(!ev.at)ev.at=new Object();ev.at.implicitQuery=query;this.sendEvent(bnCommon.valueToJSON(ev),false);this.exitPause();}
BNObserver.prototype.exitPause=function(){var delayMS=bnPolicy.get(this.myType,"ep");if(delayMS==null||delayMS<=0)return;var maxIter=bnPolicy.get(this.myType,"epmi");if(maxIter==null)maxIter=1000000;var startTime=new Date().getTime();var nowTime=new Date().getTime();var iterations=0;while(nowTime-startTime<delayMS){nowTime=new Date().getTime();++iterations;if(iterations>maxIter)break;}}
BNObserver.prototype.actionOccurred=function(obj){}
BNObserver.prototype.instrumentLinks=function(){bnEvent.addHandler(document.body,"click",function(){var evt=bnEvent.getEvent();if(evt.target)bnObserver.clickOccurred(evt.target);});bnLog.log("onclick handler installed");}
BNObserver.prototype.instrumentBehavior=function(){if(typeof(bnBehavior)=="object"&&bnBehavior!=null){bnEvent.addHandler(document,"mousemove",function(){var evt=bnEvent.getEvent();bnBehavior.mouseHandler(evt);});setTimeout("bnBehavior.activityCheck()",500);}}
BNObserver.prototype.show=function(obsTag){this.lingerCancelled=false;this.myTag=obsTag;this.debug=bnPolicy.get(this.myType,"debug");if(this.myTag.searchbox){var ph=document.getElementById(this.myTag.placeHolderId);if(bnPolicy.get("search","ok"))ph.appendChild(this.createSearchBox());else if(this.myTag.noload)ph.innerHTML=this.myTag.noload;}
var obsHandler="/tags2/baynoteObserver/listener2";bnMessenger.initialize(this.myTag.server,obsHandler,this.myTag.customerId,this.myTag.code,this.myTag.key,this.debug);this.url=this.myTag.getParam("url",bnPageInfo.getURL());this.url=bnCommon.addURLMetaKeys(this.url,this.myTag.metaKeys);var oldPS=this.myTag.getParam("page_status");if(!oldPS&&bnPageInfo.is404())oldPS=404;var oldTP=this.myTag.getParam("totalPurchases");var oldQ=this.myTag.getParam("query");if(oldTP||oldQ||oldPS){if(!this.myTag.attrs)this.myTag.attrs=new Object();if(!this.myTag.attrs.totalPurchases&&oldTP)this.myTag.attrs.totalPurchases=oldTP;if(!this.myTag.attrs.query&&oldQ)this.myTag.attrs.query=oldQ;if(!this.myTag.attrs.pageStatus&&oldPS)this.myTag.attrs.pageStatus=oldPS;}
if(bnCommon.hasAnyProperty(this.myTag.docAttrs)){if(!this.myTag.attrs)this.myTag.attrs=new Object();this.myTag.attrs.docAttrs=bnCommon.objectToJSON(this.myTag.docAttrs);}
this.visitOccurred();var dwellTime=bnPolicy.get(this.myType,"dt");var dwellMSec=dwellTime*1000;setTimeout("bnObserver.lingerOccurred("+dwellTime+")",dwellMSec);this.instrumentLinks();if(bnPolicy.get("baynoteObserver","ub")){this.instrumentBehavior();}
bnResourceManager.registerAndAddResource(this.myType,bnObserver);return true;}
var bnObserver=new BNObserver();bnTagManager.registerTagHandler(bnObserver.myType,bnObserver);