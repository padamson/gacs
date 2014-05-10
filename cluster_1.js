#!/bin/csh
#gen_pbs version: 1.0.3
#PBS -A           WPTAFITO11533311
#PBS -N           J_cluster_1
#PBS -joe
#PBS -e           cluster_1.oe
#PBS -o           cluster_1.oe
#PBS -M           padamson
#PBS -mbe
#PBS -l           walltime=12:00:00
#PBS -l           select=1:ncpus=16:mpiprocs=16
#PBS -q           standard
  

set EXEC=/apps/nwchem/scripts/nwchem_run6.3
set SCR = $WORK_DIR
cp /work1/home/padamson/gacs-uranium/cluster_1.nw $SCR/.

cd $SCR

echo "Job $PBS_JOBID "cluster_1" started on `date` running on `hostname`">cluster_1.log

$EXEC cluster_1.nw cluster_1.out 16

echo "Job ended on `date`">>cluster_1.log

cp cluster_1.out /work1/home/padamson/gacs-uranium/.
cp *.db /work1/home/padamson/gacs-uranium/.
cp cluster_1.log /work1/home/padamson/gacs-uranium/.

