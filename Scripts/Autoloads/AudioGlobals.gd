extends Node

@export var MusicBusName: StringName = &"Music"
@export var WorldBusName: StringName = &"World"
@export var UIBusName: StringName = &"UI"

var MusicBusIndex: int = -1
var WorldBusIndex: int = -1
var UIBusIndex: int = -1

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
	
	AudioServer.bus_layout_changed.connect(UpdateBusIndices)
	UpdateBusIndices()
	
	if GameGlobals.IsWeb():
		WebMusicPlayer = AudioStreamPlayer.new()
		add_child(WebMusicPlayer)
	
	#SaveGlobals.SettingsProfile_GameVolumeChanged_ConnectAndTryEmit(OnGameVolumeChanged)
	#SaveGlobals.SettingsProfile_MusicVolumeChanged_ConnectAndTryEmit(OnMusicVolumeChanged)
	#SaveGlobals.SettingsProfile_UIVolumeChanged_ConnectAndTryEmit(OnUIVolumeChanged)

func UpdateBusIndices():
	MusicBusIndex = AudioServer.get_bus_index(MusicBusName)
	WorldBusIndex = AudioServer.get_bus_index(WorldBusName)
	UIBusIndex = AudioServer.get_bus_index(UIBusName)

func OnGameVolumeChanged(InValue: float):
	AudioServer.set_bus_volume_db(WorldBusIndex, linear_to_db(InValue))

func OnMusicVolumeChanged(InValue: float):

	var NormalGainPart := minf(InValue, 0.6)
	var ExtraGainPart := InValue - NormalGainPart
	
	var NewVolumeDb := linear_to_db(NormalGainPart / 0.6 + ExtraGainPart / 0.4)
	#print(NewVolumeDb)
	AudioServer.set_bus_volume_db(MusicBusIndex, NewVolumeDb)

func OnUIVolumeChanged(InValue: float):
	AudioServer.set_bus_volume_db(UIBusIndex, linear_to_db(InValue))

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
