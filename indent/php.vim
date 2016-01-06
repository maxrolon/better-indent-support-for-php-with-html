" Code originally from
" http://vim.wikia.com/wiki/Better_indent_support_for_php_with_html

" Better indent support for PHP by making it possible to indent HTML sections
" as well.
if exists("b:did_indent")
  finish
endif

" This script pulls in the default indent/php.vim with the :runtime command
" which could re-run this script recursively unless we catch that:
if exists('s:doing_indent_inits')
  finish
endif
let s:doing_indent_inits = 1
runtime! indent/html.vim
unlet b:did_indent
runtime! indent/php.vim
unlet s:doing_indent_inits

function! GetPhpHtmlIndent(lnum)
  if exists('*HtmlIndent')
    let html_ind = HtmlIndent()
  else
    let html_ind = HtmlIndentGet(a:lnum)
  endif
  let php_ind = GetPhpIndent()

  echo "php indent ".php_ind.", html_ind ".html_ind

  if php_ind > -1
    if getline(a:lnum) =~ "<"
      return -1
    endif

    if html_ind > 0 && php_ind == 0
      let l:opening_tag = search('<?','b')
      if l:opening_tag+1 == v:lnum
        return html_ind
      endif
    endif

    return php_ind
  endif
  if html_ind > -1
    if getline(a:lnum) =~ "^<?" && (0< searchpair('<?', '', '?>', 'nWb')
          \ || 0 < searchpair('<?', '', '?>', 'nW'))
      return -1
    endif
    return html_ind
  endif
  return -1
endfunction

setlocal indentexpr=GetPhpHtmlIndent(v:lnum)
setlocal indentkeys+=<>>