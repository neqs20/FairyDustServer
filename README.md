[![Fairy Dust Sever logo](/fairy_dust_server_128x128.png)](https://discord.gg/7PVQxmr)
## FairyDust Server

### How to set it up ?

### Clone it, build it, run it

* First you need a linux machine (optionally virtaul machine or [WSL](https://docs.microsoft.com/en-us/windows/wsl/install-win10))
* Clone my fork of [Godot Engine](https://github.com/HazmatDemon/godot/tree/3.2-server) and run ```./lsr.sh```
* You also need to run ```wer.bat``` on a windows machine to be able to run the project later
* Copy resulting binary (godot_server.x11.opt.64.llvm) into a new empty folder (e.g. your home directory)
* Clone this repository, run the project, export the pck file and place it in the same directory as the copied binary.
* Now to run it type ```./godot_server.x11.opt.64.llvm --main-pack name-of-pck-file.pck

### Download it, run it

* Go to [Releases](https://github.com/HazmatDemon/fairy-dust-server/releases/) page and download the latest release.
* Run ```./run.sh```