if (exists("b:did_ftplugin"))
  finish
endif
let b:did_ftplugin = 1

nnoremap <buffer> z :call <SID>add_mob('zombie')<CR>
command -buffer -nargs=* Item call <SID>add_item(<f-args>)
command -buffer -nargs=* Key call <SID>add_key(<f-args>)
command -buffer -nargs=* Door call <SID>add_door(<f-args>)
command -buffer -nargs=* Event call <SID>add_event(<f-args>)
command -buffer -nargs=0 CacheMetaInf call <SID>cache_meta_inf()
command -buffer -nargs=0 WriteMetaInf call <SID>write_meta_inf()
command -buffer -nargs=0 InsertMapItems call <SID>place_map_items()
command -buffer -nargs=0 A call <SID>edit_meta_file(0)
command -buffer -nargs=0 AS call <SID>edit_meta_file(1)

function! s:edit_meta_file(split) abort
    exec (a:split ? "sp" : "e")  . s:get_meta_fname()
endfunction

function! s:add_mob(type) abort
    let new_mob = {
        \ 'type': a:type,
        \ 'x': col(".") - 1,
        \ 'y': line(".") - 1
    \ }

    call add(b:map_data['mobiles'], new_mob)
    normal rz

    echomsg 'Added: ' . string(new_mob)
endfunction

function! s:add_item(type, quantity) abort
    let new_item = {
        \ 'type': a:type,
        \ 'quantity': str2nr(a:quantity),
        \ 'x': col(".") - 1,
        \ 'y': line(".") - 1
    \ }
    call add(b:map_data['items'], new_item)
    normal rI
    echomsg 'Added: ' . string(new_item)
endfunction

function! s:add_key(name, door_id) abort
    let new_key = {
        \ 'name': a:name,
        \ 'door_id': str2nr(a:door_id),
        \ 'x': col(".") - 1,
        \ 'y': line(".") - 1
    \ }
    call add(b:map_data['keys'], new_key)
    normal r%
    echomsg 'Added: ' . string(new_key)
endfunction

function! s:add_door(name, door_id) abort
    let new_door = {
        \ 'name': a:name,
        \ 'door_id': str2nr(a:door_id),
        \ 'x': col(".") - 1,
        \ 'y': line(".") - 1
    \ }
    call add(b:map_data['locked-doors'], new_door)
    normal r*
    echomsg 'Added: ' . string(new_door)
endfunction

function! s:add_event() abort
    let new_event = {
        \ 'message': 'fill me in',
        \ 'x': col(".") - 1,
        \ 'y': line(".") - 1
    }
    call add(b:map_data['events'], new_event)
    echomsg 'Added event ' . string(event)
endfunction

function! s:cache_meta_inf() abort

    let meta_file_contents = ''
    if filereadable(s:get_meta_fname())
        let meta_file_contents = join(readfile(s:get_meta_fname()), ' ')

        try
            let b:map_data = eval(meta_file_contents)
        catch
            echoerr "Failed to parse map meta info"
        endtry
    else
        let b:map_data = {}
    endif

    if !has_key(b:map_data, 'name')
        let b:map_data['name'] = "Level name"
    endif

    if !has_key(b:map_data, 'start_position')
        let b:map_data['start_position'] = {'x': 0, 'y': 0}
    endif

    for i in ['mobiles', 'items', 'keys', 'locked-doors', 'events']
        if !has_key(b:map_data, i)
            let b:map_data[i] = []
        endif
    endfor

endfunction

function! s:write_meta_inf() abort
    let save_d = @d
    let @d = string(b:map_data)

    exec "sp " . s:get_meta_fname()
    %d
    0put d

    %s/^{\(.*\)}$/{\r\1\r}/e
    %s/, '\(keys\|items\|locked-doors\|mobiles\|events\)':/,\r'\1':/ge
    %s/'\(keys\|items\|locked-doors\|mobiles\|events\)': \zs\[\ze[^\]]/\[\r/ge
    %s/{\([^}]\{,300\}\)}\(,\)\?/{ \1 }\2\r/ge

    "use double quotes
    %s/'/"/g

    setf javascript

    normal gg=G
    wq
    redraw!

    let @d = save_d
endfunction

function! s:get_meta_fname() abort
    return substitute(expand("%:p"), '\.map$', '.json', '')
endfunction

function! s:place_map_items() abort
    call s:place_start(b:map_data['start_position'])
    call s:place_things(b:map_data['items'], 'I')
    call s:place_things(b:map_data['mobiles'], 'z')
    call s:place_things(b:map_data['keys'], '%')
    call s:place_things(b:map_data['locked-doors'], '*')
endfunction

function! s:place_start(start) abort
    call cursor(a:start['y'] + 1, a:start['x'] + 1)
    normal r<
endfunction

function! s:place_things(things, map_sym) abort
    for i in a:things
        call cursor(i['y'] + 1, i['x'] + 1)
        exec "normal r" . a:map_sym
    endfor
endfunction

setl ve=all
call s:cache_meta_inf()
let @m = ''
