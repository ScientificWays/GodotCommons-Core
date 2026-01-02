extends Node
class_name AnimStateMachine

@export var owner_sprite: AnimatedSprite2D
@export var owner_body: CharacterBody2D
@export var owner_tags_container: TagsContainer

var current_state: AnimState

func _ready() -> void:
	
	assert(owner_sprite)
	assert(owner_body)
	assert(owner_tags_container)
	
	current_state = get_child(0)

func _process(in_delta: float) -> void:
	current_state = current_state.get_next_state()
	current_state.process_state(in_delta)
