--[[
GPL License

Copyright (c) 2025 Iranoan

conky_analog (analog): Display an analog clock in the upper-right corner
conky_draw_line (draw_line): draw line in conky.text
]]

require 'cairo'
require 'cairo_xlib'
local socket = require 'socket'

-- global variable
local UTC_OFFSET = os.time()
UTC_OFFSET = os.date("*t", UTC_OFFSET).hour - os.date("!*t", UTC_OFFSET).hour
local TWO_PI = 2 * math.pi
local HALF_PI = math.pi / 2
local HOUR2SEC = 60 * 60
local Radius = 0
local LineWidth
local Center
local HourHand
local MinuteHand
local SecondHand
local ClockDial = {sec = {}, min = {}}
-- --RGB values for colour
local background = {
	red = 0,
	green = 0x2B / 0xFF,
	blue = 0x36 / 0xFF
}
local HandColor = { -- minute/hour hand color
	red = 0xEE / 0xFF,
	green = 0xE8 / 0xFF,
	blue = 0xD5 / 0xFF
}
local ContourColor = { -- minute/hour hand color (contour)
	red = 0x93 / 0xFF,
	green = 0xA1 / 0xFF,
	blue = 0xA1 / 0xFF
}
local SecondColor = { -- SecondColor hand color
	red = 0xCB / 0xFF,
	green = 0x4B / 0xFF,
	blue = 0x16 / 0xFF
}
local DialColor = {
	red = 0xB5 / 0xFF,
	green = 0x89 / 0xFF,
	blue = 0
}

function conky_analog()
	local function printDial(cr)
		cairo_set_source_rgb(cr, background.red, background.green, background.blue)
		cairo_arc(cr, Center.x, Center.y, Radius, 0, TWO_PI)
		cairo_fill(cr)
		cairo_set_line_width(cr, LineWidth * 4)
		cairo_set_source_rgb(cr, DialColor.red, DialColor.green, DialColor.blue)
		cairo_arc(cr, Center.x, Center.y, Radius, 0, TWO_PI)
		cairo_stroke(cr)
		cairo_set_line_width(cr, LineWidth * 2)
		cairo_arc(cr, Center.x, Center.y, Radius * 0.9, 0, TWO_PI)
		local dial = ClockDial.min
		for i = 1, #dial do
			cairo_move_to(cr, dial[i][1].x, dial[i][1].y)
			cairo_line_to(cr, dial[i][2].x, dial[i][2].y)
		end
		cairo_stroke(cr)
		cairo_set_line_width(cr, LineWidth)
		dial = ClockDial.sec
		for i = 1, #dial do
			cairo_move_to(cr, dial[i][1].x, dial[i][1].y)
			cairo_line_to(cr, dial[i][2].x, dial[i][2].y)
		end
		cairo_stroke(cr)
	end

	local function drawHand(cr, hand, angle)
		local function drawRectangle(h)
			local p = RotatePoint(h.p3, 0, angle) -- 3時方向の点 A
			cairo_move_to(cr, p.x, p.y)
			p = RotatePoint(0, -h.p0, angle)      -- 6時方向の点
			cairo_line_to(cr, p.x, p.y)
			p = RotatePoint(h.p9, 0, angle)       -- 9時方向の点
			cairo_line_to(cr, p.x, p.y)
			p = RotatePoint(0, h.p0, angle)       -- 12時方向の点 B
			cairo_line_to(cr, p.x, p.y)
			cairo_close_path(cr)
			cairo_set_source_rgb(cr, h.color.red, h.color.green, h.color.blue)
			cairo_fill_preserve(cr)
			cairo_stroke(cr)
		end
		if next(hand.inner) == nil then -- 内外同色は細い線ななので、幅0で描画すると先端が消える
			cairo_set_line_width(cr, 1)
			drawRectangle(hand.out)
		else
			cairo_set_line_width(cr, 0)
			drawRectangle(hand.out)
			drawRectangle(hand.inner)
		end
	end

	local function make_clock_hand(long, short, width, in_color, out_color)
		--[[ cairo の描画で枠線を使うと先端が尖らないので、時針・分針・秒針を枠線相当に見えるように重なるダイヤ型2つ描画する→頂点座標を計算
				 針が3時を指している時
					long: 3時方向に伸びる長さ (四角形の頂点A)
					short: 9時方向に伸びる長さ (四角形の頂点Bは*-1)
					width: 最大幅 (0,6 時方向の長さの倍) (四角形の頂点C, D)
					in_color: 内側の色
					out_color: 外側の色 (枠線)
					→0, 3, 9 時方向の x, y どちらかの座標 (p0, p3, p9: もう一方は 0) と色 (color) の table にする
		]]
		local hand = {out = {p3 = long, p9 = -short, p0 = width / 2, color = out_color}}
		if next(in_color) == nil then
			hand.inner = {}
		else -- 内側は最も太い部分の 1/4 までを枠線とする→縦横半分に分割した三角形の斜辺半分まで
			hand.inner = {p3 = long / 2, p9 = -short / 2, p0 = width / 4, color = in_color}
		end
		return hand
	end

	local function makeDial()
		local from, to, angle
		local r = Radius * 0.9
		for i = 1, 29 do
			if i % 5 ~= 0 then
				angle = i * TWO_PI / 60
				from = RotatePoint(r, 0, angle)
				to = RotatePoint(Radius, 0, angle)
				table.insert(ClockDial.sec, {from, to})
				from = RotatePoint(-r, 0, angle)
				to = RotatePoint(-Radius, 0, angle)
				table.insert(ClockDial.sec, {from, to})
			end
		end
		r = Radius * 0.8
		for i = 0, 5 do
			angle = i * TWO_PI / 12
			from = RotatePoint(r, 0, angle)
			to = RotatePoint(Radius, 0, angle)
			table.insert(ClockDial.min, {from, to})
			from = RotatePoint(-r, 0, angle)
			to = RotatePoint(-Radius, 0, angle)
			table.insert(ClockDial.min, {from, to})
		end
	end

	local cs, cr
	if conky_window == nil then
		return
	end

	if cs == nil or cairo_xlib_surface_get_width(cs) ~= conky_window.width or cairo_xlib_surface_get_height(cs) ~= conky_window.height then
		if cs then
			cairo_surface_destroy(cs)
		end
		cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height)
	end
	if cr then
		cairo_destroy(cr)
	end
	cr = cairo_create(cs)
	if Radius == 0 then
		Radius = math.min(conky_window.width, conky_window.height) * 0.2
		LineWidth = Radius * 0.01
		Center = {x = conky_window.width - Radius - LineWidth * 2, y = Radius + LineWidth * 2}
		HourHand   = make_clock_hand(Radius * 0.8,  Radius * 0.2, LineWidth * 20, HandColor, ContourColor)
		MinuteHand = make_clock_hand(Radius * 0.9,  Radius * 0.2, LineWidth * 20, HandColor, ContourColor)
		SecondHand = make_clock_hand(Radius * 0.98, Radius * 0.3, LineWidth * 3,  {},        SecondColor)
		makeDial()
	end

	printDial(cr)

	local ts = '' .. socket.gettime()
	local milsec = tonumber(string.sub(ts, -5)) * 10000 % 10000 / 10000
	ts = tonumber(ts) - milsec
	local sec = ts % 60
	ts = ts // 60
	local min = ts % 60
	ts = (ts // 60 + UTC_OFFSET) % 12
	local theta = TWO_PI * (ts * HOUR2SEC + min * 60 + sec + milsec) / (HOUR2SEC * 12) - HALF_PI
	drawHand(cr, HourHand, theta)
	theta = TWO_PI * (min * 60 + sec + milsec) / HOUR2SEC - HALF_PI
	drawHand(cr, MinuteHand, theta)
	cairo_set_source_rgb(cr, SecondColor.red, SecondColor.green, SecondColor.blue)
	theta = TWO_PI * sec / 60 - HALF_PI -- conky.conf で update_interval を細かくしても、秒針はなめらかに動かさない→milsec は足さない
	drawHand(cr, SecondHand, theta)
	cairo_arc(cr, Center.x, Center.y, LineWidth * 5, 0, TWO_PI)
	cairo_fill(cr)
	cairo_destroy(cr)
	cairo_surface_destroy(cs)
	cr = nil
end

function RotatePoint(x, y, angle)
	local sin = math.sin(angle)
	local cos = math.cos(angle)
	return {
		x = cos * x - sin * y + Center.x,
		y = sin * x + cos * y + Center.y
	}
end

function conky_draw_line(x0, y0, x1, y1, r, g, b, w)
	local cs, cr
	if conky_window == nil then
		return
	end

	if cs == nil or cairo_xlib_surface_get_width(cs) ~= conky_window.width or cairo_xlib_surface_get_height(cs) ~= conky_window.height then
		if cs then
			cairo_surface_destroy(cs)
		end
		cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height)
	end
	if cr then
		cairo_destroy(cr)
	end
	cr = cairo_create(cs)
	cairo_set_line_width(cr, w)
	cairo_set_source_rgb(cr, r, g, b)
	-- 細い線が薄くなるのを防ぐために一旦整数化して座標をピクセルの中間 (+0.5) にして描画する
	x0 = math.floor(x0)
	x1 = math.floor(x1)
	y0 = math.floor(y0)
	y1 = math.floor(y1)
	cairo_move_to(cr, x0 + 0.5, y0 + 0.5)
	cairo_line_to(cr, x1 + 0.5, y1 + 0.5)
	cairo_stroke(cr)
	cairo_destroy(cr)
	cairo_surface_destroy(cs)
	cr = nil
	if conky_window == nil then
		return "conky_window is nil"
	-- elseif conky_window.surface == nil then
	-- 	return "conky_window.surface is nil (Wayland mode)"
	end
	return ""
end
