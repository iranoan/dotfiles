vim9script
scriptencoding utf-8

def UnzipText(epub_path: string, inner_path: string): string
	var lines: list<string> = systemlist(['unzip', '-p', epub_path, inner_path])
	return v:shell_error == 0 ? join(lines, "\n") : ''
enddef

export def StdOutImgCmd(id: number, epub: string): list<string>
	if !executable('unzip')
		popup_image#AddErrorMessage(id, ['Install unzip'])
		return []
	endif
	var epub_path: string = expand(epub)->fnamemodify(':p')
	var output_dir: string = $'{$MYVIMDIR}temp/'
	var container_xml: string = UnzipText(epub_path, 'META-INF/container.xml')
	if !isdirectory(output_dir)
		mkdir(output_dir)
	endif
	if empty(container_xml)
		popup_image#AddErrorMessage(id, ["Do not find 'META-INF/container.xml'"])
		return []
	endif
	var opf_relative_path: string = matchstr(container_xml, 'full-path="\zs[^"]\+\ze"')
	if empty(opf_relative_path)
		popup_image#AddErrorMessage(id, ['Do not find opf file'])
		return []
	endif
	var opf_xml: string = UnzipText(epub_path, opf_relative_path)
	if empty(opf_xml)
		popup_image#AddErrorMessage(id, [$"Do not include opf file: {opf_relative_path}"])
		return []
	endif
	# EPUB3: <item ... properties="...cover-image..." id="ID" ...>
	var cover_item_match: string = matchstr(opf_xml, '<item\s\+[^>]*properties="[^"]*cover-image[^"]*"[^>]*>')
	var cover_id: string
	if !empty(cover_item_match)
		cover_id = matchstr(cover_item_match, 'id="\zs[^"]\+\ze"')
	endif
	# EPUB2: <meta name="cover" content="ID" />
	if empty(cover_id)
		var meta_match: string = matchstr(opf_xml, '<meta\s\+[^>]*name="cover"[^>]*content="\zs[^"]\+\ze"')
		if !empty(meta_match)
			cover_id = meta_match
		endif
	endif
	# 4. 表紙画像の href (相対パス) を特定
	var image_href: string
	if !empty(cover_id)
		var item_by_id: string = matchstr(opf_xml, $'<item\s\+[^>]*id="{cover_id}"[^>]*>')
		image_href = matchstr(item_by_id, 'href="\zs[^"]\+\ze"')
	else
		image_href = matchstr(cover_item_match, 'href="\zs[^"]\+\ze"')
	endif
	if empty(image_href)
		popup_image#AddErrorMessage(id, [$"Do not include image file: {image_href}"])
		return []
	endif
	var opf_dir: string = fnamemodify(opf_relative_path, ':h')
	var full_image_path: string = (opf_dir == '.' || empty(opf_dir))
		? image_href
		: opf_dir .. '/' .. image_href

	# unzip -c (標準出力に書き出す) <epub> <内部画像パス>
	return ['unzip', '-c', epub_path, full_image_path]
enddef
