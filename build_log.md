[2017.08.31]
* Started git repo.
* Completed "Still", "Idle", "Walk", "Jump", "Hurt", "Stunned" animations of Keshia Erasia.
* Separated Sirurueruerue & Sugsesugsem & Big Bro & Waitie Changie's body parts.
* Resized Sirurueruerue & Sugsesugsem & Big Bro & Waitie Changie's png files to make them smalller.

**Commit**

[2017.09.01]
* Fixed animation positioning bug.
* Completed the positioning of "Bro SS Sprites" scene.
* Separated body parts as png files of Ranawato Plato & Socklataaz Sockrateez & Wendy Vista.

[2017.09.04]
* Wrote scripts in `CharacterCommon.gd` to control movement animations (aka. jump, walk, idle, still).

[2017.09.05]
* Completed "Still", "Idle", "Walk", "Jump", "Hurt", "Stunned" animations for Sirurueruerue.
* Completed "Still", "Idle", "Walk", "Jump", "Hurt", "Stunned" animations for Sugsesugsem.

[2017.09.06]
* Completed "Still", "Walk", "Jump" animations for Big Bro.
* Completed "Still", "Idle", "Walk", "Jump", "Hurt", "Stunned" animations for Ranawato Plato.
* Completed "Still", "Idle", "Walk", "Jump", "Hurt", "Stunned" animations for Waitie Changie.

[2017.09.08]
* Completed "Still", "Idle", "Walk", "Jump", "Hurt", "Stunned" animations for Socklataaz Sockrateez.
* Completed "Still", "Idle", "Walk", "Jump", "Hurt", "Stunned" animations for Othox Codox.
* Completed "Still", "Idle", "Walk", "Jump", "Hurt", "Stunned" animations for Wendy Vista.

**Commit**

[2017.09.11]
* Completed "Basic Attack", "Basic Skill", "Basic Skill Landing" animations for Keshia Erasia.
* Refactored some status variables such as `can_move`, so that they could be more flexible with timers.
* Start implementing Keshia Erasia's basic attack and basic skill.

[2017.09.12]
* Completed the basic attack of Keshia Erasia.
* Implemented abnormal status: stun.

[2017.09.13]
* Completed the basic skill of Keshia Erasia.
* Deleted unneeded `.tres` animation files.

[2017.09.15]
* Completed "Horizontal Skill" animations for Keshia Erasia.
* Completed `StraightLineMovement.gd` for linear movement.
* Completed the horizontal skill of Keshia Erasia.
* Completed `PencilDart.gd` and its scene for horizontal skill of Keshia Erasia.

**Commit**

[2017.09.18]
* Completed "Up Skill", "Down Skill" and "Down Skill Resume" animations for Keshia Erasia.
* Completed the up skill of Keshia Erasia. Phew.

[2017.09.19]
* Completed the down skill of Keshia Erasia.
* Fix a bug in the basic skill.

[2017.09.20]
* Redesign the structure of character scenes (now the animation part isn't saved in a separate scene).
* Change layer names in Globals for the sake of consistency.
* Add more layers to Globals such as Enemy Layer, Friendly Fire Layer, Enemy Fire Layer, etc.
* Figured out the collision mechanics between Enemy, Character, Enemy Fire, Friendly Fire.
* Finished implementing the actual damge code for Keshia's basic attack.
* Created a dummy target enemy for debugging and testing.

[2017.09.21]
* Fix a bug that Keshia's basic attack would hit multiple targets.
* Implemented the hit box & target hit of Keshia's basic skill, horizontal skill, up skill.

[2017.09.22]
* Apply a snap grid of 50px times 50px.
* Rework some graphics so that they are 50px multiple in sizes.
* Level design research.

**Commit**

[2017.09.23]
* Reorganize the file structures of Graphics directory.
* Completed "Attack", "Still", "Searching", "Hurt", "Stunned", "Walk" animations of CD Punch.
* Completed "Still" animation of Dark Earspider.

[2017.09.27]
* Completed "Swing", "Hurt", "Die", "Clap", "Spin Silk", "Stunned" animations of Dark Earspider.
* Completed "Die" animation of CD Punch.
* Completed "Still", "Die", "Count Down", "Explode" animations of Red Earspider.
* Completed graphics of Mouse.

[2017.09.28]
* Completed "Die", "Hurt", "Spawn Mousy", "Stunned", "Walk", "Still" animations of Mouse.
* Completed Mousy Bomb graphics.

[2017.09.29]
* Completed graphics of Amazlet, Paranoid Android, Harddies, Calcasio, Sonmera.

**Commit**

[2017.10.02]
* I played TOO MUCH Overwatch these weeks, so I don't have much time to work on my projects, BAD!
* Completed graphics of Canmera, Batterio, Sockute, Laserphone, Radiogugu.

[2017.10.03]
* Completed graphics of Eelo Puncher, Eelo Kicker, Latortrans, ASCII Bomber, ASCII Gunner.

[2017.10.05]
* Completed graphics of Cliffy, Flaggomine, iSnail, Windy Meteory, Chromoghast, Clockword Fox.

[2017.10.06]
* Completed graphics of Godotbos, Eyemac, Floopy, Plugobra.

**Commit**

[2017.10.09]
* Assembled graphics of Amazlet, Paranoid Android, Harddies, Calcasio, Sonmera, Canmera, Batterio, Sockute, Laserphone, Radiogugu, Eelo Puncher, Eelo Kicker, Latortrans, ASCII Gunner, ASCII Bomber, Cliffy, Flaggomine, Windy Meteory, Chromoghast, Clockwork Fox, iSnail, Godotbos to scenes.

[2017.10.10]
* Assembled graphics of Floopy, Plugobra, eyeMac to scenes.

[2017.10.11]
* Completed animations of Paranoid Android, ASCII Bomber, ASCII Gunner, Batterio, Calcasio.

[2017.10.12]
* Completed animations of Canmera, Chromoghast, Cliffy.

[2017.10.13]
* Completed animations of Clockwork Fox, Eelo Puncher, Eelo Kicker, Flaggomine, Floopy.

**Commit**

[2017.10.16]
* Completed animations of Harddies, Laserphone, Plugobra, Sockute, Sonmera, Windy Meteory, iSnail.

[2017.10.17]
* Completed animations of Amazlet, Radiogugu.

[2017.10.20]
* Completed animations of Latortrans, eyeMac, Godotbos.
Milestone: Finally completed all animations of the enemies of Computer Room.

**Commit**

[2017.10.24]
* Played a lot of HotS and Overwatch today without working on my game, feeling guilty now. :P
* Well, at least I did some research on "enemy distance check" and "Placeholder Scenes in Godot". Also scheduled the next sprint.

[2017.10.25]
* Fixed the bug that "Idle" animation would be played when moving in a same direction too long.
* Deleted unneeded variables and `if` conditions in `FollowingCamera.gd`.
* Implemented `func clamp_pos_within_cam_bounds(pos)` so that no boundary colliders are needed in the following camera. More elegant, yeah!
* Delcared some essentail variables in `LevelPartCommon.gd`.
* Implemented `CharacterAveragePosition.gd`. Now the following camera is controlled by the average positions of each character. This makes multiplayer mode easier to implement.

[2017.10.26]
* Implemented the triggering event when the player enters the level part so that previous level part will be destroyed, the next level part will be instanced, and the camera controlling scheme will be updated.

[2017.10.27]
* Implemented `ActivateDetection.gd` and `NearestTargetDetection.gd`.
* Trying to figure out how to implement each enemy and how to reduce repeat code in each enemy script.

**Commit**