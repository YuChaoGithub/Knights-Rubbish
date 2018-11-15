extends Node2D

var hero_stat_names = ["keshia_played", "wendy_played", "ranawato_played", "othox_played", "bross_played"]

func _ready():
	var player_settings = get_node("/root/PlayerSettings")
	var steam_works = get_node("/root/Steamworks")
	
	if player_settings.player_count > 1:
		steam_works.increment_stat("coop_mode_played")
	else:
		steam_works.increment_stat("solo_mode_played")
	
	for hero in player_settings.heroes_chosen:
		steam_works.increment_stat(hero_stat_names[hero])