@tool
class_name AutoSizeLabel
extends Label

@export var minFontSize: int = 15:
	set(v):
		minFontSize = v
		updateFontSize()
@export var maxFontSize: int = 25:
	set(v):
		maxFontSize = v
		updateFontSize()

func _ready() -> void:
	# Ensure text doesn't spill past visual boundaries while calculating
	#clip_text = true 
	item_rect_changed.connect(updateFontSize)
	updateFontSize()

# Automatically intercept property adjustments (like text updates)
func _set(property: StringName, value: Variant) -> bool:
	if property == &"text":
		text = value
		updateFontSize()
		return true
	return false

func updateFontSize() -> void:
	var font := get_theme_font("font")
	if not font:
		return
		
	# Begin tracking downward from maximum size limit
	var currentSize := maxFontSize
	
	while currentSize > minFontSize:
		# Check horizontal space requirements for the text string
		var text_size := font.get_string_size(text, horizontal_alignment, -1, currentSize)
		
		# If the calculated text fits within the Label's current width, stop shrinking
		if text_size < size:
			break
		currentSize -= 1

	# Override the active theme font size inline
	add_theme_font_size_override("font_size", currentSize)
