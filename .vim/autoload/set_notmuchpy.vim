scriptencoding utf-8

function set_notmuchpy#main() abort
	packadd notmuch-py-vim
	let g:notmuch_folders = [
				\ [ 'Check',          '(tag:check and not tag:Trash)'],
				\ [ 'draft',          '((folder:.draft or tag:draft) not tag:Trash not tag:Spam)' ],
				\ [ 'ToDo',           '(tag:ToDo not tag:Trash)' ],
				\ [ 'New Search',     '' ],
				\ [ '', '' ],
				\ [ 'inbox',          '(tag:inbox not tag:Trash not tag:Spam)' ],
				\ [ 'Chubu',          '(folder:.Chubu not tag:Trash not tag:Spam)' ],
				\ [ '  biwako',       '(folder:.Chubu.biwako not tag:Trash not tag:Spam)' ],
				\ [ '  chukyo',       '(folder:.Chubu.chukyo not tag:Trash not tag:Spam)' ],
				\ [ '  ComputerUser', '(date:183days..now folder:.Chubu.ComputerUser not tag:Trash not tag:Spam)' ],
				\ [ '  other',        '(date:731days..now folder:.Chubu.other not tag:Trash not tag:Spam)' ],
				\ [ 'Nifty',          '(folder:.Nifty not tag:Trash not tag:Spam)' ],
				\ [ '  Hidemaru',     '(folder:.Nifty.Hidemaru not tag:Trash not tag:Spam)' ],
				\ [ '    Beta',       '(folder:.Nifty.Hidemaru.Beta not tag:Trash not tag:Spam)' ],
				\ [ '    Macro',      '(folder:.Nifty.Hidemaru.Macro not tag:Trash not tag:Spam)' ],
				\ [ '  TuruKame',     '(folder:.Nifty.TuruKame not tag:Trash not tag:Spam)' ],
				\ [ '  HideSoft',     '(folder:.Nifty.HideSoft not tag:Trash not tag:Spam)' ],
				\ [ '  LibreOffice',  '(folder:.Nifty.LibreOffice not tag:Trash not tag:Spam)' ],
				\ [ '  Linux',        '(folder:.Nifty.Linux not tag:Trash not tag:Spam)' ],
				\ [ '  massan-ML',    '(folder:.Nifty.massan-ML not tag:Trash not tag:Spam)' ],
				\ [ '  other',        '(date:92days..now folder:.Nifty.other not tag:Trash not tag:Spam)' ],
				\ [ '', '' ],
				\ [ 'new',            '(tag:inbox and tag:unread not tag:Trash not tag:Spam)' ],
				\ [ 'unread',         '(tag:unread not tag:Trash not tag:Spam)' ],
				\ [ 'important',      '(tag:flagged not tag:Trash not tag:Spam)' ],
				\ [ 'sent+replied',   '(date:92days..now (tag:sent or tag:replied) not tag:Trash not tag:Spam)' ],
				\ [ 'attachment',     '(tag:attachment not tag:Trash not tag:Spam)' ],
				\ [ 'Trash',          '(folder:.Trash or tag:Trash)' ],
				\ [ 'Spam',           '(folder:.Spam or tag:Spam)' ],
				\ [ 'Error Date',     '(not date:1970-01-01-09:01..now not tag:Trash not tag:Spam)' ],
				\ ]
				" \ [ 'All',            'path:**' ],
				" \ [ 'Signed+ToDo',    '(tag:signed and tag:ToDo)' ],
				" \ [ 'Encrypt',        '(tag:signed or tag:encrypted)' ],
				" \ [ 'Check',          '(tag:signed or tag:encrypted) tag:ToDo' ],
				" \ [ 'Error Test',     'path:/' ],
				" \ [ 'Ubuntu',         'to:ubuntu-jp@lists.ubuntu.com' ],
				" \ [ 'Checked&replay', '(date:2021-05-01..now and folder:.Chubu.ComputerUser) and ((tag:Checked and tag:replied) or tag:sent)' ],
	" let g:notmuch_display_item = ['From', 'Subject', 'Date']
	" let g:notmuch_date_format = '%Y/%m/%d %H:%M'
	let g:notmuch_save_dir = '~/downloads' "添付ファイルを保存する標準ディレクトリ無ければカレント・ディレクトリ
	let g:notmuch_from = [
				\ {
				\     'id': 'Nifty',
				\     'address' : 'Yoshinaga Hiroyuki <yoshinaga.hiroyuki@nifty.com>',
				\     'To' : '',
				\ },
				\ {
				\     'id': 'Chubu',
				\     'address' : 'Yoshinaga Hiroyuki <hyoshi@isc.chubu.ac.jp>',
				\     'To' : '\b(chubu|newton)\.ac\.jp\b',
				\ },
				\ {
				\     'id': 'Iranoan',
				\     'address' : 'Iranoan <bxn02350@nifty.com>',
				\     'To' : '@maruo\.co\.jp\b',
				\ },
				\ {
				\     'id': 'Gmail',
				\     'address' : 'Yoshinaga Hiroyuki <yoshinaga.hiroyuki@gmail.com>',
				\     'To' : '',
				\ },
				\ {
				\     'id': 'Chubu2',
				\     'address' : 'Yoshinaga Hiroyuki <cu30893@fsc.chubu.ac.jp>',
				\     'To' : '',
				\ },
			\ ]
	let g:notmuch_to = [
				\ ['folder:.Nifty.Hidemaru.Beta' , 'turukame.3@maruo.co.jp'],
				\ ['folder:.Nifty.Hidemaru.Macro', 'hidesoft.4@maruo.co.jp'],
				\ ['folder:.Nifty.Hidemaru'       , 'hidesoft.2@maruo.co.jp'],
				\ ['folder:.Nifty.TuruKame'       , 'hidesoft.8@maruo.co.jp'],
				\ ['folder:.Nifty.HideSoft'       , 'hidesoft.1@maruo.co.jp'],
				\ ['folder:.Nifty.LibreOffice'    , 'users@ja.libreoffice.org'],
				\ ['folder:.Nifty.Linux'          , 'ubuntu-jp@lists.ubuntu.com'],
				\ ['folder:.Nifty.massan-ML'      , 'massan@massan.gr.jp'],
				\ ]
	let g:notmuch_send_param = {
				\ 'chubu\.ac\.jp$': ['msmtp', '-t', '-a', 'Chubu', '-X', '-'],
				\ '*':              ['msmtp', '-t', '-a', 'Nifty', '-X', '-']
				\ }
	let g:notmuch_save_draft = 1  " 下書きを一部書き換えたファイルを送信済みとして保存するか?
	let g:notmuch_signature_prev_forward = 1  " 転送で署名の後に本文
	let g:notmuch_save_sent_mailbox = 'inbox'
	let g:notmuch_import_mailbox = 'inbox'
	let g:notmuch_ignore_tables = 1
	let g:notmuch_open_way = {'open': 'normal \x'}
	let g:notmuch_use_commandline = 1 " ファイル・オープンダイアログを使わない
	" let g:notmuch_make_dump = 1  " notmuch dump を行う
	let g:notmuch_signature = {
				\ '*'                            : '~/.signature/gmail',
				\ 'hidesoft.1@maruo.co.jp'       : '~/.signature/empty',
				\ 'hidesoft.2@maruo.co.jp'       : '~/.signature/empty',
				\ 'hidesoft.3@maruo.co.jp'       : '~/.signature/empty',
				\ 'hidesoft.4@maruo.co.jp'       : '~/.signature/empty',
				\ 'hidesoft.5@maruo.co.jp'       : '~/.signature/empty',
				\ 'hidesoft.8@maruo.co.jp'       : '~/.signature/empty',
				\ 'turukame.3@maruo.co.jp'       : '~/.signature/empty',
				\ 'turukame.4@maruo.co.jp'       : '~/.signature/empty',
				\ 'turukame.5@maruo.co.jp'       : '~/.signature/empty',
				\ }
	augroup NotmuchPython
		autocmd!
		" 個人的な設定
		" autocmd FileType notmuch-folders setlocal listchars=extends:\ ,precedes:\ " 行末に記号非表示←この方法はグローバル
		autocmd FileType notmuch-draft let @/ = '^\(\(From\|Subject\|To\|Cc\|Bcc\):\s*\)\?$'
		" autocmd FileType notmuch-draft setlocal omnifunc=goobook_complete#Complete
		autocmd FileType notmuch-edit setlocal relativenumber | let @/ = '^$' | normal! ggn
		autocmd FileType notmuch-folders nnoremap <buffer><silent>q :bwipeout<CR>
		autocmd FileType notmuch-folders,notmuch-thread,notmuch-show nnoremap <buffer><silent><C-R> :Notmuch reload<CR>
		autocmd FileType notmuch-thread,notmuch-show nnoremap <buffer><silent>m :Notmuch mail-move<CR>
		autocmd FileType notmuch-thread,notmuch-show vnoremap <buffer><silent>m :Notmuch mail-move<CR>
		autocmd FileType notmuch-thread nnoremap <buffer><silent><leader>m :Notmuch mark<CR>
		autocmd FileType notmuch-thread nnoremap <buffer><silent><leader>A :Notmuch mark-command tag-delete<CR>
		autocmd FileType notmuch-thread nnoremap <buffer><silent><leader>a :Notmuch mark-command tag-add<CR>
		autocmd FileType notmuch-thread nnoremap <buffer><silent><leader>S :Notmuch thread-sort<CR>
		autocmd FileType notmuch-thread nnoremap <buffer><silent><leader>d :Notmuch mail-delete<CR>
		autocmd FileType notmuch-thread vnoremap <buffer><silent><leader>d :Notmuch mail-delete<CR>
		autocmd FileType notmuch-thread nnoremap <buffer><silent><leader>M :Notmuch mark-command mail-move<CR>
		autocmd FileType notmuch-thread nnoremap <buffer><silent><leader>t :Notmuch search-thread<CR>
		autocmd FileType notmuch-thread,notmuch-show nnoremap <buffer><silent><leader>/ <Cmd>Notmuch search-refine<CR>
		autocmd FileType notmuch-thread,notmuch-show nnoremap <buffer><silent><leader>n <Cmd>Notmuch search-down-refine<CR>
		autocmd FileType notmuch-thread,notmuch-show nnoremap <buffer><silent><leader>N <Cmd>Notmuch search-up-refine<CR>
		autocmd FileType notmuch-thread,notmuch-show nnoremap <buffer><silent><leader>R :Notmuch run recover-mail.sh <id:> <path:><CR>
		autocmd FileType notmuch-thread,notmuch-show nnoremap <buffer><silent>e :Notmuch tag-delete unread<CR>:Notmuch mail-edit<CR>
		" autocmd FileType notmuch-thread,notmuch-show vnoremap <buffer><silent>e :Notmuch tag-delete unread<CR>:'<,'>Notmuch mail-edit<CR>
		autocmd FileType notmuch-thread,notmuch-show nnoremap <buffer><silent>q :Notmuch close<CR>
		autocmd FileType notmuch-thread,notmuch-show nnoremap <buffer><silent>x :Notmuch tag-toggle Trash<CR>
		autocmd FileType notmuch-thread,notmuch-show vnoremap <buffer><silent>x :Notmuch tag-toggle Trash<CR>
		autocmd FileType notmuch-thread,notmuch-show setlocal nospell
		" autocmd FileType notmuch-draft call search('^\(\(From\|Subject\|To\|Cc\|Bcc\):\s*\)\?$', 'e')
		" ごく個人的なタグ付け
		autocmd FileType notmuch-folders,notmuch-thread,notmuch-show nnoremap <buffer><silent><Leader>r :!getmail -r nifty -r chubu<CR>:Notmuch reload<CR>
		autocmd FileType notmuch-thread,notmuch-show nnoremap <buffer><silent><Leader>bs :Notmuch tag-add Spam<CR>:Notmuch run bsfilter --sub-clean --add-spam --insert-flag --insert-probability --update<CR>
		autocmd FileType notmuch-thread,notmuch-show nnoremap <buffer><silent><Leader>bc :Notmuch tag-delete Spam<CR>:Notmuch run bsfilter --sub-spam --add-clean --insert-flag --insert-probability --update<CR>
		autocmd FileType notmuch-folders setlocal nospell
		autocmd FileType notmuch-thread,notmuch-show nnoremap <buffer><silent><leader>co :Notmuch tag-set -unread -NotOK +OK<CR>:Notmuch view-unread-mail<CR>
		autocmd FileType notmuch-thread,notmuch-show nnoremap <buffer><silent><leader>cn :Notmuch tag-set -unread -OK +NotOK<CR>:Notmuch view-unread-mail<CR>
		" autocmd FileType notmuch-show,notmuch-draft,notmuch-edit nested setlocal syntax=notmuch-mail
	augroup END
endfunction
