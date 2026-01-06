# -- STGFrame --



\[this readme \& documentation is currently unfinished.]



STGFrame is an open-source framework to develop touhou-style shmup games in Godot. This project is currently maintained on Godot 4.5.



To use this project, either:
A) Clone the repository to your Godot Projects folder and scan that folder from the Projects List window.

B) Download the ZIP of this repository, then select "Import" from the Projects List window and select the downloaded ZIP.



The project so far is represented in the "main.tscn" scene, which is also the default scene to open when running the game.

main.tscn consists of a player in a scene with a UI border. There are several patterns the player can view by opening main.tscn and editing main.gd; simply change the function in \_ready() to whichever pattern you wish to view.



This project does not aim to provide all the amenities of a shmup, such as High Score or Replays; the primary focus of this project is to provide a stable framework to make bullet hell patterns. All other features can be added to taste by the developer who uses this project as a template.



### Autoloads:



**Danmaku.gd**

Streamlines the process of creating bullets \& various patterns. Also includes some miscellaneous functions related to bullets.

\[note: lasers will be supported later]



**Gametray.gd**

Node under which all in-game nodes are parented to. Also currently contains a basic "pause" function (esc to pause/unpause).



**Tool.gd**

Miscellaneous but useful functions used regularly in various situations. Also contains a reference to the Player and Boss.



#### 
