source("./hbtnet/analysis/plot_util.R")

sim_data_VR_VI <- read.csv("./data/supp_05_VR_VI.csv")
sim_data_choice <- read.csv("./data/supp_05_choice.csv")

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
supp_05a <- show_devaluation_02(averaged_data_VR_VI)
supp_05b <- show_degree_02(averaged_data_VR_VI)
supp_05c <- show_centrality_02(averaged_data_VR_VI)

supp_05d <- ggplot(sim_data_choice) +
  stat_summary(fun="mean", geom="bar",
               aes(x = schedule, y = devaluation),
               fill = "gray", size = 1, width = 0.75) +
  stat_summary(fun.min = function(x) mean(x) - sd(x) / sqrt(length(x)),
               fun.max = function(x) mean(x) + sd(x) / sqrt(length(x)),
               aes(x = schedule, y = devaluation),
               geom = "errorbar",
               width = 0.3, size = 1) +
  geom_jitter(aes(x = schedule, y = devaluation),
              size = 6, width = 0.2) +
  xlab("Availability of choice") +
  ylab("Resistance to devaluation") +
  theme_classic() +
  theme(aspect.ratio = 1) +
  font_config

supp_05a
supp_05b
supp_05c
supp_05d

ggsave("./fig/supp_05a_devalue.jpg", supp_05a)
ggsave("./fig/supp_05b_degree.jpg", supp_05b)
ggsave("./fig/supp_05c_central.jpg", supp_05c)
ggsave("./fig/supp_05d_devalue.jpg", supp_05d)
