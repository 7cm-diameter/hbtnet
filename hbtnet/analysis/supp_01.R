source("./hbtnet/analysis/plot_util.R")

sim_data <- read.csv("./data/supp_02_sim1.csv")
sim_data_VR_VI <- read.csv("./data/supp_02_VR_VI.csv")
sim_data_choice <- read.csv("./data/supp_02_choice.csv")

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


supp_02a <- show_devaluation_01(averaged_data) +
  facet_wrap(~N)
supp_02b <- show_degree_01(averaged_data) +
  ylim(0, 100) +
  facet_wrap(~N)
supp_02c <- show_centrality_01(averaged_data) +
  facet_wrap(~N)

supp_02d <- show_devaluation_02(averaged_data_VR_VI) +
  facet_wrap(~N)

supp_02e <- show_degree_02(averaged_data_VR_VI) +
  facet_wrap(~N)

supp_02f <- show_centrality_02(averaged_data_VR_VI) +
  facet_wrap(~N)

supp_02g <- ggplot(sim_data_choice) +
  stat_summary(fun="mean", geom="bar",
               aes(x = schedule, y = devaluation),
               fill = "gray", size = 1, width = 0.75) +
  stat_summary(fun.min = function(x) mean(x) - sd(x) / sqrt(length(x)),
               fun.max = function(x) mean(x) + sd(x) / sqrt(length(x)),
               aes(x = schedule, y = devaluation),
               geom = "errorbar",
               width = 0.3, size = 1) +
  geom_jitter(aes(x = schedule, y = devaluation),
              size = 5, width = 0.2) +
  xlab("Availability of choice") +
  ylab("Resistance to devaluation") +
  theme_classic() +
  theme(aspect.ratio = 1) +
  font_config +
  facet_wrap(~N)

supp_02a
supp_02b
supp_02c
supp_02d
supp_02e
supp_02f
supp_02g

ggsave("./fig/supp_02a_devalue.jpg", supp_01a)
ggsave("./fig/supp_02b_degree.jpg", supp_01b)
ggsave("./fig/supp_02c_central.jpg", supp_01c)
ggsave("./fig/supp_02d_devalue.jpg", supp_01d)
ggsave("./fig/supp_02e_degree.jpg", supp_01e)
ggsave("./fig/supp_02f_central.jpg", supp_01f)
ggsave("./fig/supp_02g_devalue.jpg", supp_01g)
