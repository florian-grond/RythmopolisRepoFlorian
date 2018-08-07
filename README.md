# RythmopolisRepoFlorian

Software dependencies:

1) install SuperCollider 3.8 (sclang scsynth, the precompiled package with the ide comes with both) 3.8
https://supercollider.github.io/download

2) download and install the SC3 plugins make sure you use the same version as above (3.8)
https://github.com/supercollider/sc3-plugins/releases


You need to know about 2 directories

Extensions
and  
downloaded-quarks

both reside in the user support directory

how to get there:

option 1) start the IDE:
evaluate the following code:
Platform.userAppSupportDir
this will return on OSX:
/Users/yourUSRname/Library/Application Support/SuperCollider

option 2)
in the IDE you can also go to File->Open user support directory


If the folder Extensions does not exist, create it!
put the SC3plugins folder into the Extension folder
/Users/yourUSRname/Library/Application Support/SuperCollider/Extensions


3) install the ATK quark
in the IDE execute the following line

Quarks.gui

a GUI opens, select the atk-sc3 quark, from the buttons,
it will fetch the corresponding language extensions and puts them into the downloaded-quarks folder
(it will also resolve some dependencies, wslib, MatLib, ... )


4) recompile the ClassLibrary from the IDE menu -> Language

if you see conflicts when recompiling remove all the .sc files (the duplicate classes) from the ATK folder in the Extensions/SC3-plugins make sure you keep the .scx (the actual binary of the plugin)



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
