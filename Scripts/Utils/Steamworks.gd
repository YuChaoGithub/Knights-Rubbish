extends Node

var stats_received_success = false

var hero_complete_stat_names = ["keshia_completed", "wendy_completed", "ranawato_completed", "othox_completed", "bross_completed"]

func _ready():
	# return
	
	if Steam.restartAppIfNecessary(980440):
		get_tree().quit()
		
	if !Steam.steamInit():
		print("SteamInit() failed.")
	else:
		Steam.connect("user_stats_received", self, "stats_received")
		Steam.requestCurrentStats()
	
func _process(delta):
	Steam.run_callbacks()
	
func set_achievement(name):
	print("Achievement set: ", name)
	if !stats_received_success:
		return
		
	Steam.setAchievement(name)
    
func set_starting_achievements():
	var date = OS.get_date()
	if date.month == 11 && date.day == 24:
		set_achievement("BIRTHDAY")
	elif date.month == 2 && date.day == 29:
		set_achievement("FEB_TWO_NINE")
	elif date.month == 2 && date.day == 14:
		set_achievement("VALENTINE")
	elif date.weekday == 5 && date.day == 13:
		set_achievement("FRIDAY_THIRTEENTH")
		
	set_achievement("GIFT")

func stats_received(game_id, result, user_id):
	if result == 1:
		stats_received_success = true
		set_starting_achievements()
	else:
		print("Failed to receive stats: Error Code ", result)
	
func store_stats():
	print("Store Steam stats.")
	if !stats_received_success:
		return
		
	Steam.storeStats()
	
func increment_stat(name, by = 1):
	print("Increment stat for ", name, " by ", by, ".")
	if !stats_received_success:
		return
		
	var count = Steam.getStatInt(name)
	Steam.setStatInt(name, count + by)
		
func quit_steamworks():
	if Steam.isSteamRunning():
		store_stats()
		Steam.shutdown()
		
func eyemac_defeated():
	increment_stat("eyemac_killed")
	
	var heroes = get_node("/root/PlayerSettings").heroes_chosen
	for hero in heroes:
		increment_stat(hero_complete_stat_names[hero])
		
func ult_cast():
	increment_stat("ult_cast")
	
func eelo_killed():
	increment_stat("eelo_killed")