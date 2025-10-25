@tool
extends TileMapLayer
class_name LevelTileMapLayer

const InvalidCell: Vector2i = Vector2i.MAX

@export var terrain_data_array: Array[LevelTileSet_TerrainData]
@export_tool_button("Try Regenerate TileSet") var try_regenerate_tile_set_action: Callable = try_regenerate_tile_set
@export var generated_tile_set_script: GDScript = preload("res://addons/GodotCommons-Core/Scripts/Tiles/TileSets/LevelTileSet_AutoWalls.gd")

@export_flags_2d_physics var TilePlaceBlockCollisionMask: int = 1 + 2 + 8 + 16 + 128

#var TilePlaceCheckOffsets: Array[Vector2] = [
#	Vector2(0.0, 0.0),
#	Vector2(6.0, 6.0),
#	Vector2(-6.0, 6.0),
#	Vector2(6.0, -6.0),
#	Vector2(-6.0, -6.0)
#]

@export var floor_layer: LevelTileMapLayer
@export var damage_layer: LevelTileMapLayer_Damage

@export var TilePlaceCheckShape: Shape2D

var level_tile_set: LevelTileSet_Auto_Base:
	get(): return tile_set

signal regenerated_tile_set()

class TilePlaceData:
	var Cell: Vector2i
	var Terrain_id: int
	var ShouldCheckOcclusionByTile: bool
	var ShouldCheckOcclusionByPhysicsQuery: bool

var PendingTilePlaceArray: Array[TilePlaceData]
@onready var PendingTilePlaceArrayMutex: Mutex = Mutex.new()

@export var FloorIgniteFXScene: PackedScene = preload("res://addons/GodotCommons-Core/Scenes/Particles/Fire/Fire002_TileIgnite.tscn")

signal ImpactApplied(in_cell: Vector2i)

func _ready():
	
	if Engine.is_editor_hint():
		if not floor_layer:
			floor_layer = get_parent().find_child("*?loor*")
		if not damage_layer:
			damage_layer = find_child("*?amage*")
	
	try_regenerate_tile_set()

func _enter_tree() -> void:
	if not Engine.is_editor_hint():
		GameGlobals.pre_explosion_impact.connect(HandleExplosionImpact)
		GameGlobals.PostBarrelRamImpact.connect(HandleBarrelRamImpact)

func _exit_tree() -> void:
	if not Engine.is_editor_hint():
		GameGlobals.pre_explosion_impact.disconnect(HandleExplosionImpact)
		GameGlobals.PostBarrelRamImpact.disconnect(HandleBarrelRamImpact)

func _physics_process(in_delta: float):
	if PendingTilePlaceArray.is_empty():
		set_physics_process(false)
	else:
		ProcessPendingTileArray(in_delta)

var hidden_generated_tile_set: TileSet

func _notification(in_what: int) -> void:
	
	## Easiest fix for emit_signalp: Can't emit non-existing signal "changed"
	if in_what == NOTIFICATION_PREDELETE:
		tile_set = null
	elif in_what == NOTIFICATION_EDITOR_PRE_SAVE:
		if is_using_generated_tile_set():
			hidden_generated_tile_set = tile_set
			tile_set = null
	elif in_what == NOTIFICATION_EDITOR_POST_SAVE:
		if is_using_generated_tile_set():
			tile_set = hidden_generated_tile_set
			hidden_generated_tile_set = null

func is_using_generated_tile_set() -> bool:
	return not terrain_data_array.is_empty()

func try_regenerate_tile_set() -> bool:
	
	if is_using_generated_tile_set():
		assert(generated_tile_set_script)
		if generated_tile_set_script:
			tile_set = generated_tile_set_script.new(terrain_data_array)
			print("Generated tile_set for ", self)
			regenerated_tile_set.emit()
			return true
	return false

func HandleExplosionImpact(InImpact: Explosion2D_Impact):
	
	var owner_explosion := InImpact.owner_explosion
	
	var CenterCell := local_to_map(owner_explosion.global_position)
	var ImpactedCells: Array[Vector2i] = []
	
	var RadiusTiles := ceili((owner_explosion._radius * owner_explosion.data.tiles_impact_radius_mul) / float(tile_set.tile_size.x))
	
	ForEachTileInRadius(CenterCell, RadiusTiles, func(in_cell: Vector2i):
	
		#if randf() < ((in_cell.x - 1) / float(RadiusTiles)) + ((in_cell.x - 1) / float(RadiusTiles)):
		#	continue
		
		var WasImpacted := false
		
		var OffsetCell := in_cell - CenterCell
		var OffsetCellFloat := Vector2(OffsetCell.x, OffsetCell.y)
		
		var DistanceCells := OffsetCellFloat.length()
		var DistanceMul := 1.0 - minf(DistanceCells / RadiusTiles, 1.0)
		
		if DistanceMul > 0.0:
			var ImpulseDirection := OffsetCellFloat / DistanceCells
			var TargetImpulse := ImpulseDirection * owner_explosion._max_impulse * DistanceMul
			WasImpacted = TryImpactCell(in_cell, owner_explosion._max_damage * owner_explosion.data.tiles_impact_damage_mul * DistanceMul, TargetImpulse, owner_explosion.data.can_ignite_debris, false)
		if WasImpacted:
			ImpactedCells.append(in_cell)
	)
	if not ImpactedCells.is_empty():
		BetterTerrain.update_terrain_cells(self, ImpactedCells)
		WorldGlobals._level.request_nav_update()

func HandleBarrelRamImpact(InBarrelRoll: BarrelPawn2D_Roll):
	
	var ImpactData := InBarrelRoll.LastRamImpactData
	
	if ImpactData.Target != self:
		return
	
	if ImpactData.ImpulseMul > 0.0 and ImpactData.RamDamage > 5.0:
		var TargetCell := local_to_map(to_local(ImpactData.LocalPosition - ImpactData.LocalNormal))
		TryImpactCell(TargetCell, ImpactData.RamDamage * ImpactData.ImpulseMul, ImpactData.linear_velocity * InBarrelRoll.OwnerBody.mass)

func has_cell(in_cell: Vector2i) -> bool:
	return BetterTerrain.get_cell(self, in_cell) >= 0

func get_cell_terrain_data(in_cell: Vector2i) -> LevelTileSet_TerrainData:
	assert(has_cell(in_cell))
	return level_tile_set.get_terrain_data(BetterTerrain.get_cell(self, in_cell))

func TryImpactCell(in_cell: Vector2i, in_damage: float, in_impulse: Vector2 = Vector2.ZERO, in_can_ignite: bool = false, in_should_update_terrain_and_navigation: bool = true) -> bool:
	
	var OutImpacted := false
	
	if not has_cell(in_cell):
		return OutImpacted
	
	var cell_terrain_data := get_cell_terrain_data(in_cell)
	var should_ignite := in_can_ignite \
		and in_damage >= cell_terrain_data.ignite_damage_threshold \
		and cell_terrain_data.ignite_damage_probability_mul >= randf()
	
	if not cell_terrain_data.is_unbreakable:
		
		var CellHealthData := damage_layer.get_cell_data(in_cell)
		
		if CellHealthData.health > in_damage:
			UtilHandleCellDamage(in_cell, in_damage, in_impulse)
		else:
			UtilHandleCellBreak(in_cell, in_impulse, should_ignite, in_should_update_terrain_and_navigation)
		OutImpacted = true
	
	if has_cell(in_cell):
		
		if cell_terrain_data.can_ignite and should_ignite:
			
			var BreakProbability := in_damage * cell_terrain_data.ignite_damage_to_break_probability_mul
			
			if BreakProbability >= randf():
				UtilHandleCellPostIgnite(in_cell)
				OutImpacted = true
			else:
				UtilHandleCellIgnite(in_cell)
				OutImpacted = true
	if OutImpacted:
		ImpactApplied.emit(in_cell)
	return OutImpacted

func TryBreakCell(in_cell: Vector2i, in_impulse: Vector2 = Vector2.ZERO, in_can_ignite: bool = false, in_should_update_terrain_and_navigation: bool = true) -> bool:
	return TryImpactCell(in_cell, INF, in_impulse, in_can_ignite, in_should_update_terrain_and_navigation)

func UtilHandleCellDamage(in_cell: Vector2i, in_damage: float, in_impulse: Vector2):
	damage_layer.SubtractCellHealth(in_cell, in_damage)

var MarkedToFallWallCellWeights: Dictionary = {}

func UtilHandleCellBreak(in_cell: Vector2i, in_impulse: Vector2, in_should_ignite: bool, in_should_update_terrain_and_navigation: bool) -> void:
	
	var cell_terrain_data := get_cell_terrain_data(in_cell)
	
	for sample_neighbor: Vector2i in TileGlobals.GenerateNeighborCellArray(in_cell):
		
		if not has_cell(sample_neighbor):
			continue
		
		var NeighborTerrainData := get_cell_terrain_data(sample_neighbor)
		
		if cell_terrain_data.can_fall and NeighborTerrainData.can_fall and not MarkedToFallWallCellWeights.has(sample_neighbor):
			
			var FallProbability := MarkedToFallWallCellWeights.get(in_cell, 0.8) as float
			if randf() < FallProbability:
				MarkedToFallWallCellWeights[sample_neighbor] = FallProbability * 0.2
				GameGlobals.spawn_one_shot_timer_for(self, util_handle_cell_fall.bind(sample_neighbor, in_impulse), 0.1)
		
		#var SampleNeighborFloorTerrain := BetterTerrain.get_cell(self, sample_neighbor)
		
		#if SampleNeighborWallTerrain != BetterTerrain.TileCategory.EMPTY and SampleNeighborFloorTerrain == BetterTerrain.TileCategory.EMPTY:
		#	BetterTerrain.set_cell(self, sample_neighbor, NeighborTerrainData.FallTerrainName))
	
	if floor_layer:
		BetterTerrain.set_cell.call_deferred(floor_layer, in_cell, floor_layer.level_tile_set.get_terrain_id(cell_terrain_data.post_break_floor_terrain_name))
	
	if MarkedToFallWallCellWeights.has(in_cell):
		MarkedToFallWallCellWeights.erase(in_cell)
	
	damage_layer.ClearCellData(in_cell)
	erase_cell(in_cell)
	
	if in_should_update_terrain_and_navigation:
		BetterTerrain.update_terrain_cell(self, in_cell)
		WorldGlobals._level.request_nav_update()
	
	if cell_terrain_data.gibs_scene:
		
		var gibs_position := map_to_local(in_cell)
		
		if cell_terrain_data.is_gibs_template:
			GibsTemplate2D.spawn(gibs_position, cell_terrain_data.gibs_scene, -in_impulse, in_should_ignite, 0.5)
		else:
			var new_gib := Gib2D.spawn(gibs_position, cell_terrain_data.gibs_scene)
			new_gib.ready.connect(new_gib.apply_central_impulse.bind(-in_impulse.rotated(randf_range(-0.5, 0.5))), CONNECT_DEFERRED)
			if in_should_ignite and new_gib.ignite_probability > 0.0:
				GameGlobals.ignite_target(new_gib, randf_range(1.0, 5.0))

func util_handle_cell_fall(in_cell: Vector2i, in_break_impulse: Vector2) -> void:
	
	if not has_cell(in_cell):
		return
	
	UtilHandleCellBreak(in_cell, in_break_impulse, false, true)


func UtilHandleCellIgnite(in_cell: Vector2i):
	
	var IgniteParticles := FloorIgniteFXScene.instantiate()
	IgniteParticles.position = map_to_local(in_cell)
	add_child(IgniteParticles)
	
	var IgniteParticlesPivot := IgniteParticles.get_node("ParticlesPivot")
	IgniteParticlesPivot.SetExpireTime(randf_range(5.0, 10.0))
	IgniteParticlesPivot.Expired.connect(OnCellIgniteExpired.bind(IgniteParticles, in_cell))

func OnCellIgniteExpired(InIgniteParticles: Node, in_cell: Vector2i):
	InIgniteParticles.queue_free()
	UtilHandleCellPostIgnite(in_cell)

func UtilHandleCellPostIgnite(in_cell: Vector2i):
	var cell_terrain_data := get_cell_terrain_data(in_cell)
	BetterTerrain.set_cell(self, in_cell, level_tile_set.get_terrain_id(cell_terrain_data.post_ignite_terrain_name))

func AddPendingTilePlace(in_cell: Vector2i, InTerrainName: String, InShouldCheckOcclusionByTile: bool, InShouldCheckOcclusionByPhysicsQuery: bool):
	
	var NewPendingData := TilePlaceData.new()
	NewPendingData.Cell = in_cell
	NewPendingData.Terrain_id = level_tile_set.get_terrain_id(InTerrainName)
	NewPendingData.ShouldCheckOcclusionByTile = InShouldCheckOcclusionByTile
	NewPendingData.ShouldCheckOcclusionByPhysicsQuery = InShouldCheckOcclusionByPhysicsQuery
	
	PendingTilePlaceArrayMutex.lock()
	PendingTilePlaceArray.append(NewPendingData)
	PendingTilePlaceArrayMutex.unlock()
	
	if not is_physics_processing():
		set_physics_process(true)

func ProcessPendingTileArray(in_delta: float):
	
	PendingTilePlaceArrayMutex.lock()
	for SampleData: TilePlaceData in PendingTilePlaceArray:
		
		if SampleData.ShouldCheckOcclusionByTile:
			if has_cell(SampleData.Cell):
				continue
		
		if SampleData.ShouldCheckOcclusionByPhysicsQuery:
			var SpaceState := get_world_2d().direct_space_state
			var PointQuery := PhysicsShapeQueryParameters2D.new()
			PointQuery.collision_mask = TilePlaceBlockCollisionMask
			PointQuery.shape = TilePlaceCheckShape
			var CheckCenter := map_to_local(SampleData.Cell)
			#for SampleCheckOffset: Vector2 in TilePlaceCheckOffsets:
			#	PointQuery.position = CheckCenter + SampleCheckOffset
			#	var Results = SpaceState.intersect_point(PointQuery, 1)
			#	if not Results.is_empty():
			#		return false
			PointQuery.transform.origin = CheckCenter
			var Results = SpaceState.intersect_shape(PointQuery, 1)
			if not Results.is_empty():
				continue
		BetterTerrain.set_cell(self, SampleData.Cell, SampleData.Terrain_id)
		BetterTerrain.update_terrain_cell(self, SampleData.Cell)
	PendingTilePlaceArray.clear()
	PendingTilePlaceArrayMutex.unlock()

func ForEachTileInRadius(InCenterCell: Vector2i, in_radius: int, in_callable: Callable):
	
	for y: int in range(-in_radius, in_radius + 1):
		var CurrentHalfWidth: int = (in_radius - abs(y)) + 1
		for x: int in range(-CurrentHalfWidth, CurrentHalfWidth):
			in_callable.call(InCenterCell + Vector2i(x, y))
