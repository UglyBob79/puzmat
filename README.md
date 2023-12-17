# PuzMat - A matrix made for puzzle solving

PuzMat is a matrix that doesn't focus solely on math operations, but more on operations used for solving code puzzles, for example [Advent of Code](https://adventofcode.com/). The goal is to provide many generic operations, like movement, searching, shortest path, data manipulation as well as support for layers.

## Features

- **Generic:** Supports any type of data, for instance Strings, integers and booleans. More complex types can be used, but are not thoroughly tested.
- **Layers:** For many problems, more than one matrix is needed. To prevent having to manage that yourself, PuzMat supports multiple layers.
- **Easy creation:** PuzMat supports multiple ways of creating the matrix. By providing dimensions and default value, from a standard dart matrix or mapping data to multiple layers.
- **Transpose:** Standard matrix transpose operations is supported.
- **Flip:** The matrix can be flipped horizontally or vertically.
- **Move:** Layer elements can be moved in 4 directions, with support for obstacles, which can be used for many puzzles.
- **String representation:** MapHaz supports several modes for toString() representation, which can be setup for each matrix. The current options are to show one or all layers, but it can also overlay the layers into a single representation.

## Getting started

TODO: List prerequisites and provide or point to information on how to
start using the package.

## Usage

TODO: Include short and useful examples for package users. Add longer examples
to `/example` folder.

```dart
const like = 'sample';
```

## Additional information

TODO: Tell users more about the package: where to find more information, how to
contribute to the package, how to file issues, what response they can expect
from the package authors, and more.
