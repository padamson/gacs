#!/bin/csh
#gen_pbs version: 1.0.3
#PBS -A           account
#PBS -N           J_u3o8_1_10
#PBS -joe
#PBS -e           u3o8_1_10.oe
#PBS -o           u3o8_1_10.oe
#PBS -M           padamson
#PBS -mbe
#PBS -l           walltime=12:00:00
#PBS -l           select=1:ncpus=32:mpiprocs=32
#PBS -q           standard
  

set EXEC = ./clstr_1_10.csh
set SCR = $WORK_DIR

cd $SCR

cp /home/padamson/Research/u3o8/clstr_1_10.csh $SCR/.

echo "Job $PBS_JOBID "clstr_1_10" started on `date` running on `hostname`">clstr_1_10.log

$EXEC

echo "Job ended on `date`">>clstr_1_10.log

cp cluster_*.out /home/padamson/Research/u3o8/.
cp clstr_1_10.log /home/padamson/Research/u3o8/.

