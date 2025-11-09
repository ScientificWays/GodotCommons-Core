extends Resource
class_name PawnWaveData2D

@export_category("Pawns")
@export var pawns: Array[PackedScene]
@export var pawns_weights: Array[float]

@export_category("Wave")
@export var wave_size_min: float = 4.0
@export var wave_size_max: float = 6.0

func try_spawn_wave(init_pawn_callable: Callable, in_pool_max: float = -1.0) -> float:
	
	assert(pawns.size() == pawns_weights.size())
	
	var out_spawned_size := 0.0
	
	var wave_size := randf_range(wave_size_min, wave_size_max)
	if in_pool_max >= 0.0:
		wave_size = minf(wave_size, in_pool_max)
	
	while wave_size > 0.0:
		
		var sample_pawn_scene := pawns[GameGlobals_Class.array_get_random_index_weighted(pawns_weights)]
		var sample_pawn := sample_pawn_scene.instantiate() as Pawn2D
		
		init_pawn_callable.call(sample_pawn)
		
		wave_size -= sample_pawn.spawn_value
		out_spawned_size += sample_pawn.spawn_value
	return out_spawned_size
