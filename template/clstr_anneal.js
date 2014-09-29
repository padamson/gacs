#!/bin/csh
#gen_pbs version: 1.0.3
#PBS -A           account
#PBS -N           J_u3o8_anneal
#PBS -joe
#PBS -e           u3o8_anneal.oe
#PBS -o           u3o8_anneal.oe
#PBS -M           padamson
#PBS -mbe
#PBS -l           walltime=12:00:00
#PBS -l           select=1:ncpus=16:mpiprocs=16
#PBS -q           standard
  

set EXEC = ./clstr_anneal.csh
set SCR = $WORK_DIR

cd $SCR

cp /home/padamson/anneal/u3o8/clstr_anneal.csh $SCR/.

echo "Job $PBS_JOBID "clstr_anneal" started on `date` running on `hostname`">clstr_anneal.log

$EXEC

echo "Job ended on `date`">>clstr_anneal.log

cp cluster_*.out /home/padamson/anneal/u3o8/.
cp clstr_anneal.log /home/padamson/anneal/u3o8/.

