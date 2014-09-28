use Random;
use Help;

var numberOfAtoms:int;
var numberOfAtomTypes:int;
var D1:domain(1) = {1..numberOfAtomTypes};
var D2:domain(2) = {1..numberOfAtomTypes,1..numberOfAtomTypes};
var numberOfEachAtomType:[D1] int;
var atomTypes:[D1] string;
var numberOfClusters:int;
var numberOfOffspringPerClusterPair:int;
//TODO: add option to specify min bond length per atom type pair
//var minBondLength: [1..numberOfAtomTypes,1..numberOfAtomTypes] real;
var minBondArray:[D2] real; 
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
    generateRandomClusters();
  } else if (generateOffspring) then {
    //generateOffspringClusterFiles();
    generateOffspringClusters();
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

proc randomInteger_1_4():int{
  var randomNumbers = new RandomStream();
  var x:real  = randomNumbers.getNext();
  if x < 0.25 then 
    return 1;
  else if x < 0.5 then
    return 2;
  else if x < 0.75 then
    return 3;
  else if x <= 1.0 then
    return 4;
  else {
    writeln("error in randomInteger_1_4");
    exit(0);
    return 0;
  }
}

proc randomInteger_1_2():int{
  var randomNumbers = new RandomStream();
  var x:real  = randomNumbers.getNext();
  if x < 0.5 then
    return 1;
  else if x <= 1.0 then
    return 2;
  else {
    writeln("error in randomInteger_1_2");
    exit(0);
    return 0;
  }
}

proc generateOffspringClusters(){
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
  var atomCoordinatesJ, atomCoordinatesJRotated, atomCoordinatesJMirror: [1..numberOfAtoms,1..3] real;
  var normI:[1..3] real;
  var dI:real;
  var normJ:[1..3] real;
  var dJ:real;
  var Rx,Ry,Rz:[1..3,1..3] real;
  var signedPPDI,signedPPDIMirror:[1..numberOfAtoms] real;
  var posPPDI:[1..numberOfAtomTypes] int;
  var negPPDI:[1..numberOfAtomTypes] int;
  var signedPPDJ,signedPPDJMirror:[1..numberOfAtoms] real;
  var posPPDJ:[1..numberOfAtomTypes] int;
  var negPPDJ:[1..numberOfAtomTypes] int;
  var posnegIndex:int;
  var numberOfAtomsIndex:int;
  var posposCoord, posnegCoord, negposCoord, negnegCoord, 
      offspringCoord: [1..numberOfAtoms,1..3] real; 
  var posposAtomType, posnegAtomType, negposAtomType, negnegAtomType, 
      offspringAtomType: [1..numberOfAtoms] string; 
  var randomNumbers = new RandomStream();
  var generatedOffspring:bool;
  var validOffspring:[1..4] string;
  var validOffspringCounter:int;

  for i in 1..numberOfClusters-1 {

    clusterFilenameI = "cluster_" + i + ".xyz";
    writeln("reading parent geometry from ",clusterFilenameI);
    (atomTypesI,atomCoordinatesI) = readClusterXYZ(clusterFilenameI);
    //writeln("atomTypesI",atomTypesI);

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

        generatedOffspring = false;
        validOffspringCounter = 0;

        while (validOffspringCounter == 0 ) {

          (Rx,Ry,Rz) = generateRandomRotationMatrices(randomNumbers);
          atomCoordinatesJRotated = rotateCoordinates(Rx,Ry,Rz,atomCoordinatesJ);
          
          /*
          writeln("rot mat's: ");
          writeln(Rx);
          writeln(Ry);
          writeln(Rz);

          writeln("atomCoordinatesJRotated: ");
          writeln(atomCoordinatesJRotated);
          */
          
          (normI,dI) = generateRandomPlane(randomNumbers);
          (normJ,dJ) = (normI,dI);

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

          if ((+ reduce posPPDI) > 0 && 
              (+ reduce negPPDI) > 0 && 
              (+ reduce posPPDJ) > 0 && 
              (+ reduce negPPDJ) > 0    ) then {

            //var pospos:[1..numberOfAtomTypes] int = posPPDI + posPPDJ; //option 1
            var posneg:[1..numberOfAtomTypes] int = posPPDI + negPPDJ; //option 2
            var negpos:[1..numberOfAtomTypes] int = negPPDI + posPPDJ; //option 3
            //var negneg:[1..numberOfAtomTypes] int = negPPDI + negPPDJ; //option 4

            /*
            if checkOffspringCandidate(pospos) then {
              validOffspringCounter += 1;
              validOffspring[validOffspringCounter] = "pospos";
              writeln("pospos is true");
              writeln("posPPDI:",posPPDI);
              writeln("posPPDJ:",posPPDJ);
            }
            */
            
            if checkOffspringCandidate(posneg) then {
              validOffspringCounter += 1;
              validOffspring[validOffspringCounter] = "posneg";
              writeln("posneg is true");
              writeln("posPPDI:",posPPDI);
              writeln("negPPDJ:",negPPDJ);
            }

            if checkOffspringCandidate(negpos) then {
              validOffspringCounter += 1;
              validOffspring[validOffspringCounter] = "negpos";
              writeln("negpos is true");
              writeln("negPPDI:",negPPDI);
              writeln("posPPDJ:",posPPDJ);
            }
            
            /*
            if checkOffspringCandidate(negneg) then {
              validOffspringCounter += 1;
              validOffspring[validOffspringCounter] = "negneg";
              writeln("negneg is true");
              writeln("negPPDI:",negPPDI);
              writeln("negPPDJ:",negPPDJ);
            }
            */

            if validOffspringCounter > 0 then {
              writeln("validOffspring: ",validOffspring);
              var offspringSelection:int;

              if validOffspringCounter == 2 then {
                offspringSelection = randomInteger_1_2();
                /*
              } else if validOffspringCounter == 4 then {
                offspringSelection = randomInteger_1_4();
                */
              } else {
                writeln("error when selecting offspring");
                exit(0);
              }

              writeln("offspringSelection: ",offspringSelection);
              //invert atomCoordinatesJ before splicing
              //atomCoordinatesJMirror = -1.0*atomCoordinatesJ;
              select validOffspring[offspringSelection] {
                /*
                when "pospos" {
                  (offspringAtomType,offspringCoord) = 
                    fillOffspring(
                        signedPPDI, atomTypesI, atomCoordinatesI,
                        signedPPDJ, atomTypesJ, atomCoordinatesJMirror);
                }
                */
                when "posneg" {
                  signedPPDJMirror = -1*signedPPDJ;
                  (offspringAtomType,offspringCoord) = 
                    fillOffspring(
                        signedPPDI, atomTypesI, atomCoordinatesI,
                        signedPPDJMirror, atomTypesJ, atomCoordinatesJ);
                }
                when "negpos" {
                  signedPPDIMirror = -1*signedPPDI;
                  (offspringAtomType,offspringCoord) = 
                    fillOffspring(
                        signedPPDIMirror, atomTypesI, atomCoordinatesI,
                        signedPPDJ, atomTypesJ, atomCoordinatesJ);
                }
                /*
                when "negneg" {
                  signedPPDIMirror = -1*signedPPDI;
                  signedPPDJMirror = -1*signedPPDJ;
                  (offspringAtomType,offspringCoord) = 
                    fillOffspring(
                        signedPPDIMirror, atomTypesI, atomCoordinatesI,
                        signedPPDJMirror, atomTypesJ, atomCoordinatesJMirror);
                }
                */
              }

              //TODO: mutate offspring
              writeOffspringXYZ(
                  offspringIndex,
                  offspringAtomType,
                  offspringCoord,
                  writer);

              writeln("offspringAtomType: ",offspringAtomType);
              writeln("offspringCoord: ",offspringCoord);
                
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

proc fillOffspring(
    signedPPDI:[] real, atomTypesI:[] string, atomCoordinatesI: [] real, 
    signedPPDJ:[] real, atomTypesJ:[] string, atomCoordinatesJ: [] real) {
  var offspringAtomType:[1..numberOfAtoms] string;
  var offspringCoord:[1..numberOfAtoms,1..3] real;
  var ii:int = 0;
  var distanceCheckCounter: int;
  var distanceCheck: real;
  for i in 1..numberOfAtoms {
    if signedPPDI[i] > 0 then {
      ii += 1;
      offspringAtomType[ii] = atomTypesI[i];
      offspringCoord[ii,1..3] = atomCoordinatesI[i,1..3];
    }
    if signedPPDJ[i] > 0 then {
      ii += 1;
      offspringAtomType[ii] = atomTypesJ[i];
      offspringCoord[ii,1..3] = atomCoordinatesJ[i,1..3];
    }
  }

  return (offspringAtomType, offspringCoord);
}


proc checkOffspringCandidate(offspringNumberOfEachAtomType:[] int):bool{
  var boolTemp:bool = true;
  for ii in 1..numberOfAtomTypes {
    boolTemp = (boolTemp && (offspringNumberOfEachAtomType[ii] == numberOfEachAtomType[ii]) );
  }
  return boolTemp;
}

proc generateRandomPlane(randomNumbers:RandomStream){
  var norm: [1..3] real;
  fillRandom(norm);
  norm = -1.0 + norm * 2.0;
  var d: real;
  d = randomNumbers.getNext();
  //writeln("norm: ",norm);
  //writeln("d: ",d);
  return (norm,d);
}

proc rotateCoordinates(Rx:[1..3,1..3] real, Ry:[1..3,1..3] real, Rz:[1..3,1..3] real, coords:[] real) {
  const D:domain(2) = coords.domain;
  const d1:domain(1) = D.dim(1);
  var coordinates:[D] real;
  for i in d1 {
    coordinates[i,1..3] = multiplyMatrixVector(Rx, coords[i,1..3]);
    coordinates[i,1..3] = multiplyMatrixVector(Ry, coordinates[i,1..3]);
    coordinates[i,1..3] = multiplyMatrixVector(Rz, coordinates[i,1..3]);
  }
  return coordinates;
}

proc multiplyMatrixVector(A:[1..3,1..3] real, x:[1..3] real): [1..3] real{
  var xp:[1..3] real = 0.0;
  for i in 1..3 {
    for j in 1..3 {
      xp[i] += A[i,j]*x[j];
    }
  }
  return xp;
}

proc generateRandomRotationMatrices(randomNumbers:RandomStream){

  var Rx,Ry,Rz:[1..3,1..3] real;
  var thetaX: real; 
  thetaX = randomNumbers.getNext();
  thetaX = thetaX*2.0*3.14159265;
  var thetaY: real;
  thetaY = randomNumbers.getNext();
  thetaY = thetaY*2.0*3.14159265;
  var thetaZ: real;
  thetaZ = randomNumbers.getNext();
  thetaZ = thetaZ*2.0*3.14159265;

  Rx = ((1.0, 0.0, 0.0),
      (0.0, cos(thetaX), -1.0*sin(thetaX)),
      (0.0, sin(thetaX), cos(thetaX)));
  Ry = ((cos(thetaY), 0.0, sin(thetaY)),
      (0.0, 1.0, 0.0),
      (-1.0*sin(thetaY), 0.0, cos(thetaY)));
  Rz = ((cos(thetaZ), -1.0*sin(thetaZ), 0.0),
      (sin(thetaZ), cos(thetaZ), 0.0),
      (0.0, 0.0, 1.0));

  return (Rx,Ry,Rz);
}

proc generateRandomClusters(){
  for clusterIndex in 1..numberOfClusters {
    clusterFilename = "cluster_" + clusterIndex + ".xyz";
    writeln("Writing cluster to file: ",clusterFilename);
    var clusterFile = open(clusterFilename,iomode.cw);
    var writer = clusterFile.writer();

    randomClusterCartesianCoordinates(
        numberOfAtomTypes,
        numberOfEachAtomType,
        atomTypes,
        minBondArray,
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
    select inputLineA {
      when "numberOfAtomTypes" do {
        //inputLineB = reader.read(string);
        numberOfAtomTypes = reader.read(int);
        D1 = {1..numberOfAtomTypes};
        D2 = {1..numberOfAtomTypes, 1..numberOfAtomTypes};
      }
      when "numberOfEachAtomType" do {
        inputLineB = reader.read(string);
        numberOfEachAtomTypeCounter += 1;
        numberOfEachAtomType[numberOfEachAtomTypeCounter]=inputLineB:int;
      }
      when "atomTypes" do {
        inputLineB = reader.read(string);
        atomTypesCounter += 1;
        atomTypes[atomTypesCounter] = inputLineB;
      }
      when "numberOfClusters" do {
        inputLineB = reader.read(string);
        numberOfClusters = inputLineB:int;
      }
      when "generateRandom" do {
        inputLineB = reader.read(string);
        generateRandom = inputLineB:bool;
      }
      when "generateOffspring" do {
        inputLineB = reader.read(string);
        generateOffspring = inputLineB:bool;
      }
      when "numberOfOffspringPerClusterPair" do {
        inputLineB = reader.read(string);
        numberOfOffspringPerClusterPair = inputLineB:int;
      }
      when "minBondArray" do {
        for i in D2.dim(1) {
          for j in D2.dim(2) {
            minBondArray(i,j) = reader.read(real);
          }
        }
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
    minBondArray:[] real,
    clusterIndex: int,
    writer: channel) {

  var minBond: real;
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
      minBond = minBondArray[atomTypeArray[i],atomTypeArray[j]];
      if (distance(cartesianCoordinates[i,1..3],cartesianCoordinates[j,1..3]) < minBond) {
        writeln("atom ",i," and atom ",j," are too close");
        writeln("atom ",i," coords: ",cartesianCoordinates[i,1..3]);
        writeln("atom ",j," coords: ",cartesianCoordinates[j,1..3]);
        writeln("minBond: ",minBond);
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

proc writeOffspringXYZ(
    offspringIndex:int,
    offspringAtomTypes:[] string,
    offspringCoord: [] real,
    writer: channel) {

  writer.writeln(numberOfAtoms);
  writer.writeln(offspringIndex);
  //TODO: sort to group the same types of atoms together (but maybe this doesn't matter)
  for i in 1..numberOfAtoms{
    writer.writeln(offspringAtomTypes[i]," ",offspringCoord[i,1..3]);
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
