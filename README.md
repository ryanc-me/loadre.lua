#loadre.lua

loadre lurker implementation that allows re-loading of middleclass entities after a hotswap. it requires [middleclass](https://github.com/kikito/middleclass), [lume](github.com/rxi/lume), [lurker](github.com/rxi/lurker), and optionally [linen](github.com/mginshe/linen). please see the respective pages (in order) for guides on their setup and installation.



### What is Loadre?
---
loadre keeps a snapshot of entity data. when a hotswap occurs, it uses this data to re-initialize all registered classe's and restore their pre-hotswap state. of course, any changes to the classes .lua file will override this snapshot.


### How do I Install Loadre?
---
drop loadre.lua somewhere in your project (maybe a /lib folder). once you have it added, you'll need to grab the `mixin` by `requiring` it. something like:

```lua
function love.load()
  LoadreMixin = require("loadre")

  -- require classes AFTER loadre
end
```


### How do I *use* Loadre?
---
loadre is designed to be a drop-and-go solution, but there are a few more steps before your classes will reload properly. each class will need to `include` loadre, and call the `Loadre()` initializer. the `Loadre()` function creates the first snapshot, so make sure you call it **last** inside the classes' `initialize()` method. this function should be called with the same arguments that your classes' `initialize()` method takes. here's a small example:

```lua
classTest = class("classTest")
classTest:include(SomeOtherMixin)
classTest:include(LoadreMixin)  -- this is the variable we define earlier in love.load()

function classTest:initialize(x, y, w, h, name)
  -- do some initialization
  self:someOtherInitializer()
  
  self.pos = {x = x, y = y}
  self.size = {w = w, h = h}
  self.name = name
  
  self:Loadre(x, y, w, h, name) -- call Loadre() last, including the args
end
```

and that's it! your class will now check for updates every time lurker.scan is called, which brings me to my next point of interest


### Catches/Notes
---
 + loadre implements a new function, `loadre.reload()`, which is set to lurker's postswap callback by default: `lurker.postswap = loadre.reload`. if you plan on using the postswap function for anything else, you will have to call `loadre.reload()` manually from your custom postswap function.

 + each class now has a `__reload()` method. this can be called at any time, and will check for updates in the classes' initializer. 

 + *loadre effectively doubles your classes' ram usage* - keep this in mind. each 'snapshot' is really just a copy of the class, so if you're storing a lot of data it may get a little laggy. most use-cases won't be affected by this, especially if you're using it for debugging.


### Credit/License
---
all credit goes to [rxi](github.com/rxi/) for the hotswapping functionality, as well as his utility library. as of 12/03/2014 lurker, lume, linen, and loadre are all released under the MIT open-source license, and are free to download and fuck around with as you please :)
