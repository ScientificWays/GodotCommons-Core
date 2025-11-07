extends Control
class_name LeaderboardUI_Entry

@export_category("Elements")
@export var player_rank: VHSLabel
@export var player_photo: TextureRect
@export var player_name: VHSLabel
@export var player_score: VHSLabel

var data: Dictionary

func _ready() -> void:
	
	#print("ID: " + str(data.id))
	#print("Name: " + str(data.name))
	#print("Score: " + str(data.score))
	#print("Rank: " + str(data.rank))
	#print("Photo: " + str(data.photo))
	
	player_rank.label_text = String.num_int64(data.rank)
	player_name.label_text = data.name
	player_score.label_text = String.num_int64(data.score)
	
	if data.photo == null:
		player_photo.visible = false
	else:
		_handle_photo_http_request()

func _handle_photo_http_request() -> void:
	
	var http_request = HTTPRequest.new()
	http_request.timeout = 5.0
	http_request.request_completed.connect(_photo_http_request_completed)
	add_child(http_request)

	var error = http_request.request(data.photo)
	if error != OK:
		push_error("%s _handle_photo_http_request() error code %d" % [ self, error ] )
		player_photo.visible = false

func _photo_http_request_completed(in_result: int, in_response_code: int, in_headers: PackedStringArray, in_body: PackedByteArray) -> void:
	
	#print("_photo_http_request_completed() %s %s %s %s" % [ in_result, in_response_code, in_headers, in_body ])
	
	if in_result == HTTPRequest.RESULT_SUCCESS and not in_body.is_empty():
		
		var image = Image.new()
		var error := FAILED
		
		if not in_headers.is_empty() and in_headers[0].containsn("png"):
			error = image.load_png_from_buffer(in_body)
			if error != OK: error = image.load_jpg_from_buffer(in_body)
		else:
			error = image.load_jpg_from_buffer(in_body)
			if error != OK: error = image.load_png_from_buffer(in_body)
		
		if error == OK:
			player_photo.texture = ImageTexture.create_from_image(image)
			player_photo.visible = true
		else:
			push_error("%s _photo_http_request_completed() error code %d" % [ self, error ] )
			player_photo.visible = false
	else:
		push_error("%s _photo_http_request_completed() unsuccessful result with code %d" % [ self, in_result ] )
		player_photo.visible = false
