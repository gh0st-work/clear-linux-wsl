# [Clear Linux](https://www.clearlinux.org/) Windows WSL Installation
**Features:**
- Works in 2024
- The latest releases, provided weekly

## Installation
- Update your Windows (min 2 Apr 2023, required for importing from `.xz`)
- [Activate WSL](https://learn.microsoft.com/en-us/windows/wsl/install) if not have been activated yet

- Download the latest Clear Linux server rootfs tarball (main purpose of this repo is maintaing of this tarball):
  <br>[`https://github.com/gh0st-work/clear-linux-wsl/releases/latest/download/clear_linux_rootfs.tar.xz`](https://github.com/gh0st-work/clear-linux-wsl/releases/latest/download/clear_linux_rootfs.tar.xz)
  
- Start a new Powershell session:
  <br>`<WIN + r>` `powershell` `<ENTER>`
  <br><br>![image](https://github.com/gh0st-work/clear-linux-wsl/assets/59336046/e930276e-6fac-4762-8303-a9389e64b8b9)
  <br>Or just run Powershell from Windows Start Menu

- Create sources directory:
  ```bash
  mkdir /wsl_distros/sources
  ```
  ![image](https://github.com/gh0st-work/clear-linux-wsl/assets/59336046/014706e1-78e2-4cfc-8c58-d73de0423692)


- Copy (or move) the `clear_linux_rootfs.tar.xz` to the `/wsl_distros/sources/` directory:
  ```bash
  cp -v $HOME/Downloads/clear_linux_rootfs.tar.xz /wsl_distros/sources/
  ```
  ![image](https://github.com/gh0st-work/clear-linux-wsl/assets/59336046/0761ca8f-2860-46ad-b98a-54ca99a1b866)


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
  ![image](https://github.com/gh0st-work/clear-linux-wsl/assets/59336046/c6323f37-a4f3-4224-bf5f-721fd9108c1e)


- Create on your desktop shortcut with path:
  ```bash
  %windir%\system32\cmd.exe /k cd %userprofile% && wsl.exe -d ClearLinux --cd ~
  ```
  and name
  <br>`ClearLinux`
  <br><br>Recomended:
    - Change icon in Properties to [`https://raw.githubusercontent.com/gh0st-work/clear-linux-wsl/main/clear_linux_logo.ico`](https://raw.githubusercontent.com/gh0st-work/clear-linux-wsl/main/clear_linux_logo.ico)

- Run it
  
  ![image](https://github.com/gh0st-work/clear-linux-wsl/assets/59336046/0381edc8-39b5-41a2-ab73-1dff6d5b74f7)


- Update the system:
  ```bash
  swupd update
  ```

- Create a new user (change `USERNAME` to your username):
  ```bash
  useradd -m -s /bin/bash USERNAME
  ```
  ```bash
  passwd USERNAME
  ```

- Add basic bundles: 
  ```bash
  swupd bundle-add sysadmin-basic sudo
  ```

- Add user to sudoers (change `USERNAME` to your username):
  ```bash
  usermod -aG wheel USERNAME
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
  default = USERNAME
  ```
  Don't forget to change `USERNAME` to your username, and then exit writing with `EOF` at a new line:
  ```bash
  EOF
  ```

- Shutdown WSL machine with:
  ```bash
  exit
  wsl.exe -d ClearLinux --shutdown
  exit
  ```
  
- Edit your shortcut path (in Properties) adding `-u USERNAME` (change `USERNAME` to your username) before `--cd ~`:
  ```bash
  %windir%\system32\cmd.exe /k cd %userprofile% && wsl.exe -d ClearLinux -u USERNAME --cd ~
  ```

- Run it

  ![image](https://github.com/gh0st-work/clear-linux-wsl/assets/59336046/d2f51814-d660-43f0-a09e-24163aadcc72)

  And here you are, logged as your user without any errors

- Recommended:
  - Pin to taskbar after running

- Happy hacking :)

  And don't forget to star the repo pls!

## Installation from source
For more experienced users: you can use `get_latest_rootfs.sh` script to get official images yourself, if you assume this repo GitHub releases can be compromised
- Install [Ubuntu WSL](https://www.microsoft.com/store/productId/9PDXGNCFSCZV) and run it
- Download the script:
  ```bash
  wget https://raw.githubusercontent.com/gh0st-work/clear-linux-wsl/main/get_latest_rootfs.sh
  ```
- Run it:
  ```bash
  bash get_latest_rootfs.sh 1 1
  ```
  Where:
  - First argument sets xz compression level to 1 as you are not limited by GitHub size limit and don't want to waste time
  - Second argument sets threads count to 1, you can calculate it yourself using `lscpu`
  <br>
- Copy result tarball to Windows `Downloads` folder (change `WINDOWS_USERNAME` to your Windows user username):
  ```bash
  sudo cp clear_linux_rootfs.tar.xz /mnt/c/Users/WINDOWS_USERNAME/Downloads/
  ```
- Follow default installation instructions

## Devlog
- The main idea is to update & maintain 
  [this installation method `extract rootfs to .tar`](https://community.clearlinux.org/t/rootfs-for-wsl-gitlab/1302) 
  that was mentioned in 
  [this tutorial](https://community.clearlinux.org/t/tutorial-clearlinux-on-wsl2/1835) 
  to contain the latest version 
  (not 4 years old version as it is in the original tutorial)

- Was decided to use [GitHub Action](https://github.com/gh0st-work/clear-linux-wsl/blob/main/.github/workflows/ci.yaml) 
  to provide the latest version & to save my 20yo laptop resources (mainly my time lol) & just for fun of automation

- GitHub only allows to store maximum 2GB files

- Was decided to experiment with compression

- gzip compression of any level did not give satisfying result

- Found that `wsl` supports `.xz` compression container 
  (w lzma2 compression, generally available on any unix machine) 
  [as of 2 Apr 2023 as mentioned here](https://github.com/microsoft/WSL/issues/6056#issuecomment-1493423070)

- Found unix compressions
  [benchmark #1](https://stephane.lesimple.fr/blog/lzop-vs-compress-vs-gzip-vs-bzip2-vs-lzma-vs-lzma2xz-benchmark-reloaded/)
  & [benchmark #2](https://www.rootusers.com/gzip-vs-bzip2-vs-xz-performance-comparison/)

- `xz -4` level of compression gives `1.9G` output that is alright 
  (for now, may change in future, have ~10-15% to compress where)

- `xz -T2` threads specified to speedup compression
  (takes ~14min to compress 
  & ~9min to upload artifact 
  & ~1min to upload artifact to release draft, 
  ~24min together)

- Found [an article that explains some math behind determining the optimal threads count](https://pavelkazenin.wordpress.com/2014/08/02/optimal-number-of-threads-in-parallel-computing/).
  This task does not require such kind of complexity to measure lzma2 algo params, 
  but just found it interesting for further reading

- Works as 4 Dec 2023,
  provided detailed `README.md` 
  & `Installation from source` instructions, 
  trust nobody not even yourself kekw

- Now accepts `get_latest_rootfs.sh` arguments
  & changed `Installation from source` instructions
  & tested

- Auto-releases enabled:
  Every GHA run automatically publishes a release

- `xz -5` level of compression set,
  as [40580 release](https://github.com/gh0st-work/clear-linux-wsl/releases/tag/40580) reaches `1.9`-`2.0` GB.
  New `5` level of compression gives `1.85` GB result
  (takes ~18min to compress 
  & ~8min to upload artifact 
  & ~1min to upload artifact to release draft, 
  ~27min together)

