##### Language/Editor #####
export LANG=en_US.UTF-8
export EDITOR=nvim

#### Starship prompt
eval "$(starship init zsh)"

#### autosuggestions
source $HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh
#### syntax highlighting
source $HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

#### History #####
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000
setopt SHARE_HISTORY          # 複数端末／タブ間で履歴を即時共有（追記・読込を含む）
setopt HIST_IGNORE_ALL_DUPS   # 重複コマンドは古い方を履歴から削除
setopt HIST_IGNORE_SPACE      # 先頭がスペースのコマンドは履歴に残さない
setopt HIST_REDUCE_BLANKS     # 余分な空白を圧縮して記録
setopt HIST_VERIFY            # 履歴展開（!）は即実行せずプロンプトに展開

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

#### pet (snippet manager): Ctrl+G で登録済みスニペットを fzf 検索し、
#### 選んだコマンドを実行せずプロンプトに挿入する（少し変更して Enter）
if command -v pet &>/dev/null; then
  function pet-select() {
    BUFFER=$(pet search --query "$LBUFFER")
    CURSOR=$#BUFFER
    zle redisplay
  }
  zle -N pet-select
  bindkey '^g' pet-select

  # prev: 直前に実行したコマンドを pet new に渡して登録する
  #       （pet new は Command 欄を自動で埋めないため、履歴から取り出して渡す）
  #       対話シェルでは「prev 呼び出し行」自体が履歴の先頭に入るため、
  #       それを読み飛ばして直近の実コマンドを拾う。タグ入力は `prev -t` で透過。
  function prev() {
    local last
    last=$(fc -lrn | awk 'NF && $0 !~ /^[[:space:]]*prev([[:space:]]|$)/ {print; exit}')
    pet new "$@" "$last"
  }
fi

#### zoxide (must be at the end)
eval "$(zoxide init zsh)"
