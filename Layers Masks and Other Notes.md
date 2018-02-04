# Collision

## Layers
(1)Character
(2)Platforms
(4)Camera Bounds
(8)Collectibles, Friendly AoE, Friendly Triggers
(16)Enemy Movement Collider, Enemy Damage Collider
(32)Friendly Fire
(64)Enemy Fire
(128) Not Important.
(256) Enemy only platforms
(512) Player only platforms

## Masks:
Character: (2), (4), (512)
Platforms / Camera Bounds: None
Collectibles, etc.: (1)
Enemy Movement Collider: (2) (256)[Sometimes none]
Enemy Damage Collider: None
Friendly Fire: (16)
Enemy Fire: (1)
