#!/bin/bash
#datadir=~/Research/data
nu=$1
no=$2
charge=$3
wrkdir=u${1}o${2}${charge}
mkdir ../$wrkdir
cd ../$wrkdir

sed "s/u3o8/$wrkdir/g" ../template/nw_head.txt > nw_head.txt.$$
sed "s/charge 0/charge $charge/g" nw_head.txt.$$ > nw_head.txt
rm nw_head.txt.$$
cp ../template/nw_tail.txt .

sed "s/u3o8/$wrkdir/g" ../template/clstr_1_10.js > clstr_1_10.js
sed "s/u3o8/$wrkdir/g" ../template/clstr_1_10.csh > clstr_1_10.csh

sed "s/numberOfEachAtomType 3/numberOfEachAtomType $nu/g" ../template/cluster.in > cluster.in.$$
sed "s/numberOfEachAtomType 8/numberOfEachAtomType $no/g" cluster.in.$$ > cluster.in
rm cluster.in.$$

generateCluster -i cluster.in

for i in {1..10}
do
  tail -n +3 cluster_$i.xyz > cluster_$i.$$
  cat nw_head.txt cluster_$i.$$ nw_tail.txt > cluster_$i.nw
  rm cluster_$i.xyz cluster_$i.$$
done

