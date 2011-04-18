GrowlSafariBridge
=================

GrowlSafariBridge enables arbitrary javascript (including Safari Extensions) to notify via Growl.

INSTALL
-------

Download GrowlSafariBridge.webplugin from <https://github.com/uasi/growl-safari-bridge/downloads>
and copy it to ~/Library/Internet Plug-Ins/.

USAGE
-----

    // Load GrowlSafariBridge plug-in
    document.write('<object type="application/x-growl-safari-bridge" width="0" height="0" id="growl-safari-bridge"></object>');
    
    // Get the element
    window.GrowlSafariBridge = document.getElementById('growl-safari-bridge');
    
    // Check if the plug-in is available
    if (GrowlSafariBridge.notify !== undefined) {
      // Notify
      GrowlSafariBridge.notify('Title', 'Description');
      GrowlSafariBridge.notify('Title only', undefined, {isSticky: 1, priority: 1, imageUrl: 'http://www.example.com/example.jpg'})
    }
