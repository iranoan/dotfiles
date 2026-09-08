vim9script
scriptencoding utf-8

if exists('b:current_syntax')
	finish
endif

syntax region LsFileRow oneline start=/^-[-rwx]\{9}/ end=/$/ contains=LsInfo,LsFiles,LsExecFiles
syntax region LsDirRow oneline start=/^d[-rwx]\{9}/ end=/$/ contains=LsInfo,LsDirectory
syntax region LsSymlinkRow oneline start=/^l[-rwx]\{9}.* !\?->/ end=/$/ contains=LsInfo,Lslink
syntax region LsBlockEtcRow oneline start=/^[bcsp][-rwx]\{9}.* ->/ end=/$/ contains=LsInfo,Lslink

syntax match LsInfo /^[-dl][-rwx]\{9}\s\+\%([0-9.]\+[KMGT ]B\|---\) \d\{4}-\d\d-\d\d\s\+\d\d:\d\d:\d\d\%( \)\@=/ contained contains=LsPermission,LsSize,LsDate nextgroup=LsDirectory,Lslink,LsFiles,LsExecFiles,LsBlockEtc
syntax match LsPermission /^[-dl][-rwx]\{9}/ contained
syntax match LsSize /\%([0-9.]\+[KMGT ]B\|---\)/ contained
syntax match LsDate /\d\{4}-\d\d-\d\d\s\+\d\d:\d\d:\d\d/ contained

syntax match LsDirectory /\%(^d[-rwx]\{9}\s\+\%([0-9.]\+[KMGT ]B\|---\)\s\+\d\{4}-\d\d-\d\d\s\+\d\d:\d\d:\d\d \)\@<=.\+/ contained
syntax match Lslink      /\%(^l[-rwx]\{9}\s\+\%([0-9.]\+[KMGT ]B\|---\)\s\+\d\{4}-\d\d-\d\d\s\+\d\d:\d\d:\d\d \)\@<=.\+/ contained contains=LsSymlinkName,LsSymlinkExec,LsBrokenSymlinkName,LsSymlinkArrow,LsSymlinkTargetDir,LsSymlinkTargetFile,LsSymlinkTargetExec,LsBrokenSymlinkTargetFile
syntax match LsFiles     /\%(^-[-r][-w]-[-rwx]\{6}\s\+\%([0-9.]\+[KMGT ]B\|---\)\s\+\d\{4}-\d\d-\d\d\s\+\d\d:\d\d:\d\d \)\@<=.\+/ contained contains=@LsFile
syntax match LsExecFiles /\%(^-[-r][-w]x[-rwx]\{6}\s\+\%([0-9.]\+[KMGT ]B\|---\)\s\+\d\{4}-\d\d-\d\d\s\+\d\d:\d\d:\d\d \)\@<=.\+/ contained contains=LsExecUnix
syntax match LsBlockEtc  /\%(^[bcsp][-rwx]\{9}\s\+\%([0-9.]\+[KMGT ]B\|---\)\s\+\d\{4}-\d\d-\d\d\s\+\d\d:\d\d:\d\d \)\@<=.\+/ contained

syntax match LsSymlinkName /\%(^l[-r][-w]-[-rwx]\{6}\s\+\%([0-9.]\+[KMGT ]B\|---\)\s\+\d\{4}-\d\d-\d\d\s\+\d\d:\d\d:\d\d \)\@<=.\+\%( ->\)\@=/ contained nextgroup=LsSymlinkArrow
syntax match LsSymlinkExec /\%(^l[-r][-w]x[-rwx]\{6}\s\+\%([0-9.]\+[KMGT ]B\|---\)\s\+\d\{4}-\d\d-\d\d\s\+\d\d:\d\d:\d\d \)\@<=.\+\%( ->\)\@=/ contained nextgroup=LsSymlinkArrow
syntax match LsBrokenSymlinkName /\%(^l[-rwx]\{9}\s\+\%([0-9.]\+[KMGT ]B\|---\)\s\+\d\{4}-\d\d-\d\d\s\+\d\d:\d\d:\d\d \)\@<=.\+\%( !->\)\@=/ contained nextgroup=LsSymlinkArrow
syntax match LsSymlinkArrow /!\?->/ contained nextgroup=LsSymlinkTargetDir,LsSymlinkTargetFile,LsSymlinkTargetExec,LsBrokenSymlinkTargetFile
syntax match LsSymlinkTargetDir /\%( -> \)\@<=.*\/$/ contained
syntax match LsSymlinkTargetFile /\%( -> \)\@<=.*[^\/]$/ contained contains=@LsFile
syntax match LsSymlinkTargetExec /\%(^l[-r][-w]x[-rwx]\{6}\s\+\%([0-9.]\+[KMGT ]B\|---\)\s\+\d\{4}-\d\d-\d\d\s\+\d\d:\d\d:\d\d .\+ -> \)\@<=.\+[^/]$/ contained
syntax match LsBrokenSymlinkTargetFile /\%( !-> \)\@<=.*$/ contained

syntax cluster LsFile contains=LsTextFile,LsExecFile,LsSrcFile,LsDocSrc,LsImage,LsAudio,LsVideo,LsDocument,LsArchive,LsOld
syntax match LsTextFile /.*\.\%(txt\|org\|mkd\)$/ contained
syntax match LsExecFile /.*\.\%(cmd\|exe\|com\|bat\|reg\|app\)$/ contained
syntax match LsExecUnix /.*$/ contained
syntax match LsSrcFile /.*\.\%(h\|hpp\|c\|C\|cc\|cpp\|cxx\|objc\|cl\|sh\|bash\|csh\|zsh\|el\|vim\|java\|lua\|pl\|pm\|py\|rb\|hs\|php\|erb\|rdf\|js\|coffee\|l\|n\|p\|pod\|go\|sql\|csv\|tsv\|sv\|svh\|v\|vh\|vhd\)$/ contained
syntax match LsDocSrc /.*\.\%(haml\|htm\|html\|shtml\|xhtml\|xml\|md\|man\|0\|1\|2\|3\|4\|5\|6\|7\|8\|9\|less\|css\|sass\|scss\|tex\)$/ contained
syntax match LsImage /.*\.\%(bmp\|cgm\|dl\|dvi\|emf\|eps\|gif\|jpeg\|jpg\|JPG\|jxl\|mng\|pbm\|pcx\|pgm\|png\|PNG\|ppm\|pps\|ppsx\|ps\|svg\|svgz\|tga\|tif\|tiff\|xbm\|xcf\|xpm\|xwd\|xwd\|yuv\|nef\|NEF\|webp\|heic\|HEIC\|avif\)$/ contained
syntax match LsAudio /.*\.\%(aac\|au\|flac\|m4a\|mid\|midi\|mka\|mp3\|mpa\|mpeg\|mpg\|ogg\|opus\|ra\|wav\)$/ contained
syntax match LsVideo /.*\.\%(anx\|asf\|avi\|axv\|flc\|fli\|flv\|gl\|m2v\|m4v\|mkv\|mov\|MOV\|mp4\|mp4v\|mpeg\|mpg\|nuv\|ogm\|ogv\|ogx\|qt\|rm\|rmvb\|swf\|vob\|webm\|wmv\)$/ contained
syntax match LsDocument /.*\.\%(doc\|docx\|rtf\|odt\|dot\|dotx\|ott\|xls\|xlsx\|ods\|ots\|ppt\|pptx\|odp\|otp\|fla\|psd\|pdf\|cbz\)$/ contained
syntax match LsArchive /.*\.\%(7z\|apk\|arj\|bin\|bz\|bz2\|cab\|deb\|dmg\|gem\|gz\|iso\|jar\|msi\|rar\|rpm\|tar\|tbz\|tbz2\|tgz\|tx\|war\|xpi\|xz\|z\|Z\|zip\|zst\)$/ contained
syntax match LsOld /.*\.\%(org_archive\|log\|bak\|BAK\|old\|OLD\|off\|OFF\|dist\|DIST\|orig\|ORIG\|swp\|swo\)$/ contained

highlight def link LsSize Number
highlight def link LsDirectory Directory
highlight def link LsSymlinkName Underlined
highlight def link LsSymlinkExec Underlined
highlight def link LsBrokenSymlinkName Error
highlight def link LsSymlinkArrow Comment
highlight def link LsSymlinkTargetDir Directory
highlight def link LsBrokenSymlinkTargetFile Comment
highlight def link LsTextFile Statement
highlight def link LsExecFile Removed
highlight def link LsExecFiles Removed
highlight def link LsExecUnix Removed
highlight def link LsSymlinkTargetExec Removed
highlight def link LsSrcFile PreProc
hlset(hlget('Statement')->map((_, v) => extendnew(v, {name: 'LsDocSrc', term: {underline: true}, gui: {underline: true}})))
highlight def link LsImage helpNote
highlight def link LsAudio Type
highlight def link LsVideo Special
highlight def link LsDocument Constant
hlset(hlget('Underlined')->map((_, v) => extendnew(v, {name: 'LsArchive', term: {underline: false, bold: true}, gui: {underline: false, bold: true}})))
highlight def link LsOld Comment

b:current_syntax = 'LsLike'
