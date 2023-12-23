import 'package:puzmat/puzmat.dart';
import 'package:test/test.dart';

void main() {
  group('PuzMat test:', () {

    setUp(() {
      // Additional setup goes here.
    });

    test('Create empty Integer', () {
      var puzMat = PuzMat(3, 5, 0);

      expect(puzMat.cols, 5);
      expect(puzMat.rows, 3);

      for (int row = 0; row < puzMat.rows; row++) {
        for (int col = 0; col < puzMat.cols; col++) {
          expect(puzMat[0][row][col], 0);
        }
      }
    });

    test('Create empty String', () {
      var puzMat = PuzMat(3, 5, '.');

      expect(puzMat.cols, 5);
      expect(puzMat.rows, 3);

      for (int row = 0; row < puzMat.rows; row++) {
        for (int col = 0; col < puzMat.cols; col++) {
          expect(puzMat[0][row][col], '.');
        }
      }
    });

    test('Create from Matrix', () {
      var matrix = [
        [1, 2, 3],
        [4, 5, 6],
        [7, 8, 9]
      ];

      var puzMat = PuzMat.fromMatrix(matrix);

      expect(puzMat.cols, 3);
      expect(puzMat.rows, 3);

      for (int i = 0; i < puzMat.rows * puzMat.cols; i++) {
        expect(puzMat[0][i ~/ puzMat.rows][i % puzMat.rows], i + 1);
      }
    });

    test('Get row', () {
      var matrix = [
        [1, 2, 3],
        [4, 5, 6],
        [7, 8, 9]
      ];

      var puzMat = PuzMat.fromMatrix(matrix);

      expect(puzMat.cols, 3);
      expect(puzMat.rows, 3);

      expect(puzMat.row(1), [4, 5, 6]);
    });

    test('Get column', () {
      var matrix = [
        [1, 2, 3],
        [4, 5, 6],
        [7, 8, 9]
      ];

      var puzMat = PuzMat.fromMatrix(matrix);

      expect(puzMat.cols, 3);
      expect(puzMat.rows, 3);

      expect(puzMat.column(1), [2, 5, 8]);
    });

    test('Transpose', () {
      var matrix = [
        [1, 2, 3],
        [4, 5, 6],
        [7, 8, 9]
      ];

      var puzMat = PuzMat.fromMatrix(matrix);

      expect(puzMat.cols, 3);
      expect(puzMat.rows, 3);

      expect(puzMat.transpose.matrix[0],
      [
        [1, 4, 7],
        [2, 5, 8],
        [3, 6, 9]
      ]);
    });

    test('Transpose Layers', () {
      var matrix = [
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
      ];

      var puzMat = PuzMat.from3DMatrix(matrix);

      expect(puzMat.cols, 3);
      expect(puzMat.rows, 3);
      expect(puzMat.layers, 2);

      expect(puzMat.transpose.matrix,
      [
        [
          [1, 4, 7],
          [2, 5, 8],
          [3, 6, 9]
        ],
        [
          [1, 2, 3],
          [4, 5, 6],
          [7, 8, 9]
        ]
      ]
      );
    });

    test('Flip horizontal', () {
      var matrix = [
        [1, 2, 3],
        [4, 5, 6],
        [7, 8, 9]
      ];

      var puzMat = PuzMat.fromMatrix(matrix);

      expect(puzMat.cols, 3);
      expect(puzMat.rows, 3);

      expect(puzMat.flipHorizontal.matrix[0],
      [
        [3, 2, 1],
        [6, 5, 4],
        [9, 8, 7]
      ]);
    });

    test('Flip vertical', () {
      var matrix = [
        [1, 2, 3],
        [4, 5, 6],
        [7, 8, 9]
      ];

      var puzMat = PuzMat.fromMatrix(matrix);

      expect(puzMat.cols, 3);
      expect(puzMat.rows, 3);

      expect(puzMat.flipVertical.matrix[0],
      [
        [7, 8, 9],
        [4, 5, 6],
        [1, 2, 3]
      ]);
    });
  });

  test('[] Operator', () {
    var matrix = [
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
    ];

    var puzMat = PuzMat.from3DMatrix(matrix);

    expect(puzMat.cols, 3);
    expect(puzMat.rows, 3);
    expect(puzMat.layers, 2);

    expect(puzMat[0],
      [
        [1, 2, 3],
        [4, 5, 6],
        [7, 8, 9]
      ]
    );

    expect(puzMat[1],
      [
        [1, 4, 7],
        [2, 5, 8],
        [3, 6, 9]
      ]
    );

    expect(puzMat[1][1],
      [2, 5, 8]
    );

    expect(puzMat[0][2][1], 8);
  });

  test('Map layers', () {
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

      expect(puzMat.cols, 10);
      expect(puzMat.rows, 10);
      expect(puzMat.layers, 3);

      expect(puzMat[0][0], ['.', '.', '.', '.', '.', '.', '.', '.', '.', '.']);
      expect(puzMat[1][5], [' ', ' ', '#', ' ', ' ', ' ', ' ', '#', ' ', '#']);
      expect(puzMat[2][6], [' ', ' ', 'O', ' ', ' ', ' ', 'O', ' ', ' ', 'O']);
  });

  test('Empty directions', () {
    List<List<String>> map = [
      ".O........",
      "O.O..O....",
      ".O....O...",
      "O.....O...",
      "O......O.."]
      .map((l) => l.split('')).toList();

    var puzMat = PuzMat.mapLayers(map, [['.'], ['O']], empty: ['.', ' ']);
    puzMat.setToStringMode(ToStringMode.overlay);
    print(puzMat);

    expect(puzMat.empty4Dirs([1], [1, 1]).length, 0);
    expect(puzMat.empty4Dirs([1], [5, 2]), unorderedEquals([Dir.south, Dir.west]));
    expect(puzMat.empty4Dirs([1], [1, 4]), unorderedEquals([Dir.north, Dir.east]));
    expect(puzMat.empty4Dirs([1], [6, 4]), unorderedEquals([Dir.west]));
    expect(puzMat.empty4Dirs([1], [5, 1]), unorderedEquals(Dir.values));
  });
}
