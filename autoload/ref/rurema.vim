" vim-ref source for rurema
"
" Note:
"   you must install rurema command before use this source
"
"       % gem install rurema
"
" Author :
"   rhysd (@Linda_pp)
"
" License:
"   licensed under the MIT Lisence (http://www.opensource.org/licenses/mit-license.php)

let s:save_cpo = &cpo
set cpo&vim

" options {{{
if !exists('g:ref_rurema_cmd')
    let g:ref_rurema_cmd = executable('rurema') ? 'rurema' : ''
endif
" }}}
let s:source = {'name' : 'rurema'} " {{{

function! s:source.available()
    return !empty(g:ref_rurema_cmd)
endfunction

function! s:source.get_body(query)
    if a:query != ''
        if(a:query =~# '^\k\+\#\p\+$')
            let content = ref#system(ref#to_list(g:ref_rurema_cmd, self.make_cmd(a:query))).stdout
            if content =~# '^no such method'
                echoerr 'no such method exists.'
                exit
            endif

            return split(content, "\n")

        else
            let cached = self.cache(a:query)
            if type(cached) != type(0) || cached != 0
                return cached
            endif

            let content = ref#system(ref#to_list(g:ref_rurema_cmd, self.make_cmd(a:query))).stdout
            if content =~# '^no such method'
                echoerr 'no such method exists.'
                exit
            endif

            let instance_methods = split(ref#system(g:ref_rurema_cmd . ' ' . a:query . '#'))
            return self.cache(a:query, split(content . "\n=== instance methods\n\n" . join(instance_methods, "\n"), "\n"))
        endif
    endif

    return self.complete(a:query)
endfunction

function! s:source.complete(query)
    let cached = self.cache('ref-rurema_all')
    if type(cached) != type(0) || cached != 0
        return cached
    endif

    let all_list = []
    let classes = split(ref#system(g:ref_rurema_cmd . " --list").stdout, "\n")

    return self.cache('ref-rurema_all', classes)
endfunction

function! s:source.get_keyword()
    if &l:filetype ==# 'ref-rurema'
        let curline = getline(".")
        let secline = search('^=== instance methods$', 'bnW')

        if secline != 0
            return ['rurema', curline]
        else
            let cword = ref#get_text_on_cursor('\(\p\+#\p\+\)')
            return ['rurema', (empty(cword) ? ref#get_text_on_cursor('\(\p\+\)') : cword)]
        endif
    else
        let cword = ref#get_text_on_cursor('\(\p\+#\p\+\)')
        return ['rurema', (empty(cword) ? ref#get_text_on_cursor('\(\p\+\)') : cword)]
    endif
endfunction

function! s:source.opened(query)
    call s:syntax()
endfunction
" }}}
" functions {{{
function! s:source.make_cmd(query)
    let cmd = a:query." --no-ask"
    if exists('g:ref_rurema_ruby')
        let cmd .= " --rubyver=".g:ref_rurema_ruby
    endif

    if empty(a:query)
        let cmd .= " --list"
    endif

    return cmd
endfunction

function! ref#rurema#define()
    return copy(s:source)
endfunction

function! s:syntax()
    if exists('b:current_syntax') && b:current_syntax ==# 'ref-rurema'
        return
    endif

    syntax clear

    syntax match refRuremaHeader '^class\>' nextgroup=refRuremaClassName skipwhite
    syntax match refRuremaClassName '.\+$' contained
    syntax match refRuremaSection '^=\+.\+$'
    syntax match refRuremaDescription '^\s\+.\+$'
    " syntax match refRuremaInstanceMethods '^[\k\:]\+#\p\+$'
    syntax match refRuremaInstanceMethods '^\k\+#\p\+$'
    syntax match refRuremaNotation '^@\w\+\>'

    highlight default link refRuremaHeader Type
    highlight default link refRuremaClassName Identifier
    highlight default link refRuremaSection Special
    highlight default link refRuremaDescription Statement
    highlight default link refRuremaInstanceMethods Identifier
    highlight default link refRuremaNotation Constant

    let b:current_syntax = 'ref-rurema'
endfunction

call ref#register_detection('ruby', 'rurema', 'overwrite')
" }}}

let &cpo = s:save_cpo
unlet s:save_cpo
