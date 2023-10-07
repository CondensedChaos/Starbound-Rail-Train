Starbound Train system

7/Oct/2023: Temporary fix for items not showing up in rail crafting table when not in admin mode: download [blueprints.zip](https://github.com/CondensedChaos/Starbound-Rail-Train/releases/download/1.2/blueprints.zip) and unzip in starbound/mods folder
The fix will be merged in the main mod as soon as possible
===========================

# Overview
This mod add a train system to be used with Startbound's rail tram system.  
It provides a framework that includes train crafting, personalization of trains, creation of lines and scheduling of trains.  
Any user with some experience in modding can add additional train cars to be used with this mod (Refer to [modding](https://github.com/CondensedChaos/Starbound-Rail-Train#modding))  
There are two operating modes, free and scheduled.  

A Many Tabs Patch is also available [Here](https://github.com/CondensedChaos/Starbound-Rail-Train-Many-Tabs-Patch/tree/main)  

<a href="https://youtu.be/p0koywGE3aU"><img src="https://markdown-videos.vercel.app/youtube/p0koywGE3aU"></a></img>  
<a href="https://youtu.be/j72Pmk6Tagk"><img src="https://markdown-videos.vercel.app/youtube/j72Pmk6Tagk"></a></img>

---
# Installation
Grab latest release from [here](https://github.com/CondensedChaos/Starbound-Rail-Train/releases)  
download either the zipped (.zip) version or the .pak version  

Zip version name: "Starbound-Rail-Train-\<version\>.zip"  
Pak version name: "Starbound-Rail-Train-\<version\>.pak"  

-If you downloaded the zipped version it has to be extracted in \<Starbound folder\>\mods  
-If you downloaded the .pak version just put the .pak file as it is in \<Starbound folder\>\mods

Starbound folder is typically for Steam version: "C:\Program Files (x86)\Steam\steamapps\common\Starbound\" for the windows version  
GOG or other version are typically under either "C:\Program Files (x86)\Starbound" or "C:\Program Files\Starbound" for the windows version  
You will need to download and overwrite again the mod evertytime it gets updated if you download it from GitHub  
Steam Workshop version that gets autoupdated is also available but you need to have a Starbound copy bought from Steam, get it [here](https://steamcommunity.com/sharedfiles/filedetails/?id=3006987088)  

In the [releases tab](https://github.com/CondensedChaos/Starbound-Rail-Train/releases) there's also an instance world that includes a ready-made demo train network of two lines that can be used to understand better how the mod works.  
Refer to [rail-demo](https://github.com/CondensedChaos/Starbound-Rail-Train/tree/main#rail-demo) for more informations

---

## To report a bug or to ask a question to the developer
If you need to report a bug, be sure to install as well the ["Enable logging patch"](https://github.com/CondensedChaos/Starbound-Rail-Train/releases/download/1.0/Starbound-Rail-Train-Enable-Logging-Patch.pak) in your \<Starbound folder\>\mods folder, be warned that by enabling logging the mod will produce a big deal of logging in your starbound.log and try to reproduce the issue.

To share the log file you can use a service like [PasteBin](https://pastebin.com/) and post the link to your log file along with the issue you encountered.

You can also have a live view of your starbound.log while you're playing, if you wish to: if you're using windows, with the following command in a powershell prompt: "Get-Content \<Starbound folder\>\storage\starbound.log -Wait"

Send as much informations as possible on how to reproduce the bug, how it happened and so forth, be sure to include your starbound.log file (found in \<Starbound folder\>\storage)

To report a bug/contact the developer you can either:
  - Use the [Issues](https://github.com/CondensedChaos/Starbound-Rail-Train/issues) tab on github (you'll need a GitHub account)
  - Make a comment on the discussion page under "Bug Reporting" on the mod's Steam page (you can use the comments if you're just asking for help with the mod)
  - if you do not have a GitHub account or a Steam account you can use [This Form](https://docs.google.com/forms/d/e/1FAIpQLScRjkyEhFuLu1DFb9Ea0Roxx3Dc11vulyZgTt9HoLfyP2EClw/viewform) to contact the developer.

Uninstall the logging patch by deleting the Starbound-Rail-Train-Enable-Logging-Patch.pak in your \<Starbound folder\>\mods folder after you're done.

## Free Mode
In free mode the trains are crafted using the **"Trainset Configurator"** (crafted at Rail Crafting Table) and just placed on the rails.  
Once the train is placed it will continue to go over the rails and stops at stations, you can either make a circular rail line around the planet or use rail bumbers to revert its direction so it goes back and forth.  
To create stops you need to use the custom rail markers (called **"Rail station marker"**, craftable at the Rail Crafting Table) supplied with the mod (**_do not use conventional vanilla tram stops_**).  
Since the game loads the world in *"chunks"* that are approximately 20x20 blocks, you will need special items to place on the rail every 19 tiles that will keep that tract of world loaded (similar to Minecraft "Chunks Loaders")  
There are two variants of chunk loaders, they're only different in appearance but they serve the same functions: **"catenaries"** and **"rail chunk loaders"**  

Free mode [usage](https://github.com/CondensedChaos/Starbound-Rail-Train#free-mode-1)

## Scheduled mode
In scheduled mode special items that controls the rail stops are used in conjuction with **Rail station markers**, those are the **"Station controllers"** craftable at the Rail crafting table.  
Those are used to define a train line and wired to a rail station marker. Each station has to have its Station Controlled.  

Stations should be placed east to west.  
After all the stations controllers are placed and wired to its rail station marker a train line has to be defined using the station controller user interface (just interact with the first station) a line has to be created and all the other stations of the line added.  

A test run has to be made to measure the travel time for each section of the line.  
With the data from the test run you should then use the provided web app (more of this later) to plan the trains schedule.  

Then go back to the station controller to create the schedule using the data from the web app, you can choose how many trains to have for each direction, choose their speed for each tract and stop times for each station, and when the trains should start.  

Then you'll have to craft a train at the **Trainset Configurator** for each tran you schedule, and import the items in the Train Configurator (more in depth usage for Scheduled mode here)  
Catenaries and/or Chunk Loaders has to be used too in scheduled mode.  

Scheduled mode [usage](https://github.com/CondensedChaos/Starbound-Rail-Train#scheduled-mode-1)

---
# Reccomended mods

## Many Tabs compatibility patch
A patch to support Many tabs, highly reccomended, needs Many Tabs and Many Tabs Handcrafting Expansion  
It will create an own tab in the Rail Crafting Table for all the craftable components of this mod  

### From Steam Workshop:
[here](https://steamcommunity.com/sharedfiles/filedetails/?id=3006988151)
### DRM-free version:
[From Github](https://github.com/CondensedChaos/Starbound-Rail-Train-Many-Tabs-Patch/tree/main)

---

## Many Tabs:
This mod allows nearly all Crafting Tables to have more tabs to avoid cluttering if you use many mods  
### From Steam Workshop:
[Part 1](https://steamcommunity.com/workshop/filedetails/?id=1119086325) and [Part 2](https://steamcommunity.com/workshop/filedetails/?id=956247051)  
Be sure to subscribe to both mods (it's a 2-part mod)  
### DRM-free version:
[From Chucklefish Forum](https://community.playstarbound.com/resources/many-tabs.4813/)  
or  
[From SkyMods Part 1](https://catalogue.smods.ru/archives/5449) and [Part 2](https://catalogue.smods.ru/archives/5447)  
If you're downloading from SkyMods be sure to download both Part 1 and Part 2  

---

## Many Tabs Handcrafting Expansion:
It expands Many Tabs to support even more crafting tables  
### From Steam Workshop:
[Part 1](https://steamcommunity.com/workshop/filedetails/?id=2248892900) and [Part 2](https://steamcommunity.com/workshop/filedetails/?id=956247051)  
Be sure to subscribe to both mods (it's a 2-part mod)  
### DRM-free version:
[From SkyMods Part 1](https://catalogue.smods.ru/archives/111834) and [Part 2](https://catalogue.smods.ru/archives/111835)  
Be sure to download both Part 1 and Part 2  

---

## Many Tabs Rail Crafting Table:
It expands Many Tabs to better support Rail Crafting Table  
### From Steam Workshop:
[Here](https://steamcommunity.com/sharedfiles/filedetails/?id=2810272474) 
### DRM-Free version:
Not yet available, will notify when it will be available  

---

## Enhanced Rails
It will allow you to use an additional rail network (slick rail) that will allows for faster trains  
### From Steam Workshop:
[here](https://steamcommunity.com/sharedfiles/filedetails/?id=921924325)
### DRM-Free version:
[from Chucklefish forum](https://community.playstarbound.com/resources/enhanced-rails.4708/)

---

## Instant Crafting
Disables the timer on client-side crafting tables so that everything you craft finish instantaneously.  
### From Steam Workshop:
[Instant Crafting](https://steamcommunity.com/sharedfiles/filedetails/?id=729427744)  
[Instant Crafting Fixes (additional supports for other mods)](https://steamcommunity.com/workshop/filedetails/?id=1607460753)  
[Instant Crafting More Fixes (additional support for even more mods)](https://steamcommunity.com/sharedfiles/filedetails/?id=2809626987)  
### DRM-Free version:
[Instant Crafting from ChuckleFish Forum](https://community.playstarbound.com/resources/instant-crafting.3731/) or [From Skymods](https://catalogue.smods.ru/archives/24774)  
[Instant Crafting Fixes (additional supports for other mods)](https://catalogue.smods.ru/archives/80366)  
[Instant Crafting More Fixes (additional support for even more mods)](https://catalogue.smods.ru/archives/115134)  

---

## Skizot's Dozers
Adds bulldozers to make tunnels, fun to use!  
### From Steam Workshop:
[here](https://steamcommunity.com/sharedfiles/filedetails/?id=729428803)  
### DRM-Free version:
[from Chucklefish Forum](https://community.playstarbound.com/resources/skizots-dozers.3094/)  
or  
[from Skymods](https://catalogue.smods.ru/archives/24653)  

---

# Usage
To allow Starbound to run the trains you will need to use rail chunk-loaders.  
Similar to Minecraft's [Chunk Loaders](https://www.sportskeeda.com/minecraft/chunk-loaders-minecraft-all-need-know) they are items that sits on the rails and have to be placed every 18 tiles.  

Starbound divides the world in chunks, each chunk is roughly 20x20 tiles, if no player is present in a determined chunk the game will not render that chunk so for example it will have the effect that any vehicle running outside player's vicinity will be stopped.  
Rail chunk loaders force the chunk where they are put to not be put to sleep.

There are two kinds of Rail Chunk Loaders: simple chunk loaders and catenaries.  
They provide exactly the same function and their difference is purely aesthetic.  
Catenaries are build to provide a real-life [overhead lines](https://www.trackopedia.com/en/encyclopedia/infrastructure/power-systems-and-overhead-lines) look and feel.  

## Kind of networks

### Non-circular lines

They are rail lines that start in a point and end somewhere else,  for trains going to east: trains will start from station 1 (or any other subsequent station except station 4) and end their ride at last station (station 4 in this example), at the end of theri ride the trains will invert their direction, going from east to west and go back to station 1 on the same track.

Conversely trains going from west to east will start at last station (or any other previous station except station 1) and end their ride at station 1, inverting their direction and going back east towards station 4.

In both cases the loop will continue indefinitely.

The same line can have both trains going to east and west simultaneosly like a railway with two parallel rails.

<div align="center">
<img src="https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/3275c4ac-84d4-4c2c-ad5d-1ac309e6dce5.png" alt="non-circular" />
</div>

### Circular lines

They are rail lines that form a circular path, trains can start at any station and at the end of the ride the trains are back where they started without inverting their direction and will continue riding the rails keeping their original direction.
In Starbuond it's a train line that circle an entire planet.

For example a train going towards east starting from station 1 will pass through station 2, 3 and 4 and then it will encounter station 1 again and will continue to go east without inverting their direction.

Conversely a train going towards west starting from station 1 will pass through station 4, 3 and 2 and then it will encounter station 1 again and will continue to go west without inverting their direction.

The same line can have both trains going to east and west simultaneosly like a railway with two parallel rails.

<div align="center">
<img src="https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/1da0-44ab-9756-be7a55b8d319.png" alt="circular" />
</div>

## Tram network preparation

### Height requirements
Minimum height if you're buiding a tunnel and you're using catenaries is 12 blocks:  
![size1](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/42efff3b-a6a2-482d-99aa-d56f8b037fdd.png)

The trains comprehensive of Pantographs are 10 blocks high:  
![size2](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/f077ae2e-ef5e-45c3-920b-1bd02f8deb7b.png)

If you're building a tunnel and you don't want to use catenaries and pantographs, the minimum height to allow trains to pass is 9 blocks:  
![size3](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/b8263d55-0b54-4b9e-a2b2-0c9ff8f110e6.png)  
The use of [Skizot's Dozers](https://github.com/CondensedChaos/Starbound-Rail-Train/tree/main#skizots-dozers) can be very useful (and fun) to dig tunnels.

### Place Rail Chunk loaders or Catenaries
If you're using catenaries or rail chunk loaders they will both highlight their area of incluence in red, make sure to place the other chunk-loaders between the green and the red area:  
![catenaries1](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/e199536e-e385-4fbc-8ebd-463c44d864a6.png)  
![catenaries2](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/4161c4a7-4be1-4ea8-879f-0b6eeccc390f.png)  

When placing the next chunk-loader a "phantom" image of the next chunk-loader or catenary will follow the mouse cursor to allow a perfect and fast placement:  

#### Catenaries:
![catenaries3](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/2aee9d66-de4e-4166-a183-90f30aa22051.png)  
![catenaries4](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/18e21977-fa29-4d84-ad94-c1e4ef0f96bb.png)  
#### Plain chunk-loaders:  
![chunk-loaders area1](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/77313de7-2ea7-432c-b1ff-98ee47301116.png)  
![chunk-loaders area2](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/99ac73af-241d-4c3b-bf6a-427532fa833c.png)  

#### Place the rails:
After placing all the catenaries in the area where your rail network will be (be sure to cover the whole area where the trains will transit) you can begin to place the actual rails:
![catenaries8](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/40ed3124-ac8c-4bd2-a0f1-ebf3f310ca85.png)  
![catenaries9](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/c52c7899-d5b0-4774-a816-193d86ce6bea.png)  

#### note for circular lines:
When building a circular line, after making a complete circle around the planet it could happen that the network is uneven and the next catenary position won't match like this:  
![Uneven catenaries1](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/dbb0ee66-64a1-477a-93b8-afdac398b66c.png)  
or this:  
![uneven catenaries2](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/d1f1f739-bba0-443e-a8b2-6c76cc08e9e2.png)  
To solve this problem use the catenary with girder for uneven network (called catenary girder, no wires):  
![uneven2a](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/e0ae2121-b506-43bd-839d-fd2db32c6af7.png)  
And extend the wires with "catenary wires":  
![uneven2b](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/21fe68c1-92e4-4d01-81de-27420e6c92d5.png)  
![uneven2c](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/e1bc5a1e-01dd-4605-a77b-20b05bf73f97.png)  
If you think that the girders are too close to each other, you can also use plain rail chunk-loaders without girders:  
![uneven2c1](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/e5764911-942b-41ec-ae25-b2b4b338ae28.png)  
And just extend the wires with "catenary wires":  
![uneven2c2](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/05935410-a585-417f-a651-f120c6a8776f.png)  
![uneven2c3](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/3c906eaa-865d-4203-982a-f3856fce987b.png)  

### Place Rail Stations Markers
Rail station markers are used to mark stations where the trains will stop
![stationmarker1](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/42809523-4da6-46e4-a657-ab4208f94a25.png)  
They are crafted at rail crafting table:
![railstationmarker craft](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/aff5d72e-b504-406a-9feb-3db1dbd540e7.png)  
![rail station marker craft](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/c2e83c5d-f7ba-43ba-98fc-55541278cdaf.png)  
![station marker2](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/e592b3ed-d081-4028-8cd9-0dc02735006f.png)  

![station marker3](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/a585ba44-b478-4eb6-96ba-0d622cb1f572.png)  
After deciding where the station will be you should use a [platform block](https://starbounder.org/Blocks#Platforms) (do not use regular blocks or trains will collide and won't be able to pass through)
to let passangers get off and on trains, be sure to be long enough as the trains that you intend to use on the network:  
![station marker3a](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/e79e89e4-5515-41da-afc6-312aa54be9d2.png)  
![station 1](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/21885e3e-ecd5-4405-8ab5-ada4e80b7983.png)  
Then you can decorate the station:  
![station 2](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/0c3fe947-5b97-4edd-967a-92d73f14af82.png)  

***For Scheduled mode only:***  
Also place a Station controller and wire it to station marker:  
![station marker 4](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/ca685ffa-c7a1-4195-8fd3-5e6cba19c9d8.png)  
![station marker 5](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/c0e239b7-8445-4449-aee7-ec69d18e1300.png)  
![station marker 6](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/e452b780-a7c4-42c5-a5fc-6a3d591bdd9e.png)  
![station marker 7](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/f9a0abbf-e1fa-45a8-b6a2-8e21bae34d37.png)  

![station marker 8](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/9d9db061-bab5-4694-8724-0cf7c205bde6.png)  

Two stations controllers can be wired to a single rail station marker if that station is shared between two lines:  
![station marker 9](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/b813102e-8ba4-47eb-9ebb-a8086280d532.png)  
for more information refer to ["Scheduled mode with two or more lines"](https://github.com/CondensedChaos/Starbound-Rail-Train#scheduled-mode-with-two-or-more-lines)  
Name your station:  
![line creation1](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/5d397e57-3b07-447a-90ef-8f042124fe0d.png)  
![line creation2](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/4055304b-5f13-4027-96fd-ef9b22813bcc.png)  

### Wall-mounted Station Controller
There is also a wall-mounted version of Station Controller:
![station controller wall](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/6ff6306a-c315-41bc-bd14-834821eed0b4.png)  
![station controller wall 2](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/d356bff9-83fd-4192-b0f6-42575444630a.png)
![wall-station controller1](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/a2a29d79-8249-42c2-8369-6ef872318c87.png)  

#### note for non-circular lines
If you're building a [non-circular line](https://github.com/CondensedChaos/Starbound-Rail-Train/tree/main#non-circular-lines):
- If you're using [free mode](https://github.com/CondensedChaos/Starbound-Rail-Train/tree/main#free-mode-1)
  You have to put a [rail bumper](https://starbounder.org/Rail_Bumper) at both sides of the lines:  
  - just before the first Station Marker, as in this picture:  
    ![non-circular without bumper-2](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/f1cf1c55-4349-47e2-b21c-7615fddd5f4a.png)  
  - just after the last Station Marker, as in this picture:  
    ![non-circular without bumper](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/5b56a6e5-28bf-43c7-82b7-c125b3d12bf1.png)  
  This will ensure that trains will invert their direction when reaching both ends of the line:  

https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/976ac2b0-21d0-4daf-b6b4-fcb4509b3fc5

- If you're using [scheduled mode](https://github.com/CondensedChaos/Starbound-Rail-Train/tree/main#scheduled-mode-1)
  You don't need rail bumpers as trains will sense they reached the end of the line and they have to invert direction, just extend the rails for some tiles (4 is enough) at both ends of the line as in the picture:  
  ![non-circular wihout bumper-2](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/9a547991-6792-4095-9f75-3c4234c23ced.png)
  ![non-circular wihout bumper](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/02975412-12e8-4435-baaa-69321c2e76ef.png)  

https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/031df3cb-40b3-4f08-8699-502e966c0703

---
## Components

### Train scheduling web-app
There's a web-app availabe to aid you in scheduling of trains in scheduled mode.
Open the trains schedule web-app [here](condensedchaos.github.io)
Usage of the Web-App: [here](https://github.com/CondensedChaos/condensedchaos.github.io)

### Trainset Configurator
![trainconfigurator](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/22002a29-4499-46e7-9930-516bd98dbef5.png)  
![train configurator1](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/be8ed6f4-af5f-4307-9a90-d912de0555a4.png)  
![trainconfigurator2](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/a7f00cb9-3d45-42a4-bcd7-312ed1f9d580.png)  
![train configurator2](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/2a5b0c99-69f2-4959-b604-62a647cd8bcd.png)  
![train configurator3](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/9503fecd-7707-437c-b710-ab3d443df47f.png)  
![train configurator4](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/00a4205f-d62b-443b-b1d1-e6327436a7b8.png)  
![train configurator5](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/c3a4c92c-8921-4261-bb66-750dc985fc7e.png)  
![train configurator6](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/9f57baa4-b9df-4cc5-9cf4-3d0de4bfccef.png)  
![trainset configurator craft](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/6aaca641-38a7-4d1e-a7e2-45eb1631c96f.png)  

### Catenaries/Chunk loaders
![catenary](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/0565a745-601c-4993-8b67-e6cfde30afaa.png)  

![catenary1](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/e86de415-b396-49e5-89ca-e243a0949da9.png)
![catenary2](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/164c06c5-0704-465e-95a8-51f76031c954.png)
![catenary3](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/a990e637-37ed-4550-b055-367d6235a13f.png)

![catenary-wires](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/ddb76dcc-50f9-4e9e-993f-f0c14202fce1.png)  
![catenary-wires2](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/c863709b-a063-452f-a2f7-586fcaffc36e.png)  
![catenary craft](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/0e84c00e-c1dc-41ef-a914-692eb8512c72.png)  
![rail chunk loader craft](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/1d17a7b0-28f0-4c62-b1d5-0038e8b478a6.png)  
![wires-craft](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/cbc388c4-88cb-4ddb-aad8-d5f214d8ad72.png)  

#### 45°degrees Catenaries
![catenary45](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/076150ba-3c37-4cf4-bbc7-5d2bc6d3268b.png)  

![catenary45-1](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/c9ee1cbb-8eaf-4da3-911b-b2de00ab6fd8.png)
![catenary45-5](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/54e0d32e-9219-4704-9bfb-916e10d5f96b.png)  
![catenary45-4](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/3b0dfcc9-8199-4521-9cc9-6958dc33f0e2.png)  
![catenary45-3](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/aa53da59-ca2a-4789-b7e5-e7fa145424fe.png)  
![catenary45-2](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/8e971ecf-f187-49b6-85c1-5575ed8ee27f.png)  

![catenary-wires45](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/0fcd12d2-9a20-47f5-80a4-f121f5acc430.png)  
![catenary-wires45-2](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/f37e8faf-d501-4cce-bc97-e20edf4a9ebe.png)  
![girderext](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/31591d13-bf29-4bc9-8ed5-85f0f18a33a6.png)  
![girderext-1](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/43c6d2b9-b747-41a7-8e4a-be28e9716fe2.png)  

### Station Controller
![station-controller1](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/efb8104c-8039-48b3-a74a-e32453341d34.png)  
![station-controller1-2](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/c4725aca-7390-4ea9-8716-530a39758651.png)  
Wall mounted version:  
![station controller wall](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/6ff6306a-c315-41bc-bd14-834821eed0b4.png)  
![station controller wall 2](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/d356bff9-83fd-4192-b0f6-42575444630a.png)  

### Custom Rail station marker
![marker1](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/82b54190-3bcb-4c66-9322-b08f2c7b136d.png)  
![marker2](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/2d740b1a-f1e7-485c-87ba-eb8ada5a8f6d.png)  

---
## Free Mode
In free mode the trains are crafted using the **"Trainset Configurator"** (crafted at Rail Crafting Table) and just placed on the rails.  
Once the train is placed it will continue to go over the rails and stops at stations, you can either make a circular rail line around the planet or use rail bumbers to revert its direction so it goes back and forth.  
To create stops you need to use the custom rail markers (called **"Rail station marker"**, craftable at the Rail Crafting Table) supplied with the mod (**_do not use conventional vanilla tram stops_**).  
Since the game loads the world in *"chunks"* that are approximately 20x20 blocks, you will need special items to place on the rail every 19 tiles that will keep that tract of world loaded (similar to Minecraft "Chunks Loaders")  
There are two variants of chunk loaders, they're only different in appearance but they serve the same functions: **"catenaries"** and **"rail chunk loaders"**  

### Prepare your network

### 1)Place Rail Station Markers
Refer to [Place Rail Stations Markers](https://github.com/CondensedChaos/Starbound-Rail-Train/blob/main/README.md#place-rail-stations-markers)

### 2)Place Chunk Loaders/Catenaries - 3)Place the rails
Refer to [Place Rail Chunk Loaders or Catenaries](https://github.com/CondensedChaos/Starbound-Rail-Train/blob/main/README.md#place-rail-chunk-loaders-or-catenaries)

### Craft trains
Craft a Trainset Configurator from Rail Crafting Table and refer to [Trainset-Configurator](https://github.com/CondensedChaos/Starbound-Rail-Train/tree/main#trainset-configurator)  
And craft as many trains as you want to use on the network

### Place trains
Select the item of the trains you have just crafted:  
![place trains1](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/c4587d7b-5c3e-4812-bc90-b20af79f412f.png)  
a preview of where the train will be placed will appear, when is green means it is in a suitable position to be placed:  
![place trains2](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/3b8a623f-0545-44c8-b468-70c5e2c89d30.png)  
Be sure to place the train just above the rail track or it could be failed to spawn:  
![place trains 2a](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/0edaf219-1d92-40ee-bb3f-9ad3f17dd089.png)  
![place trains3](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/9ea0ad71-8789-474c-9b27-ea345790cbf4.png)  
Repeat the above steps for every train that you want to place.

---
## Scheduled mode
In scheduled mode special items that controls the rail stops are used in conjuction with **Rail station markers**, those are the **"Station controllers"** craftable at the Rail crafting table.  
Those are used to define a train line and wired to a rail station marker. Each station has to have its Station Controlled.  

Stations should be placed from east to west.  
After all the stations controllers are placed and wired to its rail station marker a train line has to be defined using the station controller user interface (just interact with the first station) a line has to be created and all the other stations of the line added.  

A test run has to be made to measure the travel time for each section of the line.  
With the data from the test run you should then use the provided web app (more of this later) to plan the trains schedule.  

Then go back to the station controller to create the schedule using the data from the web app, you can choose how many trains to have for each direction, choose their speed for each tract and stop times for each station, and when the trains should start.  

Then you'll have to craft a train at the **Trainset Configurator** for each tran you schedule, and import the items in the Train Configurator (more in depth usage for Scheduled mode here)  
Catenaries and/or Chunk Loaders has to be used too in scheduled mode.  

### Kind of lines
Refer to [Kind of networks](https://github.com/CondensedChaos/Starbound-Rail-Train/tree/main#kind-of-networks)

### Prepare your network

### Place Rail Station Markers
![stationmarker1](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/42809523-4da6-46e4-a657-ab4208f94a25.png)  
![railstationmarker craft](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/aff5d72e-b504-406a-9feb-3db1dbd540e7.png)  
![station marker2](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/e592b3ed-d081-4028-8cd9-0dc02735006f.png)  
![station marker3](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/a585ba44-b478-4eb6-96ba-0d622cb1f572.png)  
![station marker3a](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/e79e89e4-5515-41da-afc6-312aa54be9d2.png)  

### Place Station Controllers 
And wire them to Rail Station Markers  
IMPORTANT: Stations are to be plaeced in order from east to west  
![station controller craft](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/12554c65-a599-499a-9208-2e80d1d5b538.png)  
![station marker 4](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/ca685ffa-c7a1-4195-8fd3-5e6cba19c9d8.png)  
![station marker 5](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/c0e239b7-8445-4449-aee7-ec69d18e1300.png)  
![station marker 6](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/e452b780-a7c4-42c5-a5fc-6a3d591bdd9e.png)  
![station marker 7](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/f9a0abbf-e1fa-45a8-b6a2-8e21bae34d37.png)  
![station marker 8](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/9d9db061-bab5-4694-8724-0cf7c205bde6.png)  
![station marker 9](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/b813102e-8ba4-47eb-9ebb-a8086280d532.png)  

#### Name your stations
![line creation1](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/5d397e57-3b07-447a-90ef-8f042124fe0d.png)  
![line creation2](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/4055304b-5f13-4027-96fd-ef9b22813bcc.png)  

### 4)Place Chunk Loaders/Catenaries - 5)Place the rails
Refer to [Place Rail Chunk loaders or Catenaries](https://github.com/CondensedChaos/Starbound-Rail-Train/tree/main#place-rail-chunk-loaders-or-catenaries)  

### Create a Line
![line creation3](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/30fa0857-0674-45a4-9432-3c63516d3402.png)  
![line creation4](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/891cf0b0-95cd-4642-9979-6d5f14ff4dc0.png)  
![line creation5](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/0ced7315-3f90-4f2f-a992-b3a5745be4ad.png)  
![line creation6](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/057f2be1-91d0-448d-b489-e4f93cf3b8e4.png)  
![line creation7](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/4807e3d4-1740-4270-a39b-80430bab4804.png)  
Select the "circular" checkbox if your line goes all around your planet:
![line creation8](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/c9e0f280-9a6e-4e4d-ae67-b2c5082602d3.png)  

#### Add Stations  
IMPORTANT: Stations should be ordered from east to west  
![line creation9](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/91d0b7fc-602e-4663-ae27-7d441c70b9a1.png)  
![linecreation10](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/5794114c-0576-49a6-a0da-6264bbdcd21e.png)  
![line creation11](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/e36ec300-5825-4a6e-8d16-8d6453d1ac31.png)  
![line creation12](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/bfcb931d-9092-4c70-a581-708f192e8c59.png)  

---  
If you order the stations in the wrong order you can reorder them using the "Reorder stations" button
![line creation13](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/4b545a5e-3dd4-43fb-8274-0d45400f73ca.png)  
![line creation14](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/aa2ecef2-436a-4552-87c5-ca48201b246a.png)  
![line creation15](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/865da791-9aa4-4e35-a932-59fc598d69e4.png)  

### Do test runs
![line creation 16](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/60190db1-ae44-4da2-968d-8260575eec01.png)  
![line creation17](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/f2fd65f0-b1b1-455a-a4b1-d70b97edc4e2.png)  
![line creation18](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/fa5ccb43-c30d-4604-8dc6-d5f68833730f.png)  
![line creation19](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/55f471e5-6f91-45cc-8ac9-f9028007320b.png)  
The more test runs you make the more precise the readings will be but it will take more time, 10 test runs is best, more than that it's just overkill, 5 should be acceptable.  

Note: As of now there is no way to know if test runs are over, checking from time to time the test run dialog if you see the test run data on the upper left then it's over, there's an upcoming feature planned to show live the test run datax status and position of the trains as they go in the GUI.

### Make schedules with web-app
Open the trains schedule web-app [here](https://condensedchaos.github.io/)  
Usage of the Web-App: [here](https://github.com/CondensedChaos/condensedchaos.github.io)  

### Craft Trains
Craft a Trainset Configurator from Rail Crafting Table and refer to [Trainset-Configurator](https://github.com/CondensedChaos/Starbound-Rail-Train/tree/main#trainset-configurator)  
Craft as many trains are required from the schedule you made with the app.

### Create the schedule in-game
![00](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/b6ff8dee-ac1f-49d7-947d-ef3fd387def4.png)  
![01](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/1e881b54-4a19-4c94-8571-da60fbea1286.png)  
When entering the schedule dialo for the first time one eastbound train and one westbound train will be created starting at time 0 from station 1 (for non-circular line eastbound trains start at station 1 and westbound trains start at last station) if you don't want either of these you can delete them or change their starting station and/or starting time.  
![02](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/cd116b64-5573-463a-98a4-f99fd3619f49.png)  
Clicking on a train will allow you to modify its speed for each section of the railway, its stopping time for each station, its starting time, starting station and to add the actual train spawner you got from train configurator.  
![03](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/120935ab-ba21-42b3-a245-887db316a37e.png)  
Clicking the add train dialog will create a new train for your timetable:  
![04](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/f2fd00ab-000e-43b4-abb0-a62e517656c1.png)  
![05](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/8c3881ad-8303-4d07-bfc6-c4cfdebfffb9.png)  

#### Add train items in Station Controller  
After you made your schedule you can add train spawner items to each train:  
![06](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/cdd84aa3-6b44-42f4-b5ce-63dab4ae339c.png)  
![07](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/bc50e1b7-1ffa-485c-af39-ca853e61ec91.png)  

### Start trains
Interact with any station controller to open its GUI, select "Lines":  
![start trains1](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/2e30681f-a2c5-4ba7-9ef1-e5bfacaeec07.png)  
Select "Start trains":  
![start trains2](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/818ef96b-803e-4824-b62d-deb39611f537.png)  
If more lines are present in the planet a dialogue will be opened to ask which line should be started:  
![start trains 3](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/957ebcd6-89dd-4b85-af43-662c5edb0a88.png)  
If only one line is present that line will be started without any further comfirmation.

---

# Scheduled mode with two or more lines

Below are all the use-cases:  

## Case 1a

A circular line sharing a part of its path with one or more non-circular line, the non-circular line's stations are all shared with the circular line.  

<div align="center">
<img src="https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/248907757-260acd28-b71b-4472-8a7a-b64f26e8143b.png" alt="Case 1 - 1 Circular line sharing stations with a non-circular line" />
</div>

In example above you should create line A as a circular line:  
  - [Place Rail Station Markers](https://github.com/CondensedChaos/Starbound-Rail-Train/tree/main#place-rail-station-markers)
  - [Place station controllers](https://github.com/CondensedChaos/Starbound-Rail-Train/tree/main#place-station-controllers) and name your stations
  - [Place Rail Chunk loaders or Catenaries](https://github.com/CondensedChaos/Starbound-Rail-Train/tree/main#place-rail-chunk-loaders-or-catenaries)
  - [Place the rails](https://github.com/CondensedChaos/Starbound-Rail-Train/tree/main#place-the-rails)
  - [Create the Line-A](https://github.com/CondensedChaos/Starbound-Rail-Train/tree/main#create-a-line) as CIRCULAR-LINE and [add the other stations](https://github.com/CondensedChaos/Starbound-Rail-Train/tree/main#add-stations)

Don't proceed to do test-runs or the other passages after adding the stations.  
Now you'll have to craft the station controllers for Line B, one for each stations and place them like that, wiring Line B's station controllers to the same station controller of the correspondent Line A's station:  
![station marker 9](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/b813102e-8ba4-47eb-9ebb-a8086280d532.png)  
Place station 1-B next to station 2-A, [name the station](https://github.com/CondensedChaos/Starbound-Rail-Train/tree/main#name-your-stations)
Then placestation 2-B next to station 3-A and name the station and so forth.  
[Create the Line-B](https://github.com/CondensedChaos/Starbound-Rail-Train/tree/main#create-a-line) as NON-CIRCULAR-LINE(do not tick "circular" checkbox) and [add the other Line-B stations](https://github.com/CondensedChaos/Starbound-Rail-Train/tree/main#add-stations)  
Open the station controller for Line A (left one), select "Lines: and select "Test run" (refer to ["Do test runs"](https://github.com/CondensedChaos/Starbound-Rail-Train/tree/main#do-test-runs))  
![rail demo 9](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/e608678f-90d8-4f5b-a927-5da49087ec22.png)  
Start test runs for "Line A", the more test runs you make the more precise the readings will be but it will take more time, 10 test runs is best, more than that it's just overkill, 5 should be acceptable:  
![rail demo 11](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/3fa10c3d-009a-4d3f-8231-01ae898131cb.png)
![rail demo 12](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/f2d04564-7dcb-4fda-ba28-13dec6dc9136.png)  

Repeat the steps above for "Line B" (open the station controller on the right)
You should run the testruns for both lines in parallel while the other line is running the tests.

Using the testrun data from both lines open the marey-chart webapp plan the schedule for your trains, refer to the manual of the web app [here](https://github.com/CondensedChaos/condensedchaos.github.io/tree/main)  
Particularly to the sections:
[More lines in a graph](https://github.com/CondensedChaos/condensedchaos.github.io/tree/main#more-lines-in-a-graph)  
[How to use](https://github.com/CondensedChaos/condensedchaos.github.io/tree/main#how-to-use)  
[Case 1a](https://github.com/CondensedChaos/condensedchaos.github.io/tree/main#case-1a)  

Web-app URL : https://condensedchaos.github.io  

After you have made your schedule you'll have to recreate in-game the schedule you've made in the web-app  
refer to:  
[Create the schedule in-game](https://github.com/CondensedChaos/Starbound-Rail-Train/tree/main#create-the-schedule-in-game)  
[Add train items in Station Controller](https://github.com/CondensedChaos/Starbound-Rail-Train/tree/main#add-train-items-in-station-controller)  
Do it for both Line-A and Line-B, after you made your schedule and added train items for both Lines you can start your trains, refer to: [Start trains](https://github.com/CondensedChaos/Starbound-Rail-Train/tree/main#start-trains)  

## Case 1b

Two or more non-circular lines sharing parts of their paths, the smaller lines' stations are all shared with the bigger one's

<div align="center">
<img src="https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/55642e8a-9ca3-4982-b727-d40674a48904.png" alt="Case 1b" />
</div>

Procedure is same as [Case 1a](https://github.com/CondensedChaos/Starbound-Rail-Train/tree/main#case-1a) execpt that both Line-A and Line-B are NON-CIRCULAR

After you have completed the test runs for both lines open the marey-chart webapp plan the schedule for your trains, refer to the manual of the web app [here](https://github.com/CondensedChaos/condensedchaos.github.io/tree/main)  
Particularly to the sections:
[More lines in a graph](https://github.com/CondensedChaos/condensedchaos.github.io/tree/main#more-lines-in-a-graph)  
[How to use](https://github.com/CondensedChaos/condensedchaos.github.io/tree/main#how-to-use)  
[Case 1b](https://github.com/CondensedChaos/condensedchaos.github.io/tree/main#case-1b)  

Web-app URL : https://condensedchaos.github.io  

After you have made your schedule you'll have to recreate in-game the schedule you've made in the web-app  
refer to:  
[Create the schedule in-game](https://github.com/CondensedChaos/Starbound-Rail-Train/tree/main#create-the-schedule-in-game)  
[Add train items in Station Controller](https://github.com/CondensedChaos/Starbound-Rail-Train/tree/main#add-train-items-in-station-controller)  
Do it for both Line-A and Line-B, after you made your schedule and added train items for both Lines you can start your trains, refer to: [Start trains](https://github.com/CondensedChaos/Starbound-Rail-Train/tree/main#start-trains)  

## Case 2a

A circular line sharing some of its station with a non-circular line. The non-circular line's tracks it's the same as the circular line's although some of the stations are not shared.

<div align="center">
<img src="https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/395a-4065-ab50-f6ce869f9d52.png" alt="Case 2a" />
</div>

Procedure is same as [Case 1a](https://github.com/CondensedChaos/Starbound-Rail-Train/tree/main#case-1a)  
Except that Station 3-B sits in the middle between station 3-A and Station 4-A

After you have completed the test runs for both lines open the marey-chart webapp plan the schedule for your trains, refer to the manual of the web app [here](https://github.com/CondensedChaos/condensedchaos.github.io/tree/main)  
Particularly to the sections:
[More lines in a graph](https://github.com/CondensedChaos/condensedchaos.github.io/tree/main#more-lines-in-a-graph)  
[How to use](https://github.com/CondensedChaos/condensedchaos.github.io/tree/main#how-to-use)  
[Case 2a](https://github.com/CondensedChaos/condensedchaos.github.io/tree/main#case-2a)  

Web-app URL : https://condensedchaos.github.io  

After you have made your schedule you'll have to recreate in-game the schedule you've made in the web-app  
refer to:  
[Create the schedule in-game](https://github.com/CondensedChaos/Starbound-Rail-Train/tree/main#create-the-schedule-in-game)  
[Add train items in Station Controller](https://github.com/CondensedChaos/Starbound-Rail-Train/tree/main#add-train-items-in-station-controller)  
Do it for both Line-A and Line-B, after you made your schedule and added train items for both Lines you can start your trains, refer to: [Start trains](https://github.com/CondensedChaos/Starbound-Rail-Train/tree/main#start-trains)  

## Case 2b

Two non-circular line sharing some stations, one line starts where the other line ends.

<div align="center">
<img src="https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/6d21895c-e57a-493e-90ce-c684ec6487c6.png" alt="Case 2b" />
</div>

Similar to [Case 1b](https://github.com/CondensedChaos/Starbound-Rail-Train/tree/main#case-1b) the only difference is that when one line ends the other line begins, the only shared station is the last station of Line-A that is the first station of Line-B.

After you have completed the test runs for both lines open the marey-chart webapp plan the schedule for your trains, refer to the manual of the web app [here](https://github.com/CondensedChaos/condensedchaos.github.io/tree/main)  
Particularly to the sections:
[More lines in a graph](https://github.com/CondensedChaos/condensedchaos.github.io/tree/main#more-lines-in-a-graph)  
[How to use](https://github.com/CondensedChaos/condensedchaos.github.io/tree/main#how-to-use)  
[Case 2b](https://github.com/CondensedChaos/condensedchaos.github.io/tree/main#case-2b)  

Web-app URL : https://condensedchaos.github.io  

After you have made your schedule you'll have to recreate in-game the schedule you've made in the web-app  
refer to:  
[Create the schedule in-game](https://github.com/CondensedChaos/Starbound-Rail-Train/tree/main#create-the-schedule-in-game)  
[Add train items in Station Controller](https://github.com/CondensedChaos/Starbound-Rail-Train/tree/main#add-train-items-in-station-controller)  
Do it for both Line-A and Line-B, after you made your schedule and added train items for both Lines you can start your trains, refer to: [Start trains](https://github.com/CondensedChaos/Starbound-Rail-Train/tree/main#start-trains)  

## Case 3a

To be implemented:  
![case3a](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/2fc5-46a6-b334-202ffa2c120b.png)

## Case 3b

To be implemented:
![case3b](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/4c86e6ae-3e19-4cb3-9809-3f614f80886d.png)

---

# Rail-demo
It's an instance world that includes a ready-made demo train network of two lines that can be used to understand better how the mod works.

it's called "raildemo.zip", to install it you have to open the downloaded zip file and
unzip the content of the folder named as "1 - EXTRACT CONTENT OF THIS FOLDER INSIDE starbound -> mods" in \<Starbound folder\>\mods

and the content of folder named as "2 - EXTRACT CONTENT OF THIS FOLDER INSIDE starbound->storage->universe" in \<Starbound folder\>\universe\storage

To access the demo just craft a "rail demo world teleporter" from the empty-hand (press C in-game) crafting:  
![rail demo1](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/cf1f7bec-657f-4ada-98d4-ef613308ad12.png)  
Place the teleporter and warp in the demo-world:  
![rail demo2](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/57720c33-05fb-4297-ad2d-06ca3f472d45.png)  
![rail demo 3](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/846cc428-fefd-45b2-8748-96e1606f0be2.png)  

When warped you will find yourself at the first station of the network:  
![rail demo 4](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/7f64d495-5c83-4167-a7dd-22697183ea80.png)  

Trains are stopped when entering the first time, just open any "Station Controller" (refer to components):  
![rail demo 5](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/6c054e6a-a05e-4060-b496-8349e84d0d8a.png)  
Then go in the "Lines" tab and click "Start trains" and select both "Line A" and "Line B":
![rail demo 6](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/965a1fa3-82c9-47cc-a1d8-b5ecca80b0ab.png)  
![rail demo 7](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/fca2bee9-7e36-4243-aae9-1b0fb753b235.png)  
![rail demo 8](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/867b50a2-5308-46fe-bc05-8cda34d93f5b.png)  

Trains will be spawned according to a schedule that was made on my computer, so running times might be different because of system performance and lag.  
If you want you can make your own schedule based on the running time of your machine. To do so clear the testrun data first:  
Open the station controller for Line A (left one), select "Lines: and select "Test run"  
![rail demo 9](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/e608678f-90d8-4f5b-a927-5da49087ec22.png)  
Select "Clear Testrun Data":  
![rail demo 10](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/71c9a7b6-012e-4c73-b6a9-16d0983f9d8f.png)  
Start test runs for "Line A", the more test runs you make the more precise the readings will be but it will take more time, 10 test runs is best, more than that it's just overkill, 5 should be acceptable:
![rail demo 11](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/3fa10c3d-009a-4d3f-8231-01ae898131cb.png)
![rail demo 12](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/f2d04564-7dcb-4fda-ba28-13dec6dc9136.png)  

Repeat the steps above for "Line B" (open the station controller on the right)
You should run the testruns for both lines in parallel while the other line is running the tests.

As of now there is no way to know if test runs are over, checking from time to time the test run dialog if you see the test run data on the upper left then it's over, there's an upcoming feature planned to show live the test run data, status and position of the trains as they go in the GUI.

Using your own testrun data and the marey-chart webapp plan the schedule for your trains, refer to the manual of the web app [here](https://github.com/CondensedChaos/condensedchaos.github.io/tree/main)  
Particularly to the section [More lines in a graph](https://github.com/CondensedChaos/condensedchaos.github.io/tree/main#more-lines-in-a-graph)  
and [How to use](https://github.com/CondensedChaos/condensedchaos.github.io/tree/main#how-to-use)  
The layout of the lines in the rail demo world correspond to [Case 1a](https://github.com/CondensedChaos/condensedchaos.github.io/tree/main#case-1a)  
This is the diagram that shows the layout: 
![rail demo schema](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/raildemoschema.png)  

# Known Issues
Since the mod relies extensively on the function [world.time()](https://starbounder.org/Modding:Lua/Tables/World), the [/timewarp](https://starbounder.org/Commands#Admin_Commands) must not be used in planets where there are trains running.
A workaround could be to implement another command that should be used instead that will warp the time and notify all running trains on the planets that time has shifted but I haven't started to tackle this problem and I am not sure if it's a feasible solution yet.

# Admin commands to spawn items
/spawnitem trainConfigurator  
/spawnitem stationController  
/spawnitem stationController2  
/spawnitem customrailstop  
/spawnitem railchunkloader  

-=Catenaries=-  
/spawnitem catenaries1  
/spawnitem catenaries2  
/spawnitem catenary-wires  

-=45° Catenaries=-  
/spawnitem catenaries45deg1  
/spawnitem catenaries45deg2  
/spawnitem catenaries45deg3  
/spawnitem catenaries45deg4  
/spawnitem catenary-wires45  

# To-do
1) More colors for the trains
2) Password protection of Station Controllers for multiplayer servers.
3) Live view of trains running in each line in Station Controller's GUI
4) Live view of testruns in Station Controller's GUI
5) Error handlings for line naming/renaming and stations naming/renaming
6) Deleting a station from a line is not implemented yet
7) Renaming of lines button not implemented yet (it's present but does nothing)
8) Delete line button
9) Adding a dialog to change stop lenght and speed for all (or some) scheduled trains all at once
10) Train spawn error handling
11) The eventuality that trains are deleted after some time has to be taken into account and periodical checks to insure that all trains still exist in the world

# Modding
You can design your own train car to be used with this mod, just download the "traincar-modding-template.zip" from latest [Release](https://github.com/CondensedChaos/Starbound-Rail-Train/releases)  
Modify this template to your liking

First of all choose a name for your vehicle, rename all the files and folder that has the name "vehiclename" with the name of your choice, do not use spaces.  
1) list of folders to rename:
   - vehicles/vehiclename (rename it to vehicles/\<your_vehicle_name\>)
   - interface/linkedTrain/trainConfigurator/vehiclename (rename it to interface/linkedTrain/trainConfigurator/\<your_vehicle_name\>)
2) list of files to rename:
   - vehicles/vehiclename/vehiclename.vehicle (rename it to \<your_vehicle_name\>.vehicle  
   - vehicles/vehiclename/vehiclename.animation (rename it to \<your_vehicle_name\>.animation  

After that you'll have to change all the mentions of "vehiclename" to < your_vehicle_name > in all files:
1) in interface/linkedTrain/trainConfigurator/settings.json.patch at line 5
2) in objects/crafting/trainConfigurator/listOfCars.json.patch at line 4 and line 13
3) in vehicles/vehiclename/vehiclename.vehicle at line 2, line 11 (change it to: "animation" : "/vehicles/\<your_vehicle_name>/\<your_vehicle_name\>.animation"), line 16, 19, 22, 25, 28, 31, 34, 37, 40, 43, 46, 49, 52, 118

The folder interface/linkedTrain/trainConfigurator/vehiclename/ contains the preview for train configurator.  
Body is the bottom part of the vehicle, cockpit is the top part.  
[Pantograph](https://en.wikipedia.org/wiki/Pantograph_(transport)) is the apparatus that is mounted on the train's roof that is in contact with the overhead wires to get electricity.  
If you do not wish to create a new pantograph for your train you can use the provided asset, just be sure to change the width of the sprite to your train's sprite size.  

The folder vehicles/vehiclename/ contains the sprites that will be used in game and the definition of the vehicle's parameters-

Explaination of files:
Any vehicle for this mod can have up to 10 different decals, named from decal "A" to decal "J", the decal that follows will be placed above the decal that precedes, like layers.
- cockpitred.png : top part of the train, sprite relative to red color.  
- red.png : bottom part of the train (the part named "body") relative to the red color.
- decalB0.png : sprite nr 1 of the wheels
- decalB1.png : sprite nr 2 of the wheels
- decalA1.png : graffiti sprites (as an example)
- headlight.png : sprite of the headlights, it has 2 frames, frames at the left is the headlight when turned on, the other frame is the headlight turned off
- reverseheadlight.png : sprite of the headlight at the tail of the train, it has 2 frames, frames at the left is the headlight when turned on, the other frame is the headlight turned off
- taillight.png : sprite of the tail-light, it has 2 frames, frames at the left is the headlight when turned on, the other frame is the headlight turned off
- decalPlaceholder.png : and empty, transparent image that is placed by the mod when a decal is hidden, it has to be the same frame size as the other sprites (body, cockpit and decals)
- default.frames: defines frame size for cockpit, body and decals sprites
- *.frames files : defines frame size for all other sprites
- vehiclename.vehicle : JSON file that defines all the parameters for your vehicle, you should edit this file and follow the instruction in the comments (lines that start with //)
- vehiclename.animation : JSON file that defines the animation parameters for the sprites, you should edit this file and follow the instructions in the comments

Explaination of sprites (valid for cockpit, body, decals):
![-=animationsExplaination=-](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/2df726d2-f17f-4563-9281-e845975f1728.png)  

Explaination of pantograph sprite (frame width is equal to vehicle lenght, height is 34 pixels):
![-=pantograph=-](https://raw.githubusercontent.com/CondensedChaos/Starbound-Rail-Train/main/docs/media/b5dfffed-bf65-402c-a34f-ba3157f1f1a2.png)

Other files to edit:
- objects/crafting/trainConfigurator/listOfCars.json.patch : JSON file that stores paramenters regarding the train car like pixel size, numer of decals, colors and such.

The example provided in this template will generate a vehicle with just 1 color for body, 1 color for cockpit and 1 decal with 2 wheels kind.
If you want to add more colors and/or decals just modify the listOfCars.json.patch to your likings and add the required files to interface/linkedTrain/trainConfigurator/vehiclename and vehicles/vehiclename/

Naming format for colors:
- cockpit:
  - in interface/linkedTrain/trainConfigurator/vehiclename/cockpit = \<color name\>.png
  - in vehicles/vehiclename/ = cockpit\<color name\>.png
- body:
  - in interface/linkedTrain/trainConfigurator/vehiclename/body = \<color name\>.png
  - in vehicles/vehiclename/ = \<color name\>.png
- decals:
  - in interface/linkedTrain/trainConfigurator/vehiclename/ = make a folder named decal\<LETTER\> and then create the preview files named 1.png 2.png and so on
  - in vehicles/vehiclename/ = decal\<letter\>\<number\>.png

You can have 10 different decals for each train, named with letters from A to J.

Names are [case sensitive](https://en.wikipedia.org/wiki/Case_sensitivity)

---

# Credits

A huge thanks to Jay, the creator of Enhanced Rails, mod that inspired me on creating a dedicated mod for train networks.  

[Enhanced Rails](https://steamcommunity.com/sharedfiles/filedetails/?id=921924325) on Steam Workshop  
[Enhanced Rails](https://community.playstarbound.com/resources/enhanced-rails.4708/) on Chucklefish Forum  
[Steam workshop profile](https://steamcommunity.com/profiles/76561197994271611/myworkshopfiles/)  
[Chucklefish Forum profile](https://steamcommunity.com/profiles/76561197994271611)  

---
# License

<a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png" /></a><br /><span xmlns:dct="http://purl.org/dc/terms/" property="dct:title">Starbound Train System</span> by <a xmlns:cc="http://creativecommons.org/ns#" href="https://github.com/CondensedChaos/Starbound-Rail-Train/tree/main" property="cc:attributionName" rel="cc:attributionURL">[Condensed Chaos](https://github.com/CondensedChaos) ([Meteora](https://steamcommunity.com/profiles/76561198397117901/myworkshopfiles/?appid=211820) on [Steam Workshop](https://steamcommunity.com/app/211820/workshop/))</a> is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/">Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License</a>.
