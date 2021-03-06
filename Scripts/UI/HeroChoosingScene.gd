extends CanvasLayer

const ICONS_COL_COUNT = 5
const ICONS_ROW_COUNT = 1

const ENTER_ANIMATION_DURATION = 1.5
const LEAVE_ANIMATION_DURATION = 1.0

const AUDIO_VOLUME_DB = -5
const PLAYER_2_AUDIO_PITCH = 0.8

var hero_lock_sound = preload("res://Audio/button_click.wav")
var hero_choosing_sound = preload("res://Audio/hero_choosing.wav")

var lock_audio_player
var choosing_audio_player = [null, null]

var hero_infos = [
    preload("res://Scripts/Constants/KeshiaErasiaConstants.gd"),
    preload("res://Scripts/Constants/WendyVistaConstants.gd"),
    preload("res://Scripts/Constants/RanawatoPlatoConstants.gd"),
    preload("res://Scripts/Constants/OthoxCodoxConstants.gd"),
    preload("res://Scripts/Constants/BroSSConstants.gd"),
    preload("res://Scripts/Constants/KeshiaErasiaConstants.gd"),
    preload("res://Scripts/Constants/KeshiaErasiaConstants.gd"),
    preload("res://Scripts/Constants/KeshiaErasiaConstants.gd"),
    preload("res://Scripts/Constants/KeshiaErasiaConstants.gd"),
    preload("res://Scripts/Constants/KeshiaErasiaConstants.gd"),
]

var key_setting_scene = preload("res://Scenes/UI/Key Setting Scene.tscn")

# Hero current selected.
var p1_selection = 0
var p2_selection = 0

var p1_locked = false
var p2_locked = false

var enter_timer
var leave_timer

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
    lock_audio_player = AudioStreamPlayer.new()
    lock_audio_player.stream = hero_lock_sound
    lock_audio_player.volume_db = AUDIO_VOLUME_DB
    add_child(lock_audio_player)

    choosing_audio_player[0] = AudioStreamPlayer.new()
    choosing_audio_player[0].stream = hero_choosing_sound
    choosing_audio_player[0].volume_db = AUDIO_VOLUME_DB
    add_child(choosing_audio_player[0])

    choosing_audio_player[1] = AudioStreamPlayer.new()
    choosing_audio_player[1].stream = hero_choosing_sound
    choosing_audio_player[1].volume_db = AUDIO_VOLUME_DB
    choosing_audio_player[1].pitch_scale = PLAYER_2_AUDIO_PITCH
    add_child(choosing_audio_player[1])

    set_process(false)

    if player_count == 1:
        single_player_paper.visible = true

        # Hide all multiplayer UIs.
        p1_paper.visible = false
        p2_paper.visible = false
        selection_frame_p2.visible = false

    # Store rect positions of hero icons.
    for index in range(ICONS_COL_COUNT * ICONS_ROW_COUNT):
        hero_icons_pos.push_back(get_node("HeroBox/HeroIcons/" + str(index + 1)).rect_position)

    # Set frame.
    var player_settings = get_node("/root/PlayerSettings")
    p1_selection = player_settings.heroes_chosen[0]
    if player_settings.heroes_chosen.size() == 2:
        p2_selection = player_settings.heroes_chosen[1]
    update_hero_selection_frames()

    enter_timer = cd_timer.new(ENTER_ANIMATION_DURATION, self, "set_process", true)

func _process(delta):
    # P1.
    if !p1_locked:
        if Input.is_action_just_pressed("p1_up"):
            p1_selection = clamp_index_in_range(p1_selection, p1_selection - ICONS_COL_COUNT, 0)
        elif Input.is_action_just_pressed("p1_down"):
            p1_selection = clamp_index_in_range(p1_selection, p1_selection + ICONS_COL_COUNT, 0)
        elif Input.is_action_just_pressed("p1_left"):
            p1_selection = clamp_index_in_range(p1_selection, p1_selection - 1, 0)
        elif Input.is_action_just_pressed("p1_right"):
            p1_selection = clamp_index_in_range(p1_selection, p1_selection + 1, 0)

    if Input.is_action_just_pressed("p1_attack"):
        if p1_locked:
            selection_checkmark_p1.visible = false
            p1_locked = false

            if player_count == 1:
                lock_audio_player.play()
                single_player_paper.hero_deselected()
            else:
                lock_audio_player.play()
                p1_paper.hero_deselected()

            check_deselection()
        elif !(p2_locked && p2_selection == p1_selection):  # Cannot select the same hero.:
            selection_checkmark_p1.visible = true
            p1_locked = true

            if player_count == 1:
                lock_audio_player.play()
                single_player_paper.hero_selected()
            else:
                lock_audio_player.play()
                p1_paper.hero_selected()

            check_selection_complete()

    # P2.
    if player_count > 1:
        if !p2_locked:
            if Input.is_action_just_pressed("p2_up"):
                p2_selection = clamp_index_in_range(p2_selection, p2_selection - ICONS_COL_COUNT, 1)
            elif Input.is_action_just_pressed("p2_down"):
                p2_selection = clamp_index_in_range(p2_selection, p2_selection + ICONS_COL_COUNT, 1)
            elif Input.is_action_just_pressed("p2_left"):
                p2_selection = clamp_index_in_range(p2_selection, p2_selection - 1, 1)
            elif Input.is_action_just_pressed("p2_right"):
                p2_selection = clamp_index_in_range(p2_selection, p2_selection + 1, 1)

        if Input.is_action_just_pressed("p2_attack"):
            if p2_locked:
                selection_checkmark_p2.visible = false
                lock_audio_player.play()
                p2_paper.hero_deselected()
                p2_locked = false

                check_deselection()
            elif !(p1_locked && p1_selection == p2_selection):  # Cannot select the same hero.
                selection_checkmark_p2.visible = true
                lock_audio_player.play()
                p2_paper.hero_selected()
                p2_locked = true

                check_selection_complete()

    update_hero_selection_frames()

# Well, I shouldn't do this, but the choosing sound will be played here.
func clamp_index_in_range(original, new, player_index):
    if new < 0 || new >= ICONS_COL_COUNT * ICONS_ROW_COUNT:
        return original
    else:
        choosing_audio_player[player_index].play()
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
    leave_timer = cd_timer.new(LEAVE_ANIMATION_DURATION, self, "switch_to_game_scene")

func switch_to_game_scene():
    var loading_scene = get_node("/root/LoadingScene")
    loading_scene.pop_curr_scene_from_stack()    # So players can exit directly to main menu.
    loading_scene.load_next_scene()

func back_button_pressed():
    main_animator.play("Leave")
    leave_timer = cd_timer.new(LEAVE_ANIMATION_DURATION, self, "switch_back_to_original_scene")

func setting_button_pressed():
    var ks_scene = key_setting_scene.instance()
    ks_scene.resume_scene = self
    add_child(ks_scene)
    set_process(false)

func resume_current():
    set_process(true)

func switch_back_to_original_scene():
    get_node("/root/LoadingScene").load_previous_scene()