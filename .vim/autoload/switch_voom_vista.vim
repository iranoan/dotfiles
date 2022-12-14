" Voom に未対応は Vista を使う様に分岐関数とキーマップ
scriptencoding utf-8

function switch_voom_vista#main() abort
	" 対応しているファイルが存在するか? を使って、次のコマンドでリスト化
	" r!find "$HOME/.vim/pack/github/opt/VOoM/autoload/voom/" -type d | xargs --no-run-if-empty -I{} find "{}" -type f -name "voom_mode_*.py" | sed -r -e 's:.+/voom_mode_:'\'':g' -e 's:\.py:'\'':g' | tr '\n' ','| sed -e 's/,/, /g' -e 's/, $//g'
	let l:voom_support_list = [
				\ 'asciidoc', 'cwiki', 'dokuwiki', 'fmr', 'fmr1', 'fmr2', 'fmr3', 'hashes', 'html', 'xhtml', 'inverseAtx', 'latex', 'latexDtx', 'markdown', 'org', 'pandoc', 'paragraphBlank', 'paragraphIndent', 'paragraphNoIndent', 'python', 'rest', 'taskpaper', 'thevimoutliner', 'txt2tags', 'viki', 'vimoutliner', 'vimwiki', 'wiki'
				\ ]
	if &filetype ==? 'tex'
		silent execute 'Voom latex'
	elseif &filetype ==? 'text'
		silent execute 'Voom markdown'
		echo 'Voom markdown'
	elseif index( [ 'c', 'h', 'cpp', 'sh', 'python', 'vim' ], &filetype ) >= 0 " taglist, Voom 両方に対応しているファイルタイプも有るので、取り敢えずこれだけを Vista を使う
		silent Vista
	elseif &filetype ==? 'xhtml'
		silent Voom html
	elseif index( l:voom_support_list, &filetype ) >= 0
		silent execute 'Voom ' . &filetype
	else
		echomsg 'No Support filetype:''' . &filetype . ''''
	endif
endfunction
