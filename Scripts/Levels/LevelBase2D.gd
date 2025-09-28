extends Node2D
class_name LevelBase2D

@export_category("Game Mode")
@export var DefaultGameMode: GameModeData
@export var DefaultGameModeArgs: Dictionary

@export_category("Players")
@export var DefaultPlayerSpawn: Node2D
@export var RespawnAllPlayersOnBeginPlay: bool = true

@export_category("Music")
@export var LevelMusicBankLabel: String = "Music"
@export var LevelMusic: MusicTrackResource
@export var StartLevelMusicOnBeginPlay: bool = true
@export var StopLevelMusicOnEndPlay: bool = true

@export_category("Hints")
@export var TriggerTutorialHints: bool = false

#const ForceMoodMeta: StringName = &"ForceMood"

const WorldBankLabel: String = "World"
#const MusicBankLabel: String = "Music"

var _YSorted: Node2D

@export var _CanvasModulate: CanvasModulate

#signal CreatureSpawned(InCreature: Creature)
#signal BossCreatureSpawned(InCreature: Creature)

#signal CreatureDied(InCreature: Creature)
#signal BossCreatureDied(InCreature: Creature)

#signal StageBossDefeated(InBossCreature: Creature)
#signal ChapterBossDefeated(InBossCreature: Creature)

#signal CreatureRelevantDetectedTargetChanged(InCreature: Creature, InOldTarget: Node2D, InNewTarget: Node2D)

func _ready() -> void:
	
	_YSorted = Node2D.new()
	_YSorted.y_sort_enabled = true
	add_child(_YSorted)
	move_child(_YSorted, 0)
	
	if not UIGlobals.pause_menu_ui:
		await UIGlobals.pause_menu_ui_created
	UIGlobals.pause_menu_ui.can_be_enabled = true
	UIGlobals.pause_menu_ui.skip_lerp_visible()
	
	_sync_with_game_state()
	WorldGlobals._game_state.handle_level_ready()
	
	print(WorldGlobals._game_state._game_args)

func _enter_tree() -> void:
	WorldGlobals._level = self

func _exit_tree() -> void:
	WorldGlobals._level = null

func _sync_with_game_state() -> void:
	
	if WorldGlobals._game_state:
		pass
	else:
		var new_game_seed := 2729052680
		#var new_game_seed := randi()
		
		assert(DefaultGameMode)
		WorldGlobals._game_state = DefaultGameMode.init_new_game_state(new_game_seed, DefaultGameModeArgs)
	
	assert(WorldGlobals._game_state)
	WorldGlobals._game_state.on_begin_play.connect(handle_begin_play)
	WorldGlobals._game_state.on_end_play.connect(handle_end_play)

func handle_begin_play() -> void:
	
	if RespawnAllPlayersOnBeginPlay:
		PlayerGlobals.RespawnAllPlayers()
	
	if StartLevelMusicOnBeginPlay and not AudioGlobals.IsMusicPlaying(LevelMusicBankLabel, LevelMusic):
		AudioGlobals.TryPlayMusic(LevelMusicBankLabel, LevelMusic)
	
	#_LevelTileMap.UpdateUnbreakableCells()
	#_LevelTileMap.InitNavigation()
	
	Bridge.platform.send_message(Bridge.PlatformMessage.GAMEPLAY_STARTED)

func handle_end_play() -> void:
	
	if StopLevelMusicOnEndPlay and MusicManager._is_playing_music():
		MusicManager.stop(1.0)
	
	Bridge.platform.send_message(Bridge.PlatformMessage.GAMEPLAY_STOPPED)

func get_player_spawn_position(in_player: PlayerController) -> Vector2:
	return DefaultPlayerSpawn.global_position if DefaultPlayerSpawn else Vector2.ZERO
