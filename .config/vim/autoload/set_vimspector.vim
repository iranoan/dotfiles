scriptencoding utf-8

function set_vimspector#main(cmd) abort
	let g:vimspector_enable_mappings = 'HUMAN' " packadd の前で指定しないと、実際には mapping されない
	" let g:vimspector_variables_display_mode = 'full'
	call pack_manage#SetMAP('vimspector', a:cmd, [
				\ #{mode: 'n', key: '<Leader>df',       method: 1, cmd: 'call vimspector#AddFunctionBreakpoint(''<cexpr>'')'},
				\ #{mode: 'n', key: '<Leader>dc',       method: 1, cmd: 'call vimspector#Continue()'},
				\ #{mode: 'n', key: '<Leader>dd',       method: 1, cmd: 'call vimspector#DownFrame()'},
				\ #{mode: 'n', key: '<Leader>dp',       method: 1, cmd: 'call vimspector#Pause()'},
				\ #{mode: 'n', key: '<Leader>dR',       method: 1, cmd: 'call vimspector#Restart()'},
				\ #{mode: 'n', key: '<Leader>dr',       method: 1, cmd: 'call vimspector#RunToCursor()'},
				\ #{mode: 'n', key: '<Leader>ds',       method: 1, cmd: 'call vimspector#StepInto()'},
				\ #{mode: 'n', key: '<Leader>dS',       method: 1, cmd: 'call vimspector#StepOut()'},
				\ #{mode: 'n', key: '<Leader>dn',       method: 1, cmd: 'call vimspector#StepOver()'},
				\ #{mode: 'n', key: '<Leader>d<Space>', method: 1, cmd: 'call vimspector#Stop()'},
				\ #{mode: 'n', key: '<Leader>db',       method: 1, cmd: 'call vimspector#ToggleBreakpoint()'},
				\ #{mode: 'n', key: '<Leader>dx',       method: 1, cmd: 'call vimspector#Reset( { ''interactive'': v:false } )'},
				\ #{mode: 'n', key: '<Leader>di',       method: 0, cmd: 'VimspectorBalloonEval'},
				\ #{mode: 'x', key: '<Leader>di',       method: 0, cmd: 'VimspectorBalloonEval'},
				\ ] )
	call timer_start(1, {->execute('delfunction set_vimspector#main')})
endfunction
