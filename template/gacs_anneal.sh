#!/bin/bash
if (( $# != 7 )); then
  echo "Illegal number of parameters (expecting 6)"
  echo "==================================================="
  echo "nu) number of Uranium atoms (integer)"
  echo "no) number of Oxygen atoms (integer)"
  echo "charge) charge of molecule (e.g. +0, -1, +1)"
  echo "mult) multiplicity of molecule (1 or 2)"
  echo "nnodes) number of nodes (integer)"
  echo "wall) walltime requested in hours (e.g. 12, 24, 36)"
  echo "numberOfClusters) number of clusters"
  exit 1
fi
nu=$1
no=$2
charge=$3
mult=$4
nnodes=$5
wall=$6
numberOfClusters=$7
wrkdir=u${1}o${2}${charge}
mkdir $HOME/anneal/$wrkdir
cd $HOME/anneal/$wrkdir

mach=`uname -n | awk '{print substr ($0, 0, 2)}'`

if [[ "$mach" == 'sp' ]]; then
  ncpu=$(expr $nnodes * 16)
  mem=$(expr $nnodes * 30)
  sed "s/EXEC=/EXEC=apps\/nwchem\/scripts\/nwchem_run6\.3\/g" $HOME/gacs-uranium/template/clstr_anneal.csh > clstr_anneal.csh
  sed "s/u3o8/$wrkdir/g" clstr_anneal.csh > clstr_anneal.csh.$$
  sed "s/out 16/out $ncpu/g" clstr_anneal.csh.$$ > clstr_anneal.csh
  rm clstr_anneal.csh.$$
  chmod u+x clstr_anneal.csh
  account=WPTAFITO11533311
  sed "s/u3o8/$wrkdir/g" $HOME/gacs-uranium/template/clstr_anneal.js > clstr_anneal.js.$$
  sed "s/account/$account/g" clstr_anneal.js.$$ > clstr_anneal.js
  sed "s/select=1/select=$nnodes/g" clstr_anneal.js > clstr_anneal.js.$$
  sed "s/walltime=12/walltime=$wall/g" clstr_anneal.js.$$ > clstr_anneal.js
  rm clstr_anneal.js.$$
elif [[ "$mach" == 'li' ]]; then
  ncpu=$(expr $nnodes * 24)
  mem=$(expr $nnodes * 63)
  sed "s/EXEC=/EXEC=app\/nwchem\/scripts\/nwchem_run6\.3\/g" $HOME/gacs-uranium/template/clstr_anneal.csh > clstr_anneal.csh
  sed "s/u3o8/$wrkdir/g" clstr_anneal.csh > clstr_anneal.csh.$$
  sed "s/out 16/out $ncpu/g" clstr_anneal.csh.$$ > clstr_anneal.csh
  rm clstr_anneal.csh.$$
  chmod u+x clstr_anneal.csh
  account=WPMWPASC96150LTN
  sed "s/u3o8/$wrkdir/g" $HOME/gacs-uranium/template/clstr_anneal.js > clstr_anneal.js.$$
  sed "s/account/$account/g" clstr_anneal.js.$$ > clstr_anneal.js
  sed "s/ncpus=16/ncpus=24/g" clstr_anneal.js > clstr_anneal.js.$$
  sed "s/mpiprocs=16/mpiprocs=24/g" clstr_anneal.js.$$ > clstr_anneal.js
  sed "s/select=1/select=$nnodes/g" clstr_anneal.js > clstr_anneal.js.$$
  sed "s/walltime=12/walltime=$wall/g" clstr_anneal.js.$$ > clstr_anneal.js
  rm clstr_anneal.js.$$
elif [[ "$mach" == 'ga' ]]; then
  nproc=$(expr $nnodes * 16)
  mem=$(expr $nnodes * 60)
  account=AFITO11533311
  sed "s/u3o8/$wrkdir/g" $HOME/gacs-uranium/template/clstr_anneal.js.garnet > clstr_anneal.js.$$
  sed "s/account/$account/g" clstr_anneal.js.$$ > clstr_anneal.js
  sed "s/select=1/select=$nnodes/g" clstr_anneal.js > clstr_anneal.js.$$
  sed "s/walltime=12/walltime=$wall/g" clstr_anneal.js.$$ > clstr_anneal.js
  sed "s/aprun -n 16/aprun -n $nproc/g" clstr_anneal.js > clstr_anneal.js.$$
  mv clstr_anneal.js.$$ clstr_anneal.js
fi

sed "s/u3o8/$wrkdir/g" $HOME/gacs-uranium/template/nw_head.txt > nw_head.txt.$$
sed "s/charge 0/charge $charge/g" nw_head.txt.$$ > nw_head.txt
sed "s/memory 30/memory $mem/g" nw_head.txt > nw_head.txt.$$
mv nw_head.txt.$$ nw_head.txt

if [[ "$mult" == '2' ]]; then
  sed "s/mult 1/mult 2/g" $HOME/gacs-uranium/template/nw_tail_anneal.txt > nw_tail_anneal.txt.$$
  sed "s/#odft/odft/g" nw_tail_anneal.txt.$$ > nw_tail_anneal.txt
elif [[ "$mult" == '1' ]]; then
  cp $HOME/gacs-uranium/template/nw_tail_anneal.txt .
fi
sed "s/u3o8/$wrkdir/g" nw_tail_anneal.txt > nw_tail_anneal.txt.$$
mv nw_tail_anneal.txt.$$ nw_tail_anneal.txt

sed "s/numberOfEachAtomType 3/numberOfEachAtomType $nu/g" $HOME/gacs-uranium/template/cluster.in > cluster.in.$$
sed "s/numberOfEachAtomType 8/numberOfEachAtomType $no/g" cluster.in.$$ > cluster.in
sed "s/numberOfClusters 10/numberOfClusters $numberOfClusters/g" cluster.in > cluster.in.$$
mv cluster.in.$$ cluster.in

generateCluster -i cluster.in

for i in $(eval echo "{1..$numberOfClusters}")
do
  tail -n +3 cluster_$i.xyz > cluster_$i.$$
  cat nw_head.txt cluster_$i.$$ nw_tail_anneal.txt > cluster_$i.nw
  rm cluster_$i.xyz cluster_$i.$$
done
rm nw_head.txt nw_tail_anneal.txt

#qsub clstr_anneal.js
