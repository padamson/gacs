#!/bin/csh
#gen_pbs version: 1.0.3
#PBS -A account
#PBS -q standard
#PBS -l walltime=12:00:00
#PBS -l select=1:ncpus=16:mpiprocs=16
#PBS -N J_u3o8_anneal
#PBS -joe
#PBS -e u3o8_anneal.oe
#PBS -o u3o8_anneal.oe
#PBS -M padamson
#PBS -mbe

set EXEC = ./clstr_anneal.csh

# create a job-specific subdirectory based on JOBID and cd to it
JOBID=`echo ${PBS_JOBID} | cut -d '.' -f 1`
set SCR = ${WORKDIR}/${JOBID}
cd $SCR

cp $HOME/anneal/u3o8/clstr_anneal.csh $SCR/.

echo "Job $PBS_JOBID "clstr_anneal" started on `date` running on `hostname`">clstr_anneal.log

$EXEC

echo "Job ended on `date`">>clstr_anneal.log

cp cluster_*.out $HOME/anneal/u3o8/.
cp clstr_anneal.log $HOME/anneal/u3o8/.

