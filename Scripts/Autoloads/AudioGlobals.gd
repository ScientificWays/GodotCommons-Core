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

func _ready():
	
	AudioServer.bus_layout_changed.connect(UpdateBusIndices)
	UpdateBusIndices()
	
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

func IsMusicPlaying(InBankLabel: String, InMusicTrack: MusicTrackResource) -> bool:
	return MusicManager.is_playing(InBankLabel, InMusicTrack.name)

func TryPlayMusic(InBankLabel: String, InMusicTrack: MusicTrackResource, InOffset: float = 0.0, InCrossfadeTime: float = 5.0, InAutoLoop: bool = false) -> bool:
	
	if not MusicManager.has_loaded:
		await MusicManager.loaded
		#return false
	
	if InMusicTrack:
		ResourceGlobals.GetOrCreateMusicBankAndAppendEvent(InBankLabel, InMusicTrack)
		MusicManager.play(InBankLabel, InMusicTrack.name, InOffset, InCrossfadeTime, InAutoLoop)
		return true
	else:
		return false
