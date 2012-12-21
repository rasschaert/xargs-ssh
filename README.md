xargs-ssh
=============

This simple bash script runs multiple ssh commands in parallel by leveraging the parallel processing power of xargs. I first learned of this trick on [Jordan Sissel's blog](http://www.semicomplete.com/blog/articles/week-of-unix-tools/day-5-xargs.html).

There are already a number of tools available to run ssh in parallel:
* [pssh](http://www.theether.org/pssh/)
* [sshpt](http://code.google.com/p/sshpt/)
* [clusterssh](http://clusterssh.sourceforge.net/)
* [Capistrano](http://capistranorb.com/)
* [Fabric](http://fabfile.org/)
* [Func](https://fedorahosted.org/func/)

These tools all have numerous advantages and features that this simple script doesn't. The single advantage that xarg-ssh has over these alternatives is that it's just a bash script that you can run.

Dependencies:
-------------
The following tools are needed to run xargs-ssh.bash:
* bash
* openssh-client (also known as "ssh")
* xargs
* awk
* tput
* find
* POSIX shell (also known as "sh")
* printf
* perl (this is a dependency I hope to remove soon)

These are all tools that are commonly found on any GNU/Linux system.