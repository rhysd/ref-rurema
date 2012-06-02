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

if !exists('g:ref_rurema_cmd')
    let g:ref_rurema_cmd = executable('rurema') ? 'rurema' : ''
endif

if !exists('g:ref_rurema_ruby')
    let g:ref_rurema_ruby = '1.9.3'
endif

let s:source = {'name' : 'rurema'}

function! s:source.available()
    return !empty(g:ref_rurema_cmd)
endfunction

function! s:source.get_body(query)
    if a:query != ''
        let content = ref#system(ref#to_list(g:ref_rurema_cmd, a:query)).stdout
        if content !~# '^no such method'
            return content
        endif
    endif

endfunction

let &cpo = s:save_cpo
unlet s:save_cpo