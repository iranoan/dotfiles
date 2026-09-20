vim9script
scriptencoding utf-8

def Call(helper: dict<any>): dict<any>
	var Promise = vital#fern#import('Async.Promise')
	var F = vital#fern#import('System.Filepath')
	var nodes = helper.sync.get_selected_nodes()
	var root_path = F.to_slash(F.remove_last_separator(helper.sync.get_root_node()._path))
	var path: string
	var dir_paths: list<string>

	if empty(root_path)
		return Promise.reject('Invalid root.')
	endif
	dir_paths = mapnew(nodes, (_, v) => v._path )
	if dir_paths == []
		return {}
	elseif len(dir_paths) == 1 && !isdirectory(dir_paths[0])
		dir_paths = [fnamemodify(dir_paths[0], ':h')]
	endif
	fff#FFFiles(dir_paths)
	return Promise.resolve().then((_, _) => helper.async.redraw())
enddef

export def FFFiles(): void
	fern#mapping#call(Call)
enddef
