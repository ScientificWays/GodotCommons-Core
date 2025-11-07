extends Node
class_name PlatformGlobals_Class

signal web_interstitial_started()
signal web_interstitial_finished(in_success: bool)

#var vk_ads: VkAds

#signal vk_interstitial_started()
#signal vk_interstitial_finished(in_success: bool)

var yandex_ads: YandexAds

signal yandex_interstitial_started()
signal yandex_interstitial_finished(in_success: bool)

func _ready() -> void:
	
	if is_web():
		
		TranslationServer.set_locale(Bridge.platform.language)
		
		Bridge.platform.pause_state_changed.connect(_on_web_pause_state_changed)
		Bridge.advertisement.interstitial_state_changed.connect(_on_web_interstitial_ad_state_changed)
		Bridge.advertisement.rewarded_state_changed.connect(_on_web_rewarded_ad_state_changed)
		
		update_web_is_paused()
		
		update_interstitial_ad_next_show_time()
	
	elif is_mobile(false):
		
		#vk_ads = VkAds.new()
		#vk_ads.interstitial_id = 1913782
		#add_child(vk_ads)
		
		#vk_ads.interstitial_loaded.connect(on_vk_ads_interstitial_loaded)
		#vk_ads.interstitial_failed_to_load.connect(on_vk_ads_interstitial_failed_to_load)
		#vk_ads.interstitial_closed.connect(on_vk_ads_interstitial_closed)
		
		yandex_ads = YandexAds.new()
		yandex_ads.interstitial_id = "R-M-17344604-2"
		add_child(yandex_ads)
		
		yandex_ads.interstitial_loaded.connect(_on_yandex_ads_interstitial_loaded)
		yandex_ads.interstitial_failed_to_load.connect(_on_yandex_ads_interstitial_failed_to_load)
		yandex_ads.interstitial_closed.connect(_on_yandex_ads_interstitial_closed)
		
		update_interstitial_ad_next_show_time()

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

##
## Environment
##
static func has_any_feature(in_features: Array[String]) -> bool:
	return in_features.any(func(feature: String): return OS.has_feature(feature))

static func has_all_features(in_features: Array[String]) -> bool:
	return in_features.all(func(feature: String): return OS.has_feature(feature))

static func is_mobile(InCheckWeb: bool = true) -> bool:
	
	#if DisplayServer.has_feature(DisplayServer.FEATURE_TOUCHSCREEN):
	#	return true
	
	if InCheckWeb and OS.has_feature("web"):
		
		#var UserAgent := JavaScriptBridge.eval("navigator.userAgent;", true) as String
		#UserAgent = UserAgent.to_lower()
		
		#const MobileKeywords := [
		#	"android", "iphone", "ipad", "ipod", "blackberry",
		#	"windows phone", "opera mini", "mobile"
		#]
		#if MobileKeywords.any(func(InKeyWord): return UserAgent.find(InKeyWord) != -1):
		#	return true
		return Bridge.device.type == Bridge.DeviceType.MOBILE
	return OS.has_feature("mobile")

static func is_pc(InCheckWeb: bool = true) -> bool:
	
	if InCheckWeb and OS.has_feature("web"):
		return Bridge.device.type == Bridge.DeviceType.DESKTOP
	return OS.has_feature("pc")

static func is_web() -> bool:
	return OS.has_feature("web")

static func is_release() -> bool:
	return OS.has_feature("release")

static func is_debug() -> bool:
	return OS.has_feature("debug")

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
var web_is_paused: bool = false:
	set(in_is_paused):
		
		web_is_paused = in_is_paused
		
		if web_is_paused:
			GameGlobals.AddPauseSource(self)
		else:
			GameGlobals.RemovePauseSource(self)
		web_is_paused_changed.emit()
signal web_is_paused_changed()

func _on_web_pause_state_changed(in_is_paused: bool) -> void:
	update_web_is_paused()

func update_web_is_paused() -> void:
	web_is_paused = Bridge.game.visibility_state == Bridge.VisibilityState.HIDDEN \
		#or not get_window().has_focus() \
		or Bridge.advertisement.interstitial_state == Bridge.InterstitialState.OPENED \
		or Bridge.advertisement.rewarded_state == Bridge.RewardedState.OPENED

##
## Social
##
var is_pending_rate: bool = false
signal rate_finished()

func can_request_rate_game() -> bool:
	print(Time.get_ticks_msec())
	return Bridge.social.is_rate_supported \
		and (Time.get_ticks_msec() > (60000 * 3)) \
		and (not is_pending_rate)

func request_rate_game() -> void:
	
	assert(not is_pending_rate)
	
	if can_request_rate_game():
		
		print("is_pending_rate = true")
		is_pending_rate = true
		
		Bridge.social.rate(_on_rate_game_finished)
		
		if is_pending_rate:
			print("await rate_finished")
			await rate_finished
			print("emitted rate_finished")
		else:
			print("immediate rate finish")

func _on_rate_game_finished(in_success: bool) -> void:
	
	print("_on_rate_game_finished() in_success == ", in_success)
	
	is_pending_rate = false
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
	
	update_web_is_paused()
	
	match in_state:
		Bridge.InterstitialState.OPENED:
			web_interstitial_started.emit()
		Bridge.InterstitialState.CLOSED:
			web_interstitial_finished.emit(true)
		Bridge.InterstitialState.FAILED:
			web_interstitial_finished.emit(false)

func _on_web_rewarded_ad_state_changed(in_state: String) -> void:
	update_web_is_paused()

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
## Metrics
##
func send_metrics(in_code: int, in_type: String, in_target_name: String, in_release_only: bool = true):
	
	if not is_web():
		return
	
	if in_release_only and not is_release():
		return
	
	#print("PlatformGlobals.send_metrics() code = %d, target_name = %s", [ in_code, in_target_name ])
	
	#var js_window := JavaScriptBridge.get_interface("window")
	#js_window.ym(in_code, in_type, in_target_name)
	
	var eval_js_code := "ym(%d, \"%s\", \"%s\")" % [ in_code, in_type, in_target_name ]
	print("PlatformGlobals.send_metrics() eval_js_code = ", eval_js_code)
	JavaScriptBridge.eval(eval_js_code)
