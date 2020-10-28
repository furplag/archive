# RHEL, Cent OS

## General Setting

### unforcing SELinux
```selinux.bash
[root@anywhere ~]# setenfoce 0 && sed -i -e 's/^SELINUX=.*/#\0\nSELINUX=Permissive/' /etc/selinux/confog
```

### internationalization /localization
#### Display language
```locale.bash
# 7 or later
[root@gte el7]# localectl set-locale LANG=[language]_[country].UTF-8

# if you using GUI, also you need install "langpack (s) " .

# 6 and older
[root@lte el6]# sed -i -e 's/^LANG=.*/#\0\nLANG=[language]_[country].UTF-8/' /etc/sysconfig/i18n

# affected after reboot .
```

### Keyboard mapping
```keymap.bash
# 7 or later
[root@gte el7]# localectl set-keymap {keymapname}

# 6 and older
[root@lte el6]# sed -i -e 's/^\(KEYTABLE="\).*/\1"{keytable}"/' \
  -e 's/^\(MODEL="\).*/\1"{model}"/' \
  -e 's/^\(LAYOUT=\).*/\1"{layout}"/' \
  /etc/sysconfig/keyboard

# affected after reboot .
```

### Minimal (CUI) to Desktop (GUI)
```minimal-gui.sh
# 8
[root@gte el8]# dnf install -y control-center gnome-classic-session gnome-terminal gnome-terminal-nautilus

# 7
[root@ el7]# yum groupinstall -y "X Window System" "Fonts" "Xfce" && \
  yum install -y gnome-classic-session gnome-terminal gnome-terminal-nautilus

# 6 and older
[root@lte el6]# yum groupinstall "Base" "Desktop" "X Window System" -y

# switch GUI to default .
  # 7 or later
[root@gte el7]# systemctl set-default graphical.target
  
  # 6 and older
[root@lte el6]# sed -i -e 's/id:[0-6]/id:5/' /etc/inittab

# affected after reboot .
```
