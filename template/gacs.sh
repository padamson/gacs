#!/bin/bash
if (( $# != 6 )); then
  echo "Illegal number of parameters (expecting 6)"
  echo "==================================================="
  echo "nu) number of Uranium atoms (integer)"
  echo "no) number of Oxygen atoms (integer)"
  echo "charge) charge of molecule (e.g. +0, -1, +1)"
  echo "mult) multiplicity of molecule (1 or 2)"
  echo "nnodes) number of nodes (integer)"
  echo "wall) walltime requested in hours (e.g. 12, 24, 36)"
  exit 1
fi
nu=$1
no=$2
charge=$3
mult=$4
nnodes=$5
wall=$6
wrkdir=u${1}o${2}${charge}
mkdir /home/padamson/Research/$wrkdir
cd /home/padamson/Research/$wrkdir

mach=`uname -n | awk '{print substr ($0, 0, 2)}'`

if [[ "$mach" == 'sp' ]]; then
  ncpu=$(expr $nnodes * 16)
  sed "s/u3o8/$wrkdir/g" /home/padamson/gacs-uranium/template/clstr_1_10.csh > clstr_1_10.csh.$$
  sed "s/out 16/out $ncpu/g" clstr_1_10.csh.$$ > clstr_1_10.csh
  rm clstr_1_10.csh.$$
  account=WPTAFITO11533311
  sed "s/u3o8/$wrkdir/g" /home/padamson/gacs-uranium/template/clstr_1_10.js > clstr_1_10.js.$$
  sed "s/account/$account/g" clstr_1_10.js.$$ > clstr_1_10.js
  sed "s/select=1/select=$nnodes/g" clstr_1_10.js > clstr_1_10.js.$$
  sed "s/walltime=12/walltime=$wall/g" clstr_1_10.js.$$ > clstr_1_10.js
  rm clstr_1_10.js.$$
elif [[ "$mach" == 'li' ]]; then
  ncpu=$(expr $nnodes * 24)
  sed "s/apps/app/g" /home/padamson/gacs-uranium/template/clstr_1_10.csh > clstr_1_10.csh
  sed "s/u3o8/$wrkdir/g" clstr_1_10.csh > clstr_1_10.csh.$$
  sed "s/out 16/out $ncpu/g" clstr_1_10.csh.$$ > clstr_1_10.csh
  rm clstr_1_10.csh.$$
  account=WPMWPASC96150LTN
  sed "s/u3o8/$wrkdir/g" /home/padamson/gacs-uranium/template/clstr_1_10.js > clstr_1_10.js.$$
  sed "s/account/$account/g" clstr_1_10.js.$$ > clstr_1_10.js
  sed "s/ncpus=16/ncpus=24/g" clstr_1_10.js > clstr_1_10.js.$$
  sed "s/mpiprocs=16/mpiprocs=24/g" clstr_1_10.js.$$ > clstr_1_10.js
  sed "s/select=1/select=$nnodes/g" clstr_1_10.js > clstr_1_10.js.$$
  sed "s/walltime=12/walltime=$wall/g" clstr_1_10.js.$$ > clstr_1_10.js
  rm clstr_1_10.js.$$
fi
chmod u+x clstr_1_10.csh

sed "s/u3o8/$wrkdir/g" /home/padamson/gacs-uranium/template/nw_head.txt > nw_head.txt.$$
sed "s/charge 0/charge $charge/g" nw_head.txt.$$ > nw_head.txt
rm nw_head.txt.$$

if [[ "$mult" == '2' ]]; then
  sed "s/mult 1/mult 2/g" /home/padamson/gacs-uranium/template/nw_tail.txt > nw_tail.txt.$$
  sed "s/#odft/odft/g" nw_tail.txt.$$ > nw_tail.txt
  rm nw_tail.txt.$$
elif [[ "$mult" == '1' ]]; then
  cp /home/padamson/gacs-uranium/template/nw_tail.txt .
fi

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

#qsub clstr_1_10.js
