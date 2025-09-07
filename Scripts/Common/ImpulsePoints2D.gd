extends Path2D
class_name ImpulsePoints2D

static func TryGetFrom(InNode: Node) -> ImpulsePoints2D:
	return ModularGlobals.TryGetFrom(InNode, ImpulsePoints2D)

@export var LerpToCenterOfMassValue: float = 0.5

func _ready():
	pass

func _enter_tree():
	ModularGlobals.InitModularNode(self)

func _exit_tree():
	ModularGlobals.DeInitModularNode(self)

func GetLocalImpulsePosition(InGlobalSourcePosition: Vector2) -> Vector2:
	
	var LocalSourcePosition := to_local(InGlobalSourcePosition)
	var CurvePosition := curve.get_closest_point(LocalSourcePosition)
	
	#print("Curve = ", CurvePosition.length_squared(), "; Source = ",  LocalSourcePosition.length_squared())
	
	var _OwnerRigidBody := get_parent() as RigidBody2D
	
	if CurvePosition.length_squared() < LocalSourcePosition.length_squared():
		return CurvePosition.lerp(_OwnerRigidBody.center_of_mass, 0.5)
	else:
		return _OwnerRigidBody.center_of_mass * LerpToCenterOfMassValue
