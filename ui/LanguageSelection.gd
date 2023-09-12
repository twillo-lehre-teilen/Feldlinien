extends Popup


onready var language_chooser := $VBoxContainer/LanguageChooser

var locales = []


func _on_LanguageSelection_about_to_show() -> void:
	update_locales()


func update_locales() -> void:
	# fetch the loaded locales
	locales = TranslationServer.get_loaded_locales()
	# populate the locale dropdown
	language_chooser.clear()
	var current_locale = TranslationServer.get_locale()
	var index := 0
	for locale in locales:
		var locale_name = TranslationServer.translate("LOCALE_" + locale.to_upper())
		if locale_name.empty():
			locale_name = TranslationServer.get_locale_name(locale)
		language_chooser.add_item(locale_name)
		if current_locale.begins_with(locale):
			# select the currently active locale
			language_chooser.select(index)
		index += 1


func _on_LanguageChooser_item_selected(index: int) -> void:
	# apply the new locale
	var selected_locale = locales[index]
	TranslationServer.set_locale(selected_locale)
	# this forces the popup to recalculate its dimensions
	rect_size = Vector2.ZERO
	hide()
	popup_centered()


func _on_ButtonOK_pressed() -> void:
	hide()
