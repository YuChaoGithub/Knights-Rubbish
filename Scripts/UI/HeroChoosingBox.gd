extends Control

onready var hero_image = $Hero
onready var hero_name_label = $Name
onready var point_labels = [$Point1, $Point2, $Point3]
onready var checkmark = $Check
onready var select_text = $SelectText
onready var animator = $AnimationPlayer

func hero_changed(hero):
    hero_image.texture = hero.avatar
    hero_name_label.text = hero.name
    
    for index in range(point_labels.size()):
        point_labels[index].text = hero.points[index]

func hero_selected():
    checkmark.visible = true
    select_text.visible = false
    animator.play("Selected")

func hero_deselected():
    checkmark.visible = false
    select_text.visible = true
    animator.play("Original")