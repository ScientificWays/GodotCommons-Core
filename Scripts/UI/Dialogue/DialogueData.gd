extends Resource
class_name DialogueData

@export_category("Text")
@export_multiline var text: String = "Sample dialogue text..."
@export var text_display_speed: float = 32.0

@export_category("Speaker")
var speaker_display_data: ResourceDisplayData
