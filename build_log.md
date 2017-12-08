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

[2017.10.30]
* Implemented `HorizontalMovementWithGravity.gd`.
* Completed CDPunch's movement.

[2017.10.31]
* Completed CDPunch's animation & attack pattern.
* Implemented `HealthSystem.gd` for enemies' health management.
* Implemented `MultiTickTimer.gd` for damge over time.

[2017.11.01]
* Tested and fixed bugs in `HealthSystem.gd` and `MultiTickTimer.gd`.
* Healing, damage taking, and dying system is completed for CDPunch.

[2017.11.02]
* Completed scripting CDPunch's damaged, stunned, die animations.
* Replaced the health system of `CharacterCommon.gd` with `HealthSystem.gd`.

[2017.11.03]
* Staggered CDPunch's turn so that they won't all turn at the same time.
* Shorten CDPunch's Searching animation length.
* Scripted hurt animation in `CharacterCommon.gd`.
* Make Pencil Dart of Keshia Erasia affected by gravity.
* Made Mob Health Bar graphics, scene, scripts.

**Commit**

[2017.11.06]
* Completed `MobHealthBar.gd` and integration with CDPunch.
* Reposition CDPunch's sprites and animations so that it turns correctly.
* Refactored CDPunch's script using principles of Clean Code. Well, probably.
* Change Keshia Erasia's hurt animation to modulating (blink red) only. Otherwise, it looked extremely awkward to switch between Hurt and Basic Skill animations.
* Drew digits 0 to 9 for damage indicator.
Murmur: I spent so much time scripting a single mob (CDPunch), and it contains 200+ lines of code. How will I ever complete the game. *sigh*

[2017.11.07]
* Implemented `NumberIndicator.gd` and integrate it with CDPunch and `CharacterCommon.gd`.
* Shrinked Keshia Erasia's Up Skill's hit box so that it won't hit enemies below Keshia's head.
* Fixed a bug that CDPunch won't recover from its hurt animation. I don't know how I solved this though...It just works now.
* Drew "Stunned" text and integrate it with `NumberIndicator.gd`.

[2017.11.09]
* Implemented `EnemyCommon.gd` to take out some common code for damage, stun, animation, health and health bar from CDPunch.
* Merged `AnimatorPlayer.gd`, `ActivateDetection.gd` into `EnemyCommon.gd`.
Comment: **I AM A CODE REFACTORING KING!!!**

[2017.11.10]
* Started to implement `DarkEarspider.gd`. The code is now full with bugs. Will clean them up next week.

**Commit**

[2017.11.13]
* Included `damaged_over_time(...)` in `EnemyCommon.gd`.
* Implemented `RandomMovement.gd` to generate a sequence of random movement for mobs (or other nodes).
* Completed scripting DarkEarspider.

[2017.11.14]
* Added `additional_movement_x` variable for `CharacterCommon.gd` to perform horizontal movement skills or being knocked back.
* Completed `knocked_back(...)` in `CharacterCommon.gd`. Tested, it worked.

[2017.11.15]
* I don't know why, but apparently I have to add `int(number)` in a `%` operation even if number is already an integer...hmm, weird.
* Completed scripting RedEarspider.
* Refactored `CDPunch.gd` into a clean state machine.

[2017.11.16]
* Refactored `CDPunch.gd` and `DarkEarspider.gd` by taking out repeated code and put it in `EnemyCommon.gd`.
* Removed `HorizontalMovementWithGravity.gd` and added `GravityMovement.gd`. Use `GravityMovement.gd` with `StraightLineMovement.gd` to attain the same effect with `HorionztalMovementWithGravity.gd`. Fixed `CDPunch.gd`, `RedEarspider.gd` and `PencilDart.gd` to adept this change.

[2017.11.17]
* Implemented `NumberSpawnPos.gd`, making the spawning position y of the numbers different.
* Keshia's Basic Attack's hitbox is now turned off correctly after an empty swing.

[2017.11.18]
* Use modulate in scripting instead of animation player to control characters' hurt animation so that characters' current animation won't be stopped.
* CDPunch now knocks back characters...it feels so good!
* Cleaned some code in `KeshiaErasiaSkills.gd`.
* Fixed a nasty bug related with physics frame & scripting frame...probably (idk the real reason causing this bug). Now Keshia's Basic Attack won't hit the enemy when its mask is set to 0. (That is, I put all the collision masking changes into the AnimationPlayer).
* Fixed a bug that DarkEarspider would drop infinitely if the attack target is above him.
* Completed scripting Mouse and Mousy Bomb.
Comment: Wow, what an effective day.

**Commit**

[2017.11.20]
* Scripted Amazlet, Paranoid Android, Amazlet Frizbee.
* Added `is_landed()` to `GravityMovement.gd`.
* Modified `MousyBomb.gd` so that it would be freed after a centain time if it didn't hit a character.

[2017.11.22]
* Added `healed(val)` and `healed_over_time(...)` in every mob, since they might be healed somehow.
* Number Indicator can now show "Immune" text for stun or damage immune.
* Added `InitRandom.gd` so that the random number generator is only randomized once.

[2017.11.23]
* Completed scripting Harddies and Harddies Ring.

[2017.11.24]
* Scripted some Calcasio behaviors.

[2017.11.25]
* Fixed a bug that mobs aren't `queue_free`ed as expected. (So hard to find the bug...it appears that there are some sequentially wrong design between *die* and *damaged*)
* Separated gravity movement from horizontal movement from CDPunch and Mouse so that they won't be stun locked in the middle of the air.
* Completed scripting Calcasio and Calcasio Bullet. Cool.

**Commit**

[2017.11.29]
* Completed scripting Sonmera (except its screenshot perk).
* Completed scripting Canmera and Canmera Missle.

[2017.12.01]
* Completed scripting Batterio.
* Completed Sockute and Sockute Lightning Ball.

[2017.12.02]
* Completed scripting Laserphone.

**Commit**

[2017.12.04]
* Painful and depressed. Can't work (nor live) efficiently.
* Completed scripting Floopy.
* Added RNG Initializer to the game level so that random behaviors are truly (pseudo) random.
* Now "Immune" text will be shown if the character takes damage or stun hit when invincible.

[2017.12.05]
* Umm...declared some constants of Radiogugu.
* Just trying to list something here to make it look like I've done something while I actually haven't.

[2017.12.06]
* Completed scripting Radiogugu Floopy Spawn Pos.
* Implemented `speed_changed()` in `CharacterCommon.gd` for slow and speed effect.
* Refactored `SpeedPotion.gd` to fit the new speed change code of characters.
* Completed scripting `RadioguguWatch.gd` but haven't tested yet.

[2017.12.08]
* Completed scripting Radiogugu. Phew.
Comment: Have a feeling that I will never finish this game. It's toooo time consuming.

Sprint: Explode animation scene. Abnormal status indicator. (Probably should be combined with Number Indicator.)