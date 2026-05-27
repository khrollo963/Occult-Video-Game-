class_name BackgroundApplier
extends RefCounted

const LEGACY_MENU := Color(0.37280384, 0.2171683, 0.5887938, 1.0)
const LEGACY_MIKE := Color(1.0, 0.0, 0.0, 1.0)
const LEGACY_GABE := Color(0.0, 0.023529412, 0.9098039, 1.0)
const LEGACY_YURI := Color(0.08, 0.25, 0.12, 1.0)
const LEGACY_RAPH := Color(1.0, 1.0, 0.2, 1.0)


static func apply(root: Node, legacy_color: Color) -> void:
	var settings: Node = root.get_node_or_null("/root/SettingsManager")
	var use_classic := false
	if settings:
		use_classic = settings.background_style == "classic"

	var gradient := root.get_node_or_null("SimpleGradientBg")
	var decor := root.get_node_or_null("SkyOverlay")
	var legacy := root.get_node_or_null("LegacyBackground")

	if gradient:
		gradient.visible = not use_classic
	if decor:
		decor.visible = not use_classic
	if legacy:
		legacy.visible = use_classic
		var fill: ColorRect = legacy.get_node_or_null("Fill")
		if fill:
			fill.color = legacy_color
