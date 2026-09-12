vim9script
scriptencoding utf-8

export def PptxOdp(id: number, pptx: string): string
	if !executable('soffice') # check installation status of conversion program
		popup_image#AddErrorMessage(id, ['Install LibreOffice/OpenOffice and Set path to soffice'])
		return ''
	endif
	var pptx_path: string = expand(pptx)->fnamemodify(':p') # to full path
	var output_dir: string = $'{$MYVIMDIR}temp/' # output directory
	if !isdirectory(output_dir)
		mkdir(output_dir)
	endif
	var stdout: list<string> = systemlist($'soffice --headless  --convert-to png --outdir {output_dir} {pptx_path} 2>&1') # convert
	if v:shell_error != 0 # check success
		popup_image#AddErrorMessage(id, [$"Can not convert: {pptx}"] + stdout)
		return ''
	endif
	return $'{output_dir}{fnamemodify(pptx, ':t:r')}.png' # return output file path
enddef
