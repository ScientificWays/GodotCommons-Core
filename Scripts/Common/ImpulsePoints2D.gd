extends Path2D
class_name ImpulsePoints2D

static func try_get_from(in_node: Node) -> ImpulsePoints2D:
	return ModularGlobals.try_get_from(in_node, ImpulsePoints2D)

@export var LerpToCenterOfMassValue: float = 0.5

func _ready():
	pass

func _enter_tree():
	ModularGlobals.init_modular_node(self)

func _exit_tree():
	ModularGlobals.deinit_modular_node(self)

func GetLocalImpulsePosition(InGlobalSourcePosition: Vector2) -> Vector2:
	
	var LocalSourcePosition := to_local(InGlobalSourcePosition)
	var CurvePosition := curve.get_closest_point(LocalSourcePosition)
	
	#print("Curve = ", CurvePosition.length_squared(), "; Source = ",  LocalSourcePosition.length_squared())
	
	var _OwnerRigidBody := get_parent() as RigidBody2D
	
	if CurvePosition.length_squared() < LocalSourcePosition.length_squared():
		return CurvePosition.lerp(_OwnerRigidBody.center_of_mass, 0.5)
	else:
		return _OwnerRigidBody.center_of_mass * LerpToCenterOfMassValue
