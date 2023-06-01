Starbound Rail Train system
===========================

# Overview
This mod add a train system to be used with Startbound's rail tram system.
It provides a framework that includes train crafting, personalization of trains, creation of lines and scheduling of trains.
Any user with some experience in modding can add additional train cars to be used with this mod (Refer to modding)

There are two operating modes, free and scheduled.

## Free Mode
In free mode the trains are crafted using the **"Trainset Configurator"** (crafted at Rail Crafting Table) and just placed on the rails.

Once the train is placed it will continue to go over the rails and stops at stations, you can either make a circular rail line around the planet or use rail bumbers to revert its direction so it goes back and forth.

To create stops you need to use the custom rail markers (called **"Rail station marker"**, craftable at the Rail Crafting Table) supplied with the mod (**_do not use conventional vanilla tram stops_**).

Since the game loads the world in *"chunks"* that are approximately 20x20 blocks, you will need special items to place on the rail every 19 tiles that will keep that tract of world loaded (similar to Minecraft "Chunks Loaders")

There are two variants of chunk loaders, they're only different in appearance but they serve the same functions: **"catenaries"** and **"rail chunk loaders"**

## Scheduled mode
In scheduled mode special items that controls the rail stops are used in conjuction with **Rail station markers**, those are the **"Station controllers"** craftable at the Rail crafting table.
Those are used to define a train line and wired to a rail station marker. Each station has to have its Station Controlled.

Stations should be placed from west to east.
After all the stations controllers are placed and wired to its rail station marker a train line has to be defined using the station controller user interface (just interact with the first station) a line has to be created and all the other stations of the line added.

A test run has to be made to measure the travel time for each section of the line.
With the data from the test run you should then use the provided web app (more of this later) to plan the trains schedule.

Then go back to the station controller to create the schedule using the data from the web app, you can choose how many trains to have for each direction, choose their speed for each tract and stop times for each station, and when the trains should start.

Then you'll have to craft a train at the **Trainset Configurator** for each tran you schedule, and import the items in the Train Configurator (more in depth usage for Scheduled mode here)

Catenaries and/or Chunk Loaders has to be used too in scheduled mode.
---
# Installation
..........................................................................

..........................................................................

---
# Reccomended mods
..........................................................................

..........................................................................

---
# Usage
..........................................................................

..........................................................................

## Tram network preparation

![size1](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/42efff3b-a6a2-482d-99aa-d56f8b037fdd)

![size2](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/f077ae2e-ef5e-45c3-920b-1bd02f8deb7b)

![size3](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/b8263d55-0b54-4b9e-a2b2-0c9ff8f110e6)

![catenaries1](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/e199536e-e385-4fbc-8ebd-463c44d864a6)

![catenaries2](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/4161c4a7-4be1-4ea8-879f-0b6eeccc390f)

![catenaries3](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/2aee9d66-de4e-4166-a183-90f30aa22051)

![catenaries4](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/18e21977-fa29-4d84-ad94-c1e4ef0f96bb)

![catenaries5](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/598ec510-1645-4fcd-b6e4-495e6114c4b6)

![catenaries6](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/0db2c829-911b-4f28-b5d6-bbc77a54f343)

![catenaries7](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/8bbddd29-f203-45cc-aaf8-833181d9c75a)

![catenaries7a](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/16aa7cb9-76f5-4ba4-b84a-27bdcd3fbcea)

![catenaries7b](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/2d59480f-f237-45d8-8da4-820263e48a6d)

![catenaries7c](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/2a270538-c2b1-4932-aae2-812cdaae1274)

![catenaries7d](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/46987784-895f-4830-9c51-d63caee12fb7)

![catenaries8](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/40ed3124-ac8c-4bd2-a0f1-ebf3f310ca85)

![catenaries9](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/c52c7899-d5b0-4774-a816-193d86ce6bea)

![stationmarker1](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/42809523-4da6-46e4-a657-ab4208f94a25)

![railstationmarker craft](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/aff5d72e-b504-406a-9feb-3db1dbd540e7)

![station marker2](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/e592b3ed-d081-4028-8cd9-0dc02735006f)

![station marker3](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/a585ba44-b478-4eb6-96ba-0d622cb1f572)

![station marker3a](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/e79e89e4-5515-41da-afc6-312aa54be9d2)

---
## Components
..........................................................................

..........................................................................

### Trainset Configurator
![trainconfigurator](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/22002a29-4499-46e7-9930-516bd98dbef5)

![train configurator1](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/be8ed6f4-af5f-4307-9a90-d912de0555a4)

![trainconfigurator2](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/a7f00cb9-3d45-42a4-bcd7-312ed1f9d580)

![train configurator2](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/2a5b0c99-69f2-4959-b604-62a647cd8bcd)

![train configurator3](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/9503fecd-7707-437c-b710-ab3d443df47f)

![train configurator4](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/00a4205f-d62b-443b-b1d1-e6327436a7b8)

![train configurator5](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/c3a4c92c-8921-4261-bb66-750dc985fc7e)

![train configurator6](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/9f57baa4-b9df-4cc5-9cf4-3d0de4bfccef)

![trainset configurator craft](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/6aaca641-38a7-4d1e-a7e2-45eb1631c96f)


### Catenaries/Chunk loaders
![catenary](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/0565a745-601c-4993-8b67-e6cfde30afaa)

![catenary1](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/e86de415-b396-49e5-89ca-e243a0949da9)
![catenary2](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/164c06c5-0704-465e-95a8-51f76031c954)
![catenary3](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/a990e637-37ed-4550-b055-367d6235a13f)

![catenary-wires](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/ddb76dcc-50f9-4e9e-993f-f0c14202fce1)

![catenary-wires2](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/c863709b-a063-452f-a2f7-586fcaffc36e)

![catenary craft](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/0e84c00e-c1dc-41ef-a914-692eb8512c72)

![rail chunk loader craft](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/1d17a7b0-28f0-4c62-b1d5-0038e8b478a6)

![wires-craft](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/cbc388c4-88cb-4ddb-aad8-d5f214d8ad72)

#### 45°degrees Catenaries
![catenary45](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/076150ba-3c37-4cf4-bbc7-5d2bc6d3268b)

![catenary45-1](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/261c2f8c-4bde-4b3d-8023-a8b879d15e44)
![catenary45-2](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/97e56038-18d7-4016-836f-861c24b02aaf)
![catenary45-3](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/f7f18c07-2c15-4b16-b2b2-6a94bf0b143b)
![catenary45-4](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/965b89b7-133c-41f2-ba7a-1332950597ef)
![catenary45-5](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/f3afb494-2fa4-4e43-ace1-9d0002178fea)

![catenary-wires45](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/0fcd12d2-9a20-47f5-80a4-f121f5acc430)

![catenary-wires45-2](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/0baa7437-5b66-4b50-aaf7-4afe27f0429d)

![girderext](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/31591d13-bf29-4bc9-8ed5-85f0f18a33a6)

![girderext-1](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/43c6d2b9-b747-41a7-8e4a-be28e9716fe2)

### Station Controller
![station-controller1](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/efb8104c-8039-48b3-a74a-e32453341d34)

![station-controller1-2](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/c4725aca-7390-4ea9-8716-530a39758651)


### Train scheduling web-app
..........................................................................

..........................................................................

---
## Free Mode
..........................................................................

..........................................................................

### Prepare your network
..........................................................................

..........................................................................

### Place Rail Station Markers
..........................................................................

..........................................................................

### Place Chunk Loaders/Catenaries
..........................................................................

..........................................................................

### Place the rails


### Craft trains
..........................................................................

..........................................................................

### Place trains
..........................................................................

..........................................................................

---
## Scheduled mode
..........................................................................

..........................................................................

### Prepare your network
..........................................................................

..........................................................................

### Place Rail Station Markers
![stationmarker1](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/42809523-4da6-46e4-a657-ab4208f94a25)

![railstationmarker craft](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/aff5d72e-b504-406a-9feb-3db1dbd540e7)

![station marker2](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/e592b3ed-d081-4028-8cd9-0dc02735006f)

![station marker3](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/a585ba44-b478-4eb6-96ba-0d622cb1f572)

![station marker3a](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/e79e89e4-5515-41da-afc6-312aa54be9d2)


### Place Station Controllers 
And wire them to Rail Station Markers

![station controller craft](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/12554c65-a599-499a-9208-2e80d1d5b538)

![station marker 4](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/ca685ffa-c7a1-4195-8fd3-5e6cba19c9d8)

![station marker 5](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/c0e239b7-8445-4449-aee7-ec69d18e1300)

![station marker 6](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/e452b780-a7c4-42c5-a5fc-6a3d591bdd9e)

![station marker 7](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/f9a0abbf-e1fa-45a8-b6a2-8e21bae34d37)

![station marker 8](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/9d9db061-bab5-4694-8724-0cf7c205bde6)

![station marker 9](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/b813102e-8ba4-47eb-9ebb-a8086280d532)

#### Name your stations
![line creation1](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/5d397e57-3b07-447a-90ef-8f042124fe0d)

![line creation2](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/4055304b-5f13-4027-96fd-ef9b22813bcc)


### Place Chunk Loaders/Catenaries
..........................................................................

..........................................................................

### Place the rails

### Create a Line

![line creation3](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/30fa0857-0674-45a4-9432-3c63516d3402)

![line creation4](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/891cf0b0-95cd-4642-9979-6d5f14ff4dc0)

![line creation5](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/0ced7315-3f90-4f2f-a992-b3a5745be4ad)

![line creation6](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/057f2be1-91d0-448d-b489-e4f93cf3b8e4)

![line creation7](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/4807e3d4-1740-4270-a39b-80430bab4804)

![line creation8](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/c9e0f280-9a6e-4e4d-ae67-b2c5082602d3)

Circular/non circular

#### Add Stations

![line creation9](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/91d0b7fc-602e-4663-ae27-7d441c70b9a1)

![linecreation10](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/5794114c-0576-49a6-a0da-6264bbdcd21e)

![line creation11](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/e36ec300-5825-4a6e-8d16-8d6453d1ac31)

![line creation12](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/bfcb931d-9092-4c70-a581-708f192e8c59)
---
![line creation13](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/4b545a5e-3dd4-43fb-8274-0d45400f73ca)

![line creation14](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/aa2ecef2-436a-4552-87c5-ca48201b246a)

![line creation15](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/865da791-9aa4-4e35-a932-59fc598d69e4)


### Do test runs
![line creation 16](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/60190db1-ae44-4da2-968d-8260575eec01)

![line creation17](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/f2fd65f0-b1b1-455a-a4b1-d70b97edc4e2)

![line creation18](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/fa5ccb43-c30d-4604-8dc6-d5f68833730f)

![line creation19](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/55f471e5-6f91-45cc-8ac9-f9028007320b)

### Make schedules with web-app
..........................................................................

### Craft Trains
..........................................................................

### Create the schedule in-game
![00](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/b6ff8dee-ac1f-49d7-947d-ef3fd387def4)

![01](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/1e881b54-4a19-4c94-8571-da60fbea1286)

![02](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/cd116b64-5573-463a-98a4-f99fd3619f49)

![03](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/120935ab-ba21-42b3-a245-887db316a37e)

![04](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/f2fd00ab-000e-43b4-abb0-a62e517656c1)

![05](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/8c3881ad-8303-4d07-bfc6-c4cfdebfffb9)


#### Add train items in Station Controller

![06](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/cdd84aa3-6b44-42f4-b5ce-63dab4ae339c)

![07](https://github.com/CondensedChaos/Starbound-Rail-Train/assets/121590835/bc50e1b7-1ffa-485c-af39-ca853e61ec91)


### Start trains
..........................................................................

..........................................................................

---

# Scheduled mode with two or more lines

---
# Trains schedule Web-App
..........................................................................

..........................................................................

---
# Modding
..........................................................................

..........................................................................

..........................................................................

---
# License
..........................................................................

..........................................................................

..........................................................................
