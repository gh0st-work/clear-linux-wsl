# [Clear Linux](https://www.clearlinux.org/) Windows WSL Installation
- Download the latest Clear Linux server rootfs tarball (main purpose of this repo is maintaing of this tarball):
<br>[`https://github.com/gh0st-work/clear-linux-wsl/releases/latest/downloads/clear_linux_rootfs.tar.gz`](https://github.com/gh0st-work/clear-linux-wsl/releases/latest/downloads/clear_linux_rootfs.tar.gz)
- Start a new Powershell session:
<br>`<WIN+r>` `powershell` `<ENTER>`
<br>![](https://global.discourse-cdn.com/clearlinux/original/2X/f/ff23f991225d08b7333f57ceb978a60c5cc9fddb.png)
<br>Or just run Powershell from Windows Start Menu
- Create sources directory:
<br>`mkdir /wsl_distros/sources`
- Copy (or move) the `clear_linux_rootfs.tar.gz` to the `/wsl_distros/sources/` directory:
<br>`cp -v $HOME/Downloads/clear_linux_rootfs.tar.gz /wsl_distros/sources/`
- Register Clear Linux as a new WSL2 distro:
<br>`wsl.exe --import clearlinux /wsl_distros/clearlinux /wsl_distros/sources/clear_linux_rootfs.tar.gz --version 2`
- Ensure the distro has been imported correctly:
<br>`wsl.exe --list --verbose`
- Create on your desktop shortcut with path:
<br>`%windir%\system32\cmd.exe /k cd %userprofile% && wsl.exe -d clearlinux`
<br>and name
<br>`Clear Linux`
<br>Recomended:
  - Change icon in Properties to `https://raw.githubusercontent.com/gh0st-work/clear-linux-wsl/main/clear_linux_logo.ico`
  - Pin to taskbar after running
- Run it
- Update the system:
<br>`swupd update`
- Create a new user (change `my_username` to your username):
<br>`useradd -m -s /bin/bash my_username`
<br>`passwd clearuser`
- Add basic bundles: 
<br>`swupd bundle-add sysadmin-basic sudo`
- Add user to sudoers (change `my_username` to your username):
<br>`usermod -aG wheel my_username`
- Write default `wsl.conf` config:
```bash
cat >> wsl.conf << 'EOF'
[automount]
enabled = true
options = "metadata,uid=1000,gid=1000,umask=22,fmask=11,case=off"
mountFsTab = true
crossDistro = true

[network]
generateHosts = true
generateResolvConf = true

[interop]
enabled = true
appendWindowsPath = true

[user]
default = my_username
```
<br>Don't forget to change `my_username` to your username, and then exit writing with `EOF`
```bash
EOF
```
- Restart WSL machine with:
```bash
exit
wsl.exe --shutdown
wsl.exe -d clearlinux
```
