vim9script

var asciiart = [
			\"        :::      ::::::::", 
			\"      :+:      :+:    :+:", 
			\"    +:+ +:+         +:+  ", 
			\"  +#+  +:+       +#+     ", 
			\"+#+#+#+#+#+   +#+        ", 
			\"     #+#    #+#          ", 
			\"    ###   ########.fr    "
			\]

var start = '/*'
var end = '*/'
var fill = '*'
var length = 80
var margin = 5

var types = {
			\'\.c$\|\.h$\|\.cc$\|\.hh$\|\.cpp$\|\.hpp$\|\.php': 
			\['/*', '*/', '*'], 
			\'\.htm$\|\.html$\|\.xml$': 
			\['<!--', '-->', '*'], 
			\'\.js$': 
			\['//', '//', '*'], 
			\'\.tex$': 
			\['%', '%', '*'], 
			\'\.ml$\|\.mli$\|\.mll$\|\.mly$': 
			\['(*', '*)', '*'], 
			\'\.vim$\|\vimrc$': 
			\['"', '"', '*'], 
			\'\.el$\|\emacs$': 
			\[';', ';', '*'], 
			\'\.f90$\|\.f95$\|\.f03$\|\.f$\|\.for$': 
			\['!', '!', '/']
			\}

def Filetype()
	var f = Filename()

	for type in keys(types)
		if f =~ type
			start = types[type][0]
			end = types[type][1]
			fill = types[type][2]
		endif
	endfor
enddef

def Ascii(n: number): string
	return asciiart[n - 3]
enddef

def Textline(left: string, right: string): string
	return start .. repeat(' ', margin - strlen(start)) .. left .. repeat(' ', length - margin * 2 - strlen(left) - strlen(right)) .. right .. repeat(' ', margin - strlen(end)) .. end
enddef

def Line(n: number): string
	if n == 1 || n == 11 # top and bottom line
		return start .. ' ' .. repeat(fill, length - strlen(start) - strlen(end) - 2) .. ' ' .. end
	elseif n == 2 || n == 10 # blank line
		return Textline('', '')
	elseif n == 3 || n == 5 || n == 7 # empty with ascii
		return Textline('', Ascii(n))
	elseif n == 4 # filename
		return Textline(Filename(), Ascii(n))
	elseif n == 6 # author
		return Textline("By: " .. User() .. " <" .. Mail() .. ">", Ascii(n))
	elseif n == 8 # created
		return Textline("Created: " .. Date() .. " by " .. User(), Ascii(n))
	elseif n == 9 # updated
		return Textline("Updated: " .. Date() .. " by " .. User(), Ascii(n))
	else
		return " "
	endif
enddef

def User(): string
	if exists('g:user42')
		return g:user42
	endif
	var user = $USER
	if strlen(user) == 0
		user = "marvin"
	endif
	return user
enddef

def Mail(): string
	if exists('g:mail42')
		return g:mail42
	endif
	var mail = $MAIL
	if strlen(mail) == 0
		mail = "marvin@42.fr"
	endif
	return mail
enddef

def Filename(): string
	var filename = expand("%:t")
	if strlen(filename) == 0
		filename = "< new >"
	endif
	return filename
enddef

def Date(): string
	return strftime("%Y/%m/%d %H:%M:%S")
enddef

def Insert()
	var line = 11

	# empty line after header
	append(0, "")

	# loop over lines
	while line > 0
		append(0, Line(line))
		line = line - 1
	endwhile
enddef

def Update(): bool
	Filetype()
	if getline(9) =~ start .. repeat(' ', margin - strlen(start)) .. "Updated: "
		if &mod
			setline(9, Line(9))
		endif
		setline(4, Line(4))
		return 0
	endif
	return 1
enddef

def Stdheader()
	if Update()
		Insert()
	endif
enddef

## Bind command and shortcut
command! Stdheader Stdheader()
map <F1> :Stdheader<CR>
autocmd BufWritePre * Update()
