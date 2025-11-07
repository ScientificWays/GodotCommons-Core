extends BaseButton
class_name LinkUI

@export_category("Link")
@export var prompt_text: String = "TELEGRAM_PROMPT"
@export var target_url: String = "https://t.me/cat00m"
@export var is_external: bool = true

func _ready() -> void:
	
	if is_external:
		if PlatformGlobals.is_web() and not Bridge.social.is_external_links_allowed:
			queue_free()
			return
	
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	UIGlobals.confirm_ui.toggle(prompt_text, _handle_confirm_follow)

func _handle_confirm_follow() -> void:
	OS.shell_open(target_url)
