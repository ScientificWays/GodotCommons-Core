extends Resource
class_name ResourceDisplayData

#enum CurrencyType { Experience = 0, Coins = 1 }

@export var Name: String = "Unnamed"
@export_multiline var Description: String = "No description"
@export var _Image: Texture2D
@export_color_no_alpha var OutlineColor: Color = Color.LIME_GREEN
#@export var _MaxLevel: int = 4
#@export var _UpgradePrice: Array[int] = [ 10, 20, 30, 40 ]
#@export var _UpgradeCurrency: CurrencyType = CurrencyType.Experience

@export var Image_PerSkinOverrides: Dictionary = {}

func GetImage(InSkin: StringName = StringName()) -> Texture2D:
	var OutImage := Image_PerSkinOverrides.get(InSkin, _Image) as Texture2D
	if not is_instance_valid(OutImage):
		push_warning(resource_path, " Image is invalid!")
	return OutImage
