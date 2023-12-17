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
  PuzMat.from3DMatrix(List<List<List<T>>> data) {
    _layers = data;
    // TODO Want to default this by type instead?
    _defVals = List.generate(_layers.length, (_) => null);
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
  PuzMat.mapLayers(List<List<T>> data, List<List<T>> mappings, { List<T?>? empty }) {
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
      List<List<T?>> layer = List.generate(data.length, (row) => List.generate(data[0].length, (col) => _defVals[i]));

      for (int row = 0; row < data.length; row++) {
        for (int col = 0; col < data[0].length; col++) {
          if (mappings[i].contains(data[row][col])) {
            layer[row][col] = data[row][col];
          }
        }
      }

      _layers.add(layer);
    }
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

  void setToStringMode(ToStringMode mode, {layer = -1}) {
    _toStringMode = mode;
    _toStringLayer = layer;
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
}
