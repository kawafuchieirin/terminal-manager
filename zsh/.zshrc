##### Language/Editor #####
export LANG=en_US.UTF-8
export EDITOR=nvim

#### Starship prompt
eval "$(starship init zsh)"

#### autosuggestions
source $HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh
#### syntax highlighting
source $HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

#### History search with arrow keys #####
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search

#### Make word deletion stop at path separators, etc.
WORDCHARS=''

#### Apply hidden sources (ignored by Git; e.g., secrets or machine-specific)
HIDDEN_DIR="$HOME/.config/zsh/hidden"
if [ -d "$HIDDEN_DIR" ]; then
  for f in "$HIDDEN_DIR"/*.zsh(N); do
    if [ -r "$f" ] && [ -f "$f" ]; then
      source "$f"
    fi
  done
fi

#### Aliases
source "$HOME/.config/zsh/aliases.zsh"

#### PATH / Tools
eval "$(mise activate zsh)"
export PATH="$HOME/npm-global/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

#### fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

#### zoxide (must be at the end)
eval "$(zoxide init zsh)"
