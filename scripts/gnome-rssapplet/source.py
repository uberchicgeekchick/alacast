#
# This file is part of GNOME-RSSApplet an applet for gnome-panel see README

import os
from xml.dom.minidom import parse, Element

from message import Message

def getText(node):
    "returns textvalue of one node"
    return node._get_childNodes()[0].nodeValue.encode('utf-8')

class Source:
    "Downloads one rdf feed an writes its contents to datastructure"
    Queue = [] #all message are added to the dataqueue

    def __init__(self,Channels):
        for Channel in Channels:
            self.addSource(Channel)

    def addSource(self,url):
        try:
            os.system('wget -O /tmp/rfd.rdf ' + url)
            #hack since dom.minicom can't parse an url
            dom1 = parse('/tmp/rfd.rdf')
            self.handleRSS(dom1)
        except:
            pass

    def next(self):
        "Returns next message of list"
        element=self.Queue.pop(0)  
        self.Queue.append(element)
        return element

    def handleRSS(self,rss):
        "Goes through RSS-xml Page"
        for item in rss.getElementsByTagName("item"):
            self.handleItem(item)
            
    def handleItem(self,item):
        "builds from one rss-feed a message"
                
        try: #to get all information, BUT we need at least title and link
            msg=Message(getText(item.getElementsByTagName("title")[0]),
                        getText(item.getElementsByTagName("link")[0]),
                        getText(item.getElementsByTagName("description")[0]))
        except (IndexError):
            msg=Message(getText(item.getElementsByTagName("title")[0]),
                        getText(item.getElementsByTagName("link")[0]),
                        'Sorry, RSS Feed does not provice a description')

        self.Queue.append(msg)
         
        
            
