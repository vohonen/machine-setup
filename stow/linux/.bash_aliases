# listing directory contents
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# moving between directories
alias cd..='cd ..'
alias cdb=' cd ..; cd ..'

# https://unix.stackexchange.com/questions/125385/combined-mkdir-and-cd
mkcd ()
{
	mkdir -p -- "$1" &&
	cd -P -- "$1"
}

# random commands shortened for convenience
alias so='source'
alias open='xdg-open'
alias fl='file `ls`'
alias dt='date +"%T"'
alias filecount='ls -l | grep -v ^d | grep -v ^t | grep -v ^l | wc -l'

