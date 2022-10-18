source("./hbtnet/analysis/plot_util.R")

sim_data_VR_VI <- read.csv("./data/sim2_VR_VI.csv")
sim_data_choice <- read.csv("./data/sim2_choice.csv")

se <- function(x) {
  sd(x) / sqrt(length(x))
}

averaged_data_VR_VI <- sim_data_VR_VI %>%
  split(., list(.$N, .$Training, .$schedule), drop = T) %>%
  lapply(., function(d) {
    data.frame(N = unique(d$N),
               schedule = unique(d$schedule),
               training = unique(d$Training),
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

averaged_data_choice <- sim_data_choice %>%
  split(., list(.$N, .$Training, .$schedule), drop = T) %>%
  lapply(., function(d) {
    data.frame(N = unique(d$N),
               schedule = unique(d$schedule),
               training = unique(d$Training),
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
fig4a <- show_devaluation_02(averaged_data_VR_VI)
fig4b <- show_degree_02(averaged_data_VR_VI)
fig4c <- show_centrality_02(averaged_data_VR_VI)
fig4a
fig4b
fig4c

fig4d <- ggplot(sim_data_choice) +
  stat_summary(fun="mean", geom="bar",
               aes(x = schedule, y = devaluation),
               fill = "gray",
               width = 0.5, size = 1) +
  stat_summary(fun.min = function(x) mean(x) - sd(x) / sqrt(length(x)),
               fun.max = function(x) mean(x) + sd(x) / sqrt(length(x)),
               aes(x = schedule, y = devaluation),
               geom = "errorbar",
               width = 0.2, size = 1) +
  geom_jitter(aes(x = schedule, y = devaluation),
             size = 5, width = 0.2) +
  xlab("Availability of choice") +
  ylab("Resistance to devaluation") +
  theme_classic() +
  theme(aspect.ratio = 1) +
  font_config

fig4d
ggsave("./fig/fig4a_devalue.jpg", fig4a)
ggsave("./fig/fig4b_degree.jpg", fig4b)
ggsave("./fig/fig4c_central.jpg", fig4c)
ggsave("./fig/fig4d_devalue.jpg", fig4d)

fig5 <- ggplot(sim_data_VR_VI) +
  stat_summary(fun.min = function(x) mean(x) - sd(x) / sqrt(length(x)),
               fun.max = function(x) mean(x) + sd(x) / sqrt(length(x)),
               aes(x = Training, y = self.q, color = schedule),
               geom = "errorbar",
               width = 5., size = 1) +
  stat_summary(fun="mean", geom="line",
               aes(x = Training, y = self.q, color = schedule),
               size = 2) +
  stat_summary(fun="mean", geom="point",
               aes(x = Training, y = self.q, color = schedule),
               size = 6) +
  xlab("Schedule type") +
  ylab("Q-value (operant → operant)") +
  theme_classic() +
  theme(aspect.ratio = 1) +
  font_config

fig5
ggsave("./fig/fig5_self_q.jpg", fig5)
