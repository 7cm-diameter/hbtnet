import hbtnet.sim as s
from hbtnet.sim.agent import HQAgent
from networkx import to_numpy_matrix
from numpy import int8, savetxt

if __name__ == '__main__':
    cli = s.Cli()
    yaml = cli.yaml
    print(
        f"Start the simulation according to the settings described in {yaml}")
    params, _ = s.get_parameter_setting(yaml)

    for param in params:
        print(param)
        n, qop, qot, beta = param
        agent = HQAgent(qop, qot, beta, n)
        agent.construct_network(2)
        net = to_numpy_matrix(agent).astype(int8)
        savetxt(f"{cli.output}-{n}-{qop}-{qot}-{beta}.csv",
                net,
                delimiter=",",
                fmt="%.0f")
