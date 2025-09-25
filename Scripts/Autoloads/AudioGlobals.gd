extends Node

@export var MasterBusName: StringName = &"Master"
@export var MusicBusName: StringName = &"Music"
@export var WorldBusName: StringName = &"World"
@export var UIBusName: StringName = &"UI"

var MasterBusIndex: int = -1
var MusicBusIndex: int = -1
var WorldBusIndex: int = -1
var UIBusIndex: int = -1

var music_volume_linear: float = 1.0:
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
	
	Bridge.game.connect("visibility_state_changed", UpdateVisibilityStateMute)
	
	AudioServer.bus_layout_changed.connect(UpdateBusIndices)
	UpdateBusIndices()
	
	if GameGlobals.IsWeb():
		WebMusicPlayer = AudioStreamPlayer.new()
		WebMusicPlayer.bus = MusicBusName
		add_child(WebMusicPlayer)
	
	#SaveGlobals.SettingsProfile_GameVolumeChanged_ConnectAndTryEmit(OnGameVolumeChanged)
	#SaveGlobals.SettingsProfile_MusicVolumeChanged_ConnectAndTryEmit(OnMusicVolumeChanged)
	#SaveGlobals.SettingsProfile_UIVolumeChanged_ConnectAndTryEmit(OnUIVolumeChanged)

#func _notification(InCode: int) -> void:
#	
#	if InCode == NOTIFICATION_WM_WINDOW_FOCUS_IN \
#	or InCode == NOTIFICATION_APPLICATION_FOCUS_IN \
#	or InCode == NOTIFICATION_APPLICATION_RESUMED:
#		AudioServer.set_bus_mute(MasterBusIndex, false)
#	elif InCode == NOTIFICATION_WM_WINDOW_FOCUS_OUT \
#	or InCode == NOTIFICATION_APPLICATION_FOCUS_OUT \
#	or InCode == NOTIFICATION_APPLICATION_PAUSED:
#		AudioServer.set_bus_mute(MasterBusIndex, true)

func UpdateVisibilityStateMute(InState) -> void:
	
	if InState == "hidden" \
	#or not get_window().has_focus() \
	or YandexSDK.is_ad_on_screen \
	or YandexSDK.is_rewarded_ad_on_screen:
		AudioServer.set_bus_mute(MasterBusIndex, true)
		WebMusicPlayer.stream_paused = true
	else:
		AudioServer.set_bus_mute(MasterBusIndex, false)
		WebMusicPlayer.stream_paused = false

func UpdateBusIndices():
	MasterBusIndex = AudioServer.get_bus_index(MasterBusName)
	MusicBusIndex = AudioServer.get_bus_index(MusicBusName)
	WorldBusIndex = AudioServer.get_bus_index(WorldBusName)
	UIBusIndex = AudioServer.get_bus_index(UIBusName)

func handle_music_volume_changed():

	var NormalGainPart := minf(music_volume_linear, 0.6)
	var ExtraGainPart := music_volume_linear - NormalGainPart
	
	var NewVolumeDb := linear_to_db(NormalGainPart / 0.6 + ExtraGainPart / 0.4)
	#print(NewVolumeDb)
	AudioServer.set_bus_volume_db(MusicBusIndex, NewVolumeDb)
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
		return WebMusicPlayer.playing
	else:
		return MusicManager._is_playing_music()

func IsMusicPlaying(InBankLabel: String, InMusicTrack: MusicTrackResource) -> bool:
	
	if GameGlobals.IsWeb():
		return WebMusicPlayer.playing and WebMusicPlayer.stream == InMusicTrack.stems[0].stream
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
