extends TileMapLayer
class_name LevelTileMapLayer

const InvalidCell: Vector2i = Vector2i.MAX

@export_flags_2d_physics var TilePlaceBlockCollisionMask: int = 1 + 2 + 8 + 16 + 128

#var TilePlaceCheckOffsets: Array[Vector2] = [
#	Vector2(0.0, 0.0),
#	Vector2(6.0, 6.0),
#	Vector2(-6.0, 6.0),
#	Vector2(6.0, -6.0),
#	Vector2(-6.0, -6.0)
#]

@export var DamageLayer: LevelTileMapLayer_Damage
@export var LayerNavRegion: LevelNavigationRegion2D
@export var TilePlaceCheckShape: Shape2D

@onready var _LevelTileSet: LevelTileSet = tile_set

class TilePlaceData:
	var Cell: Vector2i
	var TerrainID: int
	var ShouldCheckOcclusionByTile: bool
	var ShouldCheckOcclusionByPhysicsQuery: bool

var PendingTilePlaceArray: Array[TilePlaceData]
@onready var PendingTilePlaceArrayMutex: Mutex = Mutex.new()

@export var FloorIgniteParticlesScene: PackedScene = preload("res://addons/GodotCommons-Core/Assets/Particles/Fire/Fire002_TileIgnite.tscn")

signal ImpactApplied(InCell: Vector2i)

func _ready():
	pass

func _enter_tree() -> void:
	GameGlobals.PreExplosionImpact.connect(HandleExplosionImpact)
	GameGlobals.PostBarrelRamImpact.connect(HandleBarrelRamImpact)

func _exit_tree() -> void:
	GameGlobals.PreExplosionImpact.disconnect(HandleExplosionImpact)
	GameGlobals.PostBarrelRamImpact.disconnect(HandleBarrelRamImpact)

func _notification(in_what: int) -> void:
	
	## Easiest fix for emit_signalp: Can't emit non-existing signal "changed"
	if in_what == NOTIFICATION_PREDELETE:
		tile_set = null

func _physics_process(InDelta: float):
	if PendingTilePlaceArray.is_empty():
		set_physics_process(false)
	else:
		ProcessPendingTileArray(InDelta)

func InitNavigation():
	
	var LevelRect := get_used_rect()
	var TileSizeVectorFloat := tile_set.tile_size as Vector2
	
	if LayerNavRegion:
		
		LayerNavRegion.navigation_polygon.clear()
		LayerNavRegion.navigation_polygon.add_outline([
			Vector2(LevelRect.position) * TileSizeVectorFloat,
			Vector2(LevelRect.position.x, LevelRect.end.y) * TileSizeVectorFloat,
			Vector2(LevelRect.end) * TileSizeVectorFloat,
			Vector2(LevelRect.end.x, LevelRect.position.y) * TileSizeVectorFloat
		])
	
	#RequestNavigationUpdate(false)
	RequestNavigationUpdate()
	
	await get_tree().create_timer(1.0).timeout
	
	## Update this only once
	#_UnbreakableNavRegion.bake_navigation_polygon()

func RequestNavigationUpdate(IsOnThread: bool = true):
	
	if LayerNavRegion:
		if IsOnThread:
			LayerNavRegion.RequestUpdate()
		else:
			LayerNavRegion.bake_navigation_polygon(false)

func HandleExplosionImpact(InImpact: Explosion2D_Impact):
	
	var Explosion := InImpact.OwnerExplosion
	
	var CenterCell := local_to_map(Explosion.global_position)
	var ImpactedCells: Array[Vector2i] = []
	
	var RadiusTiles := ceili((Explosion._Radius * InImpact._TilesImpactRadiusMul) / float(tile_set.tile_size.x))
	
	ForEachTileInRadius(CenterCell, RadiusTiles, func(InCell: Vector2i):
	
		#if randf() < ((InCell.x - 1) / float(RadiusTiles)) + ((InCell.x - 1) / float(RadiusTiles)):
		#	continue
		
		var WasImpacted := false
		
		var OffsetCell := InCell - CenterCell
		var OffsetCellFloat := Vector2(OffsetCell.x, OffsetCell.y)
		
		var DistanceCells := OffsetCellFloat.length()
		var DistanceMul := 1.0 - minf(DistanceCells / RadiusTiles, 1.0)
		
		if DistanceMul > 0.0:
			var ImpulseDirection := OffsetCellFloat / DistanceCells
			var TargetImpulse := ImpulseDirection * Explosion._MaxImpulse * DistanceMul
			WasImpacted = TryImpactCell(InCell, Explosion._MaxDamage * InImpact._TilesImpactDamageMul * DistanceMul, TargetImpulse, InImpact._CanIgniteDebris, false)
		if WasImpacted:
			ImpactedCells.append(InCell)
	)
	if not ImpactedCells.is_empty():
		BetterTerrain.update_terrain_cells(self, ImpactedCells)
		RequestNavigationUpdate()

func HandleBarrelRamImpact(InBarrelRoll: BarrelPawn2D_Roll):
	
	var ImpactData := InBarrelRoll.LastRamImpactData
	
	if ImpactData.Target != self:
		return
	
	if ImpactData.ImpulseMul > 0.0 and ImpactData.RamDamage > 5.0:
		var TargetCell := local_to_map(to_local(ImpactData.LocalPosition - ImpactData.LocalNormal))
		TryImpactCell(TargetCell, ImpactData.RamDamage * ImpactData.ImpulseMul, ImpactData.LinearVelocity * InBarrelRoll.OwnerBody.mass)

func HasCell(InCell: Vector2i) -> bool:
	return BetterTerrain.get_cell(self, InCell) >= 0

func GetCellTerrainData(InCell: Vector2i) -> LeveTileSet_TerrainData:
	assert(HasCell(InCell))
	return _LevelTileSet.GetTerrainData(BetterTerrain.get_cell(self, InCell))

func TryImpactCell(InCell: Vector2i, InDamage: float, InImpulse: Vector2 = Vector2.ZERO, InCanIgnite: bool = false, InShouldUpdateTerrainAndNavigation: bool = true) -> bool:
	
	var OutImpacted := false
	
	if not HasCell(InCell):
		return OutImpacted
	
	var CellTerrainData := GetCellTerrainData(InCell)
	
	if not CellTerrainData.IsUnbreakable:
		
		var CellHealthData := DamageLayer.GetCellData(InCell)
		
		if CellHealthData.Health > InDamage:
			UtilHandleCellDamage(InCell, InDamage, InImpulse)
		else:
			UtilHandleCellBreak(InCell, InImpulse, InCanIgnite, InShouldUpdateTerrainAndNavigation)
		OutImpacted = true
	
	if HasCell(InCell):
		
		if InCanIgnite \
		and CellTerrainData.CanIgnite \
		and (InDamage >= CellTerrainData.IgniteDamageThreshold) \
		and (CellTerrainData.IgniteDamageProbabilityMul >= randf()):
			
			var BreakProbability := InDamage * CellTerrainData.IgniteDamageToBreakProbabilityMul
			
			if BreakProbability >= randf():
				UtilHandleCellPostIgnite(InCell)
				OutImpacted = true
			else:
				UtilHandleCellIgnite(InCell)
				OutImpacted = true
	if OutImpacted:
		ImpactApplied.emit(InCell)
	return OutImpacted

func TryBreakCell(InCell: Vector2i, InImpulse: Vector2 = Vector2.ZERO, InCanIgnite: bool = false, InShouldUpdateTerrainAndNavigation: bool = true) -> bool:
	return TryImpactCell(InCell, INF, InImpulse, InCanIgnite, InShouldUpdateTerrainAndNavigation)

func UtilHandleCellDamage(InCell: Vector2i, InDamage: float, InImpulse: Vector2):
	DamageLayer.SubtractCellHealth(InCell, InDamage)

var MarkedToFallWallCellWeights: Dictionary = {}

func UtilHandleCellBreak(InCell: Vector2i, InImpulse: Vector2, InCanIgniteDebris: bool, InShouldUpdateTerrainAndNavigation: bool):
	
	var CellTerrainData := GetCellTerrainData(InCell)
	
	for SampleNeighbor: Vector2i in TileGlobals.GenerateNeighborCellArray(InCell):
		
		if not HasCell(SampleNeighbor):
			continue
		
		var NeighborTerrainData := GetCellTerrainData(SampleNeighbor)
		
		if CellTerrainData.CanFall and NeighborTerrainData.CanFall and not MarkedToFallWallCellWeights.has(SampleNeighbor):
			
			var FallProbability := MarkedToFallWallCellWeights.get(InCell, 0.8) as float
			if randf() < FallProbability:
				MarkedToFallWallCellWeights[SampleNeighbor] = FallProbability * 0.2
				GameGlobals.SpawnOneShotTimerFor(self, UtilHandleCellBreak.bind(SampleNeighbor, InImpulse, false, true), 0.1)
		
		#var SampleNeighborFloorTerrain := BetterTerrain.get_cell(self, SampleNeighbor)
		
		#if SampleNeighborWallTerrain != BetterTerrain.TileCategory.EMPTY and SampleNeighborFloorTerrain == BetterTerrain.TileCategory.EMPTY:
		#	BetterTerrain.set_cell(self, SampleNeighbor, NeighborTerrainData.FallTerrainName))
	
	DamageLayer.ClearCellData(InCell)
	erase_cell(InCell)
	
	if InShouldUpdateTerrainAndNavigation:
		BetterTerrain.update_terrain_cell(self, InCell)
		RequestNavigationUpdate()
	
	if MarkedToFallWallCellWeights.has(InCell):
		MarkedToFallWallCellWeights.erase(InCell)
	
	if CellTerrainData.GibsScene:
		GibsTemplate2D.Spawn(map_to_local(InCell), CellTerrainData.GibsScene, InImpulse, InCanIgniteDebris, 0.5)

func UtilHandleCellIgnite(InCell: Vector2i):
	
	var IgniteParticles := FloorIgniteParticlesScene.instantiate()
	IgniteParticles.position = map_to_local(InCell)
	add_child(IgniteParticles)
	
	var IgniteParticlesPivot := IgniteParticles.get_node("ParticlesPivot")
	IgniteParticlesPivot.SetExpireTime(randf_range(5.0, 10.0))
	IgniteParticlesPivot.Expired.connect(OnCellIgniteExpired.bind(IgniteParticles, InCell))

func OnCellIgniteExpired(InIgniteParticles: Node, InCell: Vector2i):
	InIgniteParticles.queue_free()
	UtilHandleCellPostIgnite(InCell)

func UtilHandleCellPostIgnite(InCell: Vector2i):
	var CellTerrainData := GetCellTerrainData(InCell)
	BetterTerrain.set_cell(self, InCell, _LevelTileSet.GetTerrainID(CellTerrainData.PostIgniteTerrainName))

func AddPendingTilePlace(InCell: Vector2i, InTerrainName: String, InShouldCheckOcclusionByTile: bool, InShouldCheckOcclusionByPhysicsQuery: bool):
	
	var NewPendingData := TilePlaceData.new()
	NewPendingData.Cell = InCell
	NewPendingData.TerrainID = _LevelTileSet.GetTerrainID(InTerrainName)
	NewPendingData.ShouldCheckOcclusionByTile = InShouldCheckOcclusionByTile
	NewPendingData.ShouldCheckOcclusionByPhysicsQuery = InShouldCheckOcclusionByPhysicsQuery
	
	PendingTilePlaceArrayMutex.lock()
	PendingTilePlaceArray.append(NewPendingData)
	PendingTilePlaceArrayMutex.unlock()
	
	if not is_physics_processing():
		set_physics_process(true)

func ProcessPendingTileArray(InDelta: float):
	
	PendingTilePlaceArrayMutex.lock()
	for SampleData: TilePlaceData in PendingTilePlaceArray:
		
		if SampleData.ShouldCheckOcclusionByTile:
			if HasCell(SampleData.Cell):
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
		BetterTerrain.set_cell(self, SampleData.Cell, SampleData.TerrainID)
		BetterTerrain.update_terrain_cell(self, SampleData.Cell)
	PendingTilePlaceArray.clear()
	PendingTilePlaceArrayMutex.unlock()

func ForEachTileInRadius(InCenterCell: Vector2i, InRadius: int, InCallable: Callable):
	
	for y: int in range(-InRadius, InRadius + 1):
		var CurrentHalfWidth: int = (InRadius - abs(y)) + 1
		for x: int in range(-CurrentHalfWidth, CurrentHalfWidth):
			InCallable.call(InCenterCell + Vector2i(x, y))
