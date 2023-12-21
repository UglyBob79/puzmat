import 'dart:io';

import 'package:puzmat/puzmat.dart';

void main() {
  /// Create simple int matrix

  var intMat = PuzMat(3, 3, 0);

  print(intMat);

  // PuzMat[3][3]
  // layer: 0
  //   000
  //   000
  //   000

  /// Create from matrix

  intMat = PuzMat.fromMatrix([
    [1, 2, 3],
    [4, 5, 6],
    [7, 8, 9]
  ]);

  print(intMat);

  // PuzMat[3][3]
  // layer: 0
  //   123
  //   456
  //   789

  /// Create from 3D matrix, where the first dimension will be layers

  intMat = PuzMat.from3DMatrix([
    [
      [1, 2, 3],
      [4, 5, 6],
      [7, 8, 9]
    ],
    [
      [1, 4, 7],
      [2, 5, 8],
      [3, 6, 9]
    ]
  ]);

  print(intMat);

  // PuzMat[3][3]
  // layer: 0
  //   123
  //   456
  //   789
  // layer: 1
  //   147
  //   258
  //   369

  /// Create by mapping a String matrix with letters to separate layers

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
    "#OO..#...."
  ].map((l) => l.split('')).toList();

  /// These mappings will tell which letters go to which layer

  List<List<String>> mappings = [
    ['.'],
    ['#'],
    ['O']
  ];

  // This list sets the empty value, or default value, for each layer. For some operations, cells with that value will be considered empty

  List<String?> empty = ['.', ' ', ' '];

  var strMat = PuzMat.mapLayers(map, mappings, empty: empty);

  /// Print with default toString() mode, in separate layers

  print(strMat);

  // PuzMat[10][10]
  // layer: 0
  //   ..........
  //   ..........
  //   ..........
  //   ..........
  //   ..........
  //   ..........
  //   ..........
  //   ..........
  //   ..........
  //   ..........
  // layer: 1
  //        #
  //       #    #
  //        ##
  //      #
  //           #
  //     #    # #
  //        #

  //   #    ###
  //   #    #
  // layer: 2
  //   O
  //   O OO

  //   OO  O    O
  //    O     O
  //   O    O
  //     O   O  O
  //          O

  //    OO

  /// Enable overlay toString() mode, this will merge all layers into one. Empty values can show the layer below

  strMat.setToStringMode(ToStringMode.overlay);

  print(strMat);

  // PuzMat[10][10]
  //   O....#....
  //   O.OO#....#
  //   .....##...
  //   OO.#O....O
  //   .O.....O#.
  //   O.#..O.#.#
  //   ..O..#O..O
  //   .......O..
  //   #....###..
  //   #OO..#....

  /// Move all non-empty elements of layer 2 in to the east, layer 1 will be considered obstacles. Returns true if no movement could be made.

  bool stable = strMat.move(Dir.east, 2, [1]);

  print(stable);

  // false

  print(strMat);

  // PuzMat[10][10]
  // .O...#....
  // .OOO#....#
  // .....##...
  // .OO#.O...O
  // ..O....O#.
  // .O#...O#.#
  // ...O.#.O.O
  // ........O.
  // #....###..
  // #.OO.#....

  var fileMat = PuzMat<String>.fromFile(File('example/example.dat'), '');

  print(fileMat);

  // PuzMat[11][11]
  // layer: 0
  //   ...........
  //   .....###.#.
  //   .###.##..#.
  //   ..#.#...#..
  //   ....#.#....
  //   .##..S####.
  //   .##..#...#.
  //   .......##..
  //   .##.#.####.
  //   .##..##.##.
  //   ...........

  strMat = PuzMat.mapLayersFromLayer(fileMat, 0, [['.'], ['#'], ['S']], empty: empty);

  print(strMat);

  // PuzMat[11][11]
  // layer: 0
  //   ...........
  //   ...........
  //   ...........
  //   ...........
  //   ...........
  //   ...........
  //   ...........
  //   ...........
  //   ...........
  //   ...........
  //   ...........
  // layer: 1
  //
  //        ### #
  //    ### ##  #
  //     # #   #
  //       # #
  //    ##   ####
  //    ##  #   #
  //          ##
  //    ## # ####
  //    ##  ## ##

  // layer: 2
  //
  //
  //
  //
  //
  //        S
  //
  //
  //
  //
  //

  var found = strMat.layerFindAll(2, 'S');

  print(found);

  // [[5, 5]]

  strMat.clearLayer(2);

  print(strMat);

  // PuzMat[11][11]
  // layer: 0
  //   ...........
  //   ...........
  //   ...........
  //   ...........
  //   ...........
  //   ...........
  //   ...........
  //   ...........
  //   ...........
  //   ...........
  //   ...........
  // layer: 1
  //
  //        ### #
  //    ### ##  #
  //     # #   #
  //       # #
  //    ##   ####
  //    ##  #   #
  //          ##
  //    ## # ####
  //    ##  ## ##

  // layer: 2
  //
  //
  //
  //
  //
  //
  //
  //
  //
  //
  //

  strMat.setToStringMode(ToStringMode.overlay);

  strMat.markMoveRange(found[0], 6, 'O', 2, [1]);

  print(strMat);

  // PuzMat[11][11]
  //   ...........
  //   .....###.#.
  //   .###.##OO#.
  //   .O#O#OOO#..
  //   OOOO#O#OO..
  //   .##OOO####.
  //   .##OO#O..#.
  //   .OOOOOO##..
  //   .##O#O####.
  //   .##O.##.##.
  //   ...........

  strMat.clearLayer(2);

  strMat.markMoveRange(found[0], 6, 'O', 2, [1], exact: true);

  print(strMat);

  // PuzMat[11][11]
  //   ...........
  //   .....###.#.
  //   .###.##.O#.
  //   .O#O#O.O#..
  //   O.O.#.#.O..
  //   .##O.O####.
  //   .##.O#O..#.
  //   .O.O.O.##..
  //   .##.#.####.
  //   .##O.##.##.
  //   ...........

  int count = strMat.layerCount(2, 'O');

  print(count);

  // 16
}