#!/usr/bin/env python

# needed for doing some system actions
import sys #executing extern programm
import os
import time

# needed files I wrote by myself
from source       import Source
from settings     import MoeweSettings
from display      import GraphicDisplay
# the following Class does not work
#from configdialog import ConfigDialog

# showe the user what we have collected, some gtk-classes are needed
import pygtk
pygtk.require('2.0')

import gtk
from gtk import *
from gtk.gdk import *

from gnome.ui import *
import gnome.applet


# Class definition starts
class Main:
	"The main class which controls applet"
	Source      =None
	Settings    =MoeweSettings()
	ConfigDialog=None
	Display     =None
	Debug       =0 # 0 means: Applet is loaded to panel
	               # 1 means: Applet is loaded into own window (for debugging)

	def __init__(self):
		"Initialize Applet"
		self.Settings=MoeweSettings()
		self.Source=Source(self.Settings.Channels)
		self.Display=GraphicDisplay("Waiting f",Settings)
		self.Display.connect("clicked",self.clickedMessage)
		
		gtk.timeout_add(self.Settings.ChangeIntervall*1000,
				self.updateDisplay)

		if self.Debug == 1:

			main_window = gtk.Window(gtk.WINDOW_TOPLEVEL)
			main_window.set_title("Python Applet")

			main_window.connect("destroy", gtk.main_quit) 
			applet = gnome.applet.Applet()

			self.sample_factory(applet,None)
		
			applet.reparent(main_window)
			main_window.show_all()
			
			gtk.main()
			sys.exit()
			

		gnome.applet.bonobo_factory("OAFIID:GNOME_RSSApplet_Factory",
            				    gnome.applet.Applet.__gtype__, 
            				    "rssapplet", "0", self.sample_factory)
	def clickedMessage(self,object):
		print "User clicked Message. I start Webbrowser"
		print self.Settings.Webbrowser+" "+self.Display.Message.Execute
		os.system(self.Settings.Webbrowser+" "
			  +self.Display.Message.Execute
			  +" &")
		return gtk.True

	def sample_factory(self,applet, iid):
		"Builds Label which shows message"
		applet.add(self.Display)
		applet.show_all()
		return gtk.TRUE

	def updateDisplay(self):
		"Updates display ;-)"
		self.Debug=self.Debug+self.Settings.ChangeIntervall
		if self.Debug>self.Settings.UpdateIntervall:
			self.Source=Source(self.Settings.Channels)
			self.Debug=0
	        self.Display.showMessage(self.Source.next())
		return gtk.TRUE #show gtk that method was called succesfully
	
main=Main()

