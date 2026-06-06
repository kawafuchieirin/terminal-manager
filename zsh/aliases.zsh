##### Git #####
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --decorate'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'
alias gpl='git pull'
alias lg='lazygit'

##### Directory navigation #####
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

##### ls (color + human-readable) #####
alias ls='ls -G'
alias ll='ls -lah'
alias la='ls -a'

##### Safety #####
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

##### Shortcuts #####
alias h='history'
alias v='nvim'

##### Docker #####
alias dc='docker compose'
alias dps='docker ps'
alias dcu='docker compose up -d'
alias dcd='docker compose down'

##### Pet (snippet manager) #####
alias pn='pet new'
alias pe='pet edit'

##### Claude #####
alias cc='claude --dangerously-skip-permissions'

##### aws cli #####
alias sso='aws sso login --profile management-account'
alias wssso='aws sso login --profile workload-account'
