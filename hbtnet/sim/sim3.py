from typing import List, Tuple

import hbtnet.env as e
import hbtnet.sim as s
import hbtnet.types as tp
from hbtnet.sim.agent import QLearningAgent
from hbtnet.types import Reward
from networkx import average_shortest_path_length, betweenness_centrality
from pandas import DataFrame, concat


def run(params: Tuple[tp.N, Reward, Reward, int, tp.Alpha, tp.Gamma,
                      tp.BetaChoice, tp.BetaNetwork],
        colnames: List[str]) -> DataFrame:
    n, r, ro, ntrain, alpha, gamma, beta_choice, beta_net = params

    response_times = s.generate_response_times([0.1], (0.1, 0.5), n)

    others = [e.FixedRatio(1, ro, 10000, True) for _ in range(n - 1)]

    # Train under tandem VR VI schedule
    agent = QLearningAgent(alpha, gamma, beta_choice, beta_net, 8,
                           response_times, 1)

    VR = e.VariableRatio(15, r, ntrain, False)
    VI = e.VariableInterval(5., r, ntrain, False)
    target = [e.TandemSchedule([VR, VI])]
    env = e.ConcurrentSchedule(target, others, None)
    _ = s.train(agent, env, n) / ntrain

    agent.construct_network(2)
    tandem_VR_VI_devaluation, tandem_VR_VI_t = s.test(agent, 400, r, ro, 1, n)
    tandem_VR_VI_degree = s.count_number_of_edges(agent, 0)
    tandem_VR_VI_self_q = agent._q[0][0]
    tandem_VR_VI_centrality = betweenness_centrality(agent).get(0)
    tandem_VR_VI_d = average_shortest_path_length(agent)

    # Train under simple VR schedule
    agent = QLearningAgent(alpha, gamma, beta_choice, beta_net, 8,
                           response_times, 1)
    target = [e.VariableRatio(16, r, ntrain, False)]
    env = e.ConcurrentSchedule(target, others, None)
    _ = s.train(agent, env, n) / ntrain

    agent.construct_network(2)
    VR_devaluation, VR_t = s.test(agent, 400, r, ro, 1, n)
    VR_degree = s.count_number_of_edges(agent, 0)
    VR_self_q = agent._q[0][0]
    VR_centrality = betweenness_centrality(agent).get(0)
    VR_d = average_shortest_path_length(agent)

    # Train under tandem VI VR schedule
    agent = QLearningAgent(alpha, gamma, beta_choice, beta_net, 8,
                           response_times, 1)

    VI = e.VariableInterval(15., r, ntrain, False)
    VR = e.VariableRatio(5, r, ntrain, False)
    target = [e.TandemSchedule([VI, VR])]

    env = e.ConcurrentSchedule(target, others, None)
    _ = s.train(agent, env, n)

    agent.construct_network(2)
    tandem_VI_VR_devaluation, tandem_VI_VR_t = s.test(agent, 400, r, ro, 1, n)
    tandem_VI_VR_degree = s.count_number_of_edges(agent, 0)
    tandem_VI_VR_self_q = agent._q[0][0]
    tandem_VI_VR_centrality = betweenness_centrality(agent).get(0)
    tandem_VI_VR_d = average_shortest_path_length(agent)

    # Train under simple VI schedule
    agent = QLearningAgent(alpha, gamma, beta_choice, beta_net, 6,
                           response_times, 1)

    target = [e.VariableInterval(15., r, ntrain, False)]

    env = e.ConcurrentSchedule(target, others, None)
    _ = s.train(agent, env, n)

    agent.construct_network(2)
    VI_devaluation, VI_t = s.test(agent, 400, r, ro, 1, n)
    VI_degree = s.count_number_of_edges(agent, 0)
    VI_self_q = agent._q[0][0]
    VI_centrality = betweenness_centrality(agent).get(0)
    VI_d = average_shortest_path_length(agent)

    return DataFrame([(*params, "2:tandem-VI-VR", tandem_VI_VR_devaluation,
                       tandem_VI_VR_degree, tandem_VI_VR_centrality,
                       tandem_VI_VR_self_q, tandem_VI_VR_d, tandem_VI_VR_t),
                      (*params, "4:tandem-VR-VI", tandem_VR_VI_devaluation,
                       tandem_VR_VI_degree, tandem_VR_VI_centrality,
                       tandem_VR_VI_self_q, tandem_VR_VI_d, tandem_VR_VI_t),
                      (*params, "1:VI", VI_devaluation, VI_degree,
                       VI_centrality, VI_self_q, VI_d, VI_t),
                      (*params, "3:VR", VR_devaluation, VR_degree,
                       VR_centrality, VR_self_q, VR_d, VR_t)],
                     columns=colnames)


if __name__ == '__main__':
    cli = s.Cli()
    yaml = cli.yaml
    print(
        f"Start the simulation according to the settings described in {yaml}")

    params, paranames = s.get_parameter_setting(yaml)
    colnames = paranames + [
        "schedule", "devaluation", "degree", "centrality", "self-q", "d", "t"
    ]

    result = DataFrame(columns=colnames)

    for param in params:
        print(f"{param}")
        ret = concat(list(map(lambda _: run(param, colnames), range(10))))
        result = concat([result, ret])

    result.to_csv("./data/sim3.csv", index=False)
