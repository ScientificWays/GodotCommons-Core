extends NavigationRegion2D
class_name LevelNavigationRegion2D

var _is_waiting_update_finish: bool = false
var _should_request_update_again: bool = false

@onready var _delayed_update_timer: Timer

func _ready():
	_delayed_update_timer = Timer.new()
	_delayed_update_timer.one_shot = true
	_delayed_update_timer.wait_time = 0.5
	_delayed_update_timer.timeout.connect(delayed_update)
	add_child(_delayed_update_timer)
	bake_finished.connect(_on_bake_finished)

func request_update():
	if _is_waiting_update_finish:
		_should_request_update_again = true
	elif _delayed_update_timer.is_stopped():
		_delayed_update_timer.start()

func delayed_update():
	#print("Update")
	assert(not _is_waiting_update_finish)
	_is_waiting_update_finish = true
	bake_navigation_polygon(true)

func _on_bake_finished():
	_is_waiting_update_finish = false
	if _should_request_update_again:
		_should_request_update_again = false
		request_update()
