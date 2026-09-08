vim9script
scriptencoding utf-8

if exists('b:current_syntax')
	finish
endif

syntax match UnZipOutInfo /^\s*\d\+\s\+\d\{4}-\d\d-\d\d\s\+\d\d:\d\d\s\+/ contains=UnZipOutSize,UnZipOutDate nextgroup=UnZipOutFiles

syntax match UnZipOutSize /^\s*\d\+/ contained
syntax match UnZipOutDate /\d\{4}-\d\d-\d\d\s\+\d\d:\d\d/ contained

syntax match UnZipOutFiles /.\+/ contained contains=@UnZipOutFile,UnZipOutDirectory

syntax cluster UnZipOutFile contains=UnZipOutTextFile,UnZipOutExecFile,UnZipOutSrcFile,UnZipOutDocSrc,UnZipOutImage,UnZipOutAudio,UnZipOutVideo,UnZipOutDocument,UnZipOutArchive,UnZipOutOld
syntax match UnZipOutDirectory /.*\// contained
syntax match UnZipOutTextFile /[^/]\+\.\%(txt\|org\|mkd\)$/ contained
syntax match UnZipOutExecFile /[^/]\+\.\%(cmd\|exe\|com\|bat\|reg\|app\)$/ contained
syntax match UnZipOutExecUnix /[^/]\+$/ contained
syntax match UnZipOutSrcFile /[^/]\+\.\%(h\|hpp\|c\|C\|cc\|cpp\|cxx\|objc\|cl\|sh\|bash\|csh\|zsh\|el\|vim\|java\|lua\|pl\|pm\|py\|rb\|hs\|php\|erb\|rdf\|js\|coffee\|l\|n\|p\|pod\|go\|sql\|csv\|tsv\|sv\|svh\|v\|vh\|vhd\)$/ contained
syntax match UnZipOutDocSrc /[^/]\+\.\%(haml\|htm\|html\|shtml\|xhtml\|xml\|md\|man\|0\|1\|2\|3\|4\|5\|6\|7\|8\|9\|less\|css\|sass\|scss\|tex\)$/ contained
syntax match UnZipOutImage /[^/]\+\.\%(bmp\|cgm\|dl\|dvi\|emf\|eps\|gif\|jpeg\|jpg\|JPG\|jxl\|mng\|pbm\|pcx\|pgm\|png\|PNG\|ppm\|pps\|ppsx\|ps\|svg\|svgz\|tga\|tif\|tiff\|xbm\|xcf\|xpm\|xwd\|xwd\|yuv\|nef\|NEF\|webp\|heic\|HEIC\|avif\)$/ contained
syntax match UnZipOutAudio /[^/]\+\.\%(aac\|au\|flac\|m4a\|mid\|midi\|mka\|mp3\|mpa\|mpeg\|mpg\|ogg\|opus\|ra\|wav\)$/ contained
syntax match UnZipOutVideo /[^/]\+\.\%(anx\|asf\|avi\|axv\|flc\|fli\|flv\|gl\|m2v\|m4v\|mkv\|mov\|MOV\|mp4\|mp4v\|mpeg\|mpg\|nuv\|ogm\|ogv\|ogx\|qt\|rm\|rmvb\|swf\|vob\|webm\|wmv\)$/ contained
syntax match UnZipOutDocument /[^/]\+\.\%(doc\|docx\|rtf\|odt\|dot\|dotx\|ott\|xls\|xlsx\|ods\|ots\|ppt\|pptx\|odp\|otp\|fla\|psd\|pdf\|cbz\)$/ contained
syntax match UnZipOutArchive /[^/]\+\.\%(7z\|apk\|arj\|bin\|bz\|bz2\|cab\|deb\|dmg\|gem\|gz\|iso\|jar\|msi\|rar\|rpm\|tar\|tbz\|tbz2\|tgz\|tx\|war\|xpi\|xz\|z\|Z\|zip\|zst\)$/ contained
syntax match UnZipOutOld /[^/]\+\.\%(org_archive\|log\|bak\|BAK\|old\|OLD\|off\|OFF\|dist\|DIST\|orig\|ORIG\|swp\|swo\)$/ contained

highlight def link UnZipOutSize Number
highlight def link UnZipOutDirectory Directory
highlight def link UnZipOutTextFile Statement
highlight def link UnZipOutExecFile Removed
highlight def link UnZipOutExecUnix Removed
highlight def link UnZipOutSrcFile PreProc
hlset(hlget('Statement')->map((_, v) => extendnew(v, {name: 'UnZipOutDocSrc', term: {underline: true}, gui: {underline: true}})))
highlight def link UnZipOutImage helpNote
highlight def link UnZipOutAudio Type
highlight def link UnZipOutVideo Special
highlight def link UnZipOutDocument Constant
hlset(hlget('Underlined')->map((_, v) => extendnew(v, {name: 'UnZipOutArchive', term: {underline: false, bold: true}, gui: {underline: false, bold: true}})))
highlight def link UnZipOutOld Comment

b:current_syntax = 'UnZipOut'
