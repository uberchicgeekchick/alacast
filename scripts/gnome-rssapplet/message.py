#
# This file is part of GNOME-RSSApplet an applet for gnome-panel see README
#

class Message:

    Title=None
    Execute=None
    Description=None
	
    def __init__(self, title, execute,description):
        self.Title=title
        self.Execute=execute
        self.Description=description
        
