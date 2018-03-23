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

**Commit**

[2017.12.10]
* Completed scripting Eelo Puncher.
* Completed scripting Healing Fountain. (Need to add the sprites for it though.)

[2017.12.12]
* Completed scripting Eelo Kicker.

[2017.12.13]
* Adjusted Eelo Kicker's kicking animation.
* Fixed Healing Fountain's bug. Completed Healing Fountain's animation.
* Completed scripting Latortrans and its Balls.
* Added `confused(duration)` function to `CharacterCommon.gd`.
* Bug fix: Now the character would correctly tranfer from "Idle" animation to "Walk" animation.
Comment: Changed my daily time table. Seems like it works since I completed tons of stuff today.

[2017.12.15]
* Completed scripting ASCII Gunner.

[2017.12.17]
* Completed scripting ASCII Bomber.
* Adjusted ASCII Gunner shootings' Z layer so that it appears in the front of characters.

**Commit**

[2017.12.18]
* Added `BouncyMovement.gd`.
* Completed scripting Cliffy.

[2017.12.21]
* Completed scripting Flaggomine.
* Completed scripting Windy Meteory.

[2017.12.22]
* Completed scripting Chromoghast.
* Moved all `set_global_pos()` calls after `add_child()` to avoid positioning bugs.

[2017.12.23]
* Completed scripting Clockwork Fox.
* Completed scripting iSnail.
* Reassign all z-layer of enemy scenes. (Generally, Enemy->0, Enemy Bullet->1, Enemy Bullet Hit Effect->2).

**Commit**

[2017.12.25]
* Completed scripting Plugobra.

[2017.12.26]
* Scripting Godotbos. Not finished nor tested yet.

[2017.12.27]
* Completed scripting Godotbos.
* Fixed an intricate bug that freezes enemies in "Hurt" animation when two consecutive attacks hit.

[2017.12.28]
* Organized and remake some Eye Mac's animations.
* Scripting Eye Mac. Not finished nor teseted yet.

[2017.12.29]
* Completed scripting Eye Mac.
* Changed the duration of number indicators from 1.0 sec to 0.25 sec.
Milestone: Completed scripting all enemies in Computer Room.

[2017.12.30]
* Completed changing Keshia's basic attack. (Fully interruptable, attack twice)

**Commit**

[2018.01.02]
* Completed graphics of speed, defensive, hyper, giant/dwarf potion.
* Completed status icons of speeded, defensive, hyper, slowed, confused.

[2018.01.03]
* Refactored code for Power Ups.
* Applied graphics to Power Ups.
* Added `damage_boosted(...)`, `damage_bossted(...)`, etc. status changing functions.
* Completed characters' status icons.

[2018.01.04]
* Refactored enemy movements. (Keep the redundant code in `EnemyCommon.gd`). Rewrite every enemy related with movements.
* Rewrite the speed changing system of `CharacterCommon.gd` so that speeding overlapping is handled correctly.
* Make the status icons pop when appearing.

[2018.01.05]
* Completed implementing enemy knock back and slowed icon.
* Removed all `damaged_over_time(...)` and `healed_over_time(...)`.
* Implemented `ChangeHealthOverTime.gd` and `FireParticle.gd` in place of `damaged_over_time(...)`.

**Commit**

[2018.01.07]
* Completed fire particles.
* Removed `FireParticle.gd`, use `ChangeHealthOverTime.gd` for all circumstances instead.

[2018.01.08]
* Completed boss health bar.
* Integrated attack boost to Keshia's skills.

[2018.01.09]
* Computer Room design outline from 1-1 to 1-18.
* Completed designing character health bar HUD.
* Made Keshia's dart size according to shrink/giant potion.

[2018.01.10]
* Completed character health bar.
* Reduce/Increase the knock back rate of character and character's attacks after shink/giant potion consumed.
* Bug Fix: Disable all attack colliders of Keshia Erasia if the attack ended. (So the colliders will be off when stunned)
* Computer Room design outline from 1-19 to 1-23.

[2018.01.11]
* Completed outlining the design of Computer Room.
* Show "Immune" instead of "0" when inflicting 0 damage.

**Commit**

[2018.01.15]
* Health potion now won't be consumed if the character is in full health.
* Added a red frame in editor for the following camera.
* Figured out how to control (lock & unlock) the following camera.
* Layout the platforms of 1-1 and 1-2-1.

[2018.01.17]
* Completed graphics: Character Healing Machine, Ult Ball, Mysterious Box.
* Change Sockute lightning ball and Batterio laser to red.

[2018.01.18]
* Completed healing machine.
* Fixed a bug of Sockute that its ball may be null when setting it to start travel.
* Completed mysterious box.
* Completed Ult Stone.

[2018.01.19]
* Completed "Ult Theme" of health bar and blue eyes of Keshia Erasia.
* Completed the grabbing hand of the "drop off screen" mechanic.
* Align the camera vertically to the lowest character instead of the average position to avoid the upper character bring the lower character to its death.

[2018.01.20]
* Completed dropping hand.
* Added a semaphore lock for camera update so the camera could be locked when a character is performing the "drop off screen" sequence.
* Added `cancel_invincible_skills()` to skill implementation so no matter which skill is used, health will be deducted when dropping off screen. Also, when dropping, the charater will resume movement animation.
* Change the animation of Ult Ball (remove spinner after levitating.)

**Commit**

[2018.01.23]
* Adjusted the speed of Ult Ball's spinner.
* Adjusted some of the level layouts.

[2018.01.24]
* Fixed the bug of Keshia's horizontal skill that the pencil will stuck to the wall if Keshia is standing backside near the wall.
* Completed `CounterSignalEmitter.gd` to connect enemy elimination and camera control.
* Fixed the bug in `EnemyCommon.gd` that shrinks the x scale to 0 when passing 0 to `turn_sprites_x(facing)`.
* Make enemies not flipping furiously around x scale when hitting the wall.
* Completed level design: 1-2-1 to 1-2-3.

[2018.01.25]
* Make damage done and damage taken of the characters fluctuate in a random range.
* Decide the numeric values of Keshia Erasia's Skills.
* Reworked Keshia's down skill (immune cc & defense boost instead of invinciblilty).
* Completed Keshia's Ult animation.

[2018.01.26]
* Completed Keshia's Ult Skill.

[2018.01.28]
* Completed `RepeatingSpawner.gd` for repeated mob spawning. Not tested yet.

**Commit**

[2018.01.29]  
* Refactored camera update & level part instancing/removing mechanism. (Use `PassingTrigger.gd` instead of `LevelEntryPoint.gd`).
* Keshia's Basic Skill no longer grants invicibility while landing.
* Design level part 1-3.

[2018.01.30]
* Decreased the hit box length of Keshia's basic attack. (Avoid hitting backside).
* Completed level part 1-3.

[2018.01.31]
* Shrinked Keshia's size by 20%. (Scale 1 -> Scale 0.8)

[2018.02.01]
* Now enemies will be knocked up as expected.
* Added "Player Only Platform" as layer 512. (Put fallen-Harddies into this layer)
* Implemented tower (obstacle). Not tested yet.

[2018.02.02]
* Redesigned `PassingTrigger.gd` so that it can handle both "Lesser" and "Greater" position triggers.
* Tested and fixed bugs of Tower.
* Adjusted numeric values of power ups.
* Design level part 1-4.

[2018.02.03]
* Added "fade in" effect and "spawning particles" to Repeating Spawner.
* Fix a bug of CDPunch that it failed to search an attack target when being attacked immediately after activated.
* Determine the numeric value of Floopy.
* Floopy will now have randomized color upon instancing.
* Make Keshia's dart fall faster (to decrease it's range).
* Completed level part 1-4.
* Design level part 1-5-1, 1-5-2. Not tested yet.

[2018.02.04]
* Holy, I screwed up! I accidentally converted the project to 3.0, not knowing that many things broke. Should've added a branch. damn.

**Commit** [Godot 3.0]

* Ported fonts to Godot 3.0.
* Wrote a python script to process `.tscn` files to fix the rotation values of animations. Processed all `.tscn` files.
* Reset project settings for Godot 3.0.
* Redesigned physics layers and reassign the layers/masks of existing physic bodies.
* Redesigned render layers and reassign the layers/masks.
Comment: Seems that it's not that hard to migrate to Godot 3.0. Worth it!

**Commit**

[2018.02.07]
* Reset particle systems for Godot 3.0.
* Changed the `movement(...)` function of all movement types. It returns the relative movement vector instead of the absolute position now.
* Completed updating scripts in Algorithms, Character Skills, Constants, Effects folders for Godot 3.0.

[2018.02.08]
* Change `ACTIVATE_RANGE`s of enemies to `activate_range_x` and `activate_range_y`.
* Updated scripts in `Enemies/Common` and `Enemies/Computer Room/Amazlet.gd to Batterio.gd` for Godot 3.0.
* Added `in_range_of(...)` to `CharacterAveragePosition.gd` so that range detection can be more convenient.
Comment: Having a surgery the day after tomorrow. Good luck, me!

**Commit**

[2018.02.20]
Comment: I'm back.
* Changed `GravityMovement.gd` and `BouncyMovement.gd`'s `movement(delta)` to `move(delta)`, which directly moves the physics body. (to suit Godot 3.0's physics body api).
* Updated all the scripts to Godot 3.0 except `MovementCollisionHandler.gd` and `CharacterCommon.gd`.

[2018.02.21]
* Deleted `MovementCollisionHandler.gd`. Changed `CharacterCommon.gd` into Kinematic Body 2D, use `move_and_slide` for movement.
* Renamed `Character-.gd` to `Hero-.gd`.
* Renamed groups from `player_collider` to `hero`, `enemy_collider` to `enemy`.
* Used Tween to fade out Keshia's dart. The dart will now slide a bit when landed on the ground.

**Commit**

[2018.02.22]
* Completed drawing wooden tileset.

[2018.02.24]
* Trying to make Background Wall tilesets, but it's a total failure.

[2018.02.25]
* Added more wooden floor tilesets and finally completed making its autotile.

**Commit**

Comment: Spent a lot of time doing nothing for the past couple of weeks.

[2018.03.05]
* Fixed the bug of hurt animation due to the Animation Key changes in Godot 3.0.
* Fixed the bug of Number Indicator's color modulating.
* Laid out the original design of level 1 (1-3 ~ 1-5-2).
* Smooth the corners of Wooden Platform Tiles.
* Tuned some knock back values. (Seems like the physics engine in Godot 3.0 is a little different. Probably.)
* Changed a little for the graphics of status icons for Hero so that it looks crisper.

[2018.03.06]
* Laid out the Passing Triggers and Count Triggers of level 1.
* Relabeled the tags of parts of level 1 in Google Form.

[2018.03.07]
* Finally completed laying out the Triggers for (1-1).
* Passing Triggers' "Lesser Y" condition now will only be triggered when the character with the greatest Y becoming lower than its y value.
* Fixed some animation bugs.
Comment: Aside for weekly commits, now all big milestones should be committed upon achieving.

**Commit**

[2018.03.08]
* Completed White Wall tilesets.
* Added black outlines for Keshia and yellow lining for UI Scrap Paper so that they are more visible in white backgrounds.
* Edited 6 images of wall decorations. Phew, so tired.

[2018.03.09]
* Edited images: 7 wall deocrations, 2 wood planks, 3 tapes, 16 wood stains, 12 wood holes, 11 woode cracks, 5 switches/plugs, 2 wires.

**Commit**

[2018.03.12]
* Edited images: 1 plug, 1 light.
* Added some fonts.
* Decorated the scene of the very beginning of level 1.
* Reworked the graphics of Healing Machine.
* Redesigned the beginning part of level 1 so that players could learn the falling off mechanic.

[2018.03.13]
* Completed graphics of Trash Can, Dead Mouse.
* Edited images: 6 Tissues, 5 Papers.
* Decorated the "Ministry of Love" and "Adventure Land".

[2018.03.18]
Comment: Caught a cold, otitis externa, and existential crisis. Back on work now.
* Covered the "Adventure lan" sign with a scrap paper.
* Decorated the Up Skill Tutorial and Kill Field.

[2018.03.19]
* Fixed some graphics of stains.
* Completed Cone Light Mask of Light.
* Decorated Kill Field and Mouse Land.
* Fixed the graphical bug of mob health bar masking.

[2018.03.20]
* Fixed a level design bug (trapped beneath the mouse land).
* Added particle effects to Power Ups (so the players could the difference between them and decorations.)
* Darkened the decorations a little (by modulating).

[2018.03.21]
* Decorated Ult Zone, Fort, Inner Fort.

**Commit**

[2018.03.22]
* Decorated Laser Zone.
* Completed image: Door.

[2018.03.23]
* Completed Door.
* Designed UIs for Game Over and Menu.

To Do List:
* Game Over scene animations.
* Game Over mechanics.
* Scene switching mechanics.
* Door picker for level 1.
* Change the graphics of number indicators.
(Decorations -> Dying mechanics)
* Probably should let the camera update horizontally according to the player with the least x position.

Planned Prototype Stages:
[Ver 0.1] First level completed. (Est. May 2018)
[Ver 0.1.1] Second character (Wendy Vista) completed.
[Ver 0.2] Main UI completed.

Polishing:
* [UI] A "GO" sign when the right camera margin is changing.
* [Effect] Attack effects.
* [Effect] Ult Stone particles.
* [Animation] Parachute on potions before landing.
* [Animation] Radiogugu watch out skill blinks blue.
* [Script] Slow down walking animation while slowed.
* [Effect] Jumping dust for characters.
* [Animation] Drink potion animation.
* [Script] Status icons showed in HUD. Blinking when about to vanish.
* [Script] Adjust damage according to player numbers.
* [Graphics] Dark level: wears mining hat.
* [Easter Egg] Phone screen showing "Tall as the Sky" and "kQq".