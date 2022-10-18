from typing import Iterable, List, Optional

import hbtnet.model as m
import hbtnet.types as tp
import networkx as nx
import numpy as np
from numpy.typing import NDArray
from scipy.stats import poisson


def _softmax(v: NDArray[np.float_], beta: float) -> NDArray[np.float_]:
    vmax = np.max(v)
    v_ = np.exp((v - vmax) * beta)
    return v_ / sum(v_)


class HQAgent(m.Agent):
    """
    Used in the simulation 1.
    """

    def __init__(self, qop: tp.QValue, qot: tp.QValue, beta_net: float,
                 n: int):
        nx.Graph.__init__(self)
        self._beta_net = beta_net
        q_ = np.full(n, qot)
        q_[0] = qop
        self._q = np.outer(q_, q_)
        self._response_times = np.zeros(n)

    def update(self, s: tp.Action, a: tp.Action, a_: tp.Action,
               reward: tp.Reward):
        pass

    def choose_action(self, s: tp.Action) -> tp.Action:
        return 0

    def engage(self, action: tp.Action) -> float:
        return self._response_times[action]

    def construct_network(self, mindegree: int):
        n, _ = self._q.shape
        for s in range(n):
            probs = _softmax(self._q[s], self._beta_net)
            t: Iterable[tp.Node] = np.random.choice(n,
                                                    size=mindegree,
                                                    p=probs,
                                                    replace=False)
            [self.add_edge(s, t_) for t_ in t]

    def find_path(self, s: tp.Node, t: tp.Node) -> List[tp.Path]:
        if self.has_edge(s, t):
            # if self.has_edge(s, t) and not self.has_edge(s, s):
            return [[s, t]]
        if s == t:
            neighbors = list(nx.all_neighbors(self, s))
            s_ = np.random.choice(neighbors)
            return [[s, s_, t]]
        else:
            return list(nx.all_shortest_paths(self, s, t))

    def action_sequence(self, s: tp.Action, t: tp.Action) -> tp.ActionSequence:
        paths = self.find_path(s, t)
        i = np.random.choice(len(paths))
        return paths[i][1:]

    def choose_goal(self, rewards: NDArray[tp.Reward]) -> tp.Action:
        """
        Choose an action based on values of rewards.
        """
        probs = rewards / sum(rewards)
        return np.random.choice(len(rewards), p=probs)


class HQLocalExplore(HQAgent):

    def find_path(self, s: tp.Node, t: tp.Node) -> List[tp.Path]:
        if self.has_edge(s, t):
            # if self.has_edge(s, t) and not self.has_edge(s, s):
            return [[s, t]]
        if s == t:
            neighbors = list(nx.all_neighbors(self, s))
            s_ = np.random.choice(neighbors)
            return [[s, s_, t]]
        neighbors = list(nx.all_neighbors(self, s))
        s_ = np.random.choice(neighbors)
        path = [s, s_]
        while not self.has_edge(s_, t):
            neighbors = list(nx.all_neighbors(self, s_))
            s_ = np.random.choice(neighbors)
            path.append(s_)
        path.append(t)
        return [path]


class QLearningAgent(m.Agent):
    """
    Used in the simulation 2 and 3.
    """

    def __init__(self,
                 alpha: float,
                 gamma: float,
                 beta_choice: float,
                 beta_net: float,
                 boutlength: int,
                 response_times: NDArray[np.float_],
                 n_operant: int = 1):
        nx.Graph.__init__(self)
        n = len(response_times)
        self._alpha = alpha
        self._gamma = gamma
        self._q = np.zeros((n, n))
        self._beta_choice = beta_choice
        self._beta_net = beta_net
        self._boutlength = boutlength
        self._response_times = response_times
        self._inbout = 0
        self._n_operant = n_operant

    def update(self, s: tp.Action, a: tp.Action, a_: Optional[tp.Action],
               reward: tp.Reward):
        q_max = np.max(self._q[a])
        self._q[s][a] += self._alpha * (reward + self._gamma * q_max -
                                        self._q[s][a])

    def choose_action(self, s: tp.Action) -> tp.Action:
        """
        Choose an action based on Q-value.
        """
        if self._inbout > 0:
            self._inbout -= 1
            return s
        probs = _softmax(self._q[s], self._beta_choice)
        s = np.random.choice(len(probs), p=probs)
        if s <= (self._n_operant - 1) and self._inbout == 0:
            self._inbout = poisson.ppf(np.random.uniform(),
                                       mu=self._boutlength).astype(np.int_)
        return s

    def engage(self, action: tp.Action) -> float:
        return self._response_times[action]

    def construct_network(self, mindegree: int):
        n, _ = self._q.shape
        for s in range(n):
            probs = _softmax(self._q[s], self._beta_net)
            t: Iterable[tp.Node] = np.random.choice(n,
                                                    size=mindegree,
                                                    p=probs,
                                                    replace=False)
            [self.add_edge(s, t_) for t_ in t]

    def find_path(self, s: tp.Node, t: tp.Node) -> List[tp.Path]:
        if self.has_edge(s, t):
            return [[s, t]]
        if s == t:
            neighbors = list(nx.all_neighbors(self, s))
            s_ = np.random.choice(neighbors)
            return [[s, s_, t]]
        else:
            return list(nx.all_shortest_paths(self, s, t))

    def action_sequence(self, s: tp.Action, t: tp.Action) -> tp.ActionSequence:
        paths = self.find_path(s, t)
        i = np.random.choice(len(paths))
        return paths[i][1:]

    def choose_goal(self, rewards: NDArray[tp.Reward]) -> tp.Action:
        """
        Choose an action based on values of rewards.
        """
        probs = rewards / sum(rewards)
        return np.random.choice(len(rewards), p=probs)


class SARSAAgent(QLearningAgent):
    """
    Used in the simulation 2 and 3.
    """

    def update(self, s: tp.Action, a: tp.Action, a_: Optional[tp.Action],
               reward: tp.Reward):
        q_next = self._q[a][a_]
        self._q[s][a] += self._alpha * (reward + self._gamma * q_next -
                                        self._q[s][a])
