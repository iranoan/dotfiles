vim9script
scriptencoding utf-8
# プラグインがインストール導入済み、runtimepath に加わっているか? か調べる
scriptencoding utf-8
export def Main(plugin: string): bool
	return (match(substitute(&runtimepath, ',', '\n', 'g'), '/' .. plugin .. '\n') != -1)
enddef
