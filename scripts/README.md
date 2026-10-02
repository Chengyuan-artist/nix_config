# dotfiles 逐文件软链接方案

把 `dotfiles/` 里的**受版本控制的文件**逐个软链接到 `$XDG_CONFIG_HOME`
（默认 `~/.config`），目录本身保持为真实目录。

## 为什么用"逐文件"而不是"整目录"

- 程序运行时生成的 `session.json` / `plugin_settings.json` /
  `outputs.kdl` 等留在真实目录里，**永远不会进 git**，不需要 `.gitignore`。
- 只有你明确纳入版本控制的文件才会被链接。

## 目录结构

```
~/.config/nixpkgs/
├── dotfiles/                       # 只放要版本控制、要被链接的文件
│   ├── niri/
│   │   ├── config.kdl
│   │   └── dms/
│   │       ├── binds.kdl
│   │       └── ...
│   └── DankMaterialShell/
│       └── settings.json
└── scripts/
    └── link-dotfiles.sh            # 链接脚本
```

`dotfiles/` 下的相对路径 = `~/.config` 下的相对路径。
例如 `dotfiles/niri/config.kdl` → `~/.config/niri/config.kdl`。

## 手动使用

```bash
# 预览将要做什么（不改动任何东西）
~/.config/nixpkgs/scripts/link-dotfiles.sh --dry-run

# 实际执行
~/.config/nixpkgs/scripts/link-dotfiles.sh

# 若某文件被程序原子写覆盖成真文件，把内容同步回仓库再重建链接
~/.config/nixpkgs/scripts/link-dotfiles.sh --sync-back
```

## 注意事项

- 少数程序保存配置时用"临时文件 + rename"的原子写，会把软链接替换成真文件。
  这种情况登录时重跑脚本即可修复；加 `--sync-back` 还能把新内容写回仓库，
  避免丢改动。DMS 的 `settings.json` 建议留意，若发现被覆盖就启用 `--sync-back`。
- 软链接使用绝对路径，仓库位置变动需重跑脚本。
