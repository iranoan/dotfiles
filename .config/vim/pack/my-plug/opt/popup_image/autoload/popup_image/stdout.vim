vim9script
scriptencoding utf-8

def UnzipText(zip: string, inner_path: string): string
	var lines: list<string> = systemlist(['unzip', '-p', zip, inner_path])
		->map((_, v) => substitute(v, '\([\n\r]\|<!--[^>]*-->\)', '', 'g'))
	return v:shell_error == 0 ? join(lines, '') : ''
enddef

def GetEpubInfo(id: number, p: string): dict<string>
	if !executable('unzip')
		popup_image#AddErrorMessage(id, ['Install unzip'])
		return {}
	endif
	var epub_path: string = expand(p)->fnamemodify(':p')
	var container_xml: string = UnzipText(p, 'META-INF/container.xml')
	if empty(container_xml)
		popup_image#AddErrorMessage(id, ["Do not find 'META-INF/container.xml'"])
		return {}
	endif
	var path: string = matchstr(container_xml, 'full-path="\zs[^"]\+\ze"')
	if empty(path)
		popup_image#AddErrorMessage(id, ['Do not find opf file'])
		return {}
	endif
	var xml: string = UnzipText(epub_path, path)
	if empty(xml)
		popup_image#AddErrorMessage(id, [$"Do not include opf file: {path}"])
		return {}
	endif
	return {
		epub_path: epub_path,
		path: path,
		xml: xml
	}
enddef

def EpubMetaData(id: number, epub: string, info: dict<any>): list<string>
	var xml: list<string> = split(info.xml, '>\zs\s*\ze<')
	var meta_idx: list<number> = matchstrlist(xml, '\(<metadata\s\+xmlns:dc=["'']http://purl\.org/dc/elements/1\.1/["'']>\|</metadata>\)')
		->mapnew((_, v) => v.idx)
	if len(meta_idx) < 2
		popup_image#AddErrorMessage(id, [$"Do not get metadata: {epub}"])
		return []
	endif
	return [
			'<?xml version="1.0" encoding="UTF-8"?>',
			'<package',
			'  xmlns="http://www.idpf.org/2007/opf"',
			'  version="3.0"',
			'  xml:lang="ja"',
			'  unique-identifier="unique-id"',
			'  prefix="ebpaj: http://www.ebpaj.jp/"',
			'>'
		]
		+ map(xml[meta_idx[0] : meta_idx[1]], (_, v) => substitute(v, '\(\s\+\ze<\|>\zs\s\+\)', '', 'g'))
		  	->map((_, v) => v !~# '^</\?metadata[^>]*>$' ? $'  {v}' : v )
		+ ['</package>']
enddef

export def Epub(id: number, epub: string): dict<any>
	var info: dict<any> = GetEpubInfo(id, epub)
	if info == {}
		return {}
	endif
	# EPUB3: <item ... properties="...cover-image..." id="ID" ...>
	var cover_item_match: string = matchstr(info.xml, '<item\s\+[^>]*properties="[^"]*cover-image[^"]*"[^>]*>')
	var cover_id: string
	if !empty(cover_item_match)
		cover_id = matchstr(cover_item_match, 'id="\zs[^"]\+\ze"')
	endif
	# EPUB2: <meta name="cover" content="ID" />
	if empty(cover_id)
		var meta_match: string = matchstr(info.xml, '<meta\s\+[^>]*name="cover"[^>]*content="\zs[^"]\+\ze"')
		if !empty(meta_match)
			cover_id = meta_match
		endif
	endif
	# 4. 表紙画像の href (相対パス) を特定
	var image_href: string
	if !empty(cover_id)
		var item_by_id: string = matchstr(info.xml, $'<item\s\+[^>]*id="{cover_id}"[^>]*>')
		image_href = matchstr(item_by_id, 'href="\zs[^"]\+\ze"')
	else
		image_href = matchstr(cover_item_match, 'href="\zs[^"]\+\ze"')
	endif
	if empty(image_href)
		popup_image#AddErrorMessage(id, [$"Do not include image file: {image_href}"])
		return {
			cmd: [],
			message: EpubMetaData(id, epub, info),
			type: 'xml'
		}
	endif
	var opf_dir: string = fnamemodify(info.path, ':h')
	var full_image_path: string = (opf_dir == '.' || empty(opf_dir))
		? image_href
		: opf_dir .. '/' .. image_href

	# unzip -c (標準出力に書き出す) <epub> <内部画像パス>
	return {
			cmd: ['unzip', '-p', info.epub_path, full_image_path],
			message: EpubMetaData(id, epub, info),
			type: 'xml'
		}
enddef

export def CBZ(id: number, cbz: string): dict<any>
	if !executable('unzip')
		popup_image#AddErrorMessage(id, ['Install unzip'])
		return {}
	endif
	var file_list = systemlist(['unzip', '-Z1', cbz])
		->filter((_, v) => v !~? '__MACOSX' && v !~? '^\.') # macOSの __MACOSX などの不要な隠しフォルダ・ファイルを除外
	if v:shell_error != 0 || file_list == []
		popup_image#AddErrorMessage(id, ['Do not include file'])
		return {}
	endif
	var cover_entries: list<string>

	# ComicInfo.xml がある場合
	var xml_entry: list<string> = file_list->copy()->filter((_, v) => v =~? '\c^comicinfo\.xml$')
	if xml_entry != []
		# unzip -p で標準出力に展開して取得
		var xml_content: string = UnzipText(cbz, xml_entry[0])
		if xml_content !=# ''
			var cover_file: string = matchstr(xml_content, '\c<page\s\+[^<>]*type=["'']\%(cover["'']\|image="["'']0"["'']\)[^<>]*>')
			if cover_file !=# ''
				cover_file = matchstr(cover_file, '\c\%(key\|file\|imagepath\|name\)=\zs\("[^"]\+"\|''[^'']\+''\)\ze' )
			endif
			if cover_file !=# ''
				cover_entries = file_list->copy()->filter((_, v) => v ==# cover_file || v =~? $'/{cover_file}$')
				if cover_entries != []
					return {
						cmd: ['unzip', '-p', cbz, cover_entries[0]],
						message: [],
						type: ''
					}
				endif
			endif
		endif
	endif
	var img_ext_pat: string = '\c\.\(jpg\|jpeg\|png\|webp\|gif\|avif\|jxl\)$'
	# cover.* ファイルの検索
	cover_entries = file_list->copy()
		->filter((_, v) => v =~? $'/\(cover\|folder\){img_ext_pat}' || v =~? $'^cover{img_ext_pat}')
	if cover_entries != []
		return {
			cmd: ['unzip', '-p', cbz, cover_entries[0]],
			message: [],
			type: ''
		}
	endif

	# 名前順で先頭になる画像ファイル
	cover_entries = filter(file_list, (_, v) => v =~? img_ext_pat)
		->sort()
	if cover_entries == []
		popup_image#AddErrorMessage(id, ['Do not include file'])
		return {}
	endif
	return {
		cmd: ['unzip', '-p', cbz, cover_entries[0]],
		message: [],
		type: ''
	}
enddef
