class_name ConLex
extends CanvasLayer

@onready var newBtn: Button = $ColorRect/MarginContainer/VBoxContainer/Options/MarginContainer/HBoxContainer2/HBoxContainer/NewBtn
@onready var openBtn: Button = $ColorRect/MarginContainer/VBoxContainer/Options/MarginContainer/HBoxContainer2/HBoxContainer/OpenBtn
@onready var saveBtn: Button = $ColorRect/MarginContainer/VBoxContainer/Options/MarginContainer/HBoxContainer2/HBoxContainer/SaveBtn
@onready var saveAsBtn: Button = $ColorRect/MarginContainer/VBoxContainer/Options/MarginContainer/HBoxContainer2/HBoxContainer/SaveAsBtn

@onready var webLabel: Label = $ColorRect/MarginContainer/VBoxContainer/Options/MarginContainer/HBoxContainer2/HBoxContainer2/WebLabel
@onready var versionLabel: Label = $ColorRect/MarginContainer/VBoxContainer/Options/MarginContainer/HBoxContainer2/HBoxContainer2/VersionLabel

@onready var newEntryBtn: Button = $ColorRect/MarginContainer/VBoxContainer/Editor/MarginContainer/VBoxContainer2/HBoxContainer/HBoxContainer/NewEntryBtn
@onready var findBtn: MenuButton = $ColorRect/MarginContainer/VBoxContainer/Editor/MarginContainer/VBoxContainer2/HBoxContainer/HBoxContainer/FindBtn
@onready var findText: TextEdit = $ColorRect/MarginContainer/VBoxContainer/Editor/MarginContainer/VBoxContainer2/HBoxContainer/HBoxContainer/FindText
@onready var sortBtn: MenuButton = $ColorRect/MarginContainer/VBoxContainer/Editor/MarginContainer/VBoxContainer2/HBoxContainer/HBoxContainer/SortBtn
@onready var speechSortBtn: MenuButton = $ColorRect/MarginContainer/VBoxContainer/Editor/MarginContainer/VBoxContainer2/HBoxContainer/HBoxContainer/SpeechSortBtn

@onready var useFontBtn: CheckButton = $ColorRect/MarginContainer/VBoxContainer/Editor/MarginContainer/VBoxContainer2/HBoxContainer/HBoxContainer2/UseFontBtn
@onready var loadFontBtn: Button = $ColorRect/MarginContainer/VBoxContainer/Editor/MarginContainer/VBoxContainer2/HBoxContainer/HBoxContainer2/LoadFontBtn

@onready var entryContainer: VBoxContainer = $ColorRect/MarginContainer/VBoxContainer/Editor/MarginContainer/VBoxContainer2/ScrollContainer/EntryContainer

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
	else:
		webLabel.visible = false
	
	versionLabel.text = "ConLex v%s %s" % [ProjectSettings.get_setting("application/config/version"), OS.get_name()]
	
	newBtn.pressed.connect(onNewPressed)
	openBtn.pressed.connect(onOpenPressed)
	saveBtn.pressed.connect(onSavePressed)
	saveAsBtn.pressed.connect(onSaveAsPressed)
	
	clearEntries()
	newEntryBtn.pressed.connect(onNewEntryPressed)
	
	findBtn.get_popup().hide_on_checkable_item_selection = false
	findBtn.get_popup().index_pressed.connect(onFindPressed)
	populateFindBtn()
	
	findText.visible = false
	findText.text_changed.connect(onFindTextChanged)
	
	GlobalVars.performSort.connect(performSort)
	sortBtn.get_popup().hide_on_checkable_item_selection = false
	sortBtn.get_popup().index_pressed.connect(onSortPressed)
	
	speechSortBtn.visible = false
	var popup := speechSortBtn.get_popup()
	popup.hide_on_checkable_item_selection = false
	popup.index_pressed.connect(onSpeechSortPressed)
	populateSpeechSortBtn()
	
	useFontBtn.toggled.connect(onUseFontPressed)
	loadFontBtn.pressed.connect(onLoadFontPressed)
	loadFontBtn.visible = false
	
	fileDialog.file_selected.connect(onFileSelected)

func populateFindBtn() -> void:
	var popup := findBtn.get_popup()
	for i in GlobalVars.SortOption.size():
		if i == int(GlobalVars.SortOption.NONE) || i == int(GlobalVars.SortOption.SPEECH):
			continue
		popup.add_item(GlobalVars.SortOption.keys()[i].capitalize())
		popup.set_item_as_checkable(i, true)

func populateSpeechSortBtn() -> void:
	var i: int = 0
	var popup := speechSortBtn.get_popup()
	for part: String in GlobalVars.SpeechPart: 
		popup.add_item(part.capitalize())
		popup.set_item_as_checkable(i, true)
		i += 1
	popup.set_item_checked(int(GlobalVars.speechSort), true)

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
		SaveData.saveTo("conlex.clex", self, true)
	else:
		fileDialogUse = FileDialogUse.SAVE
		fileDialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
		
		# check if file was already saved
		if GlobalVars.currentSavePath.is_empty() || !GlobalVars.currentSavePath:
			fileDialog.clear_filters()
			fileDialog.add_filter("*.clex, *.conlex", "ConLex Save")
			fileDialog.popup_centered()
		else:
			onFileSelected(GlobalVars.currentSavePath)

func onSaveAsPressed() -> void:
	fileDialogUse = FileDialogUse.SAVE
	fileDialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	fileDialog.clear_filters()
	fileDialog.add_filter("*.conlex, *.clex", "ConLex Save")
	fileDialog.popup_centered()

func clearEntries() -> void:
	for entry in entryContainer.get_children():
		entry.queue_free()

func onNewEntryPressed() -> void:
	var entry: LexEntry = GlobalVars.LEX_ENTRY.instantiate()
	entry.id = GlobalVars.getTimeId()
	entryContainer.add_child(entry)

func sortEntries(fun: Callable) -> void:
	var entries := entryContainer.get_children()
	#print(entries)
	entries.sort_custom(fun)
	#print(entries)
	for i in range(entries.size()):
		entryContainer.move_child(entries[i], i)

func onFindPressed(index: int) -> void:
	var popup := findBtn.get_popup()
	var wasChecked := popup.is_item_checked(index)
	if wasChecked:
		popup.set_item_checked(index, false)
		GlobalVars.findOption = GlobalVars.SortOption.NONE
		findText.visible = false
		
		performSort()
	else:
		if index < 0 || index >= popup.item_count:
			printerr("Unknown sort option (%s)" % index)
			return
		
		for i in popup.item_count:
			popup.set_item_checked(i, false)
		popup.set_item_checked(index, true)
		GlobalVars.findOption = index as GlobalVars.SortOption
		findText.visible = true
		
		#onFindTextChanged()

func onFindTextChanged() -> void:
	performSort()
	var text := findText.text.to_lower()
	if text.is_empty() || text == "":
		return
	sortEntries(func(a: LexEntry, b: LexEntry) -> bool:
		var A := false
		var B := false
		match GlobalVars.findOption:
			GlobalVars.SortOption.WRITTEN:
				A = a.writtenLabel.text.to_lower().contains(text)
				B = b.writtenLabel.text.to_lower().contains(text)
			GlobalVars.SortOption.LITERAL:
				A = a.literalLabel.text.to_lower().contains(text)
				B = b.literalLabel.text.to_lower().contains(text)
			GlobalVars.SortOption.TRANSLATE:
				A = a.translateLabel.text.to_lower().contains(text)
				B = b.translateLabel.text.to_lower().contains(text)
		if A && B:
			return false
		return A
	)

func performSort() -> void:
	match GlobalVars.sortOption:
		GlobalVars.SortOption.WRITTEN:
			print("Sort by written")
			sortEntries(func(a: LexEntry, b: LexEntry) -> bool: return a.writtenLabel.text.naturalnocasecmp_to(b.writtenLabel.text) < 0)
		GlobalVars.SortOption.LITERAL:
			print("Sort by literal")
			sortEntries(func(a: LexEntry, b: LexEntry) -> bool: return a.literalLabel.text.naturalnocasecmp_to(b.literalLabel.text) < 0)
		GlobalVars.SortOption.TRANSLATE:
			print("Sort by translate")
			sortEntries(func(a: LexEntry, b: LexEntry) -> bool: return a.translateLabel.text.naturalnocasecmp_to(b.translateLabel.text) < 0)
		GlobalVars.SortOption.SPEECH:
			#print("Sort by Speech")
			#sortEntries(func(a: LexEntry, b: LexEntry) -> bool: return a.speechLabel.text.naturalnocasecmp_to(b.speechLabel.text) < 0)
			performSpeechSort()
		_:
			print("Sort by none/id")
			sortEntries(func(a: LexEntry, b: LexEntry) -> bool: return a.id.naturalnocasecmp_to(b.id) < 0)
	
	# Mark anyway
	speechSortBtn.visible = sortBtn.get_popup().is_item_checked(int(GlobalVars.SortOption.SPEECH))

func onSortPressed(index: int) -> void:
	var popup := sortBtn.get_popup()
	var wasChecked := popup.is_item_checked(index)
	if wasChecked:
		popup.set_item_checked(index, false)
		GlobalVars.sortOption = GlobalVars.SortOption.NONE
	else:
		if index < 0 || index >= popup.item_count:
			printerr("Unknown sort option (%s)" % index)
			return
		
		for i in popup.item_count:
			popup.set_item_checked(i, false)
		popup.set_item_checked(index, true)
		GlobalVars.sortOption = index as GlobalVars.SortOption
	
	performSort()

func onSpeechSortPressed(index: int) -> void:
	var popup := speechSortBtn.get_popup()
	if popup.is_item_checked(index):
		return
	else:
		if index < 0 || index >= popup.item_count:
			printerr("Unknown speech sort option (%s) % index")
			return
		
		for i in popup.item_count:
			popup.set_item_checked(i, false)
		popup.set_item_checked(index, true)
		GlobalVars.speechSort = index as GlobalVars.SpeechPart
	
	performSpeechSort()

func performSpeechSort() -> void:
	print("Sort by part of speech (%s)" % (GlobalVars.SpeechPart.keys()[int(GlobalVars.speechSort)]))
	print_debug("First sort by id")
	sortEntries(func(a: LexEntry, b: LexEntry) -> bool: return a.id.naturalnocasecmp_to(b.id) < 0)
	sortEntries(func(a: LexEntry, b: LexEntry) -> bool:
		var A: bool = a.speechContainer.get_child(int(GlobalVars.speechSort)).visible
		var B: bool = b.speechContainer.get_child(int(GlobalVars.speechSort)).visible
		if A && B:
			return false
		return A
	)

func onUseFontPressed(toggled: bool) -> void:
	loadFontBtn.disabled = !toggled
	loadFontBtn.visible = toggled
	GlobalVars.useWrittenFont = toggled
	GlobalVars.useWrittenFont = toggled
	GlobalVars.updateWrittenFont.emit()

func onLoadFontPressed() -> void:
	fileDialogUse = FileDialogUse.FONT
	fileDialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	fileDialog.clear_filters()
	fileDialog.add_filter("*.ttf", "True Type Font")
	fileDialog.add_filter("*.otf", "Open Type Font")
	fileDialog.add_filter("*.woff")
	fileDialog.add_filter("*.woff2")
	fileDialog.popup_centered()

func onFileSelected(path: String) -> void:
	match fileDialogUse:
		FileDialogUse.FONT:
			GlobalVars.writtenFont = GlobalVars.loadFont(path)
			GlobalVars.writtenFontPath = path
			GlobalVars.updateWrittenFont.emit()
		FileDialogUse.SAVE:
			if GlobalVars.currentSavePath.is_empty() || !GlobalVars.currentSavePath:
				GlobalVars.currentSavePath = path
			SaveData.saveTo(GlobalVars.currentSavePath, self, false)
		FileDialogUse.LOAD:
			SaveData.loadFrom(path, self, false)
		_:
			push_warning("File dialog was used in unknown mode!")
