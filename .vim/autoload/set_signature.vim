scriptencoding utf-8

function set_signature#main() abort
	let g:SignatureMap = {
				\ 'Leader'             :  "m",
				\ 'PlaceNextMark'      :  "m,",
				\ 'ToggleMarkAtLine'   :  "m.",
				\ 'PurgeMarksAtLine'   :  "m-",
				\ 'DeleteMark'         :  "dm",
				\ 'PurgeMarks'         :  "m<Space>",
				\ 'PurgeMarkers'       :  "m<BS>",
				\ 'GotoNextLineAlpha'  :  "']",
				\ 'GotoPrevLineAlpha'  :  "'[",
				\ 'GotoNextSpotAlpha'  :  "`]",
				\ 'GotoPrevSpotAlpha'  :  "`[",
				\ 'GotoNextLineByPos'  :  "]'",
				\ 'GotoPrevLineByPos'  :  "['",
				\ 'GotoNextSpotByPos'  :  "]`",
				\ 'GotoPrevSpotByPos'  :  "[`",
				\ 'GotoNextMarker'     :  "]-",
				\ 'GotoPrevMarker'     :  "[-",
				\ 'GotoNextMarkerAny'  :  "]=",
				\ 'GotoPrevMarkerAny'  :  "[=",
				\ 'ListBufferMarkers'  :  "m?"
				\ }
	" \ 'ListBufferMarks'    :  "m/", ←これを除外するためのようなもの
	packadd vim-signature
	call signature#utils#SetupHighlightGroups()
	call signature#sign#Refresh()
endfunction
