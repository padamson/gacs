gacs
============

This project utilizes density functional theory (DFT) calculations guided by genetic algorithm (GA) methods 
to search for cluster isomers.  It is intended for use on Spirit and Garnet at the DOD Supercomputing Resource 
Center (DSRC), but parts of it could be adapted for use elsewhere.

About
-----

The genetic algorithm driver executable `generateCluster` is built by compiling `GenerateCluster.chpl` which is 
written in [Chapel](http://chapel.cray.com/).  
The template directory contains scripts that will call `generateCluster` to build [NWChem](http://www.nwchem-sw.org/)
input files and submit them to Spirit or Garnet queues.

TODO: Currently the project merely generates random cluster geometries and builds/submits NWChem jobs to optimize the
geometries. Much work needs to be done to make it a true GA method.

Getting Started
===============

Using `git` without entering a username/password
------------------------------------------------

To use `git` to clone from and push commits to Github without a password (such as while working on a DSRC supercomputer), 
you may have to generate an SSH key and add it to your Github profile. Instructions are 
[here](https://help.github.com/articles/generating-ssh-keys/).

Install Chapel
--------------

Chapel compiles easily on both Spirit and Garnet using the supplied quick start instructions:
  > `git clone git@github.com:chapel-lang/chapel.git`
  > `cd chapel`
  > `source util/quickstart/setchplenv.bash`
  > `make`

You will also want to add `source ~/chapel/util/quickstart/setchplenv.bash` to your `~/.personal.bash_profile`.

Clone `gacs`
--------------------

`git clone git@github.com:padamson/gacs.git`

Compile and "install" `generateCluster.chpl`
--------------------------------------------

1. The scripts in the `template` directory expect to find the `generateCluster` executable in the `~/Research/bin/` directory, so
create that directory if you do not have one already:
  > `mkdir -p ~/Research/bin`
2. Add the directory to your path by adding the following to your `~/.personal.bash_profile`:
  > `export PATH=$PATH:~/Research/bin`
3. Make sure you are in the root `gacs` directory, such as:
  > `cd ~/gacs`
4. Compile the generateCluster executable:
  > `make`
