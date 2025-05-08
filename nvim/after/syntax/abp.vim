" Vim syntax file
"      Language: Adblock Plus Filter Lists
"    Maintainer: Thomas Greiner <https://www.greinr.com/>
"       Version: 0.1

if exists("b:current_syntax")
  finish
endif

" Blocking
syntax match abpBlocking "^[^\$]*" nextgroup=abpBlockingSeparator
syntax match abpBlockingSeparator "\$" contained nextgroup=abpBlockingOption
syntax match abpBlockingOption ".*" contained

" Blocking Exception
syntax match abpBlockingExceptionSeparator "^@@" nextgroup=abpBlockingException
syntax match abpBlockingException "[^\$]*" contained nextgroup=abpBlockingSeparator

" Comments
syntax match abpHeader "\c^\s*\[\s*adblock\s*\(plus\s*\(\d\+\(\.\d\+\)*\s*\)\?\)\?]\s*$"
syntax match abpComment "^\s*!.*" contains=abpCommentKey
syntax match abpCommentKey "^\s*!\s*[^:]\+:" contained nextgroup=abpCommentValue skipwhite
syntax match abpCommentValue ".*" contained

" Element Hiding
syntax match abpHidingOption "^[^#]*#@\?#.*" contains=abpHidingSeparator,abpHidingExceptionSeparator
syntax match abpHidingSeparator "##" contained nextgroup=abpHiding
syntax match abpHidingExceptionSeparator "#@#" contained nextgroup=abpHidingException
syntax match abpHiding ".*" contained
syntax match abpHidingException ".*" contained

" Highlights
hi link abpHeader Comment
hi link abpComment Comment
hi link abpCommentKey Comment
hi link abpCommentValue Special
hi link abpBlocking String
hi link abpBlockingSeparator Delimiter
hi link abpBlockingOption Keyword
hi link abpBlockingException WarningMsg
hi link abpBlockingExceptionSeparator Delimiter

hi link abpHiding String
hi link abpHidingSeparator Delimiter
hi link abpHidingExceptionSeparator Delimiter
hi link abpHidingOption Keyword
hi link abpHidingException WarningMsg

" Colors
hi ABPBlock ctermfg=Red guifg=Red
hi ABPBlockException ctermfg=Green guifg=Green
hi ABPElemhide ctermfg=DarkRed guifg=DarkRed
hi ABPOption ctermfg=DarkBlue guifg=DarkBlue
hi ABPElemhideException ctermfg=DarkGreen guifg=DarkGreen
