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
Comment: Seems like it's not that hard to migrate to Godot 3.0. Worth it!

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
Comment: Aside from weekly commits, now all big milestones should be committed upon achieving.

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

**Commit**

[2018.03.26]
* Completed Game Over animations.
* Completed single player Game Over mechanics.

[2018.03.27]
* Added a Pause Button to the game scene.
* Completed Pause Scene, Confirm Panel. (Except the functionality of Quit and Retry buttons).

**Commit**

[2018.03.28]
* Completed Loading Scene.
* Completed Scene switching singleton.
* Now the horizontal-update of camera will be triggered by the player with the least x position.
* Naming changes: Character Average Position -> HeroAveragePos. Following Camera -> FollowingCamera. Later on, all the scene names should apply camel casing.
* Started designing Door picker for level 1. (Level 1-0)
* Updated Prototype Stages and To Do Lists.

**Commit**

[2018.03.29]
Facepalms: Editor always breaks after Git operations...so annoying.
* Mobs will now be freed as expected when being killed by Keshia's Basic Skill. (By calling `stunned(...)` before `damaged(...)`)
* Added the functionality of Quit Button.
* Completed the first door of Level 1 Door Picker.
* "Immune Text" now will not be displayed when blocking a stun.
* Changed the attack hit box of CDPunch so that it won't hit heroes twice per attack. Hopefully this works.
* Implemented Main Menu Door.

**Commit**

[2018.03.30]
* Camera and passing trigger will now update left by max_x, top by min_y etc. (Not the hero average position anymore.)
* Implemented "potion drinking" delay for picking up power ups.
* Completed Drink, Size Change animation for Keshia Erasia.
* Now "Attack++", "Defense++", and "Speed++" will be shown after picking up the corresponding powerups.
* Size changing will now be performed gradually.
* Reworked size potions. They last forever, until another size potion is picked up.
* Renamed some variables for coherence.

**Commit**

[2018.04.03]
* Completed Size Changing Light.
* Made Basic Attack and Horizontal Skill animation of Wendy Vista.

[2018.04.04]
* Made Down Skill, Up Skill and Basic Skill animation of Wendy Vista.
* Defined `WendyVistaConstants.gd`.
* Modified some Keshia Erasia's skill/constants implementation for consistency.
* Started implementing `WendyVistaSkills.gd`.

[2018.04.05]
* Replace `jump_events` in `HeroCommon.gd` with a `did_jump` signal.
* Completed Drink animation of Wendy Vista.
* Placed required scenes in Wendy Vista.
* Completed Basic Attack of Wendy Vista.

**Commit**

[2018.04.06]
* Completed Down Skill, Horizontal Skill and Basic Skill of Wendy Vista.

**Commit**

[2018.04.09]
* Up Skill velocity is now calculated by total vertical displacement.
* Completed Up Skill of Wendy Vista.
* Completed Die, Size Change animation of Wendy Vista.

[2018.04.10]
* Completed Wendy Vista Ult.
* Fixed `status.no_movement` in `HeroCommon.gd` so that collision will still be detected even if it is set to true.
* Changed `HeroAveragePosition.gd` to `HeroCommon.gd`. Also simplified its code.
* Implemented 2 player controlling and hero spawning mechanic.

**Commit**

[2018.04.11]
* Modify health bar position for Player 2.
* Added a `PlayerSettings.gd` singleton node for storing hero choices (and other player settings in the future).
* Modify naming of hero array from `characters` to `heroes` in `HeroManager.gd`.
* Completed ghost health bar.

[2018.04.12]
* Redesigned the code of `NumberIndicator.gd`, it no longer needs `NumberSpawnPos.gd`.
* Completed resurrection mechanic.
* Completed Ghost Ball. (Deal damage in intervals to the player alive when being a ghost.)
* Completed screen shaking effect when a hero falls off or revives.
* Completed lightning effects upon revival.

**Commit**

[2018.04.16]
* Designed parts of Hero Selection Scene.

[2018.04.17]
* Added `avatar` and `points` to Hero Constants.
* Changed Wendy's hero id to 1. Later hero ids should be the same of implementation order.
* Designed Combo Tutorial Scene.
* Implemented parts of hero selection scene.

[2018.04.18]
* Completed Hero Selection Scene.
* Designed Key Setting Scene.

**Commit**

[2018.04.23]
* Coded some Key Settings ui.

[2018.04.24]
* Completed scripting Key Settings Scene. Kind of hard and unintuitive.

**Commit**

[2018.04.25]
* Added Key Setting Button.
* Redesigned scene loading system. A scene (path) stack is implemented.
* Fixed an animation bug that the hero box wouldn't be locked down when a hero is selected.
* Added Change Hero button in Level Picker.

[2018.04.26]
* Changed the scene transition of Key Setting and Combo Tutorial to node instancing. (So that the current scene won't be destroyed.)
* Added Level Picker Scene. Implemented Level Picker Button Set.
* Enemy's health will now scale according to the numbers of players. (Multiplier: 1 per player.)

[2018.04.27]
* Added Level Template, Level 1-2.
* Implemented Portal.

**Commit**

[2018.04.30]
* Heroes will no longer consume potions when dead, immobile or in fist.
* Fixed the bug that Wendy can cast Up Skill twice in air.
* Arranged the basic structure of Level 1-2.

[2018.05.01]
* Arranged the Latortrans area of Level 1-2. Level design is actually pretty hard.

[2018.05.02]
* Set up all the camera controlling triggers of Level 1-2. (But not tested yet).

[2018.05.03]
* Make Wendy's Basic Attack stun first then damage so that fatal blows won't let enemies moving after dying.
* Tested and modified some parts of Level 1-2.
* Added touch damage and input damage to Latortrans.
* Rearranged Latortrans area.
* Changed the shooting angle, reduced the shooting interval and added more bullets per wave for Latortrans.

[2018.05.04]
* Added some animation to make Boss Health more visible and eye catching.
* Added particles for Latortrans' input texts and balls.
* No longer shows ghost health bar in single player mode.
* Turn off Heroes' Damage Area when in fist, turn on again after they fall off from the Top Fist.
* Completed the basic layout of Level 1-2.

**Commit**

[2018.05.07]
* Portals will now be disabled if its destination isn't in camera's view. Also changed some camera transition in Level 1-2.
* Decorated half of Level 1-2.

[2018.05.08]
* Decorated Level 1-2. Only Latortrans' place left.

[2018.05.09]
* Completed decoration Level 1-2.
* Changed Chinese font.
* Latortrans' all attacks now do damage.
* Fixed the bug that heroes fire the wrong direction when Confused.

**Commit**

[2018.05.10]
* Designed Level 1-3 a little.
* Reworked Socute's particles.

[2018.05.11]
* Designed Level 1-3. Haven't tested yet.
* Sockute will now be queued free when leaving the camera.

**Commit**

[2018.05.14]
* Fixed some bugs with Level 1-3 design.
* Lost motivation again. Urg.

[2018.05.15]
* Decorated Level 1-3.

[2018.05.16]
* Completed decoring Level 1-3.
* Fixed some level design in the beginning of Level 1-3 so that the shrinked heroes won't be stuck of the walls when dropping out from Fist. Not Tested Yet.

**Commit**

[2018.05.18]
* Designed Level 1-4.

[2018.05.21]
* Made Eelo Kicker/Puncher seek the nearest healing fountain automatically so that they can be instanced by Spawner.
* Completed setting the triggers of Level 1-4.

[2018.05.22]
* Healing Fountains now can also heal heroes for half of the original amount.
* Added Landing status to Eelo Kicker/Puncher.
* Change facing of Eelo Puncher so that it's wheel won't turn the wrong direction.
* Added a `die_timer` to all mobs so that `status_timer` cancels won't affect `queue_free`.
* Made Eelo Kicker/Puncher go back to healing fountain if they can't reach the hero (in range y). (So as to avoid it flipping around in the same place like idiots.)

[2018.05.23]
Comment: Recently I sacrificed most of my time for studying NTU's transfer exam ... don't know if it's worth it.
* Fixed Eelo Puncher's many bugs.
* Implemented CountdownTV.

[2018.05.25]
* Place and hooked all the CountdownTVs with mobs and mob spawners.
* Decorated Level 1-4.

**Commit**

[2018.05.28]
* Drawn golden portrait frame and elder Eelo portrait.

[2018.05.29]
* Finished decorating Level 1-4.

[2018.05.30]
* Fixed some code for Eelo Puncher. It's movement will now be more natural.
* Tested Level 1-4. Good.

**Commit**

[2018.05.31]
* Started designing Level 1-5.

[2018.06.01]
* Completed the layout of Level 1-5.
Comment: Too depressed to work.

[2018.06.04]
* Designed the portals, power ups, and lights of level 1-5.

[2018.06.05]
* Designed the mobs of level 1-5.
* Set some of the camera changing triggers of level 1-5.

[2018.06.07]
* Set camera changing triggers of level 1-5.

[2018.06.08]
* Set camera changing triggers of level 1-5. (Inefficiently).

**Commit**

[2018.06.11]
* Finished setting the camera changing triggers of level 1-5. (Not tested yet.)

[2018.06.12]
* Tested and fixed some bugs of the camera changing triggers of level 1-5.

[2018.06.13]
* Fully tested level 1-5. Fixed a minor bug. Level 1-5 is good to go.

[2018.06.21]
Comment: Preparing for the transfer exam. Will be developing this slower.
* Started decorating level 1-5.

[2018.06.22]
* Keep on decorating level 1-5.

[2018.07.15]
* Finally back to development.
* Completed level 1-5 and 1-6.

[2018.07.16]
* Completed level 1-7.
Comment: Lose motivation once again. Might start a new project and come back to this later...

**Commit**

[2018.07.22]
* Completed the mobs and camera triggers of level 1-8. Not tested yet.
Comment: Ahhh... kind of burnt out. Will be taking a break.

[2018.07.29]
* Tested and added count down tv to level 1-8. Fix bugs.
Comment: Working on my graphic novel. Will come back to this project later.

[2018.09.10]
Comment: I'm back to save the universe. Hope that I can rush and complete the alpha version.
* Layed out the platforms of level 1-9.
* Added hover and click audio for buttons.
* Added audio for paper flipping in Hero Choosing Scene.

[2018.09.11]
* Decorated level 1-8.
* Fixed bugs related to Laserphone and Red Earspider.

[2018.09.14]
* Completed laying out level 1-9. Triggers not set yet.

**Commit**

[2018.09.15]
* Completed setting triggers and decorating level 1-9. Not tested yet.

[2018.09.16]
* Tested level 1-9. Fixed bugs.
* Layed out level 1-10.

**Commit**

[2018.09.18]
* Set triggers and decorated level 1-10. Not tested yet.

[2018.09.21]
* Tested level 1-10. Perfect.
* Finished coding `RadioguguStereoBomb.gd`. Integrated it to `Radiogugu.gd`.
* Fixed bugs of Radiogugu.
* Completed `Computer Screen.tscn`.
* Completed level 1-11. Tested.
Comment: What a sprint!

**Commit**

[2018.09.26]
* Completed making tilesets: Terminal Wall, Binary Floor.

[2018.09.29]
* Completed level 1-12.
* Completed `Terminal Upgrade.tscn`.

**Commit**

[2018.09.30]
* Dark blue wall tileset, gray platform tileset.
* Completed designing the platforms and enemies of level 1-13.
Comment: I do daily commits further on.

[2018.10.09]
* Set the triggers of level 1-13. Tested.
* Fixed bugs of `BouncyMovement.gd`. Adjust the scale of Cliffy's attacks.

[2018.10.12]
* Added Go Arrows for level 1-13.
* Fixed the bug that random movement will provide direction of 0.
* Added light to Canmera Missle.
* Redesigned Godotbos.
* Completed level 1-14. Not tested yet.

[2018.10.13]
* Tested level 1-14.
* Added Light Blue Wall, Dark Blue Floor.
* Set up iSnail, Chromoghast and Clockworkfox.

[2018.10.14]
* Completed level 1-15. Tested.
* Designed plenty of blue wall decoration tiles.

[2018.10.15]
* Completed level 1-16. Tested.

[2018.10.16]
* Completed level 1-17. Tested.

[2018.10.18]
* Fixed bugs of eyeMac.
* Designed effects for level 1-18.
* Fixed the bug that Keshia Erasia couldn't jump & attack after drinking potion while performing basic skill.
* Completed level 1-18 except the ending. Tested.

[2018.10.19]
* Designed the ending of level 1-18.
* Completed the "To be continued..." level.
* Added screen capture for Sonmera and Eyemac (show in the next level part). So cool!
Comment: Finally finished designing level 1.

[2018.10.21]
* Cleaned up cringy text labels.
* Fixed the wrongly connected doors.
* Completed level 1-0 (level 1 picker).

[2018.10.22]
* Redesigned the visual effects of Battorio, Calcasio Bullet, Canmera Missle, Chromoghast Shuriken, Cliffy Shuriken, Cliffy Light Bulb, eyeMac Mouse Bomb, eyeMac USB Bomb, eyeMac, Harddies Ring, iSnail Hourglass, Latortrans Balls, Mousy Bomb, Radiogugu Watch, Paranoid Android, Amazlet Frizbee, Sockute Lightning Ball.
Comment: What a day. Tired.

[2018.10.23]
* Added laserlight effect for all laser shooting enemies.
* Added particle systems for Radiogugu's skills, Darkearspider's clap, Godotbos Skill's Godotbos Missles, Eelo Kicker, Eelo Puncher, Harddies Drop (I really like the puff effects), Floopy, CD Punch, Keshia's Pencil Dart, Bottom Grab, Top Fist.

[2018.10.24]
* Completed Keshia and Wendy's skills' visual effects.

[2018.10.26]
* Completed Ranawato's all basic animations.
* Completed Ranawato's Basic Attack and Basic Skill.

[2018.10.29]
* Completed all of Ranawato's Skills.

[2018.10.30]
* Completed Othox's Basic Attack, Basic Skill, and Horizontal Skill.
* Fixed the bug that some heroes won't turn currently when casting horizontal skills.

[2018.10.31]
* Completed all of Othox's Skills.
* Completed Drink, Die, Size Change animations of Bro SS.

[2018.11.02]
* Completed Basic Attack, Basic Skill, Down Skill of Bro SS.

[2018.11.03]
* Completed all skills of Bro SS.
* Added "Coming Soon" labels in Hero Choosing Scene.

[2018.11.04]
* Redesigned Menu Scene.
* Added audio for all UIs.
* Fixed the bug that players could unexpectedly interact with UIs on the previous layers using Space/Enter key. (Due to Godot's default UI events)
Comment: Experiencing self-imposed crunches these weeks, haha!

[2018.11.05]
* Recorded sound effects.

[2018.11.06]
* Completed recording sound effects.

[2018.11.07]
* Added 160 sound effects to the game. (Alphabetically: amazlet_acc.wav to mouse_open_lid.wav). Soooo tired, but rewarding.

[2018.11.08]
* Added all sound effects to the game.
* Tested the game in 1P and fixed bugs.

[2018.11.09]
* Playtested the full game.
* Fixed the bug that Darkearspider often teleports while performing random movement.
* Expand the range of Laserphone's hitbox.
* Fixed the bug that the hero's `self_modulate` wouldn't recover if it is being hit while stunned.
* Rebalanced the heroes.
* Adjusted the difficulties of levels.
* Fixed the bug that `die()` will be called multiple times if the mob was damaged multiple times within in a frame.
* Deleted unused image files in the repository.
* Recorded all the skills of the heroes.

[2018.11.11]
* Recorded all heroes' combos and uploaded them on Youtube.
* Wrote lores and set up the project page on my blog.
* Updated readme.
* Playtested 2P with my brother. Still tons of bug...sigh.
* Decreased the multiplier of enemies health to 0.6 from 1.0 (times the player count).
* Removed all the "to be continued text".
* Fixed the bug that Ranawato teleports to the other side of amazlet.
* Audio are now muted when pausing.
* Bug fix: Darkearspider no longer climbs higher than its original position when being damaged.
* Adjusted ghost health: Keshia from 500 to 550. Bro SS from 550 to 650.
* Adjusted size multipliers: Shrinking (Attack: from 0.75 to 0.9, Damage Taken: from 1.2 to 1.1, Self Knockback: from 1.5 to 1.25, Enemy Knockback: from 0.5 to 0.75).
* Made Amazlet and Latortrans' touch damage a cycle so that players couldn't stand right on them and attack.
* Ghost Heroes will no longer block enemies attacks.
Comment: Video editting is so tiring, time-consuming yet fun.

[2018.11.12]
* Decreased Godot's standing time.
* Added a linkable Logo in the start menu.
* Deleted the arena button in the start menu.
* Made key configuration persistent between games.
* Now further levels will be locked before the previous ones are completed.
* Ranawato's Horizontal Skill will now be cancelled if it flies off the screen.
* Now `PassingTrigger.gd` checks for all heroes instead of only the min/max positioned one.
* Now P1 and P2 have different choosing audio in the Hero Choosing Scene.
* Attack sounds will now be muted when interrupted.
* Dying will now interrupt skills.
* Use "Health multiplier for coop" instead of "Health multiplier per players" for mob health.
* Added Splash Screen.
* Check and reset (if neccessary) all triggers carefully in all levels. Tested (1P only).
* Fixed the bug that Keshia's ult isn't fullscreen when he is shrinked or gianted.
* Rebalanced heroes. Generally, nerf Plato, Othox and Big Brother.
* Adjusted size multipliers: Shrinking (Attack: from 0.9 to 0.85).

[2018.11.13]
* Adjusted size multiplier: Gianted (Enemy Knockback: from 2.0 to 1.4).
* Made some of the enemy-only walls higher so that they won't be knocked off the platform.
* Adjusted Plato's basic attack hit box.
* Decreased the stun duration of Latortrans.
* Bug fix: Hero Ghost Box will no longer take effect if in single player mode.
* Rearranged the most annoying level: Level 1-5. Damning bug creeping one.
* Falling off the cliff will now interrupt all skill sounds.
* Added checkpoint labels.
* Rearranged Amazlet's level so that the crown is visible.
* Make potions' collider turning off and on quickly so that the heroes wouldn't need to leave and enter the powerup to consume it in certain situations.
* Added a collapsible "Pause, Keysettings" hint in Level Picker.
* Relayered Othox's drink animation so that the bottle won't appear in the back of his mouth.
* Refactored Laserphone's code.
* Fixed a bug with Plato and Othox Up Skills. (The cooldown & landing detection isn't correct.)
* P1 level play test to Godotbos level. Fixed trigger & enemy activation bugs.

[2018.11.14]
* Nerf ASCII Bomb and Gun's damage.
* Reworked Godotobos, so that it will heal and attack when its HP is below 40%.
* Windy Meteory now will not fall if the nearest hero is in hand.
* The door of the last level now can only be smashed open when it is fully landed.
* Now Harddies' health percentage will persist between flying form and stiff form.
* Fixed a weird bug that Clockworkfox's activate timer will be cancelled twice.
* Did another 1P play-test. Seemed ready to publish.

[2018.11.15]
* Changed app icon.
* Created artworks for Steam Store.
* Branched for Steam distribution.

***Steam Build**

* Toggling Steam overlay will pause the game.
* Integrated achievements. Tired.
* Can't find a way to generate customized template, asking on Reddit. Hope to get an answer soon.

[2018.11.16]
* Renamed project name to Knights Rubbish.
* Set Fullscreen on open.
* Bug fix: Wendy Basic Skill and Horizontal Skill now deals integer damage.
* Updated icon to 512px version.

[2018.11.17]
* 2P play-test with my brother. (Second time).
* Adjusted the difficulty of level 1-16.
* Fixed following camera bugs in level 1-15.
* Adjusted the hitbox activate time for Keshia's BA.
* Bug Fix: The "I give up" button now works correctly in game over scene.

[2018.11.18-23]
* Completed Steamworks configurations and graphics.
* Mac & Windows build (ver 0.1).
* Steam Store page ready to go.

[2018.11.28]
* Bug Fix: Users couldn't go to Key Settings Scene through Pause Scene.
* Now the game will automatically be paused when activating Steam Overlay.

[2018.11.29]
* Bug Fix: Camera stuck in Level 1-5.

[2018.12.01]
* Fixed a goddamn bug: I mistyped "Light bulb" to "Light Bulb" (The exported game is case sensitive.)

[2018.12.07]
* Bug Fix: Players will no longer get stuck on the upper platform of Level 1-4.

Build Notes:
For Mac Steam Build, tick the full screen checkbox!