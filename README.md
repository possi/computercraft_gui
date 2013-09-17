Computer Craft GUI API
======================

This GUI allows you to code your own Touchable Advanced-Monitor-Program for the Computer Craft Mod.
You can create UI-Widgets (manly buttons), to make your Program interactive.
You can easily build a Simple OS without need to handle click events yourself.
The API is OOP and make uses of Closures as simple EventHandlers.


Installation
============

Use pastebin to get the latest version of gui.lua. Then load the file into your Program e.g.:

```lua
  dofile("/my_files/gui.lua")
  -- That way provides you a global Object called 'gui', which provides the methods
```


You may also use the os.loadAPI to load the API

```lua
  os.loadAPI("/my_files/gui") -- so the file has to be named without .lua
  -- That way you get a the gui Object within a gui object (so you need to call gui.gui.<method>)
```

This behavior may be changed in Feature

Usage
=====

See examples for a usage description. More documentation **may** follow.

TODO
====
* Create an installer that allows you to load the latest Version of the API directly from github
* Create a better loadable API
* Much API-Documentation
