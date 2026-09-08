vim9script
scriptencoding utf-8

# if exists('b:current_syntax')
# 	finish
# endif

syntax region SevenZFileRow oneline start=/^\d\{4}-\d\d-\d\d\s\+\d\d:\d\d:\d\d\s\+[^D]/ end=/$/ contains=SevenZInfo,SevenZFiles
syntax region SevenZDirRow oneline start=/^\d\{4}-\d\d-\d\d\s\+\d\d:\d\d:\d\d\s\+D/ end=/$/ contains=SevenZInfo,SevenZDirectory

syntax match SevenZInfo /^\d\{4}-\d\d-\d\d\s\+\d\d:\d\d:\d\d\s\+[DRHSA.]\{5}\s\+\d\+[0-9 ]\+\%(\s\+\)\@=/ contained contains=SevenZPermission,SevenZSize,SevenZDate nextgroup=SevenZDirectory,SevenZFiles
syntax match SevenZDate /^\d\{4}-\d\d-\d\d\s\+\d\d:\d\d:\d\d/ contained
syntax match SevenZPermission /\%(\s\+\)\@<=[DRHSA.]\{5}\%(\s\+\)\@=/ contained
syntax match SevenZSize /\%(\s\+\)\@<=[0-9]\+\%(\s\+\)\@=/ contained

syntax match SevenZDirectory /\%(^\d\{4}-\d\d-\d\d\s\+\d\d:\d\d:\d\d\s\+D[RHSA.]\{4}\s\+\d\+\s\+[0-9 ]\+\)\@<=.\+/ contained
syntax match SevenZFiles     /\%(^\d\{4}-\d\d-\d\d\s\+\d\d:\d\d:\d\d\s\+\.[RHSA.]\{4}\s\+\d\+\s\+[0-9 ]\+\)\@<=.\+/ contained contains=@SevenZFile,SevenZDir

syntax match SevenZDir /.*\// contained
syntax cluster SevenZFile contains=SevenZTextFile,SevenZSrcFile,SevenZDocSrc,SevenZImage,SevenZAudio,SevenZVideo,SevenZDocument,SevenZArchive,SevenZOld
syntax match SevenZTextFile /[^/]*\.\%(txt\|org\|mkd\)$/ contained
syntax match SevenZSrcFile /[^/]*\.\%(h\|hpp\|c\|C\|cc\|cpp\|cxx\|objc\|cl\|sh\|bash\|csh\|zsh\|el\|vim\|java\|lua\|pl\|pm\|py\|rb\|hs\|php\|erb\|rdf\|js\|coffee\|l\|n\|p\|pod\|go\|sql\|csv\|tsv\|sv\|svh\|v\|vh\|vhd\)$/ contained
syntax match SevenZDocSrc /[^/]*\.\%(haml\|htm\|html\|shtml\|xhtml\|xml\|md\|man\|0\|1\|2\|3\|4\|5\|6\|7\|8\|9\|less\|css\|sass\|scss\|tex\)$/ contained
syntax match SevenZImage /[^/]*\.\%(bmp\|cgm\|dl\|dvi\|emf\|eps\|gif\|jpeg\|jpg\|JPG\|jxl\|mng\|pbm\|pcx\|pgm\|png\|PNG\|ppm\|pps\|ppsx\|ps\|svg\|svgz\|tga\|tif\|tiff\|xbm\|xcf\|xpm\|xwd\|xwd\|yuv\|nef\|NEF\|webp\|heic\|HEIC\|avif\)$/ contained
syntax match SevenZAudio /[^/]*\.\%(aac\|au\|flac\|m4a\|mid\|midi\|mka\|mp3\|mpa\|mpeg\|mpg\|ogg\|opus\|ra\|wav\)$/ contained
syntax match SevenZVideo /[^/]*\.\%(anx\|asf\|avi\|axv\|flc\|fli\|flv\|gl\|m2v\|m4v\|mkv\|mov\|MOV\|mp4\|mp4v\|mpeg\|mpg\|nuv\|ogm\|ogv\|ogx\|qt\|rm\|rmvb\|swf\|vob\|webm\|wmv\)$/ contained
syntax match SevenZDocument /[^/]*\.\%(doc\|docx\|rtf\|odt\|dot\|dotx\|ott\|xls\|xlsx\|ods\|ots\|ppt\|pptx\|odp\|otp\|fla\|psd\|pdf\|cbz\)$/ contained
syntax match SevenZArchive /[^/]*\.\%(7z\|apk\|arj\|bin\|bz\|bz2\|cab\|deb\|dmg\|gem\|gz\|iso\|jar\|msi\|rar\|rpm\|tar\|tbz\|tbz2\|tgz\|tx\|war\|xpi\|xz\|z\|Z\|zip\|zst\)$/ contained
syntax match SevenZOld /[^/]*\.\%(org_archive\|log\|bak\|BAK\|old\|OLD\|off\|OFF\|dist\|DIST\|orig\|ORIG\|swp\|swo\)$/ contained

highlight def link SevenZSize Number
highlight def link SevenZDirectory Directory
highlight def link SevenZDir Directory
highlight def link SevenZTextFile Statement
highlight def link SevenZSrcFile PreProc
hlset(hlget('Statement')->map((_, v) => extendnew(v, {name: 'SevenZDocSrc', term: {underline: true}, gui: {underline: true}})))
highlight def link SevenZImage helpNote
highlight def link SevenZAudio Type
highlight def link SevenZVideo Special
highlight def link SevenZDocument Constant
hlset(hlget('Underlined')->map((_, v) => extendnew(v, {name: 'SevenZArchive', term: {underline: false, bold: true}, gui: {underline: false, bold: true}})))
highlight def link SevenZOld Comment

b:current_syntax = '7zOut'
