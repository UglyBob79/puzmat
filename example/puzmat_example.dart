import 'package:puzmat/puzmat.dart';

void main() {
  var puzMat = PuzMat(10, 10, '.');

  print(puzMat);

  List<List<String>> map = [
    "O....#....",
    "O.OO#....#",
    ".....##...",
    "OO.#O....O",
    ".O.....O#.",
    "O.#..O.#.#",
    "..O..#O..O",
    ".......O..",
    "#....###..",
    "#OO..#...."]
    .map((l) => l.split('')).toList();

  puzMat = PuzMat.fromMatrix(map);

  print(puzMat);

  //puzMat[3][0] = 'X';

  //puzMat[4] = "1234567890".split('');

  //print(puzMat);

  //print(puzMat.transpose);

  while (!puzMat.move(Dir.north, ['O'], '.'));
  while (!puzMat.move(Dir.west, ['O'], '.'));
  while (!puzMat.move(Dir.south, ['O'], '.'));
  while (!puzMat.move(Dir.east, ['O'], '.'));
  print(puzMat);

  // while (!puzMat.move(Dir.NORTH, ['O'], '.')) {
  //   print(puzMat);
  // }

}