import 'package:puzmat/puzmat.dart';

void main() {
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

  List<List<String>> mappings = [
    ['.'],
    ['#'],
    ['O']
  ];

  List<String?> empty = [
    '.',
    ' ',
    ' '
  ];

  var puzMat = PuzMat.mapLayers(map, mappings, empty: empty);

  while (!puzMat.move(Dir.north, 2, [1]));
  while (!puzMat.move(Dir.west, 2, [1]));
  while (!puzMat.move(Dir.south, 2, [1]));
  while (!puzMat.move(Dir.east, 2, [1]));

  puzMat.setToStringMode(ToStringMode.overlay);
  print(puzMat);

}