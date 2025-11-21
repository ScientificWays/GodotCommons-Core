extends Node
class_name PlatformGlobals_Class

signal web_interstitial_started()
signal web_interstitial_finished(in_success: bool)

#var vk_ads: VkAds

#signal vk_interstitial_started()
#signal vk_interstitial_finished(in_success: bool)

var yandex_ads_script_path: String = "res://addons/GodotAndroidYandexAds/yandex_ads.gd"
var yandex_ads: Node

signal yandex_interstitial_started()
signal yandex_interstitial_finished(in_success: bool)

func _ready() -> void:
	
	set_process_input(false)
	
	if is_web():
		
		TranslationServer.set_locale(Bridge.platform.language)
		
		Bridge.game.visibility_state_changed.connect(_on_web_visibility_state_changed)
		Bridge.platform.pause_state_changed.connect(_on_web_pause_state_changed)
		Bridge.platform.audio_state_changed.connect(_on_web_audio_state_changed)
		
		Bridge.advertisement.interstitial_state_changed.connect(_on_web_interstitial_ad_state_changed)
		Bridge.advertisement.rewarded_state_changed.connect(_on_web_rewarded_ad_state_changed)
		
		Bridge.leaderboards.on_set_score_finished.connect(_on_web_leaderboards_set_score_finished)
		
		update_platform_wants_to_pause_game()
		update_platform_wants_to_mute_game()
		
		update_interstitial_ad_next_show_time()
	
	elif is_mobile(false):
		
		#vk_ads = VkAds.new()
		#vk_ads.interstitial_id = 1913782
		#add_child(vk_ads)
		
		#vk_ads.interstitial_loaded.connect(on_vk_ads_interstitial_loaded)
		#vk_ads.interstitial_failed_to_load.connect(on_vk_ads_interstitial_failed_to_load)
		#vk_ads.interstitial_closed.connect(on_vk_ads_interstitial_closed)
		
		yandex_ads = load(yandex_ads_script_path).new()
		yandex_ads.interstitial_id = "R-M-17344604-2"
		add_child(yandex_ads)
		
		yandex_ads.interstitial_loaded.connect(_on_yandex_ads_interstitial_loaded)
		yandex_ads.interstitial_failed_to_load.connect(_on_yandex_ads_interstitial_failed_to_load)
		yandex_ads.interstitial_closed.connect(_on_yandex_ads_interstitial_closed)
		
		update_interstitial_ad_next_show_time()

func _input(in_event: InputEvent) -> void:
	
	if is_pending_rate:
		if in_event is InputEventScreenTouch:
			print("_on_rate_game_finished() from fallback input")
			_on_rate_game_finished(false)
			assert(not is_processing_input())

##
## Game
##
func _on_web_visibility_state_changed(in_state: String) -> void:
	update_platform_wants_to_pause_game()
	update_platform_wants_to_mute_game()

##
## Messages
##
func send_gameplay_started_message() -> void:
	if is_web():
		Bridge.platform.send_message(Bridge.PlatformMessage.GAMEPLAY_STARTED)

func send_gameplay_stopped_message() -> void:
	if is_web():
		Bridge.platform.send_message(Bridge.PlatformMessage.GAMEPLAY_STOPPED)

func send_game_loading_started_message() -> void:
	if is_web():
		Bridge.platform.send_message(Bridge.PlatformMessage.IN_GAME_LOADING_STARTED)

func send_game_loading_stopped_message() -> void:
	if is_web():
		Bridge.platform.send_message(Bridge.PlatformMessage.IN_GAME_LOADING_STOPPED)

##
## Environment
##
static func has_any_feature(in_features: Array[String]) -> bool:
	return in_features.any(func(feature: String): return OS.has_feature(feature))

static func has_all_features(in_features: Array[String]) -> bool:
	return in_features.all(func(feature: String): return OS.has_feature(feature))

static func is_mobile(in_check_web: bool = true) -> bool:
	if in_check_web and OS.has_feature("web"):
		return Bridge.device.type == Bridge.DeviceType.MOBILE
	return OS.has_feature("mobile")

static func is_mobile_web() -> bool:
	if OS.has_feature("web"):
		return Bridge.device.type == Bridge.DeviceType.MOBILE
	return false

static func is_pc(in_check_web: bool = true) -> bool:
	
	if in_check_web and OS.has_feature("web"):
		return Bridge.device.type == Bridge.DeviceType.DESKTOP
	return OS.has_feature("pc")

static func is_pc_web() -> bool:
	if OS.has_feature("web"):
		return Bridge.device.type == Bridge.DeviceType.DESKTOP
	return false

static func is_web() -> bool:
	return OS.has_feature("web")

static func is_release() -> bool:
	return OS.has_feature("release")

static func is_debug() -> bool:
	return OS.has_feature("debug")

##
## Storage
##
static func get_all_file_paths_in(in_path: String) -> Array[String]:
	
	var out_paths: Array[String] = []
	var dir_access := DirAccess.open(in_path)
	dir_access.list_dir_begin()
	
	var next_dir = dir_access.get_next()
	
	while not next_dir.is_empty():
		
		var sample_path = in_path + "/" + next_dir
		
		if dir_access.current_is_dir():
			out_paths += get_all_file_paths_in(sample_path)
		else:
			out_paths.append(sample_path)
		
		next_dir = dir_access.get_next()
	return out_paths

func request_get_data_from_platform_storage(in_keys: Array[String], in_callback: Callable) -> void:
	Bridge.storage.get(in_keys, in_callback)

func request_set_data_in_platform_storage(in_keys: Array[String], in_values: Array[Variant], in_callback: Callable) -> void:
	Bridge.storage.set(in_keys, in_values, in_callback)

func request_delete_data_in_platform_storage(in_keys: Array[String], in_callback: Callable) -> void:
	Bridge.storage.delete(in_keys, in_callback)

##
## Render
##
@onready var rendering_method_setting: StringName = ProjectSettings.get_setting_with_override(&"rendering/renderer/rendering_method")
const rendering_method_gl_compatibility : StringName = &"gl_compatibility"

func is_gl_compatibility_rendering_method() -> bool:
	return rendering_method_setting == rendering_method_gl_compatibility

##
## Pause
##
var platform_wants_to_pause_game: bool = false:
	set(in_pause):
		
		platform_wants_to_pause_game = in_pause
		
		if platform_wants_to_pause_game:
			GameGlobals.AddPauseSource(self)
		else:
			GameGlobals.RemovePauseSource(self)
		platform_wants_to_pause_game_changed.emit()
signal platform_wants_to_pause_game_changed()

func _on_web_pause_state_changed(in_is_paused: bool) -> void:
	update_platform_wants_to_pause_game()
	update_platform_wants_to_mute_game()

func update_platform_wants_to_pause_game() -> void:
	if is_web():
		platform_wants_to_pause_game = (Bridge.game.visibility_state == Bridge.VisibilityState.HIDDEN) \
			or (Bridge.advertisement.interstitial_state == Bridge.InterstitialState.OPENED) \
			or (Bridge.advertisement.rewarded_state == Bridge.RewardedState.OPENED)

##
## Audio
##
func _on_web_audio_state_changed(in_is_enabled: bool) -> void:
	print("_on_web_audio_state_changed() in_is_enabled == ", in_is_enabled)
	update_platform_wants_to_mute_game()

var platform_wants_to_mute_game: bool = false:
	set(in_mute):
		if in_mute != platform_wants_to_mute_game:
			platform_wants_to_mute_game = in_mute
			platform_wants_to_mute_game_changed.emit()
signal platform_wants_to_mute_game_changed()

func update_platform_wants_to_mute_game() -> void:
	if is_web():
		platform_wants_to_mute_game = (Bridge.game.visibility_state == Bridge.VisibilityState.HIDDEN) \
			or (Bridge.advertisement.interstitial_state == Bridge.InterstitialState.OPENED) \
			or (Bridge.advertisement.rewarded_state == Bridge.RewardedState.OPENED) \
			or not Bridge.platform.is_audio_enabled

##
## Leaderboards
##
signal leaderboard_set_score_finished(in_success: bool)

func is_in_game_leaderboards_type() -> bool:
	if is_web():
		return Bridge.leaderboards.type == Bridge.LeaderboardType.IN_GAME
	else:
		return false

func request_get_leaderboard_entries(in_leaderboard_id: String, in_get_callback: Callable) -> void:
	if is_web():
		Bridge.leaderboards.get_entries(in_leaderboard_id, in_get_callback)

func request_set_leaderboard_score(in_leaderboard_id: String, in_new_score: int, in_set_callback: Callable = Callable()) -> void:
	if is_web():
		Bridge.leaderboards.set_score(in_leaderboard_id, in_new_score, in_set_callback)

func _on_web_leaderboards_set_score_finished(in_success: bool) -> void:
	print("_on_web_leaderboards_set_score_finished() in_success == %s" % in_success)
	leaderboard_set_score_finished.emit(in_success)

##
## Social
##
@onready var was_rate_requested: bool = false

var is_pending_rate: bool = false
signal rate_finished()

func can_request_rate_game() -> bool:
	return Bridge.social.is_rate_supported \
		and (not was_rate_requested) \
		and (not is_pending_rate) \
		and (Time.get_ticks_msec() > (60000 * 3))

func request_rate_game() -> void:
	
	assert(not is_pending_rate)
	
	if can_request_rate_game():
		
		print("is_pending_rate = true")
		is_pending_rate = true
		
		Bridge.social.rate(_on_rate_game_finished)
		
		if is_pending_rate:
			
			set_process_input(true) ## Fallback finish rate
			
			print("await rate_finished")
			await rate_finished
			
			print("emitted rate_finished")
		else:
			print("immediate rate finish")

func _on_rate_game_finished(in_success: bool) -> void:
	
	print("_on_rate_game_finished() in_success == ", in_success)
	set_process_input(false)
	
	is_pending_rate = false
	was_rate_requested = true
	rate_finished.emit()

##
## Advertisements
##
var interstitial_ad_next_show_time_tick_ms: int = 0

func can_show_interstitial_ad() -> bool:
	
	if is_web():
		if not Bridge.advertisement.is_interstitial_supported:
			return false
	elif is_mobile(false):
		pass
	else:
		return false
	
	if Time.get_ticks_msec() < interstitial_ad_next_show_time_tick_ms:
		return false
	
	return true

func request_show_interstitial_ad() -> void:
	
	print("PlatformGlobals.request_show_interstitial_ad()")
	
	if can_show_interstitial_ad():
		
		if is_web():
			
			print("Bridge.advertisement.show_interstitial()")
			
			Bridge.advertisement.show_interstitial()
			await web_interstitial_finished
			
		elif is_mobile(false):
			
			print("yandex_ads.load_interstitial()")
			
			yandex_ads.load_interstitial()
			await yandex_interstitial_finished
		
		update_interstitial_ad_next_show_time()

func get_interstitial_ad_cooldown_ticks_ms() -> int:
	
	if is_web():
		return ceili(Bridge.advertisement.minimum_delay_between_interstitial * 1000.0)
	else:
		return 60000

func update_interstitial_ad_next_show_time() -> void:
	interstitial_ad_next_show_time_tick_ms = Time.get_ticks_msec() + get_interstitial_ad_cooldown_ticks_ms()

func _on_web_interstitial_ad_state_changed(in_state: String) -> void:
	
	update_platform_wants_to_pause_game()
	update_platform_wants_to_mute_game()
	
	match in_state:
		Bridge.InterstitialState.OPENED:
			web_interstitial_started.emit()
		Bridge.InterstitialState.CLOSED:
			web_interstitial_finished.emit(true)
		Bridge.InterstitialState.FAILED:
			web_interstitial_finished.emit(false)

func _on_web_rewarded_ad_state_changed(in_state: String) -> void:
	update_platform_wants_to_pause_game()
	update_platform_wants_to_mute_game()

#func _on_vk_ads_interstitial_loaded() -> void:
#	print("vk ads interstitial loaded")
#	vk_ads.show_interstitial()
#	vk_interstitial_started.emit()

#func _on_vk_ads_interstitial_failed_to_load(in_error_code) -> void:
#	printerr("vk ads interstitial failed to load! error code is %d" % in_error_code)
#	vk_interstitial_finished.emit(false)

#func _on_vk_ads_interstitial_closed() -> void:
#	vk_interstitial_finished.emit(true)

func _on_yandex_ads_interstitial_loaded() -> void:
	print("yandex ads interstitial loaded")
	yandex_ads.show_interstitial()
	yandex_interstitial_started.emit()

func _on_yandex_ads_interstitial_failed_to_load(in_error_code) -> void:
	printerr("yandex ads interstitial failed to load! error code is %d" % in_error_code)
	yandex_interstitial_finished.emit(false)

func _on_yandex_ads_interstitial_closed() -> void:
	yandex_interstitial_finished.emit(true)

##
## Telemetry
##
@onready var yandex_metrics_counter: int = ProjectSettings.get_setting_with_override(GodotCommonsCore_Settings.YANDEX_METRICS_COUNTER_SETTING_NAME) as int

func is_telemetry_enabled() -> bool:
	return is_yandex_metrics_enabled()

func is_yandex_metrics_enabled() -> bool:
	return is_web() and (yandex_metrics_counter != GodotCommonsCore_Settings.YANDEX_METRICS_COUNTER_SETTING_DISABLED)

func send_telemetry(in_target_name: String, in_params: Dictionary = {}, in_release_only: bool = true) -> bool:
	
	assert(is_telemetry_enabled())
	
	if in_release_only and not is_release():
		return false
	
	if is_yandex_metrics_enabled():
		var eval_js_code := "ym(%d, \"reachGoal\", \"%s\", %s)" % [ yandex_metrics_counter, in_target_name, JSON.stringify(in_params) ]
		print("PlatformGlobals._send_metrics() yandex_metrics: eval_js_code = ", eval_js_code)
		JavaScriptBridge.eval(eval_js_code)
	else:
		assert(false)
	return true
