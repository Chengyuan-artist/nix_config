# 我的nix配置

目前我使用nix和home-manager管理kitty配置，neovim，字体以及其他用户态非gui应用。
系统态以及gui应用使用archlinux的包管理器管理，配置文件（niri和dms）放入本仓库中使用git管理。

## nix包管理
首先安装nix，参考[nixos/download](https://nixos.org/download/)。
（如果使用archlinux则直接使用pacman安装nix即可）

添加nixpkgs和home mananger源，注意保持二者的版本一致：
```bash
nix-channel --add https://nixos.org/channels/nixos-26.05 nixpkgs
nix-channel --add https://github.com/nix-community/home-manager/archive/release-26.05.tar.gz home-manager
```

安装home-manager:
```bash
nix-shell '<home-manager>' -A install
```

下载我的nix配置：
```bash
git clone https://github.com/Chengyuan-artist/nix_config.git ~/.config/nixpkgs 
```

在home-manager配置中添加配置路径：
```bash
vim ~/.config/home-manager/home.nix
```
内容例如：
```nix
{
	imports = [/home/zcy/.config/nixpkgs/usr];
}
```

最后部署配置：
```bash
home-manager switch
```

## Archlinux配置

完成archlinux的基本安装，参考[archwiki](https://wiki.archlinux.org/title/Installation_guide)。

在仓库根目录下，从文件列表安装软件包（root权限）：
```bash
pacman -S --needed - < arch/pacman.txt
```

(备忘：sudo -> wheel分组, sddm配置 -> enable，蓝牙 -> enable bluetooth)。

安装yay，参考[github/yay](https://github.com/Jguer/yay):
```bash
sudo pacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin
makepkg -si
```

从文件列表安装AUR软件包：
```bash
yay -S --needed - < arch/yay.txt
```

若此后安装了新的软件包，使用`scripts/update-arch-packages.sh`更新`arch/pacman.txt`和`arch/yay.txt`。

按照[上述配置](#nix包管理)完成nix包的安装。

### niri+dms

使用`scripts/link-dotfiles.sh`为niri和dms配置建立指向仓库的软链接。

让dms随niri启动：
```bash
systemctl --user add-wants niri.service dms.service
```
