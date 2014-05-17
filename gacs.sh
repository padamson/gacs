#!/bin/bash
#datadir=~/Research/data

generateCluster

for i in {1..5}
do
  tail -n +3 cluster_$i.xyz > cluster_$i.$$
  cat nw_head.txt cluster_$i.$$ nw_tail.txt > cluster_$i.nw
  rm cluster_$i.xyz cluster_$i.$$
done

