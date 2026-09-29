首先安装nix，参考[nixos/download](https://nixos.org/download/)。

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
