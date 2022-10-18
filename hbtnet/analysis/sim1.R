source("./hbtnet/analysis/plot_util.R")

sim_data <- read.csv("./data/sim1.csv")

se <- function(x) {
  sd(x) / sqrt(length(x))
}

averaged_data <- sim_data %>%
  split(., list(.$N, .$Q.operant, .$Q.others, .$beta), drop = T) %>%
  lapply(., function(d) {
    data.frame(N = unique(d$N),
               q = unique(d$Q.operant),
               avr_dev = mean(d$devaluation),
               avr_degree = mean(d$degree),
               avr_centrality = mean(d$centrality),
               avr_d = mean(d$d),
               avr_t = mean(d$t),
               se_dev = se(d$devaluation),
               se_degree = se(d$degree),
               se_centrality = se(d$centrality),
               se_d = se(d$d),
               se_t = se(d$t))
}) %>%
  do.call(rbind, .) -> averaged_data

# Figure 1
fig2a <- show_devaluation_01(averaged_data)
fig2b <- show_degree_01(averaged_data)
fig2c <- show_centrality_01(averaged_data)
fig2a
fig2b
fig2c

# Figure 1d: Network example
# fid1d

# Figure 2
fig3a <- show_distance_01(averaged_data)
fig3b <- show_time_01(averaged_data)
fig3a
fig3b

ggsave("./fig/fig2a_devalue.jpg", fig2a)
ggsave("./fig/fig2b_degree.jpg", fig2b)
ggsave("./fig/fig2c_central.jpg", fig2c)
ggsave("./fig/fig3a_distance.jpg", fig3a)
ggsave("./fig/fig3b_time.jpg", fig3b)
