extends CanvasLayer

const LEX_ENTRY = preload("uid://cmkijaun62dm7")

@onready var newBtn: Button = $ColorRect/MarginContainer/VBoxContainer/Options/MarginContainer/HBoxContainer/NewBtn
@onready var openBtn: Button = $ColorRect/MarginContainer/VBoxContainer/Options/MarginContainer/HBoxContainer/OpenBtn
@onready var saveBtn: Button = $ColorRect/MarginContainer/VBoxContainer/Options/MarginContainer/HBoxContainer/SaveBtn
@onready var saveAsBtn: Button = $ColorRect/MarginContainer/VBoxContainer/Options/MarginContainer/HBoxContainer/SaveAsBtn
@onready var findBtn: Button = $ColorRect/MarginContainer/VBoxContainer/Options/MarginContainer/HBoxContainer/FindBtn

@onready var entryContainer: VBoxContainer = $ColorRect/MarginContainer/VBoxContainer/Editor/MarginContainer/VBoxContainer2/ScrollContainer/EntryContainer
@onready var newEntryBtn: Button = $ColorRect/MarginContainer/VBoxContainer/Editor/MarginContainer/VBoxContainer2/HBoxContainer/NewEntryBtn
@onready var useFontBtn: CheckButton = $ColorRect/MarginContainer/VBoxContainer/Editor/MarginContainer/VBoxContainer2/HBoxContainer/UseFontBtn
@onready var loadFontBtn: Button = $ColorRect/MarginContainer/VBoxContainer/Editor/MarginContainer/VBoxContainer2/HBoxContainer/LoadFontBtn

@onready var fileDialog: FileDialog = $FileDialog

func _ready() -> void:
	newBtn.pressed.connect(onNewPressed)
	openBtn.pressed.connect(onOpenPressed)
	saveBtn.pressed.connect(onSavePressed)
	saveAsBtn.pressed.connect(onSaveAsPressed)
	findBtn.pressed.connect(onFindPressed)
	
	clearEntries()
	newEntryBtn.pressed.connect(onNewEntryPressed)
	
	useFontBtn.toggled.connect(onUseFontPressed)
	loadFontBtn.pressed.connect(onLoadFontPressed)
	
	fileDialog.file_selected.connect(onFontFileSelected)

func onNewPressed() -> void:
	pass

func onOpenPressed() -> void:
	pass

func onSavePressed() -> void:
	pass

func onSaveAsPressed() -> void:
	pass

func onFindPressed() -> void:
	pass

func clearEntries() -> void:
	for entry in entryContainer.get_children():
		entry.queue_free()

func onNewEntryPressed() -> void:
	var entry := LEX_ENTRY.instantiate()
	entryContainer.add_child(entry)

func onUseFontPressed(toggled: bool) -> void:
	loadFontBtn.disabled = !toggled
	GlobalVars.useWrittenFont.emit(toggled)

func onLoadFontPressed() -> void:
	fileDialog.popup_centered()

func onFontFileSelected(path: String) -> void:
	GlobalVars.writtenFont = load(path)
	GlobalVars.updateWrittenFont.emit()
