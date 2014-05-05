#!/bin/bash
datadir=~/Research/data

generateCluster > $datadir/cluster_1.xyz

babel -ixyz $datadir/cluster_1.xyz -ogamin $datadir/cluster_1.inp
