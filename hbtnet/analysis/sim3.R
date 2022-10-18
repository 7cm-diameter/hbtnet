source("./hbtnet/analysis/plot_util.R")

sim_data <- read.csv("./data/sim3.csv")

se <- function(x) {
  sd(x) / sqrt(length(x))
}

averaged_data <- sim_data %>%
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

schedules <- c("VI", "Tandem VI VR", "VR", "Tandem VR VI")

# Figure 1
fig6a <- ggplot(sim_data) +
  stat_summary(fun="mean", geom="bar",
               aes(x = schedule, y = devaluation),
               fill = "gray",
               size = 1, width = 0.75) +
  stat_summary(fun.min = function(x) mean(x) - sd(x) / sqrt(length(x)),
               fun.max = function(x) mean(x) + sd(x) / sqrt(length(x)),
               aes(x = schedule, y = devaluation),
               geom = "errorbar",
               width = 0.3, size = 1) +
  geom_jitter(aes(x = schedule, y = devaluation),
              size = 5, width = 0.2) +
  xlab("Schedule type") +
  ylab("Resistance to devaluation") +
  scale_x_discrete(labels = schedules) +
  theme_classic() +
  theme(aspect.ratio = 1) +
  font_config

fig6b <- ggplot(sim_data) +
  stat_summary(fun="mean", geom="bar",
               aes(x = schedule, y = degree),
               fill = "gray",
               size = 1, width = 0.75) +
  stat_summary(fun.min = function(x) mean(x) - sd(x) / sqrt(length(x)),
               fun.max = function(x) mean(x) + sd(x) / sqrt(length(x)),
               aes(x = schedule, y = degree),
               geom = "errorbar",
               width = 0.3, size = 1) +
  geom_jitter(aes(x = schedule, y = degree),
              size = 5, width = 0.2) +
  xlab("Schedule type") +
  ylab("Degree of the operant response") +
  scale_x_discrete(labels = schedules) +
  theme_classic() +
  theme(aspect.ratio = 1) +
  font_config

fig6c <- ggplot(sim_data) +
  stat_summary(fun="mean", geom="bar",
               aes(x = schedule, y = centrality),
               fill = "gray",
               size = 1, width = 0.75) +
  stat_summary(fun.min = function(x) mean(x) - sd(x) / sqrt(length(x)),
               fun.max = function(x) mean(x) + sd(x) / sqrt(length(x)),
               aes(x = schedule, y = centrality),
               geom = "errorbar",
               width = 0.3, size = 1) +
  geom_jitter(aes(x = schedule, y = centrality),
              size = 5, width = 0.2) +
  xlab("Schedule type") +
  ylab("Betweenness centrality of the operant response") +
  scale_x_discrete(labels = schedules) +
  theme_classic() +
  theme(aspect.ratio = 1) +
  font_config


fig6a
fig6b
fig6c


fig7 <- ggplot(sim_data) +
  stat_summary(fun="mean", geom="bar",
               aes(x = schedule, y = self.q),
               color = "black", fill = "gray",
               size = 1, width = 0.75) +
  stat_summary(fun.min = function(x) mean(x) - sd(x) / sqrt(length(x)),
               fun.max = function(x) mean(x) + sd(x) / sqrt(length(x)),
               aes(x = schedule, y = self.q),
               geom = "errorbar",
               width = 0.3, size = 1) +
  geom_jitter(aes(x = schedule, y = self.q),
              size = 4, width = 0.2) +
  xlab("Schedule type") +
  ylab("Q-value (operant → operant)") +
  scale_x_discrete(labels = schedules) +
  theme_classic() +
  theme(aspect.ratio = 1) +
  font_config
fig7

ggsave("./fig/fig6a_devaluation.jpg", fig6a)
ggsave("./fig/fig6b_degree.jpg", fig6b)
ggsave("./fig/fig6c_central.jpg", fig6c)
ggsave("./fig/fig7_self_q.jpg", fig7)
