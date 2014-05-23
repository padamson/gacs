use Random;
use Help;

var numberOfAtoms: int = 7;
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
  processInput();
  takeAction();

}

proc takeAction(){

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

proc processInput(){
  numberOfAtoms = 0;
  for i in 1..numberOfAtomTypes {
    numberOfAtoms += numberOfEachAtomType[i];
  }
}

proc generateOffspringClusterFiles(){
  var offspringIndex: int = 1;
  var clusterFilenameI: string;
  var clusterFilenameJ: string;
  var clusterFileJ:file;
  var offspringFilename: string;
  var offspringFile:file;
  //TODO: add checking for correct numbers of atoms and atom types when reading cluster files
  var atomTypesI: [1..numberOfAtoms] string;
  var atomCoordinatesI: [1..numberOfAtoms,1..3] real;
  var atomTypesJ: [1..numberOfAtoms] string;
  var atomCoordinatesJ: [1..numberOfAtoms,1..3] real;
  var normI:[1..3] real;
  var dI:real;
  var normJ:[1..3] real;
  var dJ:real;
  var signedPPDI:[1..numberOfAtoms] real;
  var posPPDI:[1..numberOfAtomTypes] int;
  var negPPDI:[1..numberOfAtomTypes] int;
  var signedPPDJ:[1..numberOfAtoms] real;
  var posPPDJ:[1..numberOfAtomTypes] int;
  var negPPDJ:[1..numberOfAtomTypes] int;
  var posnegIndex:int;
  var numberOfAtomsIndex:int;
  var randomNumbers = new RandomStream();
  var boolTemp:bool;

  for i in 1..numberOfClusters-1 {

    clusterFilenameI = "cluster_" + i + ".xyz";
    writeln("reading parent geometry from ",clusterFilenameI);
    (atomTypesI,atomCoordinatesI) = readClusterXYZ(clusterFilenameI);

    for j in i+1..numberOfClusters {

      clusterFilenameJ = "cluster_" + j + ".xyz";
      writeln("reading parent geometry from ",clusterFilenameJ);
      (atomTypesJ,atomCoordinatesJ) = readClusterXYZ(clusterFilenameJ);

      //TODO: need to adjust offspring per pair based on fitness of parents
      for k in 1..numberOfOffspringPerClusterPair {


        writeln("cluster ",i," and cluster ",j," for offspring ",offspringIndex);
        offspringFilename = "offspring_" + offspringIndex + ".xyz";
        offspringFile = open(offspringFilename,iomode.cw);
        var writer = offspringFile.writer();
        writer.writeln(numberOfAtoms);

        boolTemp = false;

        while (boolTemp == false ) {
          (normI,dI) = generateRandomPlane(randomNumbers);
          (normJ,dJ) = generateRandomPlane(randomNumbers);

          for ii in 1..numberOfAtoms {
            signedPPDI[ii] = signedPointPlaneDistance(normI,dI,atomCoordinatesI[ii,1..3]);
            //writeln("signedPPDI[",ii,"]: ",signedPPDI[ii]);
            signedPPDJ[ii] = signedPointPlaneDistance(normJ,dJ,atomCoordinatesJ[ii,1..3]);
            //writeln("signedPPDI[",ii,"]: ",signedPPDJ[ii]);
          }

          posnegIndex = 1; 
          numberOfAtomsIndex = 1;
          posPPDI = 0;
          negPPDI = 0;
          posPPDJ = 0;
          negPPDJ = 0;
          for ij in 1..numberOfAtomTypes {
            for ik in 1..numberOfEachAtomType[ij] {

              if signedPPDI[numberOfAtomsIndex] > 0 then {
                posPPDI[posnegIndex] += 1;
              } else {
                negPPDI[posnegIndex] += 1;
              }

              if signedPPDJ[numberOfAtomsIndex] > 0 then {
                posPPDJ[posnegIndex] += 1;
              } else {
                negPPDJ[posnegIndex] += 1;
              }

              numberOfAtomsIndex += 1;
            }
            posnegIndex += 1;
          }

          /*
          writeln("posPPDI:",posPPDI);
          writeln("negPPDI:",negPPDI);
          writeln("posPPDJ:",posPPDJ);
          writeln("negPPDJ:",negPPDJ);
          */

          //writeln("pos + pos: ",posPPDI + posPPDJ);
          //writeln("numberOfEachAtomType: ",numberOfEachAtomType);
          //TODO: check to make sure there is at least one atom in each half

          if ((+ reduce posPPDI) > 0 && 
              (+ reduce posPPDJ) > 0 && 
              (+ reduce negPPDJ) > 0    ) then {

            var pospos:[1..numberOfAtomTypes] int = posPPDI + posPPDJ;
            var posneg:[1..numberOfAtomTypes] int = posPPDI + negPPDJ;

            boolTemp = true;
            for ii in 1..numberOfAtomTypes {
              boolTemp = (boolTemp && (pospos[ii] == numberOfEachAtomType[ii]) );
            }
            if boolTemp then {
              writeln("pospos is true");
              writeln("posPPDI:",posPPDI);
              writeln("posPPDJ:",posPPDJ);
            } else {
              boolTemp = true;
              for ii in 1..numberOfAtomTypes {
                boolTemp = (boolTemp && (posneg[ii] == numberOfEachAtomType[ii]) );
              }
              if boolTemp then {
                writeln("posneg is true");
                writeln("posPPDI:",posPPDI);
                writeln("negPPDJ:",negPPDJ);
              }
            }
          }

        } //while

        offspringIndex += 1;
        writer.flush();
        writer.close();
        offspringFile.close();

      }
    }
  }
}

proc generateRandomPlane(randomNumbers:RandomStream){
  var norm: [1..3] real;
  fillRandom(norm);
  norm = -1.0 + norm * 2.0;
  var d:real = randomNumbers.getNext();
  //writeln("norm: ",norm);
  //writeln("d: ",d);
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
proc readClusterXYZ(clusterFilename:string){
  var clusterFile = open(clusterFilename,iomode.r);
  var reader = clusterFile.reader();
  var numberOfAtomsTemp = reader.read(int);
  if (numberOfAtomsTemp != numberOfAtoms) then {
    writeln("wrong number of atoms in parent file ",clusterFilename);
    exit(0);
  }
  var atomTypesTemp: [1..numberOfAtoms] string;
  var atomCoordinatesTemp: [1..numberOfAtoms,1..3] real;
  reader.read(string);
  for i in 1..numberOfAtoms {
    atomTypesTemp[i] = reader.read(string);
    atomCoordinatesTemp[i,1] = reader.read(real); 
    atomCoordinatesTemp[i,2] = reader.read(real); 
    atomCoordinatesTemp[i,3] = reader.read(real); 
    //writeln(atomTypesTemp[i]," ",atomCoordinatesTemp[i,1..3]);
  }
  //TODO: must always sort atomTypes and atomCoordinates in a consistent way before writing
  //to support the following error checking
  //TODO: fix following error checking; will require some work earlier on
  /*
     if (atomTypesTemp != atomTypes) then {
     writeln("wrong atom types in parent file ",clusterFilename);
     exit(0);
     }
   */
  reader.close();
  clusterFile.close();
  return (atomTypesTemp, atomCoordinatesTemp);
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

proc signedPointPlaneDistance(n:[1..3] real, d:real, x:[1..3] real):real{
  return (n[1]*x[1]+n[2]*x[2]+n[3]*x[3]+d)/(sqrt(n[1]**2+n[2]**2+n[3]**2));
}

proc distance(x1: [1..3] real, x2: [1..3] real): real{
  return sqrt(
      (x1[1]-x2[1])*(x1[1]-x2[1])
      +(x1[2]-x2[2])*(x1[2]-x2[2])
      +(x1[3]-x2[3])*(x1[3]-x2[3]));
}
