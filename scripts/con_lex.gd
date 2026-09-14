extends CanvasLayer

const LEX_ENTRY = preload("uid://cmkijaun62dm7")

@onready var newBtn: Button = $ColorRect/MarginContainer/VBoxContainer/Options/MarginContainer/HBoxContainer/NewBtn
@onready var openBtn: Button = $ColorRect/MarginContainer/VBoxContainer/Options/MarginContainer/HBoxContainer/OpenBtn
@onready var saveBtn: Button = $ColorRect/MarginContainer/VBoxContainer/Options/MarginContainer/HBoxContainer/SaveBtn
@onready var saveAsBtn: Button = $ColorRect/MarginContainer/VBoxContainer/Options/MarginContainer/HBoxContainer/SaveAsBtn
@onready var findBtn: Button = $ColorRect/MarginContainer/VBoxContainer/Options/MarginContainer/HBoxContainer/FindBtn

@onready var entryContainer: VBoxContainer = $ColorRect/MarginContainer/VBoxContainer/Editor/MarginContainer/VBoxContainer2/ScrollContainer/EntryContainer
@onready var newEntryBtn: Button = $ColorRect/MarginContainer/VBoxContainer/Editor/MarginContainer/VBoxContainer2/NewEntryBtn

func _ready() -> void:
	clearEntries()
	newEntryBtn.pressed.connect(onNewEntryPressed)

func clearEntries() -> void:
	for entry in entryContainer.get_children():
		entry.queue_free()

func onNewEntryPressed() -> void:
	var entry := LEX_ENTRY.instantiate()
	entryContainer.add_child(entry)
