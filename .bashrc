# .bashrc

# User specific aliases and functions

#PS1='
#$HOSTNAME $PWD
#\! % '

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

umask 002

export CVS_RSH=ssh
export CVSROOT=/data/export/code/cvsroot
export PATH=/sbin:/usr/sbin:/usr/local/sbin:$PATH:/home/dan/bin:/home/dan/.gem/ruby/1.8/bin
export LANG=en_US.UTF-8
export PERL5LIB=/home/dmccormick/code/shutterstock-mason/lib:/home/dmccormick/code/shutterstock-mason/t/lib:/opt/local-lib/shutterstock/lib/perl5:/opt/shutterstock-perl/usr/lib/perl5
export LS_COLORS="ow=01;91:di=01;91" # linux?
export LSCOLORS=ExFxCxDxBxegedabagacad # mac
export EDITOR=vim
export HISTTIMEFORMAT='%F %T '
export REPO_PATH=/home/dmccormick/code/shutterstock-mason

alias cdi='cd /data/export/code/integration'
alias cdme='cd /home/dan/code'
alias task='task -v'

# load keychain (ssh-agent)
SSH_ENV="$HOME/.ssh/environment"

function start_agent {
     echo "Initialising new SSH agent..."
     /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
     echo succeeded
     chmod 600 "${SSH_ENV}"
     . "${SSH_ENV}" > /dev/null
     /usr/bin/ssh-add;
}

# Source SSH settings, if applicable

if [ -f "${SSH_ENV}" ]; then
     . "${SSH_ENV}" > /dev/null
     #ps ${SSH_AGENT_PID} doesn't work under cywgin
     ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
         start_agent;
     }
else
     start_agent;
fi

# Include Git bash-completion and prompt functions
#if [ -f "/usr/local/src/git-1.7.1/contrib/completion/git-completion.bash" ]; then
#    source /usr/local/src/git-1.7.1/contrib/completion/git-completion.bash
#fi

# Colour the hostname part depending on what Shutterstock environment you're in
function __host_ps1()
{
	hostname="$(hostname)"
	if [[ $hostname =~ '.*DEV.*' ]]; then
		tput setaf 4
	elif [[ $hostname =~ 'neil-ubuntu' ]]; then
		tput setaf 5
	elif [[ $hostname =~ 'worker-DEV' ]]; then
		tput setaf 2
	elif [[ $hostname =~ 'lvs[0-9]c' ]]; then
		tput setaf 1
	elif [[ $hostname =~ '(shutter)?worker[0-9]*' ]]; then
		tput setaf 3
	fi

	printf "$1" "$hostname"
	tput sgr0
}

# Colour the Git branch based on whether it's a real branch or a "MERGING", etc, kind of state branch
function __git_ps1_branch()
{
        if __gitdir > /dev/null 2>&1; then
                tput setaf 5
                echo -n "[$(basename $(dirname $(echo $(cd $(__gitdir); pwd))))]"
                tput sgr0
        fi
        if __git_ps1 > /dev/null 2>&1; then
                if [[ $(__git_ps1) =~ '\|' ]]; then
                        tput setaf 1
                else
                        tput setaf 4
                fi
                __git_ps1 "[%s]"
                tput sgr0
        fi
}

PS1='\[\033[00;31m\]$(r=$?; if test $r -ne 0; then echo "[$r]"; set ?=$r; unset r; fi)\[\033[00m\]${debian_chroot:+($debian_chroot)}\[\033[01;37m\]\u\[\033[01;30m\]@$(__host_ps1 "%s")\[\033[00;32m\]$SCREEN_WIN\[\033[00m\]$(__git_ps1_branch):\w\[\033[00m\]
\[\033[01;30m\]$(date +"%Y-%m-%d %H:%M:%S")\[\033[00m\] \[\033[00;34m\]\$\[\033[00m\] '

startdiff () {
	echo git diff --stat=120,100 start-$(git branch | awk '/^\*/{print $2}')...HEAD
	git diff --stat=120,100 start-$(git branch | awk '/^\*/{print $2}')...HEAD
}

startdifference () {
	echo git diff start-$(git branch | awk '/^\*/{print $2}')...HEAD
	git diff start-$(git branch | awk '/^\*/{print $2}')...HEAD
}

prodmasterdiff () {
	echo git diff --stat=120,100 master...HEAD
	git diff --stat=120,100 master...HEAD
}

function __git_complete_file () { return; }

