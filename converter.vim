" TODO: link it to keys
let s:HEX_CHARS = [
  \ '0', '1', '2', '3', '4', '5', '6', '7',
  \ '8', '9', 'A', 'B', 'C', 'D', 'E', 'F']

function! s:AddDecValue(hex_array, value, source_base, target_base)
  let carryover = a:value
  let tmp = 0
  let i = len(a:hex_array) - 1
  while (i >= 0)
    let tmp = (index(s:HEX_CHARS, a:hex_array[i]) * a:source_base) + carryover
    let a:hex_array[i] = s:HEX_CHARS[tmp % a:target_base]
    let carryover = tmp / a:target_base
    let i = i -1
  endwhile
endfunction

function! s:Convert(string, source_base, target_base)
  let input = split(toupper(a:string), '.\zs')
  let output = repeat(['0'], len(input) * 4)
  for digit in input
    let idx = index(s:HEX_CHARS, digit)
    if idx == -1
      echo 'Error converting base - unknown digit: ' . digit
      return ''
    end
    call s:AddDecValue(output, idx, a:source_base, a:target_base)
  endfor
  while len(output) > 1 && output[0] == '0'
    let output = output[1:]
  endwhile
  return join(output, '')
endfunction

command! -nargs=? -range DEC call s:2Dec(<line1>, <line2>)
function! s:2Dec(line1, line2) range
  call s:Hex2Dec(a:line1, a:line2)
  call s:Bin2Dec(a:line1, a:line2)
  call s:Oct2Dec(a:line1, a:line2) " must be the last
endfunction

command! -nargs=? -range DH call s:Dec2Hex(<line1>, <line2>)
function! s:Dec2Hex(line1, line2) range
  let cmd = 's/\<\d\+\>/\=printf("0x%s",s:Convert(submatch(0), 10, 16))/g'
  try 
    execute a:line1 . ',' . a:line2 . cmd
  catch
    echo 'No decimal number found'
  endtry
endfunction

command! -nargs=? -range HD call s:Hex2Dec(<line1>, <line2>)
function! s:Hex2Dec(line1, line2) range
  let cmd = 's/0x\(\x\+\)/\=printf("%s",s:Convert(submatch(1), 16, 10))/g'
  try
    execute a:line1 . ',' . a:line2 . cmd
  catch
    " echo 'No hex number starting with "0x" found'
  endtry
endfunction

command! -nargs=? -range DB call s:Dec2Bin(<line1>, <line2>)
function! s:Dec2Bin(line1, line2) range
  let cmd = 's/\<\d\+\>/\=printf("0b%s",s:Convert(submatch(0), 10, 2))/g'
  try 
    execute a:line1 . ',' . a:line2 . cmd
  catch
    echo 'No decimal number found'
  endtry
endfunction

command! -nargs=? -range BD call s:Bin2Dec(<line1>, <line2>)
function! s:Bin2Dec(line1, line2) range
  let cmd = 's/0b\(\x\+\)/\=printf("%s",s:Convert(submatch(1), 2, 10))/g'
  try
    execute a:line1 . ',' . a:line2 . cmd
  catch
    " echo 'No bin number starting with "0b" found'
  endtry
endfunction

command! -nargs=? -range DO call s:Dec2Oct(<line1>, <line2>)
function! s:Dec2Oct(line1, line2) range
  let cmd = 's/\<\d\+\>/\=printf("0%s",s:Convert(submatch(0), 10, 8))/g'
  try 
    execute a:line1 . ',' . a:line2 . cmd
  catch
    echo 'No decimal number found'
  endtry
endfunction

command! -nargs=? -range OD call s:Oct2Dec(<line1>, <line2>)
function! s:Oct2Dec(line1, line2) range
  let cmd = 's/0\(\x\+\)/\=printf("%s",s:Convert(submatch(1), 8, 10))/g'
  try
    execute a:line1 . ',' . a:line2 . cmd
  catch
    " echo 'No oct number starting with "0" found'
  endtry
endfunction