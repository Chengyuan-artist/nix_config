#!/usr/bin/env bash
#
# update-arch-packages.sh — 刷新 arch/ 下记录的包清单
#
# 生成内容:
#   arch/pacman.txt  pacman 显式安装的官方仓库包   (pacman -Qqen)
#   arch/yay.txt     yay/AUR 显式安装的包，排除 yay 自身 (pacman -Qqem)
#
# 说明:
#   pacman 无法记录“某个包是用哪个工具装的”，这里用官方仓库(native)与
#   外部包(foreign/AUR)来区分：默认来自仓库的算 pacman，AUR 的算 yay。
#
# 用法:
#   scripts/update-arch-packages.sh [--dry-run] [--check] [--help]
#
#   -n, --dry-run   只打印将要做的改动，不写文件
#   -c, --check     只检查是否有差异（有差异退出码为 1），不写文件
#
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
ARCH_DIR="$REPO_DIR/arch"
PACMAN_FILE="$ARCH_DIR/pacman.txt"
YAY_FILE="$ARCH_DIR/yay.txt"

# yay.txt 中要排除的包（每行一个，精确匹配）
EXCLUDE_YAY=(
  yay
)

DRY_RUN=0
CHECK=0
for arg in "$@"; do
  case "$arg" in
    -n|--dry-run) DRY_RUN=1 ;;
    -c|--check)   CHECK=1 ;;
    -h|--help)    sed -n '2,18p' "$0"; exit 0 ;;
    *) echo "未知参数: $arg" >&2; exit 2 ;;
  esac
done

if ! command -v pacman >/dev/null 2>&1; then
  echo "错误：找不到 pacman，本脚本只能在 Arch 系系统上运行。" >&2
  exit 1
fi

say() { printf '  %s\n' "$*"; }

# 生成两份清单（已排序，去掉空行）
gen_pacman() {
  pacman -Qqen | LC_ALL=C sort -u
}

gen_yay() {
  local exclude
  exclude="$(printf '%s\n' "${EXCLUDE_YAY[@]}")"
  pacman -Qqem \
    | grep -vxF -e "$exclude" \
    | LC_ALL=C sort -u
}

# 把内容写进文件；dry-run/check 下只报告差异。
#   参数: 目标文件, 内容
update_file() {
  local file="$1" content="$2"
  local rel="${file#"$REPO_DIR"/}"

  if [[ -f "$file" ]] && diff -q <(printf '%s\n' "$content") "$file" >/dev/null 2>&1; then
    say "无变化: $rel"
    return 0
  fi

  say "有变化: $rel"
  if [[ -f "$file" ]]; then
    diff -u "$file" <(printf '%s\n' "$content") | sed 's/^/    /' || true
  else
    printf '    (新文件)\n'
  fi

  if (( CHECK )); then
    return 1
  fi
  if (( DRY_RUN )); then
    return 0
  fi
  printf '%s\n' "$content" > "$file"
}

mkdir -p -- "$ARCH_DIR"

printf '仓库:       %s\n' "$REPO_DIR"
printf '清单目录:   %s\n' "$ARCH_DIR"
(( DRY_RUN )) && printf '模式:       dry-run（不写文件）\n'
(( CHECK ))   && printf '模式:       check（仅检查）\n'
printf '\n'

rc=0
update_file "$PACMAN_FILE" "$(gen_pacman)" || rc=1
update_file "$YAY_FILE"    "$(gen_yay)"    || rc=1

printf '\n'
if (( CHECK )); then
  if (( rc == 0 )); then
    printf '清单已是最新。\n'
  else
    printf '清单有差异。\n'
  fi
else
  printf '完成。\n'
fi
exit "$rc"
