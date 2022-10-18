from typing import Callable, List, Tuple, Union

from numpy import float_
from numpy.typing import NDArray

Node = int
Edge = Tuple[Node, Node]
Path = List[Node]

Reward = Union[float_, float]
Action = Node
QValue = float_
ActionSequence = Path
Time = float
ProbabilityFunction = Callable[[NDArray[float_]], NDArray[float_]]

N = int
Alpha = float
Gamma = float
BetaChoice = float
BetaNetwork = float
