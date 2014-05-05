use Random;

generateClusterCartesianCoordinates (2,[3,8]);
proc generateClusterCartesianCoordinates (numberOfAtomTypes: int, 
    numberOfEachAtomType: [] int) {

  var numberOfAtoms: int = 0;
  for i in 1..numberOfAtomTypes {
    numberOfAtoms += numberOfEachAtomType[i];
  }
  var cartesianCoordinates: [1..numberOfAtoms,1..3] real; 
  //
  // Fill A with random real values between 0 and 1.
  //
  fillRandom(cartesianCoordinates);
  cartesianCoordinates = ((numberOfAtoms)^(1/3)) * cartesianCoordinates;
  writeln("cartesianCoordinates are: "); writeln(cartesianCoordinates);
  writeln();
}
