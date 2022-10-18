library(tidyverse)


clear_text <- theme(axis.text = element_text(color = "transparent"),
                    axis.title = element_text(color = "transparent"),
                    legend.text = element_text(color = "transparent"),
                    legend.title = element_text(color = "transparent"),
                    strip.text = element_text(color = "transparent"),
                    strip.background = element_rect(color = "transparent",
                                                    fill = "transparent"),
                    legend.position = "none")

font_config <- theme(axis.text = element_text(size = 25, color = "black"),
                     axis.title = element_text(color = "transparent"),
                     legend.text = element_text(color = "transparent"),
                     legend.title = element_text(color = "transparent"),
                     strip.text = element_text(size = 25, color = "white"),
                     strip.background = element_rect(color = "black", fill = "black"))


show_devaluation_01 <- function(d) {
  ggplot(d) +
    geom_errorbar(aes(x = q,
                      ymax = avr_dev + se_dev,
                      ymin = avr_dev - se_dev),
                  width = 0.02, size = 1.) +
    geom_line(aes(x = q, y = avr_dev), size = 2) +
    geom_point(aes(x = q, y = avr_dev), color = "black", size = 6) +
    xlab("Q-operant") +
    ylab("Resistance to devaluation") +
    theme_classic() +
    theme(aspect.ratio = 1) +
    font_config
}

show_degree_01 <- function(d) {
  ggplot(d) +
    geom_errorbar(aes(x = q,
                      ymax = avr_degree + se_degree,
                      ymin = avr_degree - se_degree),
                  width = 0.02, size = 1.) +
    geom_line(aes(x = q, y = avr_degree), size = 2) +
    geom_point(aes(x = q, y = avr_degree), color = "black", size = 6) +
    xlab("Q-operant") +
    ylab("Degree of the operant response") +
    theme_classic() +
    theme(aspect.ratio = 1) +
    font_config
}

show_centrality_01 <- function(d) {
  ggplot(d) +
    geom_errorbar(aes(x = q,
                      ymax = avr_centrality + se_centrality,
                      ymin = avr_centrality - se_centrality),
                  width = 0.02, size = 1.) +
    geom_line(aes(x = q, y = avr_centrality), size = 2) +
    geom_point(aes(x = q, y = avr_centrality), color = "black", size = 6) +
    xlab("Q-operant") +
    ylab("Betweenness centrality of the operant response") +
    theme_classic() +
    theme(aspect.ratio = 1) +
    font_config
}

show_distance_01 <- function(d) {
  ggplot(d) +
    geom_errorbar(aes(x = q,
                      ymax = avr_d + se_d,
                      ymin = avr_d - se_d),
                  width = 0.02, size = 1.) +
    geom_line(aes(x = q, y = avr_d), size = 2) +
    geom_point(aes(x = q, y = avr_d), color = "black", size = 6) +
    xlab("Q-operant") +
    ylab("Average distance of the network") +
    theme_classic() +
    theme(aspect.ratio = 1) +
    font_config
}

show_time_01 <- function(d) {
  ggplot(d) +
    geom_errorbar(aes(x = q,
                      ymax = avr_t + se_t,
                      ymin = avr_t - se_t),
                  width = 0.02, size = 1.) +
    geom_line(aes(x = q, y = avr_t), size = 2) +
    geom_point(aes(x = q, y = avr_t), color = "black", size = 6) +
    xlab("Q-operant") +
    ylab("Time required for the simulation in the test phase") +
    theme_classic() +
    theme(aspect.ratio = 1) +
    font_config
}

show_devaluation_02 <- function(d) {
  ggplot(d) +
    geom_errorbar(aes(x = training,
                      ymax = avr_dev + se_dev,
                      ymin = avr_dev - se_dev,
                      color = schedule),
                  width = 5., size = 1.) +
    geom_line(aes(x = training, y = avr_dev,
                  color = schedule),
              size = 2) +
    geom_point(aes(x = training, y = avr_dev,
                   color = schedule),
               size = 6) +
    xlab("Amout of training") +
    ylab("Resistance to devaluation") +
    theme_classic() +
    theme(aspect.ratio = 1) +
    font_config
}

show_degree_02 <- function(d) {
  ggplot(d) +
    geom_errorbar(aes(x = training,
                      ymax = avr_degree + se_degree,
                      ymin = avr_degree - se_degree,
                      color = schedule),
                  width = 5., size = 1.) +
    geom_line(aes(x = training, y = avr_degree,
                  color = schedule),
              size = 2) +
    geom_point(aes(x = training, y = avr_degree,
                   color = schedule),
               size = 6) +
    xlab("Amout of training") +
    ylab("Degree of the operant response") +
    theme_classic() +
    theme(aspect.ratio = 1) +
    font_config
}

show_centrality_02 <- function(d) {
  ggplot(averaged_data_VR_VI) +
    geom_errorbar(aes(x = training,
                      ymax = avr_centrality + se_centrality,
                      ymin = avr_centrality - se_centrality,
                      color = schedule),
                  width = 5., size = 1.) +
    geom_line(aes(x = training, y = avr_centrality,
                  color = schedule),
              size = 2) +
    geom_point(aes(x = training, y = avr_centrality,
                   color = schedule),
               size = 6) +
    xlab("Amout of training") +
    ylab("Betweenness centrality of the operant response") +
    theme_classic() +
    theme(aspect.ratio = 1) +
    font_config
}

show_distance_02 <- function(d) {
  ggplot(averaged_data_VR_VI) +
    geom_errorbar(aes(x = training,
                      ymax = avr_d + se_d,
                      ymin = avr_d - se_d,
                      color = schedule),
                  width = 5., size = 1.) +
    geom_line(aes(x = training, y = avr_d,
                  color = schedule),
              size = 2) +
    geom_point(aes(x = training, y = avr_d,
                   color = schedule),
               size = 6) +
    xlab("Amout of training") +
    ylab("Betweenness centrality of the operant response") +
    theme_classic() +
    theme(aspect.ratio = 1) +
    font_config
}

show_time_02 <- function(d) {
  ggplot(d) +
    geom_errorbar(aes(x = training,
                      ymax = avr_time + se_time,
                      ymin = avr_time - se_time,
                      color = schedule),
                  width = 5., size = 1.) +
    geom_line(aes(x = training, y = avr_time,
                  color = schedule),
              size = 2) +
    geom_point(aes(x = training, y = avr_time,
                   color = schedule),
               size = 6) +
    xlab("Amout of training") +
    ylab("Time required for the simulation in the test phase") +
    theme_classic() +
    theme(aspect.ratio = 1) +
    font_config
}
