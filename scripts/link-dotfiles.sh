#!/usr/bin/env bash
#
# link-dotfiles.sh — 把 dotfiles/ 里的受控文件逐个软链接到 $XDG_CONFIG_HOME
#
# 设计目标:
#   * 逐文件链接（不是整目录），所以程序运行时生成的
#     session.json / plugin_settings.json / outputs.kdl 等
#     会留在真实目录里，永远不会进 git。
#   * 幂等：重复运行安全，登录时跑一遍即可修复被程序覆盖的链接。
#
# 用法:
#   scripts/link-dotfiles.sh [--dry-run] [--sync-back] [--help]
#
#   -n, --dry-run    只打印将要做的操作，不实际修改
#   -s, --sync-back  若目标是真文件（被程序原子写覆盖了软链），
#                    先把它的内容同步回仓库再重建链接
#
# 文件清单来源:
#   `git ls-files dotfiles`（只链接已纳入版本控制的文件）
#
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
SRC_REL="dotfiles"
SRC_ROOT="$REPO_DIR/$SRC_REL"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
# 备份文件名后缀：时间 + .backup，例如 config.kdl.20241002-220400.backup
BACKUP_STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_SUFFIX=".${BACKUP_STAMP}.backup"
BACKUPS=()

DRY_RUN=0
SYNC_BACK=0
for arg in "$@"; do
  case "$arg" in
    -n|--dry-run) DRY_RUN=1 ;;
    -s|--sync-back) SYNC_BACK=1 ;;
    -h|--help) sed -n '2,25p' "$0"; exit 0 ;;
    *) echo "未知参数: $arg" >&2; exit 2 ;;
  esac
done

say() { printf '  %s\n' "$*"; }
run() {
  if (( DRY_RUN )); then
    printf '  [dry-run]'
    printf ' %q' "$@"
    printf '\n'
  else
    "$@"
  fi
}

if ! git -C "$REPO_DIR" rev-parse --git-dir >/dev/null 2>&1; then
  echo "错误：$REPO_DIR 不是 git 仓库，无法通过 git 列出受控文件。" >&2
  exit 1
fi

list_files() {
  git -C "$REPO_DIR" -c core.quotePath=false ls-files -- "$SRC_REL" \
    | sed "s|^$SRC_REL/||"
}

link_one() {
  local rel="$1"
  [[ -n "$rel" ]] || return 0
  local src="$SRC_ROOT/$rel"
  local dst="$CONFIG_HOME/$rel"

  if [[ ! -e "$src" ]]; then
    say "跳过（源不存在）: $rel"
    return 0
  fi

  if [[ -L "$dst" ]]; then
    if [[ "$(readlink -- "$dst")" == "$src" ]]; then
      say "已就绪: $rel"
      return 0
    fi
    say "重建链接: $rel"
    run rm -f -- "$dst"
  elif [[ -e "$dst" ]]; then
    if (( SYNC_BACK )) && ! cmp -s -- "$dst" "$src"; then
      say "同步回仓库: $rel （live -> repo）"
      run cp -f -- "$dst" "$src"
    fi
    # 备份到该文件当前所在目录，文件名追加时间和 .backup 后缀
    local backup="$dst$BACKUP_SUFFIX"
    say "备份并接管: $rel （备份为 $(basename -- "$backup")）"
    run mv -- "$dst" "$backup"
    BACKUPS+=("$backup")
  fi

  say "链接: $dst -> $src"
  run mkdir -p -- "$(dirname -- "$dst")"
  run ln -sfn -- "$src" "$dst"
}

printf '仓库:       %s\n' "$REPO_DIR"
printf '配置根目录: %s\n' "$CONFIG_HOME"
printf '备份后缀:   %s\n' "$BACKUP_SUFFIX"
(( DRY_RUN )) && printf '模式:       dry-run（不实际修改）\n'
printf '\n'

while IFS= read -r rel; do
  link_one "$rel"
done < <(list_files)

printf '\n完成。\n'
if (( ! DRY_RUN )) && (( ${#BACKUPS[@]} > 0 )); then
  printf '被接管的原文件已就地备份：\n'
  printf '  %s\n' "${BACKUPS[@]}"
fi
