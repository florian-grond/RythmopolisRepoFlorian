# RythmopolisRepoFlorian


1) install SuperCollider 3.8 (sclang scsynth, the precompiled package with the ide comes with both)
https://supercollider.github.io/download

------------------

2) download the SC3 plugins make sure you use the same version as above (3.8)
https://github.com/supercollider/sc3-plugins/releases

------------------

You need to know about 2 directories: ../Extensions/  and  ../downloaded-quarks/

both reside in the user support directory. How to get there:

option 1) start the IDE:
evaluate the following code:

Platform.userAppSupportDir

this will return on OSX:
/Users/yourUSRname/Library/Application Support/SuperCollider

option 2)
in the IDE you can also go to File->Open user support directory.
If the folder Extensions/ does not exist, create it!

------------------

put the SC3plugins folder into the folder Extension/

/Users/yourUSRname/Library/Application Support/SuperCollider/Extensions

------------------

3) install the ATK quark
In the IDE execute the following line

Quarks.gui

a GUI opens, select the atk-sc3 quark, from the buttons,
it will fetch the corresponding language extensions and puts them into the downloaded-quarks folder
(it will also resolve some dependencies, wslib, MatLib, ... )
Recompile on the top right (button on the Quarks.gui window)

------------------

4) After recompile (recompile also works from the IDE menu -> Language)
If you see conflicts when recompiling remove all the the duplicate classes i.e. the .sc files from the ATK folder in the Extensions/SC3-plugins make sure you keep the .scx (the actual binary of the plugin)

leave the ATK classes in the downloaded-quarks directory as is.

------------------

5) fetch the resources HRIR and encoding decoding matrixes for the ATK  follow the installation instructions in these links
http://www.ambisonictoolkit.net/download/kernels/

ATK Kernel Installation
(
// Create ATK support directory
// Place unzipped kernels in the directory opened  

Atk.createUserSupportDir;
Atk.openUserSupportDir;
)

http://www.ambisonictoolkit.net/download/matrices/

ATK Matrix Installation
(
// Create ATK support directory
// Place unzipped matrices in the directory opened  

Atk.createUserSupportDir;
Atk.openUserSupportDir;
)
