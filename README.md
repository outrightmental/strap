[![Build Status](https://travis-ci.org/outrightmental/strap.svg)](https://travis-ci.org/outrightmental/strap)

# Strap

**One command to start your day.**

Bootstrap a developer workstation at the start of the day by running one command that self-updates its configuration from a git repository.

Helps to make our own physical workstation more ephemeral, enabling work on multiple workstations and recovery when one is lost or compromised.

![Strap: One command to start your day](http://static.outright.io/2015/07/strap-by-outright-mental-inc-demo-one-command-to-start-your-day.gif)

Visit the project page for more information: http://strap.outright.io/

Please see the man page for documentation and examples.

Depends on:
- bash
  http://www.gnu.org/software/bash/
- git
  http://www.git-scm.com/
- GNU getopt
  http://www.kernel.org/pub/linux/utils/util-linux/
  http://software.frodo.looijaard.name/getopt/

# Usage

When you are ready to begin a working session, start by bootstrapping your local developer machine simply with:

    strap

Which automatically straps up all the "buckles" for your workstation:   

            |
       __|  __|   __|  _` |  __ \
     \__ \  |    |    (   |  |   |
     ____/ \__| _|   \__,_|  .__/
                            _|
    
     • hello charney
    
     ✔ ubuntu
    
     • no osx
    
     ✔ base
    
     ✔ o2
    
    ping: unknown host gitlab01dv1
     • no bt
    
     ✔ gh
    
     • Strap ubuntu...
       libssl-dev 1.0.1f-1ubuntu2.15
       xclip 0.12+svn84-4
       tree 1.6.0-1
       nfs-kernel-server 1:1.2.8-6ubuntu1.1
       python-pip 1.5.4-1ubuntu3
       network-manager-openvpn-gnome 0.9.8.2-1ubuntu4
       virtualbox 4.3.10-dfsg-1ubuntu5
       python 2.7.5-5ubuntu3
       openvpn 2.3.7-debian0
       vagrant 1.4.3-1
       tmux 1.8-5
       git 1:1.9.1-1ubuntu0.1

And so on, and so forth.. This is a scaffold for *your* personal optimal configuration, to make the workstation itself ephemeral.

# Installation

From within a bash terminal:

    mkdir -p ~/OpenSource/ && cd ~/OpenSource
    git clone git@github.com:outrightmental/strap.git
    cd strap && sudo make install

If it's your first time running Strap, initialize a new strap configuration:

    strap init

This will create a folder `.strap` within your home folder, with a blank `config.sh.yml` file inside.

# Configuration

Edit the configuration with:
    
    strap edit config

This will open the configuration in your editor of choice, probably `vi` by default. *(If you prefer to use a different editor, just set environment variable `EDITOR`, e.g. `export EDITOR=nano` in your `.bash_profile`)*

Available Strap configuration options are:

+ `straps` containing straps, each of which evaluates a command in order to decide whether that strap will be included in the current run.
+ `begin` containing options about the beginning of a run.

Here's an example of a fully configured `strap edit config`:

    straps:
      o2: ping -c1 code.outright.io
      bt: ping -c1 gitlab01dv1
      gh: ping -c1 github.com
      base: echo
    begin:
      banner: "Hello World!"
    complete
      banner: "All Done!"

## Git Sync

In order to activate the git-repo-synchronization features of Strap, use `strap git <command>` to initialize a git repository from the internal buckle storage folder pointing to your origin repository of choice:

    strap git init
    strap git remote add origin git@github.com:charneykaye/strap.git
    strap git push origin master -u

# Buckles

In its simplest form, a buckle is a pointer to a "type" meaning a Prototype of something that you want to strap up on your workstation.

The fastest way to add a new one is with `strap insert <path>`:

    strap insert base/passwordstore
    
      > mkdir: created directory «/home/nick/.strap/base»
      > Enter buckle YAML for base/passwordstore:
    
    type: pass
    
      > [master 212eca8] Add given buckle for base/passwordstore to store.
      >  1 file changed, 1 insertion(+)
      >  create mode 100644 base/passwordstore.sh.yml

It's also possible to add a multiline buckle with `strap insert -m <path>`:

    strap insert -m github/passwords
    
      > Enter buckle YAML for github/passwords and press Ctrl+D when finished:
    
    type: repo
    url: git@github.com:charneykaye/pass.git
    clone_as: .password-store
    parent_path: $HOME
    
      > [master 4f0410f] Add given buckle for o2/passwords to store.
      > 1 file changed, 1 insertion(+)
      > create mode 100644 o2/pass.sh.yml

Inside of our `ubuntu` strap we might keep (for example) a buckle to ensure that VirtualBox is installed on a Debian linux workstation. We could call this `ubuntu/virtualbox` and it would be run automatically with the `ubuntu` strap  **because the strap name is found within the buckle path**.

    type: dpkg
    name: virtualbox

# Types

Currently shipped:

+ whoami (get user and touch sudo)
+ dpkg (debian packages)
+ pass (password store)
+ rbenv
+ repo (git, sync all repos)

To do:

+ profile (bash_profile)
+ options (what sections to run? input/auto)
+ ssh (test, config, install credentials)
+ openvpn (install credentials)
+ tmux
+ harvest (hcl, aliases)
+ rbtools (review board)
+ sublime (v3)
+ nginx
+ ruby (bundler for rbenv)
+ nodejs (and npm)
+ python (and pip)
+ go
+ java
+ mysql (server, client, libs)
+ mongo (server)
+ redis (server, tools)
