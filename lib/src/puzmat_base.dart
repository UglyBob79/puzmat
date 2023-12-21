import 'dart:io';
import 'dart:collection';

enum Dir { north, south, west, east }

Map<Dir, List<int>> _dMove = {
  Dir.north: [0, -1],
  Dir.south: [0, 1],
  Dir.west: [-1, 0],
  Dir.east: [1, 0]
};

enum ToStringMode { all, overlay, single }

/// `PuzMat` is a matrix class designed for solving code puzzles. It supports
/// multiple layers, enabling the representation of 2D or 3D puzzle data.
/// Each layer consists of rows and columns, and the matrix is populated
/// with elements of a specified type.
///
/// If an operation doesn't explicitly mention layers, it is assumed to work on
/// the base layer when fetching data and on all layers when performing global
/// operations.
///
/// In addition to base layer operations, `PuzMat` provides layer-specific
/// operations for more granular manipulation. Some operations take layers as
/// arguments, allowing you to target specific layers for customized actions.
///
class PuzMat<T> {
  List<List<List<T?>>> _layers = [];
  List<T?> _defVals = [];

  // parameters used to provice various versions of toString() format
  ToStringMode _toStringMode = ToStringMode.all;
  int _toStringLayer = -1;

  /// Creates a new PuzMat instance with a layer of the specified number
  /// of [rows] and [cols], initializing each element with the provided
  /// default value [defVal].
  ///
  /// The matrix is populated with [defVal], and the resulting PuzMat is ready for use.
  PuzMat(int rows, int cols, T defVal) {
    _layers.add(_createLayer(rows, cols, defVal));
    _defVals.add(defVal);
  }

  /// Creates a new PuzMat instance with a base layer from the provided [data] matrix.
  ///
  /// The [baseLayer] matrix is used to initialize the new PuzMat.
  PuzMat.fromMatrix(List<List<T>> baseLayer) {
    _layers.add(baseLayer);
    // TODO Want to default this by type instead?
    _defVals = [null];
  }

  /// Creates a new PuzMat instance with multiple layers from the provided [data] 3D matrix.
  ///
  /// The [data] 3D matrix is used to initialize the new PuzMat.
  PuzMat.from3DMatrix(List<List<List<T>>> matrix) {
    _layers = matrix;
    // TODO Want to default this by type instead?
    _defVals = List.generate(_layers.length, (_) => null);
  }

  PuzMat.fromFile(File file, String delimiterPattern, { T? empty }) {
    var matrix = file
        .readAsLinesSync()
        .map((line) => line.split(delimiterPattern))
        .map((row) => row.map((element) => _parseElement<T>(element)).toList())
        .toList();

    _layers.add(matrix);
    _defVals.add(empty);
  }

  /// Maps layers in a PuzMat instance based on specified mappings and data.
  ///
  /// Given a 2D matrix of data and a list of mappings for each layer, this method
  /// creates new layers where each element is either populated from the original
  /// data matrix or set to a specified empty value based on the mappings.
  ///
  /// If the optional [empty] parameter is provided, it should be a list of values
  /// that correspond to each mapping. Elements in the new layers not matching any
  /// mapping will be set to the respective empty value. If [empty] is null, unmatched
  /// elements will be set to null.
  ///
  /// Throws [ArgumentError] if [empty] is provided and its length is not the same as
  /// the length of mappings.
  PuzMat.mapLayers(List<List<T?>> matrix, List<List<T>> mappings, { List<T?>? empty }) {
    if (empty != null && empty.length != mappings.length) {
      throw ArgumentError.value(empty, 'empty', 'Parameter empty must be the same length as mappings or null.');
    }

    if (empty != null) {
      _defVals = empty;
    } else {
      _defVals = List.generate(mappings.length, (_) => null);
    }

    _layers = [];

    for (int i = 0; i < mappings.length; i++) {
      List<List<T?>> layer = List.generate(matrix.length, (row) => List.generate(matrix[0].length, (col) => _defVals[i]));

      for (int row = 0; row < matrix.length; row++) {
        for (int col = 0; col < matrix[0].length; col++) {
          if (mappings[i].contains(matrix[row][col])) {
            layer[row][col] = matrix[row][col];
          }
        }
      }

      _layers.add(layer);
    }
  }

  /// Creates a new PuzMat instance by mapping layers from an existing PuzMat instance.
  ///
  /// Given a source PuzMat [from] and a layer index [layer], this factory method
  /// generates a new PuzMat instance by mapping layers based on the provided
  /// [mappings]. Optionally, you can specify a default list [empty] for the
  /// generated PuzMat instance. If [empty] is not provided, it defaults to an
  /// empty list.
  factory PuzMat.mapLayersFromLayer(PuzMat<T> from, int layer, List<List<T>> mappings, { List<T?>? empty }) {
    return PuzMat.mapLayers(from.layer(layer), mappings, empty: empty);
  }

  /// Adds a new layer to the PuzMat using a 2D matrix.
  ///
  /// This method adds a new layer to the private list _layers by copying the
  /// provided 2D matrix. Additionally, it allows specifying a default value
  /// (`empty`) to be associated with the new layer in the list _defVals.
  ///
  /// Parameters:
  ///   - [matrix]: The 2D matrix representing the new layer to be added.
  ///   - [empty]: An optional parameter representing the default value for
  ///     elements in the new layer. If not provided, the default value is `null`.
  void addLayerFromMatrix(List<List<T?>> matrix, { T? empty }) {
    _layers.add(matrix);
    _defVals.add(empty);
  }

  /// Creates a new layer with a specified fill value and adds it to the PuzMat matrix.
  ///
  /// This method generates a 2D matrix with the specified dimensions (rows and columns),
  /// filled with the given fill value. The generated layer is then added to the puzzle matrix.
  ///
  /// Parameters:
  ///   - [fill]: The value to fill the matrix with.
  ///   - [empty]: An optional parameter representing the default value for
  ///     elements in the new layer. If not provided, the default value is `null`.
  ///
  /// Returns:
  ///   - void
  void newLayer(T fill, { T? empty }) {
    List<List<T?>> matrix = List.generate(
      rows,
      (row) => List<T?>.filled(cols, fill, growable: false),
      growable: false,
    );

    addLayerFromMatrix(matrix, empty: empty);
  }

  /// This getter provides the count of rows in the matrix.
  ///
  /// Returns the number of rows in the matrix.
  int get rows {
    return _layers[0].length;
  }

  /// This getter provides the count of columns in the matrix.
  ///
  /// Returns the number of columns in the matrix.
  int get cols {
    return _layers[0][0].length;
  }

  /// This getter provides the count of layers in the matrix.
  ///
  /// Returns the number of layers in the matrix.
  int get layers {
    return _layers.length;
  }

  /// If the [row] is within the current bounds of the matrix, a list of elements in that row is returned.
  ///
  /// Returns a list representing the elements in the specified [row] of the matrix base layer.
  List<T?> row(int row) {
    if (row < 0 || row >= this.rows) {
      throw RangeError("Invalid row index");
    }
    return _layers[0][row];
  }

  /// If the [column] is within the current bounds of the matrix, a list of elements in that column is returned.
  ///
  /// Returns a list representing the elements in the specified [column] of the matrix base layer.
  List<T?> column(int column) {
    List<T?> list = [];
    for (int i = 0; i < this.rows; i++) {
      list.add(_layers[0][i][column]);
    }
    return list;
  }

  /// This getter provides access to the raw matrix data stored in the PuzMat.
  /// Modifying the returned matrix directly will affect the state of the PuzMat.
  ///
  /// Returns the underlying matrix of the PuzMat instance.
  List<List<List<T?>>> get matrix {
    return _layers;
  }

  /// Retrieves the 2D matrix representing a specific layer.
  ///
  /// This method returns a 2D matrix representing the layer at the given index.
  /// It performs a validity check on the layer index to ensure it falls within
  /// the valid range of layer indices. If the layer index is invalid, a [RangeError]
  /// is thrown. Otherwise, the 2D matrix corresponding to the specified layer is
  /// returned.
  ///
  /// Parameters:
  ///   - [layer]: The index of the layer to retrieve.
  ///
  /// Returns:
  ///   - A 2D matrix representing the specified layer.
  ///
  /// Throws:
  ///   - [RangeError]: If the layer index is out of bounds.
  List<List<T?>> layer(int layer) {
    if (!layerValid(layer)) {
      throw RangeError("Invalid layer index");
    }

    return _layers[layer];
  }

  /// The transpose of a matrix swaps its rows and columns.
  ///
  /// Returns a new PuzMat representing the transpose of the current matrix.
  PuzMat get transpose {
    return PuzMat.from3DMatrix(_layers
        .map((layer) => List.generate(this.rows, (colIndex) {
              return layer.map((row) => row[colIndex]).toList();
            }))
        .toList());
  }

  /// Each row in the resulting matrix is reversed, applied on all layers.
  ///
  /// Returns a new PuzMat instance representing the matrix flipped horizontally.
  PuzMat get flipHorizontal {
    return PuzMat.from3DMatrix(_layers
        .map((layer) => layer.map((row) => row.reversed.toList()).toList())
        .toList());
  }

  /// Each row in the resulting matrix is reversed, applied on all layers.
  ///
  /// Returns a new PuzMat instance representing the matrix flipped horizontally.
  PuzMat get flipVertical {
    return PuzMat.from3DMatrix(
        _layers.map((layer) => layer.reversed.toList()).toList());
  }

  /// Accesses the 2D matrix representing a specific layer using the square bracket notation.
  ///
  /// This operator allows you to retrieve the 2D matrix corresponding to the layer at
  /// the given index using the square bracket (`[]`) notation. The layer index is used
  /// to access the desired layer within the matrix. If the layer index is invalid, a
  /// [RangeError] is thrown.
  ///
  /// Parameters:
  ///   - [layer]: The index of the layer to retrieve.
  ///
  /// Returns:
  ///   - A 2D matrix representing the specified layer.
  ///
  /// Throws:
  ///   - [RangeError]: If the layer index is out of bounds.
  List<List<T?>> operator [](int layer) {
    return _layers[layer];
  }

  /// Sets the elements at the specified [index] with the provided [value].
  ///
  /// If the [index] is within the current bounds of the matrix, the elements are updated.
  void operator []=(int index, List<T> value) {
    // TODO
    //_data[index] = value;
  }

  /// Checks if a specific element in the PuzMat instance is empty.
  ///
  /// This method verifies whether the element at the specified layer, row, and
  /// column is considered empty, based on the comparison with the default value
  /// (_defVals) associated with that layer. If the provided layer, row, or column
  /// is out of range, a [RangeError] is thrown.
  ///
  /// Example:
  /// ```dart
  /// final puzMat = PuzMat<int>();
  /// // ... (populate layers)
  /// if (puzMat.isEmpty(1, 2, 3)) {
  ///   print('The element at layer 1, row 2, and column 3 is empty.');
  /// }
  /// ```
  ///
  /// Parameters:
  /// - [layer]: The index of the layer to check.
  /// - [row]: The index of the row to check.
  /// - [col]: The index of the column to check.
  ///
  /// Returns `true` if the element is empty; otherwise, returns `false`.
  ///
  /// Throws a [RangeError] if the provided layer index is out of range or if the
  /// specified row or column is not inside the matrix range.
  bool isEmpty(int layer, int row, int col) {
    if (!inBounds(row, col)) {
      throw RangeError("Row or col not inside matrix range.");
    }

    if (layer < 0 || layer >= this.layers) {
      throw RangeError("Layer index out of range.");
    }

    return _layers[layer][row][col] == _defVals[layer];
  }

  /// Checks if the given [row] and [column] are within the bounds of the matrix.
  ///
  /// Returns `true` if both the row and column are within bounds; otherwise, returns `false`.
  bool inBounds(int row, int column) {
    return rowInBounds(row) && columnInBounds(column);
  }

  /// Checks if the given [row] is within the bounds of the matrix.
  ///
  /// Returns `true` if the row is within bounds; otherwise, returns `false`.
  bool rowInBounds(int row) {
    return 0 <= row && row < _layers[0].length;
  }

  /// Checks if the given [column] is within the bounds of the matrix.
  ///
  /// Returns `true` if the column is within bounds; otherwise, returns `false`.
  bool columnInBounds(int column) {
    return 0 <= column && column < _layers[0][0].length;
  }

  /// Checks if the given layer index is valid.
  ///
  /// This method ensures that the layer index is within the bounds of the
  /// private list _layers in the context of the containing class.
  bool layerValid(int layer) {
    return layer >= 0 && layer < _layers.length;
  }

  /// Clears all layers in the PuzMat instance.
  ///
  /// This method iterates through each layer in the PuzMat instance
  /// and clears its content using the [clearLayer] method.
  void clear() {
    for (int layer = 0; layer < _layers.length; layer++) {
      clearLayer(layer);
    }
  }

  /// Clears the content of a specific layer in the PuzMat instance.
  ///
  /// This method sets all elements in the specified layer to the default
  /// value associated with that layer. If the default values are
  /// not set, elements will be set to null.
  void clearLayer(int layer) {
    // TODO Clear by new instead? What is faster/better?
    for (int row = 0; row < _layers[layer].length; row++) {
      for (int col = 0; col < _layers[layer][0].length; col++) {
        _layers[layer][row][col] = _defVals[layer];
      }
    }
  }

  /// Moves elements in the specified layer [moveLayer] in the given direction [dir],
  /// subject to obstacle layers and boundary conditions.
  ///
  /// This method attempts to move elements in the specified layer according to the
  /// provided [dir] (direction) while respecting obstacles defined in [obstacleLayers].
  /// The method returns `true` if the move operation results in a stable state, and
  /// `false` otherwise.
  ///
  /// Parameters:
  /// - [dir]: The direction of the move operation (north, south, west, or east).
  /// - [moveLayer]: The index of the layer to be moved. Must be within the valid
  ///   layer index range [0, this.layers).
  /// - [obstacleLayers]: List of layer indexes representing obstacle layers.
  ///   Each obstacle layer index must be within the valid layer index range [0, this.layers).
  ///
  /// Throws:
  /// - [RangeError]: If the [moveLayer] or any obstacle layer index is outside
  ///   the valid layer index range.
  ///
  /// Returns:
  /// - `true` if the move operation results in a stable state, and `false` otherwise.
  ///
  /// Example usage:
  /// ```dart
  /// var puzMat = PuzMat<int>(/*...*/);
  /// var movedStably = puzMat.move(Dir.north, 1, [2, 3]);
  /// ```
  bool move(Dir dir, int moveLayer, List<int> obstacleLayers) {
    if (moveLayer < 0 || moveLayer >= this.layers) {
      throw RangeError("Invalid move layer index");
    }

    if (obstacleLayers.any((layer) => layer < 0 || layer >= this.layers)) {
      throw RangeError("Invalid obstacle layer indexes");
    }

    bool stable = true;

    for (int i = 0; i < this.rows * this.cols; i++) {
      int col = 0;
      int row = 0;

      switch (dir) {
        case Dir.north:
          col = i % this.rows;
          row = i ~/ this.rows;
          break;

        case Dir.south:
          col = i % this.rows;
          row = this.rows - 1 - (i ~/ this.rows);
          break;

        case Dir.west:
          col = i ~/ this.cols;
          row = i % this.cols;
          break;

        case Dir.east:
          col = this.cols - 1 - (i ~/this.cols);
          row = i % this.cols;
          break;
      }

      int moveRow = row + _dMove[dir]![1];
      int moveCol = col + _dMove[dir]![0];

      if (!isEmpty(moveLayer, row, col) &&
          inBounds(moveRow, moveCol) &&
          isEmpty(moveLayer, moveRow, moveCol) &&
          obstacleLayers.every((layer) => isEmpty(layer, moveRow, moveCol))) {
        _layers[moveLayer][moveRow][moveCol] = _layers[moveLayer][row][col];
        _layers[moveLayer][row][col] = _defVals[moveLayer];
        stable = false;
      }
    }

    return stable;
  }

  /// Marks a range of cells in the specified layer with a given marker value,
  /// considering obstacles and optionally restricting to an exact range.
  ///
  /// This method performs a breadth-first search from the provided [start] position
  /// in the specified [moveLayer]. It marks cells within a given [range] with the
  /// specified [mark] value, while respecting obstacle layers defined in
  /// [obstacleLayers]. The optional parameter [exact] controls whether the marking
  /// should be exact (up to the range) or include cells beyond the range.
  ///
  /// Parameters:
  /// - [start]: The starting position as a list [col, row].
  /// - [range]: The maximum number of steps away from the start position to mark.
  /// - [mark]: The value to mark the cells with.
  /// - [moveLayer]: The index of the layer to be marked.
  /// - [obstacleLayers]: List of layer indexes representing obstacle layers.
  ///   Each obstacle layer index must be within the valid layer index range [0, this.layers).
  /// - [exact]: If `true`, only marks cells within the exact range. If `false` (default),
  ///   marks cells up to and including the specified range.
  ///
  /// Example usage:
  /// ```dart
  /// var puzMat = PuzMat<int>(/*...*/);
  /// puzMat.markMoveRange([1, 1], 2, 42, 0, [2, 3], exact: true);
  /// ```
  void markMoveRange(List<int> start, int range, T mark, int moveLayer, List<int> obstacleLayers, { bool exact = false }) {
    Queue<List<dynamic>> queue = Queue<List<dynamic>>();

    queue.add([start, 0]);

    outer:
    while (queue.isNotEmpty) {
      var task = queue.removeFirst();
      List<int> pos = task[0];
      int steps = task[1];

      if (!inBounds(pos[1], pos[0]) || steps > range) {
        continue;
      }

      for (var obstacleLayer in obstacleLayers) {
        if (_layers[obstacleLayer][pos[1]][pos[0]] != _defVals[obstacleLayer])  {
          continue outer;
        }
      }

      if (!exact || (range - steps) % 2 == 0) {
        _layers[moveLayer][pos[1]][pos[0]] = mark;
      }

      for (var dir in Dir.values) {
        int moveRow = pos[1] + _dMove[dir]![1];
        int moveCol = pos[0] + _dMove[dir]![0];

        queue.add([[moveCol, moveRow], steps + 1]);
      }
    }
  }

  List<List<int>> layerFindAll(int layer, T item) {
    List<List<int>> result = [];

    for (int row = 0; row < this.rows; row++) {
      for (int col = 0; col < this.cols; col++) {
        if (_layers[layer][row][col] == item) {
          result.add([col, row]);
        }
      }
    }

    return result;
  }

  /// Counts the occurrences of a specific item in the cells of a given layer.
  ///
  /// This method iterates through the cells of the specified [layer] in the PuzMat instance
  /// and counts the occurrences of the specified [item].
  ///
  /// Parameters:
  /// - [layer]: The index of the layer to be counted.
  /// - [item]: The item whose occurrences are to be counted.
  ///
  /// Returns:
  /// - The number of occurrences of the specified [item] in the cells of the specified [layer].
  ///
  /// Example usage:
  /// ```dart
  /// var puzMat = PuzMat<int>(/*...*/);
  /// var count = puzMat.layerCount(0, 42);
  /// ```
  int layerCount(int layer, T item) {
    int result = 0;

    for (int row = 0; row < this.rows; row++) {
      for (int col = 0; col < this.cols; col++) {
        if (_layers[layer][row][col] == item) {
          result++;
        }
      }
    }

    return result;
  }

  /// Sets the toString mode for the PuzMat instance, controlling how the layers are displayed in string representation.
  ///
  /// This method allows you to specify a custom toString mode ([mode]) for the PuzMat instance.
  /// The optional parameter [layer] allows you to set the toString mode to a specific layer.
  /// If [layer] is not specified or set to -1, the toString mode will be applied to all layers.
  ///
  /// Parameters:
  /// - [mode]: The ToStringMode to be set for the PuzMat instance.
  /// - [layer]: (Optional) The index of the layer for which the toString() will be applied to.
  ///
  /// Example usage:
  /// ```dart
  /// var puzMat = PuzMat<int>(/*...*/);
  /// puzMat.setToStringMode(ToStringMode.single, layer: 1);
  /// ```
  void setToStringMode(ToStringMode mode, {layer = -1}) {
    _toStringMode = mode;
    _toStringLayer = layer;
  }

  /// Compares two layers to check if they are identical.
  ///
  /// This method compares the content of two layers (_layers[layer1] and
  /// _layers[layer2]) element-wise. If the layers are identical, it returns `true`;
  /// otherwise, it returns `false`.
  ///
  /// Parameters:
  ///   - [layer1]: The index of the first layer to be compared.
  ///   - [layer2]: The index of the second layer to be compared.
  ///
  /// Throws:
  ///   - ArgumentError: If either of the layer indices is out of bounds.
  ///
  /// Returns:
  ///   - `true` if the layers are identical.
  ///   - `false` otherwise.
  bool compareLayers(int layer1, int layer2) {
    if (!layerValid(layer1) || !layerValid(layer2)) {
      throw ArgumentError('Layer(s) our or bounds.');
    }

    for (int y = 0; y < _layers[layer1].length; y++) {
      for (int x = 0; x < _layers[layer1][y].length; x++) {
        if (_layers[layer1][y][x] != _layers[layer2][y][x]) {
          return false;
        }
      }
    }
    return true;
  }

  // TODO format cell width according to contents
  @override
  String toString() {
    StringBuffer buffer = StringBuffer();
    buffer.writeln('PuzMat[${_layers[0].length}][${_layers[0][0].length}]');

    if (_toStringMode == ToStringMode.single) {
      buffer.write(_layerToString(_toStringLayer));
    } else if (_toStringMode == ToStringMode.all) {
      for (int i = 0; i < _layers.length; i++) {
        buffer.write(_layerToString(i));
      }
    } else { // ToStringMode.overlay
      for (int row = 0; row < this.rows; row++) {
        buffer.write('  ');
        for (int col = 0; col < this.cols; col++) {
          for (int layer =this.layers - 1; layer >= 0; layer--) {
            if (_layers[layer][row][col] != _defVals[layer] || layer == 0) {
              buffer.write(_layers[layer][row][col]);
              break;
            }
          }
        }
        buffer.writeln();
      }
    }

    return buffer.toString();
  }

  /// Get a String representation of a layer.
  ///
  /// Returns a String representation of a certain layer with index [layer].
  String _layerToString(int layer) {
    return 'layer: $layer\n${_layers[layer].map((row) => "  ${row.join('')}").join('\n')}\n';
  }

  /// Creates a new layer that can be added to the PuzMat instance of the specified
  /// number of [rows] and [cols], initializing each element with the provided
  /// default value [defVal].
  ///
  /// Returns a layer that can be added to the PuzMat matrix.
  List<List<T>> _createLayer(int rows, int cols, T defVal) {
    if (_layers.isNotEmpty && (rows != this.rows || cols != this.cols)) {
      throw RangeError("New layer dimension does not match previous layers.");
    }

    return List.generate(
        rows, (row) => List<T>.generate(cols, (col) => defVal));
  }

  T _parseElement<T>(String element) {
    if (T == int) {
      return int.parse(element) as T;
    } else if (T == double) {
      return double.parse(element) as T;
    } else if (T == String) {
      return element as T;
    } else {
      throw ArgumentError("Unsupported type: $T");
    }
  }
}
