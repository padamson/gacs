use Random;

var numberOfAtomTypes:int = 2;
var numberOfEachAtomType:[1..numberOfAtomTypes] int = [3,8];
var atomTypes:[1..numberOfAtomTypes] string = ["U","O"];
var clusterIndex:int = 1;
//var minBondLength: [1..numberOfAtomTypes,1..numberOfAtomTypes] real = {{0.3,0.3},{0.3,0.3}};

generateClusterCartesianCoordinates (
    numberOfAtomTypes,
    numberOfEachAtomType,
    atomTypes,
    clusterIndex);

proc generateClusterCartesianCoordinates (
    numberOfAtomTypes: int, 
    numberOfEachAtomType: [] int,
    atomTypes:[] string,
    clusterIndex: int) {

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
    atomTypes, cartesianCoordinates);

}

proc writeClusterXYZ(
    numberOfAtoms:int, 
    clusterIndex:int,
    numberOfAtomTypes:int,
    numberOfEachAtomType:[] int,
    atomTypes:[] string,
    cartesianCoordinates: [] real) {

  writeln(numberOfAtoms); 
  writeln(clusterIndex);
  var ij:int = 0;
  for i in 1..numberOfAtomTypes {
    for j in 1..numberOfEachAtomType[i] {
      ij += 1;
      writeln(atomTypes[i]," ",cartesianCoordinates[ij,1..3]);
    }
  }

}
