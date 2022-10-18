from typing import List, Tuple

import hbtnet.env as e
import hbtnet.sim as s
import hbtnet.types as tp
from hbtnet.sim.agent import QLearningAgent
from hbtnet.types import Reward
from networkx import (average_shortest_path_length, betweenness_centrality,
                      to_numpy_matrix)
from numpy import int8, savetxt
from pandas import DataFrame, concat


def run(params: Tuple[tp.N, Reward, Reward, int, tp.Alpha, tp.Gamma,
                      tp.BetaChoice, tp.BetaNetwork],
        colnames: List[str]) -> DataFrame:
    n, r, ro, ntrain, alpha, gamma, beta_choice, beta_net = params

    # Train under concurrent VI VI schedule
    response_times = s.generate_response_times([0.1, 0.1], (0.1, 0.5), n)
    agent = QLearningAgent(alpha, gamma, beta_choice, beta_net, 8,
                           response_times, 2)

    target = [e.VariableInterval(60, r, ntrain, False) for _ in range(2)]
    others = [e.FixedRatio(1, ro, 10000, True) for _ in range(n - 2)]
    env = e.ConcurrentSchedule(target, others, None)
    _ = s.train(agent, env, n)

    agent.construct_network(2)
    choice_devaluation, choice_t = s.test(agent, 400, r, ro, 2, n)
    choice_degree = s.count_number_of_edges(agent, 0)
    choice_centrality = betweenness_centrality(agent).get(0)
    choice_d = average_shortest_path_length(agent)
    net = to_numpy_matrix(agent).astype(int8)
    savetxt("./data/network-choice.csv", net, delimiter=",", fmt="%.0f")

    # Train under concurrent VI VT schedule
    response_times = s.generate_response_times([0.1], (0.1, 0.5), n)
    agent = QLearningAgent(alpha, gamma, beta_choice, beta_net, 6,
                           response_times, 1)

    target = [e.VariableInterval(60, r, ntrain, False) for _ in range(1)]
    others = [e.FixedRatio(1, ro, 10000, True) for _ in range(n - 1)]
    independent = [e.VariableTime(60, r, 200, True)]
    env = e.ConcurrentSchedule(target, others, independent)
    _ = s.train(agent, env, n)

    agent.construct_network(2)
    no_choice_devaluation, no_choice_t = s.test(agent, 400, r, ro, 1, n)
    no_choice_degree = s.count_number_of_edges(agent, 0)
    no_choice_centrality = betweenness_centrality(agent).get(0)
    no_choice_d = average_shortest_path_length(agent)
    net = to_numpy_matrix(agent).astype(int8)
    savetxt("./data/network-no-choice.csv", net, delimiter=",", fmt="%.0f")

    return DataFrame(
        [(*params, "Choice", choice_devaluation, choice_degree,
          choice_centrality, choice_d, choice_t),
         (*params, "No choice", no_choice_devaluation, no_choice_degree,
          no_choice_centrality, no_choice_d, no_choice_t)],
        columns=colnames)


if __name__ == '__main__':
    cli = s.Cli()
    yaml = cli.yaml
    print(
        f"Start the simulation according to the settings described in {yaml}")

    params, paranames = s.get_parameter_setting(yaml)
    colnames = paranames + [
        "schedule", "devaluation", "degree", "centrality", "d", "t"
    ]

    result = DataFrame(columns=colnames)

    for param in params:
        print(f"{param}")
        ret = concat(list(map(lambda _: run(param, colnames), range(10))))
        result = concat([result, ret])

    result.to_csv(cli.output, index=False)
