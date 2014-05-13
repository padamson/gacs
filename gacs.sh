#!/bin/bash
#datadir=~/Research/data

generateCluster

for i in {1..10}
do
  tail -n +3 cluster_$i.xyz > cluster_$i.$$
  cat nw_head.txt cluster_$i.$$ nw_tail.txt > cluster_$i.nw
done

#babel -ixyz $datadir/cluster_1.xyz -ogamin $datadir/cluster_1.inp

rm *.$$
