extends BaseButton
class_name LinkUI

@export_category("Link")
@export var prompt_text: String = "TELEGRAM_PROMPT"
@export var target_url: String = "https://t.me/cat00m"
@export var is_external: bool = true

func _ready() -> void:
	
	if is_external:
		
		if PlatformGlobals_Class.is_web():
			
			var external_allowed := Bridge.social.is_external_links_allowed as bool
			
			match Bridge.platform.id:
				"qa_tool":
					external_allowed = false
				"playgama":
					external_allowed = false
			
			if not external_allowed:
				queue_free()
				return
	
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	UIGlobals.confirm_ui.toggle(prompt_text, _handle_confirm_follow)

func _handle_confirm_follow() -> void:
	OS.shell_open(target_url)
