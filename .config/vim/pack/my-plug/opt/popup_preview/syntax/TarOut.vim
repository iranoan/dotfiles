vim9script
scriptencoding utf-8

if exists('b:current_syntax')
	finish
endif

syntax region TarFileRow oneline start=/^-[-rwx]\{9}/ end=/$/ contains=TarInfo,TarFiles,TarExecFiles
syntax region TarDirRow oneline start=/^d[-rwx]\{9}/ end=/$/ contains=TarInfo,TarDirectory
syntax region TarSymlinkRow oneline start=/^l[-rwx]\{9}.* !\?->/ end=/$/ contains=TarInfo,Tarlink
syntax region TarBlockEtcRow oneline start=/^[bcsp][-rwx]\{9}.* ->/ end=/$/ contains=TarInfo,Tarlink

syntax match TarInfo /^[-dl][-rwx]\{9}\s\+\w\+\/\w\+\s\+[0-9]\+\s\+\d\{4}-\d\d-\d\d\s\+\d\d:\d\d\%( \)\@=/ contained contains=TarPermission,TarSize,TarDate nextgroup=TarDirectory,Tarlink,TarFiles,TarExecFiles,TarBlockEtc
syntax match TarPermission /^[-dl][-rwx]\{9}/ contained
syntax match TarSize /[0-9]\+/ contained
syntax match TarDate /\d\{4}-\d\d-\d\d\s\+\d\d:\d\d/ contained

syntax match TarDirectory /\%(^d[-rwx]\{9}\s\+\w\+\/\w\+\s\+[0-9]\+\s\+\d\{4}-\d\d-\d\d\s\+\d\d:\d\d \)\@<=.\+/ contained
syntax match Tarlink      /\%(^l[-rwx]\{9}\s\+\w\+\/\w\+\s\+[0-9]\+\s\+\d\{4}-\d\d-\d\d\s\+\d\d:\d\d \)\@<=.\+/ contained contains=TarSymlinkName,TarSymlinkExec,TarBrokenSymlinkName,TarSymlinkArrow,TarSymlinkTargetDir,TarSymlinkTargetFile,TarSymlinkTargetExec,TarBrokenSymlinkTargetFile
syntax match TarFiles     /\%(^-[-r][-w]-[-rwx]\{6}\s\+\w\+\/\w\+\s\+[0-9]\+\s\+\d\{4}-\d\d-\d\d\s\+\d\d:\d\d \)\@<=.\+/ contained contains=@TarFile
syntax match TarExecFiles /\%(^-[-r][-w]x[-rwx]\{6}\s\+\w\+\/\w\+\s\+[0-9]\+\s\+\d\{4}-\d\d-\d\d\s\+\d\d:\d\d \)\@<=.\+/ contained contains=@TarExecUnix
syntax match TarBlockEtc  /\%(^[bcsp][-rwx]\{9}\s\+\w\+\/\w\+\s\+[0-9]\+\s\+\d\{4}-\d\d-\d\d\s\+\d\d:\d\d \)\@<=.\+/ contained

syntax match TarSymlinkName /\%(^l[-r][-w]-[-rwx]\{6}\s\+\w\+\/\w\+\s\+[0-9]\+\s\+\d\{4}-\d\d-\d\d\s\+\d\d:\d\d \)\@<=.\+\%( ->\)\@=/ contained nextgroup=TarSymlinkArrow
syntax match TarSymlinkExec /\%(^l[-r][-w]x[-rwx]\{6}\s\+\w\+\/\w\+\s\+[0-9]\+\s\+\d\{4}-\d\d-\d\d\s\+\d\d:\d\d \)\@<=.\+\%( ->\)\@=/ contained nextgroup=TarSymlinkArrow
syntax match TarBrokenSymlinkName /\%(^l[-rwx]\{9}\s\+\w\+\/\w\+\s\+[0-9]\+\s\+\d\{4}-\d\d-\d\d\s\+\d\d:\d\d \)\@<=.\+\%( !->\)\@=/ contained nextgroup=TarSymlinkArrow
syntax match TarSymlinkArrow /!\?->/ contained nextgroup=TarSymlinkTargetDir,TarSymlinkTargetFile,TarSymlinkTargetExec,TarBrokenSymlinkTargetFile
syntax match TarSymlinkTargetDir /\%( -> \)\@<=.*\/$/ contained
syntax match TarSymlinkTargetFile /\%( -> \)\@<=.*[^\/]$/ contained contains=@TarFile
syntax match TarSymlinkTargetExec /\%(^l[-r][-w]x[-rwx]\{6}\s\+\w\+\/\w\+\s\+[0-9]\+\s\+\d\{4}-\d\d-\d\d\s\+\d\d:\d\d .\+ -> \)\@<=.\+[^/]$/ contained
syntax match TarBrokenSymlinkTargetFile /\%( !-> \)\@<=.*$/ contained

syntax cluster TarFile contains=TarTextFile,TarExecFile,TarSrcFile,TarDocSrc,TarImage,TarAudio,TarVideo,TarDocument,TarArchive,TarOld
syntax match TarTextFile /.*\.\%(txt\|org\|mkd\)$/ contained
syntax match TarExecFile /.*\.\%(cmd\|exe\|com\|bat\|reg\|app\)$/ contained
syntax match TarExecUnix /.*$/ contained
syntax match TarSrcFile /.*\.\%(h\|hpp\|c\|C\|cc\|cpp\|cxx\|objc\|cl\|sh\|bash\|csh\|zsh\|el\|vim\|java\|lua\|pl\|pm\|py\|rb\|hs\|php\|erb\|rdf\|js\|coffee\|l\|n\|p\|pod\|go\|sql\|csv\|tsv\|sv\|svh\|v\|vh\|vhd\)$/ contained
syntax match TarDocSrc /.*\.\%(haml\|htm\|html\|shtml\|xhtml\|xml\|md\|man\|0\|1\|2\|3\|4\|5\|6\|7\|8\|9\|less\|css\|sass\|scss\|tex\)$/ contained
syntax match TarImage /.*\.\%(bmp\|cgm\|dl\|dvi\|emf\|eps\|gif\|jpeg\|jpg\|JPG\|jxl\|mng\|pbm\|pcx\|pgm\|png\|PNG\|ppm\|pps\|ppsx\|ps\|svg\|svgz\|tga\|tif\|tiff\|xbm\|xcf\|xpm\|xwd\|xwd\|yuv\|nef\|NEF\|webp\|heic\|HEIC\|avif\)$/ contained
syntax match TarAudio /.*\.\%(aac\|au\|flac\|m4a\|mid\|midi\|mka\|mp3\|mpa\|mpeg\|mpg\|ogg\|opus\|ra\|wav\)$/ contained
syntax match TarVideo /.*\.\%(anx\|asf\|avi\|axv\|flc\|fli\|flv\|gl\|m2v\|m4v\|mkv\|mov\|MOV\|mp4\|mp4v\|mpeg\|mpg\|nuv\|ogm\|ogv\|ogx\|qt\|rm\|rmvb\|swf\|vob\|webm\|wmv\)$/ contained
syntax match TarDocument /.*\.\%(doc\|docx\|rtf\|odt\|dot\|dotx\|ott\|xls\|xlsx\|ods\|ots\|ppt\|pptx\|odp\|otp\|fla\|psd\|pdf\|cbz\)$/ contained
syntax match TarArchive /.*\.\%(7z\|apk\|arj\|bin\|bz\|bz2\|cab\|deb\|dmg\|gem\|gz\|iso\|jar\|msi\|rar\|rpm\|tar\|tbz\|tbz2\|tgz\|tx\|war\|xpi\|xz\|z\|Z\|zip\|zst\)$/ contained
syntax match TarOld /.*\.\%(org_archive\|log\|bak\|BAK\|old\|OLD\|off\|OFF\|dist\|DIST\|orig\|ORIG\|swp\|swo\)$/ contained

highlight def link TarSize Number
highlight def link TarDirectory Directory
highlight def link TarSymlinkName Underlined
highlight def link TarSymlinkExec Underlined
highlight def link TarBrokenSymlinkName Error
highlight def link TarSymlinkArrow Comment
highlight def link TarSymlinkTargetDir Directory
highlight def link TarBrokenSymlinkTargetFile Comment
highlight def link TarTextFile Statement
highlight def link TarExecFile Removed
highlight def link TarExecFiles Removed
highlight def link TarExecUnix Removed
highlight def link TarSymlinkTargetExec Removed
highlight def link TarSrcFile PreProc
hlset(hlget('Statement')->map((_, v) => extendnew(v, {name: 'TarDocSrc', term: {underline: true}, gui: {underline: true}})))
highlight def link TarImage helpNote
highlight def link TarAudio Type
highlight def link TarVideo Special
highlight def link TarDocument Constant
hlset(hlget('Underlined')->map((_, v) => extendnew(v, {name: 'TarArchive', term: {underline: false, bold: true}, gui: {underline: false, bold: true}})))
highlight def link TarOld Comment

b:current_syntax = 'TarOut'
