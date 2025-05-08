" Vim syntax file
"      Language: Adblock Plus Filter Lists
"    Maintainer: Thomas Greiner <https://www.greinr.com/>
"       Version: 0.1
" https://github.com/ThomasGreiner/abp-syntax
"───────────────────────────────────────────────────────────────────────────────
" Highlights modified by Chris Grieser
"───────────────────────────────────────────────────────────────────────────────

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

"───────────────────────────────────────────────────────────────────────────────
" below here, highlights are modified

" Highlights
hi link abpHeader Comment
hi link abpComment Comment
hi link abpCommentKey Comment
hi link abpCommentValue Special

hi link abpBlocking String
hi link abpBlockingSeparator Operator
hi link abpBlockingExceptionSeparator Operator
hi link abpBlockingOption Function
hi link abpBlockingException WarningMsg

hi link abpHiding String
hi link abpHidingSeparator Operator
hi link abpHidingExceptionSeparator Operator
hi link abpHidingOption Function
hi link abpHidingException WarningMsg
