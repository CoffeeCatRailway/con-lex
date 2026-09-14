class_name ConLex
extends CanvasLayer

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

enum FileDialogUse {
	FONT,
	SAVE,
	LOAD
}
var fileDialogUse := FileDialogUse.FONT

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
	
	fileDialog.file_selected.connect(onFileSelected)

func onNewPressed() -> void:
	pass

func onOpenPressed() -> void:
	fileDialogUse = FileDialogUse.LOAD
	fileDialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	fileDialog.clear_filters()
	fileDialog.add_filter("*.conlex, *.clex", "ConLex Save")
	fileDialog.popup_centered()

func onSavePressed() -> void:
	fileDialogUse = FileDialogUse.SAVE
	fileDialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	
	# check if file was already saved
	if GlobalVars.currentSavePath.is_empty() || !GlobalVars.currentSavePath:
		fileDialog.clear_filters()
		fileDialog.add_filter("*.conlex, *.clex", "ConLex Save")
		fileDialog.popup_centered()
	else:
		onFileSelected(GlobalVars.currentSavePath)

func onSaveAsPressed() -> void:
	fileDialogUse = FileDialogUse.SAVE
	fileDialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	fileDialog.clear_filters()
	fileDialog.add_filter("*.conlex, *.clex", "ConLex Save")
	fileDialog.popup_centered()

func onFindPressed() -> void:
	pass

func clearEntries() -> void:
	for entry in entryContainer.get_children():
		entry.queue_free()

func onNewEntryPressed() -> void:
	var entry: LexEntry = GlobalVars.LEX_ENTRY.instantiate()
	entry.id = GlobalVars.getNextId()
	entryContainer.add_child(entry)
	
	SaveData.entries[entry.id] = entry.toSaveEntry()

func onUseFontPressed(toggled: bool) -> void:
	loadFontBtn.disabled = !toggled
	GlobalVars.useWrittenFont = toggled
	SaveData.useWrittenFont = toggled
	GlobalVars.updateWrittenFont.emit()

func onLoadFontPressed() -> void:
	fileDialogUse = FileDialogUse.FONT
	fileDialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	fileDialog.clear_filters()
	fileDialog.add_filter("*.ttf", "True Type Font")
	fileDialog.popup_centered()

func onFileSelected(path: String) -> void:
	match fileDialogUse:
		FileDialogUse.FONT:
			GlobalVars.writtenFont = load(path)
			SaveData.writtenFontPath = path
			GlobalVars.updateWrittenFont.emit()
		FileDialogUse.SAVE:
			if GlobalVars.currentSavePath.is_empty() || !GlobalVars.currentSavePath:
				GlobalVars.currentSavePath = path
			SaveData.saveTo(GlobalVars.currentSavePath)
		FileDialogUse.LOAD:
			SaveData.loadFrom(path, self)
		_:
			push_warning("File dialog was used in unknown mode!")
