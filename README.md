# [Clear Linux](https://www.clearlinux.org/) Windows WSL Installation
**Features:**
- Works in 2023
- Latest releases

# Installation
- Update your Windows (min 2 Apr 2023, required for importing from `.xz`)
- [Activate WSL](https://learn.microsoft.com/en-us/windows/wsl/install) if not have been activated yet

- Download the latest Clear Linux server rootfs tarball (main purpose of this repo is maintaing of this tarball):
  <br>[`https://github.com/gh0st-work/clear-linux-wsl/releases/latest/downloads/clear_linux_rootfs.tar.xz`](https://github.com/gh0st-work/clear-linux-wsl/releases/latest/downloads/clear_linux_rootfs.tar.xz)

- Start a new Powershell session:
  <br>`<WIN+r>` `powershell` `<ENTER>`
  <br><br>![image](https://github.com/gh0st-work/clear-linux-wsl/assets/59336046/e930276e-6fac-4762-8303-a9389e64b8b9)
  <br>Or just run Powershell from Windows Start Menu

- Create sources directory:
  ```bash
  mkdir /wsl_distros/sources
  ```

- Copy (or move) the `clear_linux_rootfs.tar.xz` to the `/wsl_distros/sources/` directory:
  ```bash
  cp -v $HOME/Downloads/clear_linux_rootfs.tar.xz /wsl_distros/sources/
  ```

- Update WSL (min 2 Apr 2023, required for importing from `.xz`):
  ```bash
  wsl.exe --update
  ```

- Register Clear Linux as a new WSL2 distro:
  ```bash
  wsl.exe --import ClearLinux /wsl_distros/ClearLinux /wsl_distros/sources/clear_linux_rootfs.tar.xz --version 2
  ```

- Ensure the distro has been imported correctly:
  ```bash
  wsl.exe --list --verbose
  ```

- Create on your desktop shortcut with path:
  ```bash
  %windir%\system32\cmd.exe /k cd %userprofile% && wsl.exe -d ClearLinux
  ```
  and name
  <br>`ClearLinux`
  <br><br>Recomended:
    - Change icon in Properties to [`https://raw.githubusercontent.com/gh0st-work/clear-linux-wsl/main/clear_linux_logo.ico`](https://raw.githubusercontent.com/gh0st-work/clear-linux-wsl/main/clear_linux_logo.ico)
    - Pin to taskbar after running
- Run it

- Update the system:
  ```bash
  swupd update
  ```

- Create a new user (change `my_username` to your username):
  ```bash
  useradd -m -s /bin/bash my_username
  ```
  ```bash
  passwd my_username
  ```

- Add basic bundles: 
  ```bash
  swupd bundle-add sysadmin-basic sudo
  ```

- Add user to sudoers (change `my_username` to your username):
  ```bash
  usermod -aG wheel my_username
  ```

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
  Don't forget to change `my_username` to your username, and then exit writing with `EOF` at a new line:
  ```bash
  EOF
  ```

- Restart WSL machine with:
  ```bash
  exit
  wsl.exe --shutdown
  wsl.exe -d ClearLinux
  ```

### Devlogs
- The original idea is to update & maintain [this installtion method `extract rootfs to .tar`](https://community.clearlinux.org/t/rootfs-for-wsl-gitlab/1302) that was mentioned in [this tutorial](https://community.clearlinux.org/t/tutorial-clearlinux-on-wsl2/1835) to contain the latest version (not 4 years old as in original)
- Was decided to use [GitHub Action](https://github.com/gh0st-work/clear-linux-wsl/blob/main/.github/workflows/ci.yaml) to provide the latest version & to save my 20yo laptop resources (mainly my time lol) & just for fun of automation
- GitHub only allows to store maximum 2GB files
- Was decided to experiment with compression
- gzip compression of any level did not give satisfying result
- Found that `wsl` supports `.xz` compression container (w lzma2 compression, generally available on any unix machine) [as of 2 Apr 2023 as mentioned here](https://github.com/microsoft/WSL/issues/6056#issuecomment-1493423070)
- `xz -3` level of compression gives `1.9G` output that is alright (for now, Clear Linux tends to grow)
- `xz -T2` threads specified to speedup compression
- Found [an article that explains some math behind determining the optimal threads count](https://pavelkazenin.wordpress.com/2014/08/02/optimal-number-of-threads-in-parallel-computing/). This task does not require such kind of complexity to measure lzma2 algo params, but just found it interesting for further reading
