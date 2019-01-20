# touch2sudo

`touch2sudo` is a standalone program if executed authenticates the user either through Touch ID or password. A successful authentication (confirmation) is signaled by a zero exit status from touch2sudo program.
To authenticate sudo commands, we configure touch2sudo as `SSH_ASKPASS` confirmation program, invoked by ssh-agent.

Infact this program can be used for any application that requires user authentication on Mac

The setup is described in the following sections

## Mac configuration

*Fingerprint authentication is done locally on Mac, but it acts as a gating mechanism for remote sudo authentication.*

If you haven't setup Touch ID, you can find the instructions from Apple [here](https://support.apple.com/en-us/HT207054)

## Download and build touch2sudo

```
git clone https://github.com/prbinu/touch2sudo
```

**Steps**

1. Open `touch2sudo.xcodeproj` file using [Xcode](https://developer.apple.com/xcode/)

2. Build: (*Product -> Build*)

3. Archive: (*Product -> Archive -> Distribute Content -> Build Products -> Next -> Save*) Save the archive folder. The touch2sudo executable will be in the `<ArchiveDir>/Product/usr/local/bin` path.

4. Copy `touch2sudo` binary to `/usr/local/bin`


## Configure ssh-agent with touch2sudo

Generate a new SSH key pair for sudo:

```
$ ssh-keygen -t rsa -b 2048
Generating public/private rsa key pair.
Enter file in which to save the key (/Users/binu/.ssh/id_rsa): /Users/binu/.ssh/id_rsa_sudo
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /Users/binu/.ssh/id_rsa_sudo.
Your public key has been saved in /Users/binu/.ssh/id_rsa_sudo.pub.
The key fingerprint is:
SHA256:6Vf0p0iUzQaiXqjQlUU+BYeTGiQqzUeC7z7iBNg7alE binu@localhostThe key's randomart image is:
+ - -[RSA 2048] - - +
| .. o.o+=++ |
| .o = oo+++ = |
| ..= o oo+.+ + |
|.. E.o o.o + o |
|o o. . S o . .|
| o .. . o . o |
| =. . . . . |
| +..o . |
|o… . |
+ - - [SHA256] - - -+
```

Start ssh-agent

```
$ export SSH_ASKPASS=/usr/local/bin/touch2sudo
$ export DISPLAY=0
$ eval $(ssh-agent)
Agent pid 56587

$ ssh-add -c ~/.ssh/id_rsa_sudo
Identity added: /Users/binu/.ssh/id_rsa_sudo (binu@localhost)
The user must confirm each use of the key
```

To make it work, on remote server you need to configure `pam-ssh-agent-auth` - a PAM module that does SSH key authentication for sudo. 
pam-ssh-agent-auth is based on SSH *agent-forwarding* feature that allow the PAM module to authenticate sudo command using key cached in ssh-agent running on your workstation (Mac).

For the complete information on end to end setup, please read:  <TODO>

>
