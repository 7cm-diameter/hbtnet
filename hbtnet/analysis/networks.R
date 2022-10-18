library(GGally)
library(network)
library(sna)

load_network <- function(path) {
  read.csv(path, header = F) %>% data.matrix %>% network(., directed = F)
}

RED <- "#e06666ff"
BLUE <- "#6fa8dcff"
BLACK <- "#504f4fff"

single_colors <- c(RED, rep(BLACK, 49))
choice_colors <- c(RED, BLACK, BLACK, BLUE, rep(BLACK, 46))


sim1_low <- load_network("./data/network-example-50-0.1-0.1-50.0.csv")
sim1_mid <- load_network("./data/network-example-50-0.7-0.1-50.0.csv")
sim1_high <- load_network("./data/network-example-50-1.0-0.1-50.0.csv")
sim2_choice <- load_network("./data/network-choice.csv")
sim2_no_choice <- load_network("./data/network-no-choice.csv")

sim1_low_fig <- ggnet2(sim1_low,
                       color = single_colors,
                       size = 8) +
  theme(aspect.ratio = 1)
sim1_mid_fig <- ggnet2(sim1_mid,
                       color = single_colors,
                       size = 8) +
  theme(aspect.ratio = 1)
sim1_high_fig <- ggnet2(sim1_high,
                        color = single_colors,
                        size = 8) +
  theme(aspect.ratio = 1)
sim2_choice_fig <- ggnet2(sim2_choice,
                          color = choice_colors,
                          size = 8) +
  theme(aspect.ratio = 1)
sim2_no_choice_fig <- ggnet2(sim2_no_choice,
                             color = single_colors,
                             size = 8) +
  theme(aspect.ratio = 1)

ggsave("./fig/sim1_low_net.jpg", sim1_low_fig)
ggsave("./fig/sim1_mid_net.jpg", sim1_mid_fig)
ggsave("./fig/sim1_high_net.jpg", sim1_high_fig)
ggsave("./fig/sim2_choice_net.jpg", sim2_choice_fig)
ggsave("./fig/sim2_no_choice_net.jpg", sim2_no_choice_fig)
