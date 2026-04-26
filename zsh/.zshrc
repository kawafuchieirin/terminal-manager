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
if command -v fzf &>/dev/null; then
  eval "$(fzf --zsh)"
fi
export FZF_DEFAULT_OPTS='
  --height 60%
  --layout=reverse
  --border=rounded
  --color=bg+:#283457,bg:#16161e,spinner:#ff9e64,hl:#7aa2f7
  --color=fg:#c0caf5,header:#7aa2f7,info:#bb9af7,pointer:#ff9e64
  --color=marker:#9ece6a,fg+:#c0caf5,prompt:#7dcfff,hl+:#7aa2f7
'

# fd: fzf のファイル/ディレクトリ検索を高速化＋gitignore 尊重
if command -v fd &>/dev/null; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
fi

# bat: fzf の Ctrl+T プレビューにシンタックスハイライト
if command -v bat &>/dev/null; then
  export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
  export BAT_THEME="TwoDark"
fi

#### zoxide (must be at the end)
eval "$(zoxide init zsh)"
