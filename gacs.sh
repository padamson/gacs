#!/bin/bash
datadir=~/Research/data

generateCluster

tail -n +3 cluster_1.xyz > cluster_1.$$
cat nw_head.txt cluster_1.$$ nw_tail.txt > cluster_1.nw

#babel -ixyz $datadir/cluster_1.xyz -ogamin $datadir/cluster_1.inp

rm *.$$
