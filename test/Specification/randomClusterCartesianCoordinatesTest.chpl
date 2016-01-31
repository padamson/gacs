use randomClusterCartesianCoordinates;
use Random;
  
//set seed
var atoms:string = ["U", "U", "O", "O"];
var numberOfClusters:int = 4; 
var minBondArray: real; 
var maxDiff: real = 0.0001;

for clusterIndex in 1..numberOfClusters {
  clusterFilename = "cluster_" + clusterIndex + ".xyz";
  writeln("Writing cluster to file: ",clusterFilename);
  var clusterFile = open(clusterFilename,iomode.cw);
  var writer = clusterFile.writer();

  randomClusterCartesianCoordinates(
    atoms,
    minBondArray,
    clusterIndex,
    writer);

    //read each file back in

    //compare file contents to expected
  //writeln((abs(fileContents - expected) <= maxErr));

  writer.flush(); 
  writer.close();
}
