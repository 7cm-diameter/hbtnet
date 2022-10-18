from typing import List, Tuple

import hbtnet.sim as s
import hbtnet.types as tp
from hbtnet.sim.agent import HQLocalExplore
from networkx import average_shortest_path_length, betweenness_centrality
from pandas import DataFrame, concat


def run(params: Tuple[tp.N, tp.QValue, tp.QValue, tp.BetaNetwork],
        colnames: List[str]) -> DataFrame:
    n, qop, qot, beta = params
    agent = HQLocalExplore(qop, qot, beta, n)
    agent.construct_network(2)
    devaluation, t = s.test(agent, 400, 1., 0.0028, 1, n)
    centrality = betweenness_centrality(agent).get(0)
    d = average_shortest_path_length(agent)
    degree = s.count_number_of_edges(agent, 0)
    return DataFrame([(*params, devaluation, degree, centrality, d, t)],
                     columns=colnames)


if __name__ == '__main__':
    cli = s.Cli()
    yaml = cli.yaml
    print(
        f"Start the simulation according to the settings described in {yaml}")
    params, paranames = s.get_parameter_setting(yaml)
    colnames = paranames + ["devaluation", "degree", "centrality", "d", "t"]

    result = DataFrame(columns=colnames)

    for param in params:
        print(paranames)
        print(param)
        ret = concat(list(map(lambda _: run(param, colnames), range(10))))
        result = concat([result, ret])

    result.to_csv(cli.output, index=False)
