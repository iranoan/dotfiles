vim9script
scriptencoding utf-8

if exists('b:current_syntax')
	finish
endif

syntax region RarFileRow oneline start=/^\s\+-[-rwx]\{9}/ end=/$/ contains=RarInfo,RarFiles,RarExecFiles
syntax region RarDirRow oneline start=/^\s\+d[-rwx]\{9}/ end=/$/ contains=RarInfo,RarDirectory
syntax region RarSymlinkRow oneline start=/^\s\+l[-rwx]\{9}.* !\?->/ end=/$/ contains=RarInfo,Rarlink
syntax region RarBlockEtcRow oneline start=/^\s\+[bcsp][-rwx]\{9}.* ->/ end=/$/ contains=RarInfo,Rarlink

syntax match RarInfo /^\s\+[-dl][-rwx]\{9}\s\+[0-9]\+\s\+\d\{4}-\d\d-\d\d\s\+\d\d:\d\d\%( \)\@=/ contained contains=RarPermission,RarSize,RarDate nextgroup=RarDirectory,Rarlink,RarFiles,RarExecFiles,RarBlockEtc
syntax match RarPermission /^\s\+[-dl][-rwx]\{9}/ contained
syntax match RarSize /[0-9]\+/ contained
syntax match RarDate /\d\{4}-\d\d-\d\d\s\+\d\d:\d\d/ contained

syntax match RarDirectory /\%(^\s\+d[-rwx]\{9}\s\+[0-9]\+\s\+\d\{4}-\d\d-\d\d\s\+\d\d:\d\d \)\@<=.\+/ contained
syntax match Rarlink      /\%(^\s\+l[-rwx]\{9}\s\+[0-9]\+\s\+\d\{4}-\d\d-\d\d\s\+\d\d:\d\d \)\@<=.\+/ contained contains=RarSymlinkName,RarSymlinkExec,RarBrokenSymlinkName,RarSymlinkArrow,RarSymlinkTargetDir,RarSymlinkTargetFile,RarSymlinkTargetExec,RarBrokenSymlinkTargetFile
syntax match RarFiles     /\%(^\s\+-[-r][-w]-[-rwx]\{6}\s\+[0-9]\+\s\+\d\{4}-\d\d-\d\d\s\+\d\d:\d\d \)\@<=.\+/ contained contains=@RarFile,RarDir
syntax match RarExecFiles /\%(^\s\+-[-r][-w]x[-rwx]\{6}\s\+[0-9]\+\s\+\d\{4}-\d\d-\d\d\s\+\d\d:\d\d \)\@<=.\+/ contained contains=RarExecUnix,RarDir
syntax match RarBlockEtc  /\%(^\s\+[bcsp][-rwx]\{9}\s\+[0-9]\+\s\+\d\{4}-\d\d-\d\d\s\+\d\d:\d\d \)\@<=.\+/ contained

syntax match RarSymlinkName /\%(^\s\+l[-r][-w]-[-rwx]\{6}\s\+[0-9]\+\s\+\d\{4}-\d\d-\d\d\s\+\d\d:\d\d \)\@<=.\+\%( ->\)\@=/ contained nextgroup=RarSymlinkArrow
syntax match RarSymlinkExec /\%(^\s\+l[-r][-w]x[-rwx]\{6}\s\+[0-9]\+\s\+\d\{4}-\d\d-\d\d\s\+\d\d:\d\d \)\@<=.\+\%( ->\)\@=/ contained nextgroup=RarSymlinkArrow
syntax match RarBrokenSymlinkName /\%(^\s\+l[-rwx]\{9}\s\+[0-9]\+\s\+\d\{4}-\d\d-\d\d\s\+\d\d:\d\d \)\@<=.\+\%( !->\)\@=/ contained nextgroup=RarSymlinkArrow
syntax match RarSymlinkArrow /!\?->/ contained nextgroup=RarSymlinkTargetDir,RarSymlinkTargetFile,RarSymlinkTargetExec,RarBrokenSymlinkTargetFile
syntax match RarSymlinkTargetDir /\%( -> \)\@<=.*\/$/ contained
syntax match RarSymlinkTargetFile /\%( -> \)\@<=.*[^\/]$/ contained contains=@RarFile
syntax match RarSymlinkTargetExec /\%(^\s\+l[-r][-w]x[-rwx]\{6}\s\+[0-9]\+\s\+\d\{4}-\d\d-\d\d\s\+\d\d:\d\d .\+ -> \)\@<=.\+[^/]$/ contained
syntax match RarBrokenSymlinkTargetFile /\%( !-> \)\@<=.*$/ contained

syntax match RarDir /.*\// contained
syntax cluster RarFile contains=RarTextFile,RarExecFile,RarSrcFile,RarDocSrc,RarImage,RarAudio,RarVideo,RarDocument,RarArchive,RarOld
syntax match RarTextFile /[^/]*\.\%(txt\|org\|mkd\)$/ contained
syntax match RarExecFile /[^/]*\.\%(cmd\|exe\|com\|bat\|reg\|app\)$/ contained
syntax match RarExecUnix /[^/]*$/ contained
syntax match RarSrcFile /[^/]*\.\%(h\|hpp\|c\|C\|cc\|cpp\|cxx\|objc\|cl\|sh\|bash\|csh\|zsh\|el\|vim\|java\|lua\|pl\|pm\|py\|rb\|hs\|php\|erb\|rdf\|js\|coffee\|l\|n\|p\|pod\|go\|sql\|csv\|tsv\|sv\|svh\|v\|vh\|vhd\)$/ contained
syntax match RarDocSrc /[^/]*\.\%(haml\|htm\|html\|shtml\|xhtml\|xml\|md\|man\|0\|1\|2\|3\|4\|5\|6\|7\|8\|9\|less\|css\|sass\|scss\|tex\)$/ contained
syntax match RarImage /[^/]*\.\%(bmp\|cgm\|dl\|dvi\|emf\|eps\|gif\|jpeg\|jpg\|JPG\|jxl\|mng\|pbm\|pcx\|pgm\|png\|PNG\|ppm\|pps\|ppsx\|ps\|svg\|svgz\|tga\|tif\|tiff\|xbm\|xcf\|xpm\|xwd\|xwd\|yuv\|nef\|NEF\|webp\|heic\|HEIC\|avif\)$/ contained
syntax match RarAudio /[^/]*\.\%(aac\|au\|flac\|m4a\|mid\|midi\|mka\|mp3\|mpa\|mpeg\|mpg\|ogg\|opus\|ra\|wav\)$/ contained
syntax match RarVideo /[^/]*\.\%(anx\|asf\|avi\|axv\|flc\|fli\|flv\|gl\|m2v\|m4v\|mkv\|mov\|MOV\|mp4\|mp4v\|mpeg\|mpg\|nuv\|ogm\|ogv\|ogx\|qt\|rm\|rmvb\|swf\|vob\|webm\|wmv\)$/ contained
syntax match RarDocument /[^/]*\.\%(doc\|docx\|rtf\|odt\|dot\|dotx\|ott\|xls\|xlsx\|ods\|ots\|ppt\|pptx\|odp\|otp\|fla\|psd\|pdf\|cbz\)$/ contained
syntax match RarArchive /[^/]*\.\%(7z\|apk\|arj\|bin\|bz\|bz2\|cab\|deb\|dmg\|gem\|gz\|iso\|jar\|msi\|rar\|rpm\|tar\|tbz\|tbz2\|tgz\|tx\|war\|xpi\|xz\|z\|Z\|zip\|zst\)$/ contained
syntax match RarOld /[^/]*\.\%(org_archive\|log\|bak\|BAK\|old\|OLD\|off\|OFF\|dist\|DIST\|orig\|ORIG\|swp\|swo\)$/ contained

highlight def link RarSize Number
highlight def link RarDirectory Directory
highlight def link RarDir Directory
highlight def link RarSymlinkName Underlined
highlight def link RarSymlinkExec Underlined
highlight def link RarBrokenSymlinkName Error
highlight def link RarSymlinkArrow Comment
highlight def link RarSymlinkTargetDir Directory
highlight def link RarBrokenSymlinkTargetFile Comment
highlight def link RarTextFile Statement
highlight def link RarExecFile Removed
highlight def link RarExecUnix Removed
highlight def link RarSymlinkTargetExec Removed
highlight def link RarSrcFile PreProc
hlset(hlget('Statement')->map((_, v) => extendnew(v, {name: 'RarDocSrc', term: {underline: true}, gui: {underline: true}})))
highlight def link RarImage helpNote
highlight def link RarAudio Type
highlight def link RarVideo Special
highlight def link RarDocument Constant
hlset(hlget('Underlined')->map((_, v) => extendnew(v, {name: 'RarArchive', term: {underline: false, bold: true}, gui: {underline: false, bold: true}})))
highlight def link RarOld Comment

b:current_syntax = 'RarOut'
