use Random;
use Help;

var numberOfAtomTypes:int = 2;
var numberOfEachAtomType:[1..2] int = [2,5];
var atomTypes:[1..2] string = ["U","O"];
var numberOfClusters:int = 5;
//var minBondLength: [1..numberOfAtomTypes,1..numberOfAtomTypes] real;
var minBond: real = 1.0;
var inputFilename: string;
var clusterFilename: string;

proc main(args: [] string){
  var skipArg:bool = false;
  for i in args.domain {
    if args[i]=="--help" {
      printUsage();
      writeln("\nEXTRA ARGUMENTS:");
      writeln(  "================");
      writeln("-i <inputFilename>");
      exit(0);
    } else if (!skipArg && args[i]=="-i") {
      inputFilename = args[i+1];
      writeln("inputFilename: ",inputFilename);
      skipArg = true;
    } else if (skipArg) {
      skipArg = false;
    }
  }

  var inputFile = open("cluster.in",iomode.r);
  var reader = inputFile.reader();
  var inputLineA, inputLineB: string;
  var numberOfEachAtomTypeCounter,atomTypesCounter:int = 1;

  var numberOfInputLines: int = reader.read(int);

  for i in 1..numberOfInputLines {
    inputLineA = reader.read(string);
    inputLineB = reader.read(string);
    select inputLineA {
      when "minBond" do minBond=inputLineB:real;
      when "numberOfAtomTypes" do numberOfAtomTypes=inputLineB:int;
      when "numberOfEachAtomType" do {
        numberOfEachAtomType[numberOfEachAtomTypeCounter]=inputLineB:int;
        numberOfEachAtomTypeCounter += 1;
      }
      when "atomTypes" do {
        atomTypes[atomTypesCounter] = inputLineB;
        atomTypesCounter += 1;
      }
      when "numberOfClusters" do numberOfClusters = inputLineB:int;
      otherwise writeln("input keyword not recognized");
    }
  }

  for clusterIndex in 1..numberOfClusters {
    clusterFilename = "cluster_" + clusterIndex + ".xyz";
    writeln("Writing cluster to file: ",clusterFilename);
    var clusterFile = open(clusterFilename,iomode.cw);
    var writer = clusterFile.writer();

    generateClusterCartesianCoordinates(
        numberOfAtomTypes,
        numberOfEachAtomType,
        atomTypes,
        minBond,
        clusterIndex,
        writer);

    writer.flush();
    writer.close();
    clusterFile.close();
  }

}

proc generateClusterCartesianCoordinates (
    numberOfAtomTypes: int, 
    numberOfEachAtomType: [] int,
    atomTypes:[] string,
    minBond: real,
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

  //writeln("atomTypeArray=",atomTypeArray);

  //regenerate atoms that are too close to another one
  var i: int = 1;
  label distanceCheckLoop while (i < numberOfAtoms) do {
    for j in i+1..numberOfAtoms {
      if (distance(cartesianCoordinates[i,1..3],cartesianCoordinates[j,1..3]) < minBond) {
        writeln("atom ",i," and atom ",j," are too close");
        writeln("atom ",i," coords: ",cartesianCoordinates[i,1..3]);
        writeln("atom ",j," coords: ",cartesianCoordinates[j,1..3]);
        writeln("distance: ",distance(cartesianCoordinates[i,1..3],cartesianCoordinates[j,1..3]));
        fillRandom(cartesianCoordinates[j,1..3]);
        cartesianCoordinates[j,1..3] = clusterVolume * (2.0*cartesianCoordinates[j,1..3] - 1.0);
        writeln("atom ",j," new coords: ",cartesianCoordinates[j,1..3]);
        //TODO: start over with comparison; probably add a
        //counter to just abandon the molecule after a few restarts
        writeln("starting over with distance check loop");
        i = 1;
        continue distanceCheckLoop;
      }
    }
    i += 1;
  } // label distanceCheckLoop
  //TODO: figure out a way to deallocate variable 'i'
  //delete i;

  writeClusterXYZ( numberOfAtoms, clusterIndex, numberOfAtomTypes, numberOfEachAtomType,
      atomTypes, cartesianCoordinates, writer);

}

proc writeClusterXYZ(
    numberOfAtoms:int, 
    clusterIndex:int,
    numberOfAtomTypes:int,
    numberOfEachAtomType:[] int,
    atomTypes:[] string,
    cartesianCoordinates: [] real,
    writer: channel) {

  //writeln(numberOfAtoms); 
  writer.writeln(numberOfAtoms);
  //writeln(clusterIndex);
  writer.writeln(clusterIndex);
  var ij:int = 0;
  for i in 1..numberOfAtomTypes {
    for j in 1..numberOfEachAtomType[i] {
      ij += 1;
      writer.writeln(atomTypes[i]," ",cartesianCoordinates[ij,1..3]);
    }
  }

}

proc distance(x1: [1..3] real, x2: [1..3] real): real{
  return sqrt(
      (x1[1]-x2[1])*(x1[1]-x2[1])
      +(x1[2]-x2[2])*(x1[2]-x2[2])
      +(x1[3]-x2[3])*(x1[3]-x2[3]));
}
