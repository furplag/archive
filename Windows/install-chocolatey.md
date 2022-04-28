# Management of Software packages on Windows using "Chocolatey"

## TL;DR

```command.ps1
Set-ExecutionPolicy Bypass -Scope Process -Force;
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

## Overview

* [Prerequirement](#prerequirement)
* [Installation](#installation)
* [Install Chocolatey GUI](#install-chocolatey-gui)
* [Before to use](#before-to-use)


### Prerequirement

- [ ]  enable to access Internet
- [ ]  Administrators, or executable as an Administrator

> follow the guide below, if you cannot to be administrable .  
> [Chocolatey Software Docs | Setup / Non administrative Install](https://docs.chocolatey.org/en-us/choco/setup#non-administrative-install)


### Installation

1. Start "Windows PowerShell" as an Administrator .
   
   > right-click and choose "Run as Administrator" .

2. paste command below into PowerShell window, then execute .
   
   ```install-chocolatey.ps1
   Set-ExecutionPolicy Bypass -Scope Process -Force;[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
   ```

3. type `choco -v` after installation successful .


### Install Chocolatey GUI

1. type `choco install chocolateygui` onto PowerShell window, then execute .


### Before to use

read the documentation below .  
[Chocolatey Software Docs | Chocolatey - Software Management for Windows](https://docs.chocolatey.org/en-us/) .


## Trademark notice

Chocolatey is a registered trademark of Chocolatey Software, Inc.

## License
[![Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License](https://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png)](http://creativecommons.org/licenses/by-nc-sa/4.0/)

the work is licensed under a [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License](./LICENSE) .
