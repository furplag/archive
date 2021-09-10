# RHEL

## ToC
* ### el8
  * #### -bash: python: command not found
* ### el7
* ### el6

## el8

### `python` returns an error, -bash: python: command not found
* [ ] command `python3 -V || python2 -V` shows the version normally . -> Solution A.
* [ ] command `ls -al /usr/bin/python*` shows nothing . -> Solution B.
  ```result.sh
  lrwxrwxrwx. 1 root root     7  8月 19 02:23 /usr/bin/python -> python3
  lrwxrwxrwx. 1 root root     9  8月 19 02:23 /usr/bin/python2 -> python2.7
  -rwxr-xr-x. 1 root root  7144  3月 13 07:56 /usr/bin/python2.7
  lrwxrwxrwx. 1 root root     9  8月 19 02:37 /usr/bin/python3 -> python3.6
  -rwxr-xr-x. 2 root root 11336  3月 10  2021 /usr/bin/python3.6
  -rwxr-xr-x. 2 root root 11336  3月 10  2021 /usr/bin/python3.6m
  ```
#### Solution:
<details>
  <summary>A. I'm sure that I was install python ( or any versioned ) .</summary>
  
  1. configure `python` command with `alternatives --config python` .
  ```alternatives.sh
  
There are 3 programs which provide 'python'.

  Selection    Command
-----------------------------------------------
*  1           /usr/libexec/no-python
 + 2           /usr/bin/python3
   3           /usr/bin/python3.9

Enter to keep the current selection[+], or type selection number:
  ```
</details>

<details>
  <summary>B. python ain't installed yet .</summary>
  
  1. check installed package, `dnf list installed python*` .
  1. check modules, `dnf module list python*` .
  > maybe found, in Appstream, choose, and install .
  ```result.sh
  Name                   Stream             Profiles                  Summary
python27               2.7 [d]            common [d]                Python programming language, version 2.7
python36               3.6 [d][e]         build, common [d]         Python programming language, version 3.6
python38               3.8 [d]            build, common [d]         Python programming language, version 3.8
python39               3.9 [d]            build, common [d]         Python programming language, version 3.9
  ```
  1. but still not resolve, see Solution A.
</details>
