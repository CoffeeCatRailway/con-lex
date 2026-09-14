class_name LexEntry
extends Panel

@onready var writtenLabel: Label = $MarginContainer/HBoxContainer/HBoxContainer/FontPanel/ScrollContainer/AutoSizeLabel
@onready var literalLabel: Label = $MarginContainer/HBoxContainer/HBoxContainer/LiteralPanel/ScrollContainer/AutoSizeLabel
@onready var translateLabel: Label = $MarginContainer/HBoxContainer/HBoxContainer/TranslatePanel/ScrollContainer/AutoSizeLabel
@onready var speechLabel: Label = $MarginContainer/HBoxContainer/HBoxContainer/SpeechPanel/ScrollContainer/AutoSizeLabel

@onready var editBtn: TextureButton = $MarginContainer/HBoxContainer/Options/Control2/EditBtn
@onready var deleteBtn: TextureButton = $MarginContainer/HBoxContainer/Options/Control/DeleteBtn

@onready var menus: CanvasLayer = $Menus

@onready var editMenu: Panel = $Menus/CenterContainer/EditMenu
@onready var editSaveBtn: TextureButton = $Menus/CenterContainer/EditMenu/MarginContainer/VBoxContainer/HBoxContainer2/Panel/CenterContainer2/SaveBtn
@onready var editCloseBtn: TextureButton = $Menus/CenterContainer/EditMenu/MarginContainer/VBoxContainer/HBoxContainer2/Panel/CenterContainer/CloseBtn

@onready var editWrittenBox: TextEdit = $Menus/CenterContainer/EditMenu/MarginContainer/VBoxContainer/Written/TextEdit
@onready var editLiteralBox: TextEdit = $Menus/CenterContainer/EditMenu/MarginContainer/VBoxContainer/Literal/TextEdit
@onready var editTranslateBox: TextEdit = $Menus/CenterContainer/EditMenu/MarginContainer/VBoxContainer/Translated/TextEdit
@onready var editSpeechBox: TextEdit = $Menus/CenterContainer/EditMenu/MarginContainer/VBoxContainer/Speech/TextEdit

@onready var deleteMenu: Panel = $Menus/CenterContainer/DeleteMenu
@onready var deleteYesBtn: Button = $Menus/CenterContainer/DeleteMenu/MarginContainer/VBoxContainer/HBoxContainer/YesBtn
@onready var deleteNoBtn: Button = $Menus/CenterContainer/DeleteMenu/MarginContainer/VBoxContainer/HBoxContainer/NoBtn

@export var legend: bool = false

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
		
		editBtn.visible = false
		editBtn.disabled = true
		deleteBtn.visible = false
		deleteBtn.disabled = true
	
	editBtn.pressed.connect(onEditPressed)
	editSaveBtn.pressed.connect(onEditSavePressed)
	editCloseBtn.pressed.connect(onEditClosePressed)
	
	GlobalVars.useWrittenFont.connect(onUseWrittenFont)
	GlobalVars.updateWrittenFont.connect(onUpdateWrittenFont)
	
	deleteBtn.pressed.connect(onDeletePressed)
	deleteYesBtn.pressed.connect(onDeleteYesPressed)
	deleteNoBtn.pressed.connect(onDeleteNoPressed)

func onEditPressed() -> void:
	editWrittenBox.text = writtenLabel.text
	editLiteralBox.text = literalLabel.text
	editTranslateBox.text = translateLabel.text
	editSpeechBox.text = speechLabel.text
	
	menus.visible = true
	editMenu.visible = true
	deleteMenu.visible = false

func onEditSavePressed() -> void:
	writtenLabel.text = editWrittenBox.text
	literalLabel.text = editLiteralBox.text
	translateLabel.text = editTranslateBox.text
	speechLabel.text = editSpeechBox.text
	
	onEditClosePressed()

func onEditClosePressed() -> void:
	menus.visible = false
	editMenu.visible = false

func onUseWrittenFont(use: bool) -> void:
	if use:
		onUpdateWrittenFont()
	else:
		writtenLabel.remove_theme_font_override("font")

func onUpdateWrittenFont() -> void:
	if legend:
		return
	
	if GlobalVars.writtenFont:
		writtenLabel.add_theme_font_override("font", GlobalVars.writtenFont)

func onDeletePressed() -> void:
	menus.visible = true
	editMenu.visible = false
	deleteMenu.visible = true

func onDeleteYesPressed() -> void:
	queue_free()

func onDeleteNoPressed() -> void:
	menus.visible = false
	deleteMenu.visible = false
