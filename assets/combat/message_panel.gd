extends Panel

@onready var message_log: RichTextLabel = $ScrollContainer/RichTextLabel

var max_messages: int = 10
var messages: Array[String] = []

func add_message(text: String) -> void:
	messages.append(text)

	# If too many messages, remove oldest
	if messages.size() > max_messages:
		messages.pop_front()

	# Update RichTextLabel content
	_update_log()

func _update_log() -> void:
	if message_log:
		message_log.clear()
		for message in messages:
			message_log.append_text(message + "\n")

		# Auto-scroll to bottom
		await get_tree().process_frame
		message_log.scroll_to_line(message_log.get_line_count() - 1)
