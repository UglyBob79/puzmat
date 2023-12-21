# PuzMat - A matrix made for puzzle solving

PuzMat is a matrix that doesn't focus solely on math operations, but more on operations used for solving code puzzles, for example [Advent of Code](https://adventofcode.com/). The goal is to provide many generic operations, like movement, searching, shortest path, data manipulation as well as support for layers.

## Features

- **Generic:** Supports any type of data, for instance Strings, integers and booleans. More complex types can be used, but are not thoroughly tested.
- **Layers:** For many problems, more than one matrix is needed. To prevent having to manage that yourself, PuzMat supports multiple layers.
- **Easy creation:** PuzMat supports multiple ways of creating the matrix. By providing dimensions and default value, from a standard dart matrix or mapping data to multiple layers.
- **Transpose:** Standard matrix transpose operations is supported.
- **Flip:** The matrix can be flipped horizontally or vertically.
- **Move:** Layer elements can be moved in 4 directions, with support for obstacles, which can be used for many puzzles.
- **Mark range:** Mark the range of movement from a certain position in the matrix, with support for obstacles.
- **String representation:** PuzMat supports several modes for toString() representation, which can be setup for each matrix. The current options are to show one or all layers, but it can also overlay the layers into a single representation.

## Getting started

Follow these steps to integrate [PuzMat] into your Dart project. If you encounter any issues or have questions, feel free to [open an issue](link-to-issues-page).

## Installation

You can install [PuzMat] by adding it to your `pubspec.yaml` file:

```yaml
dependencies:
  puzmat: ^1.0.0
```

## Usage

In your Dart code, import the library:

```dart
import 'package:puzmat/puzmat.dart';
```

Example code:

```dart
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

  /// This list sets the empty value, or default value, for each layer. For some operations, cells
  /// with that value will be considered empty

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
  //
  //   #    ###
  //   #    #
  // layer: 2
  //   O
  //   O OO
  //
  //   OO  O    O
  //    O     O
  //   O    O
  //     O   O  O
  //          O
  //
  //    OO

  /// Enable overlay toString() mode, this will merge all layers into one. Empty values will show
  ///the layer below

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

  /// Move all non-empty elements of layer 2 in to the east, layer 1 will be considered obstacles.
  /// Returns true if no movement could be made.

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
```
