@tool
extends Resource
class_name ExplosionData2D

@export_category("Init")
@export var scene: PackedScene:
	get:
		if scene:
			return scene
		return load("res://addons/GodotCommons-Core/Scenes/Explosions/Explosion001.tscn")

func custom_init(in_explosion: Explosion2D) -> void:
	pass

@export_category("Priority")
@export var combine_priority: int = 0

@export_category("Impact")
@export var impact_delay: float = 0.1
@export var should_impact_tiles: bool = true
@export var tiles_impact_radius_mul: float = 1.0
@export var tiles_impact_damage_mul: float = 1.0
@export var should_apply_damage: bool = true
@export var damage_type: int = DamageReceiver.DamageType_Explosion
@export var can_ignite_debris: bool = true
@export var impact_sound_event: String = "res://addons/GodotCommons-Core/Assets/Audio/Events/Explosions/Default002.tres"

func load_impact_sound_event() -> SoundEventResource:
	return load(impact_sound_event)

@export_category("Smoke")
@export var smoke_particles_scene: String = "res://addons/GodotCommons-Core/Scenes/Particles/Smoke/Smoke001.tscn"
@export var smoke_particles_scene_web: String = "res://addons/GodotCommons-Core/Scenes/Particles/Smoke/Smoke001_CPU.tscn"
@export var smoke_particles_modulate: Color = Color.WHITE

func load_smoke_particles_scene() -> PackedScene:
	return load(smoke_particles_scene_web if PlatformGlobals.IsWeb() else smoke_particles_scene)

@export_category("Burn")
@export var burn_scene: String = "res://Scenes/Explosions/Burn001.tscn"

func load_burn_scene() -> PackedScene:
	return load(burn_scene)

@export_category("Shake")
@export var shake_strength_scale: float = 1.0
@export var shake_radius_scale: float = 4.0

@export_category("Audio")
@export var sound_bank_label: String = "Explosion"
