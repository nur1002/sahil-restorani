@tool
class_name IsoBox
extends StaticBody2D
## Gri kutu prototip nesnesi: izometrik bir kutu çizer ve tabanına çarpışma koyar.
## Inspector'dan boyut, yükseklik, renk ve etiket değiştirilebilir; editörde anında görünür.

const HALF_W := 32.0  # karo genişliğinin yarısı (64 / 2)
const HALF_H := 16.0  # karo yüksekliğinin yarısı (32 / 2)

## Kaç karo kapladığı (x: sağ-aşağı, y: sol-aşağı yönü)
@export var cells := Vector2(1, 1):
	set(v):
		cells = v
		_refresh()
## Kutunun ekrandaki yüksekliği (piksel)
@export var height := 20.0:
	set(v):
		height = v
		_refresh()
@export var color := Color("#B5825A"):
	set(v):
		color = v
		_refresh()
## Kutunun üstünde yazan isim (prototipte neyin ne olduğunu görmek için)
@export var etiket := "":
	set(v):
		etiket = v
		_refresh()


func _ready() -> void:
	_refresh()


func footprint() -> PackedVector2Array:
	var ex := Vector2(HALF_W, HALF_H) * cells.x / 2.0
	var ey := Vector2(-HALF_W, HALF_H) * cells.y / 2.0
	return PackedVector2Array([-ex - ey, ex - ey, ex + ey, -ex + ey])  # üst, sağ, alt, sol


func _refresh() -> void:
	queue_redraw()
	var col := get_node_or_null("CollisionPolygon2D") as CollisionPolygon2D
	if col:
		col.polygon = footprint()


func _draw() -> void:
	var f := footprint()
	var up := Vector2(0, -height)
	var top := PackedVector2Array([f[0] + up, f[1] + up, f[2] + up, f[3] + up])
	# Işık sağ üstten gelir ama tasarım belgesine göre sol yüz aydınlık, sağ yüz gölgeli.
	draw_colored_polygon(PackedVector2Array([f[3] + up, f[2] + up, f[2], f[3]]), color.lightened(0.12))
	draw_colored_polygon(PackedVector2Array([f[2] + up, f[1] + up, f[1], f[2]]), color.darkened(0.25))
	draw_colored_polygon(top, color)
	draw_polyline(PackedVector2Array([top[0], top[1], top[2], top[3], top[0]]), color.darkened(0.4), 1.0)
	if etiket != "":
		var font := ThemeDB.fallback_font
		var pos := Vector2(-100, f[0].y + up.y - 8)
		draw_string_outline(font, pos, etiket, HORIZONTAL_ALIGNMENT_CENTER, 200, 14, 4, Color(0, 0, 0, 0.6))
		draw_string(font, pos, etiket, HORIZONTAL_ALIGNMENT_CENTER, 200, 14, Color.WHITE)
