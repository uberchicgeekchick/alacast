
bnConstants=new Object();bnConstants.ANONYMOUS_USER_ID="ANONYMOUS";bnConstants.UNASSIGNED_USER_ID="UNASSIGNED";bnConstants.DEMO_USER_ID="DEMO";bnConstants.BN_PARAM_PREFIX="bn_";bnConstants.META_PAGE_STATUS="baynote_page_status";bnConstants.META_PAGE_TITLE="baynote_title";bnConstants.META_PAGE_SUBTITLE="baynote_subtitle";bnConstants.POLICY_RESOURCE_ID="Policy";bnConstants.MAX_INT=2147483647;bnConstants.JSON_CHARS={'\b':'\\b','\t':'\\t','\n':'\\n','\f':'\\f','\r':'\\r','"':'\\"','\\':'\\\\'};bnIsOpera=(navigator.userAgent.indexOf("Opera")>=0);bnIsSafari=(navigator.userAgent.indexOf("AppleWebKit")>=0);bnIsKonqueror=(navigator.userAgent.indexOf("Konqueror")>=0);bnIsKHTML=(bnIsSafari||bnIsKonqueror||navigator.userAgent.indexOf("KHTML")>=0);bnIsIE=(navigator.userAgent.indexOf("compatible")>=0&&navigator.userAgent.indexOf("MSIE")>=0&&!bnIsOpera);bnIsMozilla=(navigator.userAgent.indexOf("Gecko")>=0&&!bnIsKHTML);function StringBuffer(){this.buffer=[];}
StringBuffer.prototype.append=function append(string){this.buffer.push(string);return this;}
StringBuffer.prototype.toString=function toString(){return this.buffer.join("");}
BNTag.prototype.injectNoload=function(comment){var ph=document.getElementById(this.placeHolderId);if(this.noload)ph.innerHTML=this.noload;else if(comment)ph.innerHTML='<div comment="'+comment+'"/>';}
function BNCommon(){}
BNCommon.prototype.stringToBoolean=function(str){if(!str)return false;str=str.toLowerCase();if(str==""||str=="false"||str=="f"||str=="0"||str=="no"||str=="n")return false;return true;}
BNCommon.prototype.copyObj=function(obj,props){var newObj=new Object();for(var prop in obj){var child=obj[prop];if(typeof(child)=="undefined"||typeof(child)=="function")continue;if(child!=null)newObj[prop]=child;}
return newObj;}
BNCommon.prototype.copyProperties=function(src,dst,props){for(var i=0;i<props.length;++i){var name=props[i];var value=src[name];if(typeof(value)=="undefined"||value==null)continue;dst[name]=value;}}
BNCommon.prototype.dumpObj=function(obj,name,indent,depth,asHTML){if(asHTML){var ind="&nbsp;&nbsp;";var ret="<br>";}else{var ind="\t";var ret="\n";}
var MAX_DUMP_DEPTH=10;if(depth>MAX_DUMP_DEPTH){return indent+name+": -Maximum Depth Reached-"+ret;}
if(typeof obj=="object"){var child=null;var output=name?(indent+name+ret):"";indent+=ind;var numFunctions=0;for(var item in obj){try{child=obj[item];}catch(e){child="-Unable to Evaluate-";}
if(child==null)output+=indent+item+": <null>"+ret;else if(typeof child=="function")++numFunctions;else if(typeof child=="object")output+=this.dumpObj(child,item,indent,depth+1,asHTML);else output+=indent+item+": "+child+ret;}
if(numFunctions>0)output+=indent+"<"+numFunctions+" function(s)>"+ret;return output;}
else return obj;}
BNCommon.prototype.dump=function(obj){return this.dumpObj(obj,"","  ",5,false);}
BNCommon.prototype.dumpHTML=function(obj){return this.dumpObj(obj,"","  ",5,true);}
BNCommon.prototype.getURLParams=function(url){if(!url)var url=window.location.href;var urlParams=new Object();var tmp=url.split("?");if(tmp.length>1&&tmp[1]!=""){tmp=tmp[1];tmp=tmp.split("#");tmp=tmp[0];var params=tmp.split("&");var nameValuePair;for(var i=0;i<params.length;i++){nameValuePair=params[i].split("=");urlParams[nameValuePair[0]]=nameValuePair[1];}}
return urlParams;}
BNCommon.prototype.addURLParam=function(url,paramName,value){if(!url)return url;var urlLength=url.length;var newUrl=new StringBuffer();var insertedChar;var baseUrl=url;var baseUrlLength=urlLength;var anchor=null;var anchorIndex=url.indexOf('#');if(anchorIndex>=0){baseUrl=url.substring(0,anchorIndex);if(baseUrl=="")return url;baseUrlLength=baseUrl.length;anchor=url.substring(anchorIndex,urlLength);}
var lastChar=baseUrl.charAt(baseUrlLength-1);if(lastChar=='?'||lastChar=='&'){insertedChar=null;}else if(baseUrl.indexOf('?')>=0){insertedChar='&';}else{insertedChar='?';}
newUrl.append(baseUrl);if(insertedChar)newUrl.append(insertedChar);newUrl.append(paramName);newUrl.append('=');newUrl.append(value);if(anchor)newUrl.append(anchor);return newUrl.toString();}
BNCommon.prototype.addURLMetaKeys=function(url,metaKeyList){if(!metaKeyList)return url;var newUrl=url;var metaKeys=metaKeyList.split(",");for(var i=0;i<metaKeys.length;i++){var key=metaKeys[i];var metas=document.getElementsByName(key);for(var j=0;j<metas.length;j++){if(metas[j].tagName.toUpperCase()=="META"){newUrl=bnCommon.addURLParam(newUrl,"bn_"+key,encodeURIComponent(metas[j].content));break;}}}
return newUrl;}
BNCommon.prototype.getCookieValue=function(cookieName){return bnSystem.getCookieValue(cookieName);}
BNCommon.prototype.setCookie=function(cookieName,cookieValue,cookiePath,cookieExpires){return bnSystem.setCookie(cookieName,cookieValue,cookiePath,cookieExpires)}
BNCommon.prototype.removeCookie=function(cookieName){return bnSystem.removeCookie(cookieName);}
BNCommon.prototype.normalizeUrl=function(tag,url){if(typeof(tag.bnProxyPrefix)!="undefined"&&tag.bnProxyPrefix&&url.indexOf(tag.bnProxyPrefix)==0&&url.length>tag.bnProxyPrefix.length){return url.substring(tag.bnProxyPrefix.length,url.length);}
return url;}
BNCommon.prototype.arrayToJSON=function(arr){var a=['['],b,i,l=arr.length,v;function p(s){if(b){a.push(',');}
a.push(s);b=true;}
for(i=0;i<l;i+=1){v=arr[i];switch(typeof v){case'undefined':case'function':case'unknown':break;default:var json=bnCommon.valueToJSON(v);if(json)p(json);}}
a.push(']');return a.join('');}
BNCommon.prototype.booleanToJSON=function(bool){return String(bool);}
BNCommon.prototype.numberToJSON=function(num){return isFinite(num)?String(num):"null";}
BNCommon.prototype.objectToJSON=function(obj){var a=['{'],b,i,v;function p(s){if(b){a.push(',');}
a.push(bnCommon.valueToJSON(i),':',s);b=true;}
for(i in obj){if(obj.hasOwnProperty(i)){var json=bnCommon.valueToJSON(obj[i]);if(json)p(json);else p("null");}}
a.push('}');return a.join('');};BNCommon.prototype.stringToJSON=function(str){var specialRE=new RegExp("[\\\"\\\\\\x00-\\x1f]","g");if(specialRE.test(str)){return'"'+str.replace(specialRE,function(b){var c=bnConstants.JSON_CHARS[b];if(c)return c;c=b.charCodeAt();return'\\u00'+Math.floor(c/16).toString(16)+(c%16).toString(16);})+'"';}
return'"'+str+'"';}
BNCommon.prototype.valueToJSON=function(val){switch(typeof val){case'number':return this.numberToJSON(val);case'string':return this.stringToJSON(val);case'boolean':return this.booleanToJSON(val);case'object':if(val==null){return"null";}else if(val instanceof Array){return this.arrayToJSON(val);}else{return this.objectToJSON(val);}
case'unknown':case'function':case'undefined':break;default:alert("Unrecognized type: "+typeof val);}
return undefined;}
BNCommon.prototype.parseJSON=function(str){try{var legalRE=new RegExp("^(\\\"(\\\\.|[^\\\"\\\\\\n\\r])*?\\\"|[,:{}\\[\\]0-9.\\-+Eaeflnr-u \\n\\r\\t])+?$");if(legalRE.test(str)){return eval('('+str+')');}}catch(e){}
throw new SyntaxError("parseJSON");}
BNCommon.prototype.setDisplayBox=function(str){var oBox=document.getElementById("bn_displayBox");if(!oBox){oBox=document.createElement("div");oBox.id="bn_displayBox";oBox.style.position="absolute";oBox.style.top="0px";oBox.style.left="0px";oBox.style.backgroundColor="pink";oBox.style.border="1pt solid black";oBox.style.padding="2pt";oBox.style.filter="alpha(opacity=90)";oBox.style.opacity="0.90";oBox.style.fontFamily="arial";oBox.style.fontSize="10pt";}
oBox.innerHTML=str;}
BNCommon.prototype.trim=function(str){if(!str)return str;while(str.charAt(0)==" "||str.charAt(0)=="\n"||str.charAt(0)=="\t")
str=str.substring(1);while(str.charAt(str.length-1)==" "||str.charAt(str.length-1)=="\n"||str.charAt(str.length-1)=="\t")
str=str.substring(0,str.length-1);return str;}
BNCommon.prototype.getInnerText=function(obj){if(obj.innerText)return obj.innerText;else{var text="";switch(obj.nodeType){case 1:for(var i=0;i<obj.childNodes.length;i++)
text+=this.getInnerText(obj.childNodes.item(i));break;case 3:text+=obj.nodeValue;break;}
return this.trim(text);}}
BNCommon.prototype.hasAnyProperty=function(obj){if(obj&&(typeof(obj)!="undefined")){for(var attrName in obj){if(obj.hasOwnProperty(attrName)){var t=typeof obj[attrName];if(t!='function'&&t!='undefined'){return true;}}}}
return false;}
BNCommon.prototype.getURL=function(fullUrl,urlParams,bnParams){if(!urlParams)urlParams=new Object();if(!bnParams)bnParams=new Object();var params=bnCommon.getURLParams(fullUrl);for(var paramName in params){if(typeof(params[paramName])=="function")continue;if(paramName.indexOf(bnConstants.BN_PARAM_PREFIX)==0){bnParams[paramName]=params[paramName];}else{urlParams[paramName]=params[paramName];}}
var url=fullUrl.split("?")[0];var isFirst=true;for(var paramName in urlParams){if(typeof(params[paramName])=="function")continue;if(isFirst)url+="?";else url+="&";isFirst=false;url+=paramName+"=";var value=params[paramName];if(value)url+=value;}
return url;}
var bnCommon=new BNCommon();function BNReferrer(url){this.url=url;this.isExternal=true;this.query=null;this.source=null;var internalDomains=bnPolicy.get("baynoteObserver","dom");if(internalDomains){for(var i=0;i<internalDomains.length;i++){if(url.match(new RegExp(internalDomains[i],"i")))this.isExternal=false;}}
this.extractInfo();}
BNReferrer.prototype.extractInfo=function(){with(this){query=extractQuery(/.*\.google\..*[?&]q=([^&]*)(&.*)?$/i,url);if(query){source="Google";return;}
query=extractQuery(/.*\.google\..*[?&]as_q=([^&]*)(&.*)?$/i,url);if(query){source="Google";return;}
query=extractQuery(/.*\.yahoo\..*[?&]p=([^&]*)(&.*)?$/i,url);if(query){source="Yahoo";return;}
query=extractQuery(/.*search.*\.msn\..*[?&]q=([^&]*)(&.*)?$/i,url);if(query){source="MSN";return;}
query=extractQuery(/.*\.altavista\..*[?&]q=([^&]*)(&.*)?$/i,url);if(query){source="AltaVista";return;}
query=extractQuery(/.*\.ask\..*[?&]q=([^&]*)(&.*)?$/i,url);if(query){source="Ask";return;}
query=extractQuery(/.*a9\.com\/([^\/?]*)(\?.*)?$/i,url);if(query){source="A9";return;}
query=extractQuery(/.*[?&]bn_query=([^&]*)(&.*)?$/i,url);if(query){if(isExternal)source="external search";else source="internal search";return;}
query=null;if(isExternal)source="external";else source="internal";}}
BNReferrer.prototype.extractQuery=function(re,extrefer){if(!extrefer)return null;var match=re.exec(extrefer);if(match!=null&&match.length>=1){var query=match[1];if(query){query=unescape(query);query=query.replace(/\+/g,' ');}
return query;}
else return false;}
function BNPageInfo(){this.fullUrl=window.location.href.split("#")[0];this.urlParams=new Object();this.bnParams=new Object();this.url=bnCommon.getURL(this.fullUrl,this.urlParams,this.bnParams);if(!window.name){var date=new Date();window.name=date.getTime();}
this.checkWindowAttributes();bnResourceManager.waitForResource(bnConstants.POLICY_RESOURCE_ID,"bnPageInfo.processPageDetails()");}
BNPageInfo.prototype.checkWindowAttributes=function(){if(!document.body)
{setTimeout("bnPageInfo.checkWindowAttributes()",200);return;}
this.windowWidth=document.body.scrollWidth;this.windowHeight=document.body.scrollHeight;if(bnIsIE)this.windowHeight=document.body.offsetHeight;}
BNPageInfo.prototype.processPageDetails=function(){this.checkReferrer();this.checkTitle();this.checkIfSearchPage();this.checkIf404();this.checkIfBusinessTarget();this.checkWordCount();this.checkLinkCount();}
BNPageInfo.prototype.checkReferrer=function(){var referrer;var bn_referdata=bnCommon.getCookieValue("bn_referdata");if(bn_referdata){var parts=bn_referdata.split("|");if(url==parts[1])
referrer=parts[0];bnCommon.removeCookie("bn_referdata");}
else referrer=document.referrer;if(!referrer)this.referrer=null;else this.referrer=new BNReferrer(referrer);}
BNPageInfo.prototype.checkTitle=function(){var title=null;var metas=document.getElementsByName(bnConstants.META_PAGE_SUBTITLE);if(metas&&metas.length==1)title=metas[0].content;if(!title){var metas=document.getElementsByName(bnConstants.META_PAGE_TITLE);if(metas&&metas.length>0)title=metas[0].content;if(!title)title=document.title;}
this.title=title?title:"";}
BNPageInfo.prototype.checkIfSearchPage=function(){this.iAmSearchPage=false;this.query=null;var searchPageRegex=bnPolicy.get("baynoteObserver","spr");var searchPageRegexQueryGroup=bnPolicy.get("baynoteObserver","sprqg");if(searchPageRegex){var re=new RegExp(searchPageRegex,"i");var match=re.exec(this.url);if(match!=null&&match.length>=searchPageRegexQueryGroup+1){this.iAmSearchPage=true;this.query=unescape(match[searchPageRegexQueryGroup]);}}}
BNPageInfo.prototype.checkIf404=function(){this.iAm404=false;var metas=document.getElementsByName(bnConstants.META_PAGE_STATUS);if(metas&&metas.length>0){var status=parseInt(metas[0].content);if(status==404)this.iAm404=true;}}
BNPageInfo.prototype.checkIfBusinessTarget=function(){this.iAmBusinessTarget=false;var busTargets=bnPolicy.get("baynoteObserver","bt");if(busTargets){for(var i=0;i<busTargets.length;i++){if(this.url.match(new RegExp(busTargets[i],"i")))this.iAmBusinessTarget=true;}}}
BNPageInfo.prototype.checkWordCount=function(){if(typeof(baynote_globals)!="undefined"&&baynote_globals.skipWordCount){this.wordCount=-1;return;}
if(!document.body){this.wordCount=-1;this.linkCount=-1;setTimeout("bnPageInfo.checkWordCount()",200);return;}
this.wordCount=null;var bodyTags=document.getElementsByTagName("body");if(bodyTags.length==0)return;var bodyText=bnCommon.getInnerText(bodyTags[0]);var wordCountRE=new RegExp("\\S+","g");var words=bodyText.match(wordCountRE);if(!words)this.wordCount=0;else this.wordCount=words.length;}
BNPageInfo.prototype.checkLinkCount=function(){if(typeof(baynote_globals)!="undefined"&&baynote_globals.skipLinkCount){this.linkCount=-1;return;}
this.linkCount=null;var linkTags=document.getElementsByTagName("a");if(!linkTags)this.linkCount=0;else this.linkCount=linkTags.length;}
BNPageInfo.prototype.getWindowName=function(){return window.name;}
BNPageInfo.prototype.getWordCount=function(){return this.wordCount;}
BNPageInfo.prototype.getLinkCount=function(){return this.linkCount;}
BNPageInfo.prototype.getTitle=function(){return this.title;}
BNPageInfo.prototype.isSearchPage=function(){return this.iAmSearchPage;}
BNPageInfo.prototype.getQuery=function(tag){if(tag&&tag.query)return tag.query;return this.query;}
BNPageInfo.prototype.is404=function(){return this.iAm404;}
BNPageInfo.prototype.isBusinessTarget=function(){return this.iAmBusinessTarget;}
BNPageInfo.prototype.cookiesAreEnabled=function(){if(typeof(baynote_globals)!="undefined"&&baynote_globals.cookiesDisabled)return false;else return true;}
BNPageInfo.prototype.getURL=function(){return this.url;}
BNPageInfo.prototype.getFullURL=function(){return this.fullUrl;}
BNPageInfo.prototype.getURLParams=function(){return this.urlParams;}
BNPageInfo.prototype.getBNParams=function(){return this.bnParams;}
BNPageInfo.prototype.getBNParam=function(paramName){return this.bnParams[paramName];}
BNPageInfo.prototype.getReferrerURL=function(){if(!this.referrer)return null;return this.referrer.url;}
BNPageInfo.prototype.getReferrerSource=function(){if(!this.referrer)return null;return this.referrer.source;}
BNPageInfo.prototype.hasExtReferrer=function(){if(!this.referrer)return false;return this.referrer.isExternal;}
BNPageInfo.prototype.getReferrerQuery=function(){if(!this.referrer)return null;return this.referrer.query;}
BNPageInfo.prototype.isBinary=function(url){if(!url)return false;if(url.match(/^[^?]*\.(pdf|doc|xls|ppt)(\?.*)?$/i))return true;if(url.match(/^.*\/m?getfile\?.*$/i))return true;return false;}
var bnPageInfo=new BNPageInfo();function BNUser(){this.userId=null;var userFromURL=this.getUserFromURL();if(userFromURL){this.setUserId(userFromURL);return;}
var oldUserId=bnCommon.getCookieValue("_baynote_anon_user");if(oldUserId){this.setUserId(oldUserId);bnCommon.removeCookie("_baynote_anon_user");return;}
var userId=bnCommon.getCookieValue("bn_u");if(userId){this.setUserId(userId,true);return;}
this.setUserId(bnConstants.UNASSIGNED_USER_ID);userId=bnCommon.getCookieValue("bn_u");if(!userId)this.setUserId(bnConstants.ANONYMOUS_USER_ID,true);}
BNUser.prototype.getUserFromURL=function(){var userParam=bnPageInfo.getBNParam("bn_u");var user=null;if(userParam!=null){if(userParam=="")user=bnConstants.UNASSIGNED_USER_ID;else user=userParam;}
return user;}
BNUser.prototype.getUserId=function(tag){if(tag&&tag.userId)return tag.userId;return this.userId;}
BNUser.prototype.setUserId=function(userId,skipWrite){if(bnPageInfo.cookiesAreEnabled()&&!skipWrite)this.writeUserCookie(userId);this.userId=userId;}
BNUser.prototype.reWriteUserCookie=function(){this.writeUserCookie(this.userId);}
BNUser.prototype.writeUserCookie=function(userId){bnCommon.setCookie("bn_u",userId,"/","NEVER");}
var bnUser=new BNUser();function BNPolicy(){this.data=null;this.overrides=null;this.userId=null;this.disableAll=bnPageInfo.getBNParam("bn_disable");}
BNPolicy.prototype.get=function(pId,param){if(!pId)return this.data;if(!this.data)return null;if(!param)return this.data[pId];if(!this.data[pId])return null;return this.data[pId][param];}
BNPolicy.prototype.getOverride=function(pId){if(!pId)return this.overrides;if(!this.overrides)return null;return this.overrides[pId];}
BNPolicy.prototype.allowTag=function(tag){if(this.disableAll)return false;var pTag=this.get(tag.type);if(!pTag)return true;if(typeof(pTag.ok)=="undefined")return true;return pTag.ok;}
BNPolicy.prototype.isNew=function(){return this.isNewPolicy;}
BNPolicy.prototype.load=function(server,custName,custCode,userId){this.userId=userId;var needUserPolicy=true;bnResourceManager.loadResource(bnConstants.POLICY_RESOURCE_ID,this.getPolicyResourceAddress(server,custName,custCode,userId,needUserPolicy));}
BNPolicy.prototype.registerPolicy=function(basePolicyJSON,userPolicyJSON){this.data=this.importData(basePolicyJSON);if(userPolicyJSON){var userPolicy=bnCommon.parseJSON(userPolicyJSON);for(var category in userPolicy){if(typeof(userPolicy[category])=="function")continue;for(var paramName in userPolicy[category]){if(typeof(userPolicy[category][paramName])=="function")continue;this.setPolicyData(this.data,category,paramName,userPolicy[category][paramName]);}}}
this.overrides=this.computeOverrides();this.applyOverrides(this.overrides);this.applyDirectives();bnResourceManager.registerResource(bnConstants.POLICY_RESOURCE_ID);}
BNPolicy.prototype.getPolicyResourceAddress=function(server,custName,custCode,userId,needUserPolicy){var subDomain="";if(typeof(baynote_globals)!="undefined"&&baynote_globals.cookieSubDomain)subDomain=baynote_globals.cookieSubDomain;return(server+"/baynote/tags2/policy?customerId="+custName+"&code="+custCode+"&subdomain="+subDomain+"&userId="+userId+"&userPolicyRequested="+needUserPolicy);}
BNPolicy.prototype.importData=function(jsonStr){var data=bnCommon.parseJSON(jsonStr);if(!data)data=new Object();return data;}
BNPolicy.prototype.applyOverrides=function(overrideData){if(!overrideData)return;var atLeastOne=false;for(var cat in overrideData){if(typeof(overrideData[cat])=="function")continue;for(var key in overrideData[cat]){if(typeof(overrideData[cat][key])=="function")continue;this.setPolicyData(this.data,cat,key,overrideData[cat][key]);atLeastOne=true;}}
var testServer=bnSystem.getTestServer();if(testServer){this.setPolicyData(overrideData,"inf","server",testServer);atLeastOne=true;}
if(atLeastOne)bnCommon.setDisplayBox(bnCommon.dumpHTML(overrideData));}
BNPolicy.prototype.computeTagOverrides=function(){var tagOverrides=this.importData("{}");var bn_ov=typeof(baynote_globals)!="undefined"?baynote_globals.bn_ov:null;if(bn_ov){var categories=bn_ov.split(";");for(var i=0;i<categories.length;i++){var c=categories[i].split(":");var cName=c[0];var cValue=c[1];tagOverrides[cName]=new Object();var params=cValue.split(",");for(var j=0;j<params.length;j++){var p=params[j].split("~");this.setPolicyData(tagOverrides,cName,p[0],eval(p[1]));}}}
return tagOverrides;}
BNPolicy.prototype.computeOverrides=function(){var overrides=this.importData("{}");var tagOverrides=this.computeTagOverrides();bn_ov=bnPageInfo.getBNParam("bn_ov");if(bn_ov){var categories=bn_ov.split(";");for(var i=0;i<categories.length;i++){var c=categories[i].split(":");var cName=c[0];var cValue=c[1];if(!overrides[cName])overrides[cName]=new Object();var params=cValue.split(",");for(var j=0;j<params.length;j++){var p=params[j].split("~");this.setPolicyData(overrides,cName,p[0],eval(decodeURIComponent(p[1])));}}
this.writeOverrideCookie(bnCommon.valueToJSON(overrides));}else if(bn_ov==""){this.writeOverrideCookie("{}");}else{var cookieValue=this.readOverrideCookie();if(cookieValue)overrides=this.importData(cookieValue);else overrides=this.importData("{}");}
if(overrides){for(var cat in overrides){if(typeof(overrides[cat])=="function")continue;for(var key in overrides[cat]){if(typeof(overrides[cat][key])=="function")continue;this.setPolicyData(tagOverrides,cat,key,overrides[cat][key]);}}}
return tagOverrides;}
BNPolicy.prototype.removePolicyData=function(policyData,cat,key){if(policyData&&policyData[cat])delete policyData[cat][key];}
BNPolicy.prototype.setPolicyData=function(policyData,cat,key,value){if(!policyData[cat])policyData[cat]=new Object();policyData[cat][key]=value;}
BNPolicy.prototype.readOverrideCookie=function(){return bnCommon.getCookieValue("bn_ov");}
BNPolicy.prototype.writeOverrideCookie=function(jsonStr){if(!jsonStr||jsonStr=="{}")bnCommon.removeCookie("bn_ov");else bnCommon.setCookie("bn_ov",jsonStr,"/","NEVER");}
BNPolicy.prototype.applyDirectives=function(){var directives=this.get("dir");if(!directives)return;if(directives.au)bnUser.setUserId(this.get("inf","u"));}
var bnPolicy=new BNPolicy();function BNTagManager(){this.tags=new Array();this.tagHandlers=new Object();}
BNTagManager.prototype.getHandlerForTag=function(tId){var tag=this.getTag(tId);return this.tagHandlers[tag.type];}
BNTagManager.prototype.registerTagHandler=function(tType,handlerObj){this.tagHandlers[tType]=handlerObj;bnResourceManager.registerResource(this.getHandlerResourceId(tType));}
BNTagManager.prototype.loadHandler=function(tId){var tag=this.getTag(tId);bnResourceManager.loadResource(this.getHandlerResourceId(tag.type),this.getHandlerResourceAddress(tag));}
BNTagManager.prototype.getHandlerResourceId=function(tType){return(tType+"_handler");}
BNTagManager.prototype.getHandlerResourceAddress=function(tag){var handlerName=tag.getParam("handler",bnPolicy.get(tag.type,"hn"));if(!handlerName)handlerName="handler.js";return(tag.server+"/baynote/tags2/"+tag.type+"/"+handlerName);}
BNTagManager.prototype.getTag=function(tId){return window["bn_tags"][tId];}
BNTagManager.prototype.getTags=function(type){var tags=window["bn_tags"];var matchingTags=new Array();for(var i=0;i<tags.length;i++){if(tags[i].type==type)matchingTags.push(tags[i]);}
return matchingTags;}
BNTagManager.prototype.show=function(tId){with(this){var tag=getTag(tId);if(!tag)return;if(tag.cookie_domain&&typeof(baynote_globals)!="undefined"&&baynote_globals&&!baynote_globals.cookieDomain)
baynote_globals.cookieDomain=tag.cookie_domain;if(!bnPolicy.get()){bnResourceManager.waitForResource(bnConstants.POLICY_RESOURCE_ID,"bnTagManager.show("+tId+")");bnPolicy.load(tag.server,tag.customerId,tag.code,bnUser.getUserId(tag));return;}
if(!bnPolicy.allowTag(tag)){tag.injectNoload("tag was rejected by policy");return;}
var tHandler=getHandlerForTag(tId);if(tHandler){tHandler.show(tag);}else{bnResourceManager.waitForResource(getHandlerResourceId(tag.type),"bnTagManager.show("+tId+")");loadHandler(tId);}}}
if(typeof(bnTagManager)=="undefined"){var bnTagManager=new BNTagManager();}
function BNEvent(){}
BNEvent.prototype.addHandler=function(target,type,handler){if(target.addEventListener)target.addEventListener(type,handler,false);else if(target.attachEvent)target.attachEvent("on"+type,handler);else target["on"+type]=handler;};BNEvent.prototype.removeHandler=function(target,type,handler){if(target.removeEventListener)target.removeEventListener(type,handler,false);else if(target.detachEvent)target.detachEvent("on"+type,handler);else target["on"+type]=null;}
BNEvent.prototype.getEvent=function(){if(!window.event)return bnEvent.getEvent.caller.arguments[0];var event=window.event;if(!bnIsIE)return event;event.charCode=(event.type=="keypress")?event.keyCode:0;event.eventPhase=2;event.isChar=(event.charCode>0);event.pageX=event.clientX+document.body.scrollLeft;event.pageY=event.clientY+document.body.scrollTop;event.target=event.srcElement;event.time=(new Date).getTime();if(event.type=="mouseout")event.relatedTarget=event.toElement;else if(event.type=="mouseover")event.relatedTarget=event.fromElement;event.preventDefault=function(){this.returnValue=false;}
event.stopPropagation=function(){this.cancelBubble=true;}
return event;}
var bnEvent=new BNEvent();bnResourceManager.registerResource("Common");