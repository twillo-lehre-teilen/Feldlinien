extends PanelContainer


signal closed

const FILENAME := {
	"en": "res://locale/about_text/about_en.txt",
	"de": "res://locale/about_text/about_de.txt",
}

onready var aboutText := $VBoxContainer/ScrollContainer/AboutText


func _ready() -> void:
	hide()


func do_popup() -> void:
	var f := File.new()
	var current_locale := TranslationServer.get_locale()
	current_locale = current_locale.substr(0, current_locale.find("_"))
	# fall back to "en" if there is no text for the current locale
	if !FILENAME.has(current_locale):
		current_locale = "en"
		print("current locale not found, falling back to: " + current_locale)
	f.open(FILENAME[current_locale], File.READ)
	var text := f.get_as_text()
	aboutText.bbcode_text = text
	show()


func _on_CloseButton_pressed() -> void:
	hide()
	emit_signal("closed")
