@tool
class_name AutoSizeLabel
extends Label

@export var min_font_size: int = 12:
	set(v):
		min_font_size = v
		update_font_size()
@export var max_font_size: int = 30:
	set(v):
		max_font_size = v
		update_font_size()

func _ready() -> void:
	# Ensure text doesn't spill past visual boundaries while calculating
	clip_text = true 
	item_rect_changed.connect(update_font_size)
	update_font_size()

# Automatically intercept property adjustments (like text updates)
func _set(property: StringName, value: Variant) -> bool:
	if property == &"text":
		text = value
		update_font_size()
		return true
	return false

func update_font_size() -> void:
	var font := get_theme_font("font")
	if not font:
		return
		
	# Begin tracking downward from maximum size limit
	var current_size := max_font_size
	
	while current_size > min_font_size:
		# Check horizontal space requirements for the text string
		var text_size := font.get_string_size(text, horizontal_alignment, -1, current_size)
		
		# If the calculated text fits within the Label's current width, stop shrinking
		if text_size.x <= size.x:
			break
		current_size -= 1

	# Override the active theme font size inline
	add_theme_font_size_override("font_size", current_size)
