class_name LexEntry
extends Panel

@onready var writtenLabel: Label = $MarginContainer/HBoxContainer/HBoxContainer/WrittenContainer/ScrollContainer/AutoSizeLabel
@onready var literalLabel: Label = $MarginContainer/HBoxContainer/HBoxContainer/LiteralContainer/ScrollContainer/AutoSizeLabel
@onready var translateLabel: Label = $MarginContainer/HBoxContainer/HBoxContainer/TranslateContainer/ScrollContainer/AutoSizeLabel
@onready var speechLabel: Label = $MarginContainer/HBoxContainer/HBoxContainer/SpeechContainer/AutoSizeLabel
@onready var speechContainer: VBoxContainer = $MarginContainer/HBoxContainer/HBoxContainer/SpeechContainer/MarginContainer/ScrollContainer/VBoxContainer

@onready var editBtn: TextureButton = $MarginContainer/HBoxContainer/Options/Control2/EditBtn
@onready var deleteBtn: TextureButton = $MarginContainer/HBoxContainer/Options/Control/DeleteBtn

@onready var menus: CanvasLayer = $Menus

@onready var editMenu: Panel = $Menus/CenterContainer/EditMenu
@onready var editSaveBtn: TextureButton = $Menus/CenterContainer/EditMenu/MarginContainer/VBoxContainer/HBoxContainer2/Panel/CenterContainer2/SaveBtn
@onready var editCloseBtn: TextureButton = $Menus/CenterContainer/EditMenu/MarginContainer/VBoxContainer/HBoxContainer2/Panel/CenterContainer/CloseBtn

@onready var editWrittenBox: TextEdit = $Menus/CenterContainer/EditMenu/MarginContainer/VBoxContainer/Written/TextEdit
@onready var editLiteralBox: TextEdit = $Menus/CenterContainer/EditMenu/MarginContainer/VBoxContainer/Literal/TextEdit
@onready var editTranslateBox: TextEdit = $Menus/CenterContainer/EditMenu/MarginContainer/VBoxContainer/Translated/TextEdit
@onready var editSpeechBtn: MenuButton = $Menus/CenterContainer/EditMenu/MarginContainer/VBoxContainer/Speech/MenuButton

@onready var deleteMenu: Panel = $Menus/CenterContainer/DeleteMenu
@onready var deleteYesBtn: Button = $Menus/CenterContainer/DeleteMenu/MarginContainer/VBoxContainer/HBoxContainer/YesBtn
@onready var deleteNoBtn: Button = $Menus/CenterContainer/DeleteMenu/MarginContainer/VBoxContainer/HBoxContainer/NoBtn

@export var legend: bool = false

var id: String = "0"

func _ready() -> void:
	menus.visible = false
	editMenu.visible = false
	deleteMenu.visible = false
	
	if legend:
		writtenLabel.text = "Written"
		writtenLabel.remove_theme_font_override("font")
		literalLabel.text = "Literal"
		translateLabel.text = "Translate"
		speechLabel.text = "Speech"
		speechLabel.visible = true
		speechContainer.visible = false
		
		editBtn.visible = false
		editBtn.disabled = true
		deleteBtn.visible = false
		deleteBtn.disabled = true
	else:
		speechLabel.visible = false
		speechContainer.visible = true
		
		populateSpeechContainer()
	
	editBtn.pressed.connect(onEditPressed)
	editSaveBtn.pressed.connect(onEditSavePressed)
	editCloseBtn.pressed.connect(onEditClosePressed)
	
	var popup := editSpeechBtn.get_popup()
	popup.hide_on_checkable_item_selection = false
	popup.index_pressed.connect(onEditSpeechPressed)
	
	GlobalVars.updateWrittenFont.connect(onUpdateWrittenFont)
	onUpdateWrittenFont()
	
	deleteBtn.pressed.connect(onDeletePressed)
	deleteYesBtn.pressed.connect(onDeleteYesPressed)
	deleteNoBtn.pressed.connect(onDeleteNoPressed)

func populateSpeechContainer() -> void:
	var i: int = 0
	for pos: String in GlobalVars.POS: 
		var label := AutoSizeLabel.new()
		label.maxFontSize = 20
		label.text = pos.capitalize()
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.visible = false
		speechContainer.add_child(label)
		
		var popup := editSpeechBtn.get_popup()
		popup.add_item(label.text)
		popup.set_item_as_checkable(i, true)
		i += 1

func onEditPressed() -> void:
	editWrittenBox.text = writtenLabel.text
	editLiteralBox.text = literalLabel.text
	editTranslateBox.text = translateLabel.text
	#editSpeechBox.text = speechLabel.text
	
	for i in range(speechContainer.get_children().size()):
		var label: Label = speechContainer.get_child(i)
		editSpeechBtn.get_popup().set_item_checked(i, label.visible)
	
	menus.visible = true
	editMenu.visible = true
	deleteMenu.visible = false

func onEditSavePressed() -> void:
	writtenLabel.text = editWrittenBox.text
	literalLabel.text = editLiteralBox.text
	translateLabel.text = editTranslateBox.text
	#speechLabel.text = editSpeechBox.text
	
	for i in range(speechContainer.get_children().size()):
		var label: Label = speechContainer.get_child(i)
		label.visible = editSpeechBtn.get_popup().is_item_checked(i)
	
	onEditClosePressed()

func onEditClosePressed() -> void:
	menus.visible = false
	editMenu.visible = false

func onEditSpeechPressed(index: int) -> void:
	editSpeechBtn.get_popup().toggle_item_checked(index)

func onUpdateWrittenFont() -> void:
	if legend || OS.get_name() == "Web":
		return
	
	if GlobalVars.useWrittenFont && GlobalVars.writtenFont:
		writtenLabel.add_theme_font_override("font", GlobalVars.writtenFont)
	else:
		writtenLabel.remove_theme_font_override("font")

func onDeletePressed() -> void:
	menus.visible = true
	editMenu.visible = false
	deleteMenu.visible = true

func onDeleteYesPressed() -> void:
	queue_free()

func onDeleteNoPressed() -> void:
	menus.visible = false
	deleteMenu.visible = false
