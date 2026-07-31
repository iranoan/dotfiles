vim9script
scriptencoding utf-8

g:popup_image_options = extend(deepcopy({pt2px: {x: 96, y: 96}, min_size: {x: 5, y: 5}}), get(g:, 'popup_image_options', {}), 'force')

var popup_options: dict<any> = {
	image: {},
	border: [1, 1, 1, 1],
	padding: [1, 1, 1, 1],
	opacity: 100
}

export def Clear(id: number): void
	if has_key(popup_getoptions(id), 'image')
		popup_setoptions(id, popup_options)
		redraw!
	endif
enddef

export def Preview(id: number, f: string): bool # パス f の画像、動画、PDF を表示
	var opts: dict<any> = popup_getoptions(id)
	var max_w: number = opts.maxwidth ==  0 ? &columns : opts.maxwidth
	var max_h: number = opts.maxheight == 0 ? &lines   : opts.maxheight

	def ScaleImage(w: number, h: number): list<number>
		var scale: float = min([max_w * 5.0 / w * g:popup_image_options.pt2px.x / 72, max_h * 10.0 / h * g:popup_image_options.pt2px.y / 72])

		if scale > 1
			scale = max([g:popup_image_options.min_size.x * 5.0 / w * g:popup_image_options.pt2px.x / 72, g:popup_image_options.min_size.y * 10.0 / h * g:popup_image_options.pt2px.y / 72])
			if scale > 1
				return [float2nr(round(w * scale)), float2nr(round(h * scale))]
			endif
			return [w, h]
		endif
		return [float2nr(round(w * scale)), float2nr(round(h * scale))]
	enddef

	var p: string = shellescape(resolve(expand(f, true)))
	var w: number
	var h: number
	var t: string
	var ft: string = systemlist('file --mime-type --brief ' .. p)[0]
	var img_data: blob
	var w_h: list<number>

	if get(opts, 'image', {}) == {}
		popup_options = extendnew(opts, {image: {}})
	else # 連続して呼び出されたときに、消さないと後ろに残る
		Clear(id)
	endif
	if ft =~# '^video/'
		t = '-ss ' .. str2nr(system('ffprobe -v error -show_entries format=duration -of csv=p=0 ' .. p )) / 10.0
	elseif ft !=# 'application/pdf' && ft !~# '^image/' && ft !=# 'application/postscript'
		return true
	endif
	if ft ==# 'application/pdf'
		[w, h] = systemlist('pdfinfo ' ..  p)
			->filter((_, v) => v =~ '^Page size: ')[0]
			->matchlist('^Page size: \+\zs\(\d\+\.\?\d*\) x \(\d\+\.\?\d*\) pts')[1 : 2]
			->map((_, v) => float2nr(round(str2float(v) * 80 / 72)))
		[w, h] = ScaleImage(w, h)
		img_data = str2blob(systemlist($'pdftoppm -f 1 -l 1 -r 80 -scale-to-x {w} -scale-to-y {h} {p}')[3 : ])
	elseif ft ==# 'application/postscript'
		w_h = systemlist($'gs -dQUIET -dBATCH -dNOPAUSE -sDEVICE=bbox {p} 2>&1')
			->matchlist('^%%BoundingBox: \+\zs\(\d\+\.\?\d*\) \(\d\+\.\?\d*\) \(\d\+\.\?\d*\) \(\d\+\.\?\d*\)')[1 : ]
			->map((_, v) => float2nr(round(str2float(v) * 300 / 72)))
		[w, h] = ScaleImage(w_h[2] - w_h[0], w_h[3] - w_h[1])
		img_data = str2blob(systemlist($'gs -dQUIET -dBATCH -dNOPAUSE -dNOPROMPT -sDEVICE=png16m -r300 -sOutputFile=- {p} | ffmpeg -i - -f rawvideo -vf ''scale={w}:{h}'' -pix_fmt rgb24 - 2> /dev/null'))
	else
		[w, h] = split(system('ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0 ' .. p), ',')
		         	->map((_, v) => str2nr(v))
		[w, h] = ScaleImage(w, h)
		img_data = str2blob(systemlist($'ffmpeg {t} -i {p} -vf ''scale={w}:{h}'' -vframes 1 -f rawvideo -pix_fmt rgb24 - 2> /dev/null'))
	endif
	if len(img_data) != w * h * 3
		return false
	endif
	popup_setoptions(id, {
		image: {data: img_data, width: w, height: h},
		maxwidth: max_w, # 縦横サイズを指定しないと、連続して使われたときに直前に表示された画像サイズに引きずられる
		maxheight: max_h,
		border: [0, 0, 0, 0],
		padding: [0, 0, 0, 0], opacity: 0
	})
	return true
enddef

export def ResetPreview(id: number, f: string): void
	popup_options = extendnew(popup_getoptions(id), {image: {}})
	popup_setoptions(id, popup_options)
	if tabpagenr() == getwininfo(id)[0].tabnr
		Preview(id, f)
	else
		execute $'autocmd FuzzyFileFinder TabEnter * ++once if tabpagenr() == {getwininfo(id)[0].tabnr} | call popup_image#Preview({id}, ''{f}'') | endif'
	endif
enddef
