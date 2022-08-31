scriptencoding utf-8

function set_eblook#main() abort
	" let eblook_no_default_key_mappings = 1 "デフォルトのキーマッピング<Leader>yと<Leader><C-Y>を登録しない
	" マッピングしてから読み込めば、登録されない
	call set_map_plug#main('eblook.vim', 'EblookSearch', [
				\ {'mode': 'n', 'key': '<leader>eb', 'cmd': 'EblookSearch'},
				\ {'mode': 'v', 'key': '<leader>eb', 'cmd': 'EblookSearch'}
				\ ] )
	let g:eblookenc = 'utf-8'
	let eblook_stemming = 1
	let g:eblook_dictlist1 = [
				\{
				\ 'book': '/home/hiroyuki/EPWING/readers/',
				\ 'name': 'plus',
				\ 'title': '研究社リーダーズ＋プラスＶ２',
				\},
				\{
				\ 'book': '/home/hiroyuki/EPWING/Genius/',
				\ 'name': 'genius',
				\ 'title': 'ジーニアス英和大辞典',
				\},
				\{
				\ 'book': '/home/hiroyuki/EPWING/kohjien/',
				\ 'name': 'koujien',
				\ 'title': '広辞苑　第四版',
				\},
				\{
				\ 'book': '/home/hiroyuki/EPWING/Gakken/',
				\ 'name': 'kanjigen',
				\ 'title': '漢字源',
				\},
				\]
	let g:eblook_viewers = {
				\'jpeg': 'xdg-open %s &',
				\'bmp': 'xdg-open %s &',
				\'pbm': 'xdg-open %s &',
				\'wav': 'xdg-open %s &',
				\'mpg': 'xdg-open %s &',
				\}
endfunction
