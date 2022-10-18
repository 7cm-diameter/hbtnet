source("./hbtnet/analysis/plot_util.R")
library(viridis)

sim_data <- read.csv("./data/supp_01.csv")

se <- function(x) {
  sd(x) / sqrt(length(x))
}

averaged_data <- sim_data %>%
  split(., list(.$N, .$Q.operant, .$Q.others, .$beta), drop = T) %>%
  lapply(., function(d) {
    data.frame(N = unique(d$N),
               qop = unique(d$Q.operant),
               qot = unique(d$Q.others),
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

# Figure 1
ggplot(averaged_data) +
  geom_tile(aes(x = qop, y = qot, fill = avr_dev)) +
  xlab("Q-operant") +
  ylab("Q-others") +
  theme_classic() +
  theme(aspect.ratio = 1) +
  font_config +
  scale_fill_viridis()

ggsave("./fig/supp_01a.jpg")

ggplot(averaged_data) +
  geom_tile(aes(x = qop, y = qot, fill = avr_degree)) +
  xlab("Q-operant") +
  ylab("Q-others") +
  theme_classic() +
  theme(aspect.ratio = 1) +
  font_config +
  scale_fill_viridis()

ggsave("./fig/supp_01b.jpg")
