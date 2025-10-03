extends Node

@export var MasterBusName: StringName = &"Master"
@export var MusicBusName: StringName = &"Music"
@export var WorldBusName: StringName = &"World"
@export var UIBusName: StringName = &"UI"

var MasterBusIndex: int = -1
var MusicBusIndex: int = -1
var WorldBusIndex: int = -1
var UIBusIndex: int = -1

var music_volume_linear: float = 0.5:
	set(in_volume):
		if music_volume_linear != in_volume:
			music_volume_linear = in_volume
			handle_music_volume_changed()

var game_volume_linear: float = 1.0:
	set(in_volume):
		if game_volume_linear != in_volume:
			game_volume_linear = in_volume
			handle_game_volume_changed()

var ui_volume_linear: float = 1.0:
	set(in_volume):
		if ui_volume_linear != in_volume:
			ui_volume_linear = in_volume
			handle_ui_volume_changed()

signal music_volume_linear_changed()
signal game_volume_linear_changed()
signal ui_volume_linear_changed()

@export var WorldSoundBankName: String = "World"

#var GetCurrentMusicDataCallable: Callable
#func GetCurrentMusicData() -> MoodMusicData:
#	return GetCurrentMusicDataCallable.call()
#signal RequestSetMusicData(InData: MoodMusicData, InRestart: bool)

var GetCurrentMusicMoodCallable: Callable
func GetCurrentMusicMood() -> int:
	return GetCurrentMusicMoodCallable.call()
signal RequestSetMusicMood(InMood: int, InRestart: bool)

var CurrentMusicName: String

var WebMusicPlayer: AudioStreamPlayer

func _ready():
	
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	AudioServer.bus_layout_changed.connect(update_bus_indices)
	update_bus_indices()
	
	if GameGlobals.IsWeb():
		
		WebMusicPlayer = AudioStreamPlayer.new()
		WebMusicPlayer.bus = MusicBusName
		add_child(WebMusicPlayer)
		
		Bridge.game.visibility_state_changed.connect(on_game_visibility_state_changed)
		Bridge.advertisement.interstitial_state_changed.connect(on_advertisement_interstitial_state_changed)
		Bridge.advertisement.rewarded_state_changed.connect(on_advertisement_rewarded_state_changed)
		Bridge.platform.audio_state_changed.connect(on_audio_state_changed)
		
		GameGlobals.web_is_paused_changed.connect(update_web_mute)
		
		update_web_mute()

func update_bus_indices():
	MasterBusIndex = AudioServer.get_bus_index(MasterBusName)
	MusicBusIndex = AudioServer.get_bus_index(MusicBusName)
	WorldBusIndex = AudioServer.get_bus_index(WorldBusName)
	UIBusIndex = AudioServer.get_bus_index(UIBusName)

func on_game_visibility_state_changed(in_state: String) -> void:
	update_web_mute()

func on_advertisement_interstitial_state_changed(in_state: String) -> void:
	update_web_mute()

func on_advertisement_rewarded_state_changed(in_state: String) -> void:
	update_web_mute()

func on_audio_state_changed(in_is_enabled: bool) -> void:
	print("on_audio_state_changed() in_is_enabled == ", in_is_enabled)
	update_web_mute()

var web_mute: bool = false:
	set(in_mute):
		
		web_mute = in_mute
		
		if web_mute:
			AudioServer.set_bus_mute(MasterBusIndex, true)
			#WebMusicPlayer.stream_paused = true
		else:
			AudioServer.set_bus_mute(MasterBusIndex, false)
			#WebMusicPlayer.stream_paused = false

func update_web_mute() -> void:
	web_mute = Bridge.game.visibility_state == Bridge.VisibilityState.HIDDEN \
		#or not get_window().has_focus() \
		or Bridge.advertisement.interstitial_state == Bridge.InterstitialState.OPENED \
		or Bridge.advertisement.rewarded_state == Bridge.RewardedState.OPENED \
		or not Bridge.platform.is_audio_enabled \
		or GameGlobals.web_is_paused

func handle_music_volume_changed():

	#var NormalGainPart := minf(music_volume_linear, 0.6)
	#var ExtraGainPart := music_volume_linear - NormalGainPart
	
	#var NewVolumeDb := linear_to_db(NormalGainPart / 0.6 + ExtraGainPart / 0.4)
	#print(NewVolumeDb)
	#AudioServer.set_bus_volume_db(MusicBusIndex, NewVolumeDb)
	AudioServer.set_bus_volume_db(MusicBusIndex, linear_to_db(music_volume_linear))
	music_volume_linear_changed.emit()

func handle_game_volume_changed():
	AudioServer.set_bus_volume_db(WorldBusIndex, linear_to_db(game_volume_linear))
	game_volume_linear_changed.emit()

func handle_ui_volume_changed():
	AudioServer.set_bus_volume_db(UIBusIndex, linear_to_db(ui_volume_linear))
	ui_volume_linear_changed.emit()

func TryPlaySoundVaried_AtGlobalPosition(InBankLabel: String, InSoundEvent: SoundEventResource, InPosition: Vector2, InPitch: float, InVolume: float) -> bool:
	
	if not SoundManager.has_loaded:
		#await SoundManager.loaded
		return false
	
	if InSoundEvent:
		ResourceGlobals.GetOrCreateSoundBankAndAppendEvent(InBankLabel, InSoundEvent)
		SoundManager.play_at_position_varied(InBankLabel, InSoundEvent.name, InPosition, InPitch, InVolume)
		return true
	else:
		return false

func TryPlaySound_AtGlobalPosition(InBankLabel: String, InSoundEvent: SoundEventResource, InPosition: Vector2) -> bool:
	
	if not SoundManager.has_loaded:
		#await SoundManager.loaded
		return false
	
	if InSoundEvent:
		ResourceGlobals.GetOrCreateSoundBankAndAppendEvent(InBankLabel, InSoundEvent)
		SoundManager.play_at_position(InBankLabel, InSoundEvent.name, InPosition)
		return true
	else:
		return false

func IsAnyMusicPlaying() -> bool:
	
	if GameGlobals.IsWeb():
		return WebMusicPlayer.playing or (web_mute and is_instance_valid(WebMusicPlayer.stream))
	else:
		return MusicManager._is_playing_music()

func IsMusicPlaying(InBankLabel: String, InMusicTrack: MusicTrackResource) -> bool:
	
	if GameGlobals.IsWeb():
		return (WebMusicPlayer.playing or web_mute) and WebMusicPlayer.stream == InMusicTrack.stems[0].stream
	else:
		return MusicManager.is_playing(InBankLabel, InMusicTrack.name)

func GetCurrentMusicName() -> String:
	return CurrentMusicName

func TryPlayMusic(InBankLabel: String, InMusicTrack: MusicTrackResource, InOffset: float = 0.0, InCrossfadeTime: float = 2.0, InAutoLoop: bool = false) -> bool:
	
	if not is_instance_valid(InMusicTrack):
		push_error("AudioGlobals.TryPlayMusic() InMusicTrack is invalid!")
		return false
	
	if GameGlobals.IsWeb():
		WebMusicPlayer.stream = InMusicTrack.stems[0].stream
		WebMusicPlayer.volume_db = InMusicTrack.stems[0].volume
		WebMusicPlayer.play()
	else:
		
		if not MusicManager.has_loaded:
			await MusicManager.loaded
			#return false
		
		ResourceGlobals.GetOrCreateMusicBankAndAppendEvent(InBankLabel, InMusicTrack)
		MusicManager.play(InBankLabel, InMusicTrack.name, InOffset, InCrossfadeTime, InAutoLoop)
	CurrentMusicName = InMusicTrack.name
	return true

func TryStopMusic(InCrossfadeTime: float = 2.0) -> bool:
	
	if GameGlobals.IsWeb():
		if WebMusicPlayer.playing:
			WebMusicPlayer.stop()
			CurrentMusicName = ""
			return true
	else:
		if MusicManager._is_playing_music():
			MusicManager.stop(InCrossfadeTime)
			CurrentMusicName = ""
			return true
	push_warning("AudioGlobals.TryStopMusic() No music is playing!")
	return false
