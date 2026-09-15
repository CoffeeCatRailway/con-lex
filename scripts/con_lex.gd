class_name ConLex
extends CanvasLayer

@onready var newBtn: Button = $ColorRect/MarginContainer/VBoxContainer/Options/MarginContainer/HBoxContainer2/HBoxContainer/NewBtn
@onready var openBtn: Button = $ColorRect/MarginContainer/VBoxContainer/Options/MarginContainer/HBoxContainer2/HBoxContainer/OpenBtn
@onready var saveBtn: Button = $ColorRect/MarginContainer/VBoxContainer/Options/MarginContainer/HBoxContainer2/HBoxContainer/SaveBtn
@onready var saveAsBtn: Button = $ColorRect/MarginContainer/VBoxContainer/Options/MarginContainer/HBoxContainer2/HBoxContainer/SaveAsBtn
@onready var findBtn: Button = $ColorRect/MarginContainer/VBoxContainer/Options/MarginContainer/HBoxContainer2/HBoxContainer/FindBtn

@onready var webLabel: Label = $ColorRect/MarginContainer/VBoxContainer/Options/MarginContainer/HBoxContainer2/HBoxContainer2/WebLabel
@onready var versionLabel: Label = $ColorRect/MarginContainer/VBoxContainer/Options/MarginContainer/HBoxContainer2/HBoxContainer2/VersionLabel

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
	if OS.get_name() == "Web":
		saveAsBtn.disabled = true
		saveAsBtn.visible = false
		
		webLabel.visible = true
		
		useFontBtn.disabled = true
		useFontBtn.visible = false
		loadFontBtn.disabled = true
		loadFontBtn.visible = false
	else:
		webLabel.visible = false
	
	versionLabel.text = "ConLex v%s %s" % [ProjectSettings.get_setting("application/config/version"), OS.get_name()]
	
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
	if OS.get_name() == "Web":
		GlobalVars.webFileUpload(".clex, .conlex")
	else:
		fileDialogUse = FileDialogUse.LOAD
		fileDialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
		fileDialog.clear_filters()
		fileDialog.add_filter("*.clex, *.conlex", "ConLex Save")
		fileDialog.popup_centered()

func onSavePressed() -> void:
	if OS.get_name() == "Web":
		SaveData.saveTo("conlex.clex", true)
	else:
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
			SaveData.saveTo(GlobalVars.currentSavePath, false)
		FileDialogUse.LOAD:
			SaveData.loadFrom(path, self, false)
		_:
			push_warning("File dialog was used in unknown mode!")
