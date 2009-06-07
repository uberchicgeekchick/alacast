#
# This file is part of GNOME-RSSApplet an applet for gnome-panel see README

import pygtk
pygtk.require('2.0')

import gtk
import gnome.applet

class Console:

    Settings=0

    def __init__(self,settings):
        self.Settings=options

    def show(self, message):
        print(message)


class GraphicDisplay (gtk.Button):
    "Class which displays message in a graphical context"

    Message=None
    Settings=None
    Tooltip=gtk.Tooltips() # displays a description if avaiblable
    
    def __init__(self, str, settings):
        "Constructor"
        gtk.Button.__init__(self,str)
        self.Settings=settings
        self.Tooltip.set_tip(self, 'Empty', '')
        
    def showMessage(self,message):
        "Displays Message on the screen or somewhere"
        self.Message=message
        self.set_label(message.Title)
        self.Tooltip.set_tip(self,message.Description)


    def getMessage(self):
        "Return Message"
        return self.Message
