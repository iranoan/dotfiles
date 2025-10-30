scriptencoding utf-8

function set_altercmd#main()
	packadd vim-altercmd
	AlterCommand e[dit]     TabEdit
	AlterCommand ut[f8]     edit\ ++enc=utf8
	AlterCommand sj[is]     edit\ ++enc=cp932
	AlterCommand cp[932]    edit\ ++enc=cp932
	AlterCommand eu[c]      edit\ ++enc=eucjp-ms
	AlterCommand ji[s]      edit\ ++enc=iso-2022-jp-3
	AlterCommand mak[e]     silent\ make
	AlterCommand lmak[e]    silent\ lmake
	AlterCommand tabd[o]    silent\ tabdo
	AlterCommand windo      silent\ windo
	AlterCommand argdo      silent\ argdo
	AlterCommand cdo        silent\ cdo
	AlterCommand cfdo       silent\ cfdo
	AlterCommand ld[o]      silent\ ldo
	AlterCommand lfdo       silent\ lfdo
	AlterCommand ter[minal] topleft\ terminal
	AlterCommand man        Man
	AlterCommand p[rint]    PrintBuffer
	" ↑:print は使わないので、印刷に置き換え
	AlterCommand u[pdate]   update
	" ↑:update の短縮形は :up で :u は :undo だがまず使わない
	AlterCommand ua[ll]     bufdo\ update
	AlterCommand helpt[ags] PackManage\ tags
	AlterCommand bc         .!bc\ -l\ -q\ ~/.config/bc\ <Bar>\ sed\ -E\ -e\ 's/^\\\./0./g'\ -e\ 's/(\\\.[0-9]*[1-9])0+/\\\1/g'\ -e\ 's/\\\.$//g'
	AlterCommand bi[nary]   if\ !&binary\ <Bar>\ execute('setlocal\ binary\ <Bar>\ %!xxd')\ <Bar>\ endif
	AlterCommand nob[inary] if\ &binary\ <Bar>\ execute('setlocal\ nobinary\ <Bar>\ %!xxd\ -r')\ <Bar>\ endif
	" fugitive.vim 用 (glob() を使う存在確認は遅い)
	AlterCommand git      Git
	AlterCommand gl[og]   Gllog
	AlterCommand gd[iff]  Gdiffsplit
	" grep, lgpre は gnu-grep に置き換え
	AlterCommand gr[ep]     Grep
	AlterCommand lgr[ep]    LGrep
	AlterCommand grepa[dd]  Grepadd
	AlterCommand lgrepa[dd] LGrepadd
	call timer_start(1, {->execute('delfunction set_altercmd#main')})
endfunction
