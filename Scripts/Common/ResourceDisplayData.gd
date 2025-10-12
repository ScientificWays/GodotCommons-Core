@tool
extends Resource
class_name ResourceDisplayData

#enum CurrencyType { Experience = 0, Coins = 1 }

@export var name: String = "Unnamed"
@export_multiline var description: String = "No description"
@export var image: Texture2D
@export_color_no_alpha var outline_color: Color = Color.LIME_GREEN
#@export var _MaxLevel: int = 4
#@export var _UpgradePrice: Array[int] = [ 10, 20, 30, 40 ]
#@export var _UpgradeCurrency: CurrencyType = CurrencyType.Experience

@export var image_per_skin_overrides: Dictionary = {}

func get_image(in_skin: StringName = StringName()) -> Texture2D:
	var out_image := image_per_skin_overrides.get(in_skin, image) as Texture2D
	if not is_instance_valid(out_image):
		push_warning(resource_path, " image is invalid!")
	return out_image
