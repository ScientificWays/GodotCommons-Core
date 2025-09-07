extends NavigationRegion2D
class_name LevelNavigationRegion2D

var bWaitingUpdateFinish: bool = false
var bRequestUpdateAgain: bool = false

@onready var _DelayedUpdateTimer: Timer

func _ready():
	_DelayedUpdateTimer = Timer.new()
	_DelayedUpdateTimer.one_shot = true
	_DelayedUpdateTimer.wait_time = 0.5
	_DelayedUpdateTimer.timeout.connect(DelayedUpdate)
	add_child(_DelayedUpdateTimer)
	bake_finished.connect(OnBakeFinished)

func RequestUpdate():
	if bWaitingUpdateFinish:
		bRequestUpdateAgain = true
	elif _DelayedUpdateTimer.is_stopped():
		_DelayedUpdateTimer.start()

func DelayedUpdate():
	#print("Update")
	assert(not bWaitingUpdateFinish)
	bWaitingUpdateFinish = true
	bake_navigation_polygon(true)

func OnBakeFinished():
	bWaitingUpdateFinish = false
	if bRequestUpdateAgain:
		bRequestUpdateAgain = false
		RequestUpdate()
