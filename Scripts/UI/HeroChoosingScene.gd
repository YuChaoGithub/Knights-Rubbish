extends CanvasLayer

const ICONS_COL_COUNT = 5
const ICONS_ROW_COUNT = 2

const LEAVE_ANIMATION_DURATION = 1.0

var hero_infos = [
    preload("res://Scripts/Constants/KeshiaErasiaConstants.gd"),
    preload("res://Scripts/Constants/WendyVistaConstants.gd"),
    preload("res://Scripts/Constants/KeshiaErasiaConstants.gd"),
    preload("res://Scripts/Constants/KeshiaErasiaConstants.gd"),
    preload("res://Scripts/Constants/KeshiaErasiaConstants.gd"),
    preload("res://Scripts/Constants/KeshiaErasiaConstants.gd"),
    preload("res://Scripts/Constants/KeshiaErasiaConstants.gd"),
    preload("res://Scripts/Constants/KeshiaErasiaConstants.gd"),
    preload("res://Scripts/Constants/KeshiaErasiaConstants.gd"),
    preload("res://Scripts/Constants/KeshiaErasiaConstants.gd"),
]

# Hero current selected.
var p1_selection = 0
var p2_selection = 0

var p1_locked = false
var p2_locked = false

var timer

var hero_icons_pos = []

var cd_timer = preload("res://Scripts/Utils/CountdownTimer.gd")

onready var selection_frame_p1 = $HeroBox/HeroIcons/BoxP1
onready var selection_checkmark_p1 = selection_frame_p1.get_node("Check")
onready var selection_frame_p2 = $HeroBox/HeroIcons/BoxP2
onready var selection_checkmark_p2 = selection_frame_p2.get_node("Check")

onready var p1_paper = $SelectionBoxP1
onready var p2_paper = $SelectionBoxP2
onready var single_player_paper = $SelectionBoxSinglePlayer

onready var player_count = get_node("/root/PlayerSettings").player_count
onready var main_animator = $AnimationPlayer
onready var countdown_animator = $CountdownBox/AnimationPlayer

func _ready():
    if player_count == 1:
        single_player_paper.visible = true

        # Hide all multiplayer UIs.
        p1_paper.visible = false
        p2_paper.visible = false
        selection_frame_p2.visible = false

    # Store rect positions of hero icons.
    for index in range(ICONS_COL_COUNT * ICONS_ROW_COUNT):
        hero_icons_pos.push_back(get_node("HeroBox/HeroIcons/" + str(index + 1)).rect_position)

func _process(delta):
    # P1.
    if !p1_locked:
        if Input.is_action_just_pressed("p1_up"):
            p1_selection = clamp_index_in_range(p1_selection, p1_selection - ICONS_COL_COUNT)
        elif Input.is_action_just_pressed("p1_down"):
            p1_selection = clamp_index_in_range(p1_selection, p1_selection + ICONS_COL_COUNT)
        elif Input.is_action_just_pressed("p1_left"):
            p1_selection = clamp_index_in_range(p1_selection, p1_selection - 1)
        elif Input.is_action_just_pressed("p1_right"):
            p1_selection = clamp_index_in_range(p1_selection, p1_selection + 1)

    if Input.is_action_just_pressed("p1_attack"):
        if p1_locked:
            selection_checkmark_p1.visible = false
            p1_locked = false

            if player_count == 1:
                single_player_paper.hero_deselected()
            else:
                p1_paper.hero_deselected()

            check_deselection()
        elif !(p2_locked && p2_selection == p1_selection):  # Cannot select the same hero.:
            selection_checkmark_p1.visible = true
            p1_locked = true

            if player_count == 1:
                single_player_paper.hero_selected()
            else:
                p1_paper.hero_selected()

            check_selection_complete()

    # P2.
    if player_count > 1:
        if !p2_locked:
            if Input.is_action_just_pressed("p2_up"):
                p2_selection = clamp_index_in_range(p2_selection, p2_selection - ICONS_COL_COUNT)
            elif Input.is_action_just_pressed("p2_down"):
                p2_selection = clamp_index_in_range(p2_selection, p2_selection + ICONS_COL_COUNT)
            elif Input.is_action_just_pressed("p2_left"):
                p2_selection = clamp_index_in_range(p2_selection, p2_selection - 1)
            elif Input.is_action_just_pressed("p2_right"):
                p2_selection = clamp_index_in_range(p2_selection, p2_selection + 1)

        if Input.is_action_just_pressed("p2_attack"):
            if p2_locked:
                selection_checkmark_p2.visible = false
                p2_paper.hero_deselected()
                p2_locked = false

                check_deselection()
            elif !(p1_locked && p1_selection == p2_selection):  # Cannot select the same hero.
                selection_checkmark_p2.visible = true
                p2_paper.hero_selected()
                p2_locked = true

                check_selection_complete()

    update_hero_selection_frames()

func clamp_index_in_range(original, new):
    if new < 0 || new >= ICONS_COL_COUNT * ICONS_ROW_COUNT:
        return original
    else:
        return new

func update_hero_selection_frames():
    selection_frame_p1.rect_position = hero_icons_pos[p1_selection]

    if player_count == 1:
        single_player_paper.hero_changed(hero_infos[p1_selection])
    else:
        p1_paper.hero_changed(hero_infos[p1_selection])

        selection_frame_p2.rect_position = hero_icons_pos[p2_selection]
        p2_paper.hero_changed(hero_infos[p2_selection])

func check_selection_complete():
    if player_count == 1 || p1_locked && p2_locked:
        countdown_animator.play("Countdown")

func check_deselection():
    if countdown_animator.current_animation == "Countdown":
        countdown_animator.play("Leave")

# This will be called when the Countdown animation is completed.
func ready_countdown_completed():
    set_process(false)    # Disable all input.

    var heroes_chosen = [p1_selection]
    if player_count > 1:
        heroes_chosen.push_back(p2_selection)
    get_node("/root/PlayerSettings").heroes_chosen = heroes_chosen

    main_animator.play("Leave")
    timer = cd_timer.new(LEAVE_ANIMATION_DURATION, self, "switch_to_game_scene")

func switch_to_game_scene():
    get_node("/root/LoadingScene").load_next_scene()

func back_button_pressed():
    main_animator.play("Leave")
    timer = cd_timer.new(LEAVE_ANIMATION_DURATION, self, "switch_back_to_original_scene")

func switch_back_to_original_scene():
    get_node("/root/LoadingScene").load_quit_scene()