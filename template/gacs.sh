#!/bin/bash
#datadir=~/Research/data
nu=$1
no=$2
charge=$3
wrkdir=u${1}o${2}${charge}
mkdir /home/padamson/Research/$wrkdir
cd /home/padamson/Research/$wrkdir

mach=`uname -n | awk '{print substr ($0, 0, 2)}'`

if [[ "$mach" == 'sp' ]]; then
  sed "s/u3o8/$wrkdir/g" /home/padamson/gacs-uranium/template/clstr_1_10.csh > clstr_1_10.csh
  account=WPTAFITO11533311
  sed "s/u3o8/$wrkdir/g" /home/padamson/gacs-uranium/template/clstr_1_10.js > clstr_1_10.js.$$
  sed "s/account/$account/g" clstr_1_10.js.$$ > clstr_1_10.js
  rm clstr_1_10.js.$$
elif [[ "$mach" == 'li' ]]; then
  sed "s/apps/app/g" /home/padamson/gacs-uranium/template/clstr_1_10.csh > clstr_1_10.csh.$$
  sed "s/u3o8/$wrkdir/g" clstr_1_10.csh.$$ > clstr_1_10.csh
  rm clstr_1_10.csh.$$
  account=WPMWPASC96150LTN
  sed "s/u3o8/$wrkdir/g" /home/padamson/gacs-uranium/template/clstr_1_10.js > clstr_1_10.js.$$
  sed "s/account/$account/g" clstr_1_10.js.$$ > clstr_1_10.js
  sed "s/ncpus=32/ncpus=24/g" clstr_1_10.js > clstr_1_10.js.$$
  sed "s/mpiprocs=32/mpiprocs=24/g" clstr_1_10.js.$$ > clstr_1_10.js
  rm clstr_1_10.js.$$
fi

sed "s/u3o8/$wrkdir/g" /home/padamson/gacs-uranium/template/nw_head.txt > nw_head.txt.$$
sed "s/charge 0/charge $charge/g" nw_head.txt.$$ > nw_head.txt
rm nw_head.txt.$$
cp /home/padamson/gacs-uranium/template/nw_tail.txt .


sed "s/numberOfEachAtomType 3/numberOfEachAtomType $nu/g" /home/padamson/gacs-uranium/template/cluster.in > cluster.in.$$
sed "s/numberOfEachAtomType 8/numberOfEachAtomType $no/g" cluster.in.$$ > cluster.in
rm cluster.in.$$

generateCluster -i cluster.in

for i in {1..10}
do
  tail -n +3 cluster_$i.xyz > cluster_$i.$$
  cat nw_head.txt cluster_$i.$$ nw_tail.txt > cluster_$i.nw
  rm cluster_$i.xyz cluster_$i.$$
done

