use Random;

var numberOfAtomTypes:int = 2;
var numberOfEachAtomType:[1..numberOfAtomTypes] int = [3,8];
var atomTypes:[1..numberOfAtomTypes] string = ["U","O"];
var clusterIndex:int = 1;
//var minBondLength: [1..numberOfAtomTypes,1..numberOfAtomTypes] real = {{0.3,0.3},{0.3,0.3}};

var clusterFilename: string = "cluster_" + clusterIndex + ".xyz";
writeln("clusterFilename: ",clusterFilename);
var clusterFile = open(clusterFilename,iomode.cw);
var writer = clusterFile.writer();

generateClusterCartesianCoordinates (
    numberOfAtomTypes,
    numberOfEachAtomType,
    atomTypes,
    clusterIndex,
    writer);

proc generateClusterCartesianCoordinates (
    numberOfAtomTypes: int, 
    numberOfEachAtomType: [] int,
    atomTypes:[] string,
    clusterIndex: int,
    writer: channel) {

  var numberOfAtoms: int = 0;
  for i in 1..numberOfAtomTypes {
    numberOfAtoms += numberOfEachAtomType[i];
  }

  var clusterVolume: real = cbrt(numberOfAtoms);

  var cartesianCoordinates: [1..numberOfAtoms,1..3] real; 
  fillRandom(cartesianCoordinates);
  cartesianCoordinates = clusterVolume * (2.0*cartesianCoordinates - 1.0);

  var atomTypeArray:[1..numberOfAtoms] int;
  var atomTypeIndex:int = 1;
  var indexForAtomTypeArrayFill: int = 1;
  for i in 1..numberOfAtomTypes {
    for j in 1..numberOfEachAtomType[i] {
      atomTypeArray[indexForAtomTypeArrayFill] = atomTypeIndex;
      indexForAtomTypeArrayFill += 1;
    }
    atomTypeIndex += 1;
  }

  writeln("atomTypeArray=",atomTypeArray);

  writeClusterXYZ( numberOfAtoms, clusterIndex, numberOfAtomTypes, numberOfEachAtomType,
    atomTypes, cartesianCoordinates, writer);

  for i in 1..numberOfAtoms-1 {
    for j in i+1..numberOfAtoms {
      writeln("checking atom ",i," and atom ",j," for closeness");
      writeln(cartesianCoordinates[i,1..3]);
      writeln(cartesianCoordinates[j,1..3]);
      writeln(distance(cartesianCoordinates[i,1..3],cartesianCoordinates[j,1..3]));
      if (distance(cartesianCoordinates[i,1..3],cartesianCoordinates[j,1..3]) < 0.5) {
        writeln("atom ",i," and atom ",j," are too close");
      }
    }
  }
}

proc writeClusterXYZ(
    numberOfAtoms:int, 
    clusterIndex:int,
    numberOfAtomTypes:int,
    numberOfEachAtomType:[] int,
    atomTypes:[] string,
    cartesianCoordinates: [] real,
    writer: channel) {

  writeln(numberOfAtoms); 
  writer.write(numberOfAtoms);
  writeln(clusterIndex);
  writer.writeln(clusterIndex);
  var ij:int = 0;
  for i in 1..numberOfAtomTypes {
    for j in 1..numberOfEachAtomType[i] {
      ij += 1;
      writeln(atomTypes[i]," ",cartesianCoordinates[ij,1..3]);
    }
  }

}

proc distance(x1: [1..3] real, x2: [1..3] real): real{
  return sqrt(
     (x1[1]-x2[1])*(x1[1]-x2[1])
    +(x1[2]-x2[2])*(x1[2]-x2[2])
    +(x1[3]-x2[3])*(x1[3]-x2[3]));
}
