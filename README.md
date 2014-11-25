gacs-uranium
============

This project will utilize density functional theory (DFT) calculations guided by genetic algorithm (GA) methods 
to search for cluster isomers.  It is intended for use on Spirit and Garnet at the DOD Supercomputing Resource Center (DSRC), but
parts of it could be adapted for use elsewhere.

Getting Started
===============

Using `git` without entering a username/password
------------------------------------------------

To use `git` to clone from and push commits to Github without a password (such as while working on a DSRC supercomputer), 
you may have to generate an SSH key and add it to your Github profile. Instructions are 
[here](https://help.github.com/articles/generating-ssh-keys/).

Install Chapel
--------------

The genetic algorithm code (GenerateCluster.chpl) is writtin in [Chapel](http://chapel.cray.com/). Chapel compiles easily
on both Spirit and Garnet using the supplied quick start instructions.

Compile and "install" `generateCluster.chpl`
--------------------------------------------

1. The scripts in the `template` directory expect to find the `generateCluster` executable in the `~/Research/bin/` directory, so
create that directory if you do not have one already:

> `mkdir -p ~/Research/bin`

2. Add the directory to your path by adding the following to your `~/.personal.bash_profile`:

> `export PATH=$PATH:~/Research/bin`

2. Make sure you are in the root `gacs-uranium` directory, such as:

> `cd ~/gacs-uranium`

3. Compile the generateCluster executable:

> `make`
