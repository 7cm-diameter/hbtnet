from argparse import ArgumentParser
from time import perf_counter
from typing import List, Tuple

import hbtnet.env as e
import hbtnet.model as m
import hbtnet.types as tp
import networkx as nx
import numpy as np
from numpy.typing import NDArray


def generate_response_times(operant: List[float], range_: Tuple[float, float],
                            n: int) -> NDArray[np.float_]:
    l, h = range_
    response_times = np.random.uniform(l, h, n)
    for (i, t) in zip(range(len(operant)), operant):
        response_times[i] = t
    return response_times


def train(agent: m.Agent, env: e.ConcurrentSchedule, N: int) -> tp.Time:
    s = np.random.choice(N)
    session_duration = 0.

    while not np.all(env.finished):
        a = agent.choose_action(s)
        t = agent.engage(a)
        r = env.step(to_onehot(a, N), t)
        a_ = agent.choose_action(a)
        agent.update(s, a, a_, r)
        s = a
        session_duration += t
    return session_duration


def _travel(agent: m.Agent, rewards: NDArray[tp.Reward], nloop: int) -> float:
    number_of_operant, number_of_overall = 0, 0
    s = np.random.choice(len(rewards))
    for _ in range(nloop):
        t = agent.choose_goal(rewards)
        while s == t:
            t = agent.choose_goal(rewards)
        action_sequence = agent.action_sequence(s, t)
        if 0 in action_sequence:
            number_of_operant += 1
        number_of_overall += len(action_sequence)
        s = t
    return number_of_operant / number_of_overall


def test(agent: m.Agent, nloop: int, r: tp.Reward, ro: tp.Reward,
         n_operant: int, n: int) -> Tuple[float, float]:
    rewards = np.full(n, ro)
    s = perf_counter()
    for i in range(n_operant):
        rewards[i] = r
    pre_devaluation = _travel(agent, rewards, nloop)
    rewards[0] = 0.
    post_devaluation = _travel(agent, rewards, nloop)
    t = perf_counter()
    return post_devaluation / pre_devaluation, t - s


def to_onehot(x: int, n: int) -> NDArray[np.int_]:
    return np.identity(n)[x]


def count_number_of_edges(network: nx.Graph, node: tp.Node) -> int:
    edges = network.edges
    return len(list(filter(lambda e: node in e, edges)))


def get_parameter_setting(path: str) -> Tuple[List[Tuple], List[str]]:
    from itertools import product

    from yaml import safe_load

    with open(path) as f:
        params = safe_load(f)
        keys = list(params.keys())
        return list(product(*tuple(params.values()))), keys


class Cli(ArgumentParser):

    def __init__(self):
        super().__init__()
        self.add_argument("--yaml", "-y", required=True, type=str)
        self.add_argument("--output", "-o", required=True, type=str)
        self._arg = self.parse_args()

    @property
    def yaml(self) -> str:
        return self._arg.yaml

    @property
    def output(self) -> str:
        return self._arg.output
