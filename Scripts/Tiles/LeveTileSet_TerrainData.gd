extends Resource
class_name LeveTileSet_TerrainData

@export_category("Health")
@export var Health: float = 50.0
@export var IsUnbreakable: bool = false

@export_category("Ignite")
@export var CanIgnite: bool = false
@export var IgniteDamageThreshold: float = 20.0
@export var IgniteDamageProbabilityMul: float = 0.4
@export var IgniteDamageToBreakProbabilityMul: float = 0.02
@export var PostIgniteTerrainName: StringName = &"Floor: Dirt"

@export_category("Physics")
@export var CanFall: bool = false
@export var GibsScene: PackedScene
