vim9script
scriptencoding utf-8

g:popup_image_pt2px = extend(deepcopy({x: 96, y: 96}), get(g:, 'popup_image_pt2px', {}), 'force')

var popup_options: dict<any> = {
	image: {},
	border: [1, 1, 1, 1],
	padding: [1, 1, 1, 1],
	opacity: 100
}

export def Clear(id: number): void
	if has_key(popup_getoptions(id), 'image')
		popup_setoptions(id, extendnew(popup_options, {image: {}}))
		redraw!
	endif
enddef

export def Preview(id: number, f: string): bool # パス f の画像、動画、PDF を表示
	popup_options = popup_getoptions(id)
	var max_w: number = popup_options.maxwidth
	var max_h: number = popup_options.maxheight
	var min_w: number = popup_options.minwidth
	var min_h: number = popup_options.minheight
	def ScaleImage(w: number, h: number): list<number>
		var scale: float = min([max_w * 5.0 / w * g:popup_image_pt2px.x / 72, max_h * 10.0 / h * g:popup_image_pt2px.y / 72] )

		if scale > 1
			return [w, h]
		endif
		return [float2nr(round(w * scale)), float2nr(round(h * scale))]
	enddef

	var p: string = shellescape(resolve(expand(f)))
	var w: number
	var h: number
	var t: string
	var ft: string = systemlist('file --mime-type --brief ' .. p)[0]
	var img_data: blob

	if ft =~# '^video/'
		t = '-ss ' .. str2nr(system('ffprobe -v error -show_entries format=duration -of csv=p=0 ' .. p )) / 10.0
	elseif ft !=# 'application/pdf' && ft !~# '^image/'
		return false
	endif
	if ft ==# 'application/pdf'
		[w, h] = systemlist('pdfinfo ' ..  p)
			->filter((_, v) => v =~ '^Page size: ')[0]
			->matchlist('^Page size: \+\zs\(\d\+\.\?\d*\) x \(\d\+\.\?\d*\) pts')[1 : 2]
			->map((_, v) => float2nr(round(str2float(v) * 80 / 72)))
		[w, h] = ScaleImage(w, h)
		img_data = str2blob(systemlist($'pdftoppm -f 1 -l 1 -r 80 -scale-to-x {w} -scale-to-y {h} {p}')[3 : ])
	else
		[w, h] = split(system('ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0 ' .. p), ',')
		         	->map((_, v) => str2nr(v))
		[w, h] = ScaleImage(w, h)
		img_data = str2blob(systemlist($'ffmpeg {t} -i {p} -vf ''scale={w}:{h}'' -vframes 1 -f rawvideo -pix_fmt rgb24 - 2> /dev/null'))
	endif
	if len(img_data) != w * h * 3
		return false
	endif
	popup_setoptions(id, {image: {data: img_data, width: w, height: h}, border: [0, 0, 0, 0], padding: [0, 0, 0, 0], opacity: 0})
	return true
enddef

