" https://github.com/felixge/vim-nodejs-errorformat
if exists('g:loaded_nodejs_errorformat')
  finish
endif
let g:loaded_nodejs_errorformat = 1

let &makeprg="node %"

" Error: bar
"     at Object.foo [as _onTimeout] (/Users/Felix/.vim/bundle/vim-nodejs-errorformat/test.js:2:9)
let &errorformat  = '%AError: %m' . ','
let &errorformat .= '%AEvalError: %m' . ','
let &errorformat .= '%ARangeError: %m' . ','
let &errorformat .= '%AReferenceError: %m' . ','
let &errorformat .= '%ASyntaxError: %m' . ','
let &errorformat .= '%ATypeError: %m' . ','
let &errorformat .= '%Z%*[\ ]at\ %f:%l:%c' . ','
let &errorformat .= '%Z%*[\ ]%m (%f:%l:%c)' . ','

"     at Object.foo [as _onTimeout] (/Users/Felix/.vim/bundle/vim-nodejs-errorformat/test.js:2:9)
let &errorformat .= '%*[\ ]%m (%f:%l:%c)' . ','

"     at node.js:903:3
let &errorformat .= '%*[\ ]at\ %f:%l:%c' . ','

" /Users/Felix/.vim/bundle/vim-nodejs-errorformat/test.js:2
"   throw new Error('bar');
"         ^
let &errorformat .= '%Z%p^,%A%f:%l,%C%m' . ','

" Ignore everything else
let &errorformat .= '%-G%.%#'

function! HookCoreFilesIntoQuickfixWindow()
   let files = getqflist()
   for i in files
      let filename = bufname(i.bufnr)

      " Non-existing file in the quickfix list, assume a core file
      if !filereadable(filename)
        " Open a new split / buffer for loading this core file
        execute 'split ' filename
        " Make this buffer modifiable
        set modifiable
        " Set the buffer options
        setlocal buftype=nofile bufhidden=hide
        " Clear all previous buffer contents
        execute ':1,%d'
        " Load the node.js core file (thanks @izs for pointing this out!)
        silent! execute 'read !node -e "console.log(process.binding(\"natives\").' expand('%:r') ')"'
        " Delete the first line, always empty for some reason
        execute ':1d'
        " Tell vim to treat this buffer as a JS file
        set filetype=javascript
        " No point in making this file writable
        setlocal nomodifiable
        " Point our quickfix entry to this (our current) buffer
        let i.bufnr = bufnr("%")
        " Close the split, so our little hack stays in the background
        close
      endif
   endfor
   call setqflist(files)
endfunction

au QuickfixCmdPost make call HookCoreFilesIntoQuickfixWindow()
