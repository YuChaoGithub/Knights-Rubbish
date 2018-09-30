extends Node2D

const HEAL_AMOUNT = 50

var captured = false

func capture(area):
    if !captured && area.is_in_group("hero"):
        var hero = area.get_node("..")
        if !hero.health_system.is_full_health() && !hero.status.fallen_off && !hero.status.dead:
            hero.healed(HEAL_AMOUNT)

            captured = true
            
            $AnimationPlayer.play("Captured")