use Random;
use Help;

var numberOfAtomTypes:int = 2;
var numberOfEachAtomType:[1..2] int = [2,5];
var atomTypes:[1..2] string = ["U","O"];
var numberOfClusters:int = 5;
var numberOfOffspringPerClusterPair:int = 0;
//TODO: add option to specify min bond length per atom type pair
//var minBondLength: [1..numberOfAtomTypes,1..numberOfAtomTypes] real;
var minBond: real = 1.0;
var clusterFilename: string;
var inputFilename: string;
var generateRandom: bool = false;
var generateOffspring: bool = false;

proc main(args: [] string){

  getArgs(args);
  getInput();

  if (generateRandom) then {
    generateRandomClusterFiles();
  } else if (generateOffspring) then {
    generateOffspringClusterFiles();
    if (numberOfOffspringPerClusterPair == 0) then {
      writeln("Must set numberOfOffspringPerClusterPair > 0");
      exit(0);
    }
  } else {
    writeln("Must set generateRandom or generateOffspring in input");
    exit(0);
  }
}

proc generateOffspringClusterFiles(){
  var offspringIndex: int = 1;
  var clusterFilenameI: string;
  var clusterFileI:file;
  var clusterFilenameJ: string;
  var clusterFileJ:file;
  var offspringFilename: string;
  var offspringFile:file;
  //TODO: add checking for correct numbers of atoms and atom types when reading cluster files
  var numberOfAtomsI:int;
  var atomTypesI: [1..2] string;
  var atomCoordinatesI: [1..2,1..3] real;
  var atomTypesJ: [1..2] string;
  var atomCoordinatesJ: [1..2,1..3] real;
  var numberOfAtomsJ:int;
  var normI:[1..3] real;
  var dI:real;
  var normJ:[1..3] real;
  var dJ:real;
  var randomNumbers = new RandomStream();
  for i in 1..numberOfClusters {
    clusterFilenameI = "cluster_" + i + ".xyz";
    //TODO: create function to read geometry in from xyz file
    clusterFileI = open(clusterFilenameI,iomode.r);
    var readerI = clusterFileI.reader();
    numberOfAtomsI = readerI.read(int);
    atomTypesI.domain = {1..numberOfAtomsI};
    atomCoordinatesI.domain = {1..numberOfAtomsI,1..3};
    readerI.read(string);
    writeln("parent geometry from ",clusterFilenameI);
    for ii in 1..numberOfAtomsI {
      atomTypesI[ii] = readerI.read(string);
      atomCoordinatesI[ii,1] = readerI.read(real); 
      atomCoordinatesI[ii,2] = readerI.read(real); 
      atomCoordinatesI[ii,3] = readerI.read(real); 
      writeln(atomTypesI[ii]," ",atomCoordinatesI[ii,1..3]);
    }
    for j in i+1..numberOfClusters {
      clusterFilenameJ = "cluster_" + j + ".xyz";
      clusterFileJ = open(clusterFilenameJ,iomode.r);
      var readerJ = clusterFileJ.reader();
      numberOfAtomsJ = readerJ.read(int);
      if (numberOfAtomsI != numberOfAtomsJ) then {
        writeln("parent cluster files do not have the same numbers of atoms");
        exit(0);
      }
      atomTypesJ.domain = {1..numberOfAtomsJ};
      atomCoordinatesJ.domain = {1..numberOfAtomsJ,1..3};
      for k in 1..numberOfOffspringPerClusterPair {
        writeln("cluster ",i," and cluster ",j," for offspring ",offspringIndex);
        offspringFilename = "offspring_" + offspringIndex + ".xyz";
        offspringFile = open(offspringFilename,iomode.cw);
        var writer = offspringFile.writer();
        writer.writeln(numberOfAtomsI);

        (normI,dI) = generateRandomPlane(randomNumbers);
        (normJ,dJ) = generateRandomPlane(randomNumbers);



        offspringIndex += 1;
        writer.flush();
        writer.close();
        offspringFile.close();
      }
      readerJ.close();
    }
    readerI.close();
  }
}

proc generateRandomPlane(randomNumbers:RandomStream){
  var norm: [1..3] real;
  fillRandom(norm);
  norm = -1.0 + norm * 2.0;
  var d:real = randomNumbers.getNext();
  writeln("norm: ",norm);
  writeln("d: ",d);
  return (norm,d);
}

proc generateRandomClusterFiles(){
  for clusterIndex in 1..numberOfClusters {
    clusterFilename = "cluster_" + clusterIndex + ".xyz";
    writeln("Writing cluster to file: ",clusterFilename);
    var clusterFile = open(clusterFilename,iomode.cw);
    var writer = clusterFile.writer();

    randomClusterCartesianCoordinates(
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


proc getArgs(args:[] string){
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
      writeln("Processing input from: ",inputFilename);
      skipArg = true;
    } else if (skipArg) {
      skipArg = false;
    }
  }
  if inputFilename == "" {
    writeln("Incomplete commandline options");
    exit(0);
  }
  return;
}

proc getInput(){

  var inputFile = open(inputFilename,iomode.r);
  var reader = inputFile.reader();
  var inputLineA, inputLineB: string;
  var numberOfEachAtomTypeCounter,atomTypesCounter:int = 0;

  var numberOfInputLines: int = reader.read(int);

  for i in 1..numberOfInputLines {
    inputLineA = reader.read(string);
    inputLineB = reader.read(string);
    select inputLineA {
      when "minBond" do minBond=inputLineB:real;
      when "numberOfAtomTypes" do {
        numberOfAtomTypes=inputLineB:int;
        numberOfEachAtomType.domain = {1..numberOfAtomTypes};
        atomTypes.domain = {1..numberOfAtomTypes};
      }
      when "numberOfEachAtomType" do {
        numberOfEachAtomTypeCounter += 1;
        numberOfEachAtomType[numberOfEachAtomTypeCounter]=inputLineB:int;
      }
      when "atomTypes" do {
        atomTypesCounter += 1;
        atomTypes[atomTypesCounter] = inputLineB;
      }
      when "numberOfClusters" do numberOfClusters = inputLineB:int;
      when "generateRandom" do generateRandom = inputLineB:bool;
      when "generateOffspring" do generateOffspring = inputLineB:bool;
      when "numberOfOffspringPerClusterPair" do {
        numberOfOffspringPerClusterPair = inputLineB:int;
      }
      otherwise writeln("input keyword not recognized");
    }
  }
  if (atomTypesCounter != numberOfAtomTypes) {
    writeln("Too few atomTypes in input");
    exit(0);
  }
  if (numberOfEachAtomTypeCounter != numberOfAtomTypes) {
    writeln("Too few numberOfEachAtomType in input");
    exit(0);
  }

}

proc randomClusterCartesianCoordinates (
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
