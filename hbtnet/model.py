from abc import ABCMeta, abstractmethod
from typing import List, Optional

import networkx as nx
import numpy as np
from numpy.typing import NDArray

import hbtnet.types as tp


def _softmax(v: NDArray[np.float_], beta: float) -> NDArray[np.float_]:
    vmax = np.max(v)
    v_ = np.exp((v - vmax) * beta)
    return v_ / sum(v_)


class BehavioralNetwork(nx.Graph, metaclass=ABCMeta):

    @abstractmethod
    def construct_network(self, mindegree: int):
        pass

    @abstractmethod
    def find_path(self, s: tp.Node, t: tp.Node) -> List[tp.Path]:
        pass

    @abstractmethod
    def action_sequence(self, s: tp.Node, t: tp.Node) -> tp.Path:
        pass

    @abstractmethod
    def choose_goal(self, rewards: NDArray[tp.Reward]) -> tp.Action:
        pass


class Learner(metaclass=ABCMeta):

    @abstractmethod
    def update(self, s: tp.Action, a: tp.Action, a_: Optional[tp.Action],
               reward: tp.Reward):
        pass


class Actor(metaclass=ABCMeta):

    @abstractmethod
    def choose_action(self, s: tp.Action) -> tp.Action:
        pass

    @abstractmethod
    def engage(self, action: tp.Action) -> tp.Time:
        pass


class Agent(Learner, Actor, BehavioralNetwork):
    pass
