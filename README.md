# Strap

**One command to start your day.**

Bootstrap a developer workstation at the start of the day by running one command that self-updates its configuration from a git repository.

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

# Installation

From within a bash terminal:

    mkdir -p ~/OpenSource/ && cd ~/OpenSource
    git clone git@github.com:outrightmental/strap.git
    cd strap && sudo make install

If it's your first time running Strap, initialize a new strap configuration:

    strap init

This will create a folder `.strap` within your home folder. In order to activate the git-repo-synchronization feature of Strap, simply make that `~/.strap/` folder a git repository pointing to your origin repository of choice and Strap will take care of the rest.

# Usage

When you are ready to begin a working session, start by bootstrapping your local developer machine simply with:

    strap

# Components

Platform-agnostic components are:

+ user (whoami & group)
+ options (what sections to run? input/auto)
+ touchsudo
+ ssh (test, config, install credentials)
+ openvpn (install credentials)
+ profile (bash_profile)
+ strap
+ tmux
+ repository (git, sync all repos)
+ harvest (hcl, aliases)
+ systempackage
+ ruby (and rbenv, bundle)
+ nodejs (and npm)
+ python (and pip)
+ go
+ mysql (server, client, libs)
+ mongo (server)
+ redis (server, tools)
+ sublime (v3)

# Example

    $ strap
    
    >> User: charney
    
    >> touch sudo please
    [sudo] password for charney: 
    
    >> Pinged Gitlab @ Outright Mental Inc.
    > Welcome to GitLab, Charney Kaye!
    
    >> OS: Linux
    >> Debian Package virtualbox is installed.
    Version: 4.3.10-dfsg-1ubuntu5
    
    >> Debian Package vagrant is installed.
    Version: 1.4.3-1
    Ruby-Versions: ruby1.9.1
    
    >> Debian Package git is installed.
    Version: 1:1.9.1-1ubuntu0.1
    
    >> Debian Package xclip is installed.
    Version: 0.12+svn84-4
    
    >> Debian Package python is installed.
    Version: 2.7.5-5ubuntu3
    
    >> Debian Package tmux is installed.
    Version: 1.8-5
    
    >> Debian Package tree is installed.
    Version: 1.6.0-1
    
    >> Debian Package libssl-dev is installed.
    Version: 1.0.1f-1ubuntu2.15
    
    >> Debian Package openvpn is installed.
    Version: 2.3.7-debian0
    
    >> Debian Package network-manager-openvpn-gnome is installed.
    Version: 0.9.8.2-1ubuntu4
    
    >> Debian Package nfs-kernel-server is installed.
    Version: 1:1.2.8-6ubuntu1.1
    
    >> Debian Package python-pip is installed.
    Version: 1.5.4-1ubuntu3
    
    >> Pulling existing repository /home/charney/.rbenv
    Ya está en «master»
    Your branch is up-to-date with 'origin/master'.
    Already up-to-date.
    
    >> Pulling existing repository /home/charney/.rbenv/plugins/ruby-build
    Ya está en «master»
    Your branch is up-to-date with 'origin/master'.
    Already up-to-date.
    
    >> Rbenv Ruby: 2.1.5
    
    >> Sublime: Sublime Text Build 3083
    
    >> Password Repository
    Already up-to-date.
    Counting objects: 7, done.
    Delta compression using up to 4 threads.
    Compressing objects: 100% (4/4), done.
    Writing objects: 100% (4/4), 1.41 KiB | 0 bytes/s, done.
    Total 4 (delta 2), reused 0 (delta 0)
    To git@y00.us:charney/strap.git
       094699d..fcc924f  master -> master
    
    Bundler version 1.9.6
    >> Harvest Command Line
    >> Pulling existing repository /home/charney/OpenSource/hcl
    Ya está en «master»
    Your branch is up-to-date with 'origin/master'.
    Already up-to-date.
    
    >> Outright Mental Platform
    
    >> Pulling existing repository /home/charney/Development/o2/platform
    Ya está en «master»
    Your branch is up-to-date with 'origin/master'.
    Already up-to-date.
    
    >> Open Source Development
    
    >> Cloning new repository /home/nick/OpenSource/developer-bootstrap
    Clonar en «developer-bootstrap»...
    remote: Counting objects: 7, done.
    remote: Compressing objects: 100% (7/7), done.
    remote: Total 7 (delta 1), reused 0 (delta 0), pack-reused 0
    Receiving objects: 100% (7/7), done.
    Resolving deltas: 100% (1/1), done.
    Checking connectivity... hecho.
        
    ping: unknown host signal
    >> SKIPPING Signal (Out of Network)
    
                            --- 
                         +        -- 
                     --( /     \ )$$$$$$$$$$$$$ 
                 --$$$(   O   O  )$$$$$$$$$$$$$$$- 
                /$$$(       U     )        $$$$$$$\ 
              /$$$$$(              )--   $$$$$$$$$$$\ 
             /$$$$$/ (      O     )   $$$$$$   \$$$$$\ 
             $$$$$/   /            $$$$$$   \   \$$$$$---- 
             $$$$$$  /          $$$$$$         \  ----  - 
     ---     $$$  /          $$$$$$      \           --- 
       --  --  /      /\  $$$$$$            /     ---= 
         +        /    $$$$$$              '--- $$$$$$ 
           --\/$$$\ $$$$$$                      /$$$$$ 
             \$$$$$$$$$                        /$$$$$/ 
              \$$$$$$                         /$$$$$/ 
                \$$$$$--  /                -- $$$$/ 
                 --$$$$$$$---------------  $$$$$-- 
                    \$$$$$$$$$$$$$$$$$$$$$$$$- 
                      --$$$$$$$$$$$$$$$$$$-    
    
    >> Bootstrapped OK. Happy Coding!
