# =============================================================================
# custom/_examples/dotfiles/fish-local.fish — Декларативный fish-override
# =============================================================================
# Если этот файл лежит в custom/<host>/dotfiles/fish-local.fish, он
# симлинкается в ~/.config/fish/conf.d/local.fish (read-only из /nix/store).
# Загружается fish'ем при старте — последние alias/функции/env побеждают.
#
# Альтернатива — декларация через aliases.nix (через programs.fish.shellAliases
# в home-manager). Этот путь — для скриптов и более сложной логики, не только
# для алиасов.
#
# Чтобы активировать:
#   1. cp -r custom/_examples custom/(hostname)
#   2. Отредактируй под себя
#   3. nrs
# =============================================================================

# ── Личные алиасы (последние выигрывают над shellAliases из modules/) ────────
# alias myproj 'cd ~/work/my-project'
# alias docs 'cd ~/Documents'

# ── Личные функции (не помещаются в alias) ───────────────────────────────────
# function backup-now
#     set -l ts (date +%Y%m%d-%H%M%S)
#     borg create "/mnt/backup::manual-$ts" ~/Documents ~/Pictures ~/work
# end

# function dev-shell
#     set -l proj (basename (pwd))
#     tmux new-session -d -s $proj 'hx .'
#     tmux split-window -h -t $proj 'lazygit'
#     tmux attach -t $proj
# end

# ── Переменные окружения для твоего юзера ────────────────────────────────────
# set -x EDITOR helix
# set -x BROWSER firefox
# set -x PAGER bat

# Локальные API tokens (если не используешь sops):
# WARNING: ~/.config/fish/conf.d/local.fish (mutable вариант) НЕ уходит в git
# благодаря .gitignore, но эта декларативная версия — В РЕПО.
# Никогда не клади сюда настоящие токены! Используй sops для них (см.
# custom/_examples/secrets-usage.nix).

# ── PATH дополнения ──────────────────────────────────────────────────────────
# fish_add_path ~/bin
# fish_add_path ~/.cargo/bin
# fish_add_path ~/.local/share/go/bin
