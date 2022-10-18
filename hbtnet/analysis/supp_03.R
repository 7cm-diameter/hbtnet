source("./hbtnet/analysis/plot_util.R")

sim_data <- read.csv("./data/supp_03.csv")

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
  do.call(rbind, .)

supp_03a <- show_devaluation_01(averaged_data)
supp_03b <- show_degree_01(averaged_data)
supp_03c <- show_centrality_01(averaged_data)
supp_03a
supp_03b
supp_03c

ggsave("./fig/supp_03a_devalue.jpg", supp_03a)
ggsave("./fig/supp_03b_degree.jpg", supp_03b)
ggsave("./fig/supp_03c_central.jpg", supp_03c)

# Figure 2
supp_03d <- show_distance_01(averaged_data)
supp_03e <- show_time_01(averaged_data)

ggsave("./fig/supp_03e_time.jpg", supp_03e)
