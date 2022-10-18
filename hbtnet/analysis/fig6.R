source("./hbtnet/analysis/plot_util.R")


VI_elapsed_time <- function(x, lambda) {
  1 - exp(-lambda * x)
}

VR_elapsed_time <- function(x, lambda) {
  lambda <- 1 / lambda
  map(x, function(x_) {1 / lambda}) %>% unlist
}

VI_feedback <- function(B, lambda) {
  1 / (lambda + 0.5 * (1 / B))
}

VR_feedback <- function(B, lambda) {
  lambda * B
}

t <- seq(0, 30, 0.5)

as_function_IRT <- data.frame(t = t,
                              p = c(VR_elapsed_time(t, 0.25),
                                    VI_elapsed_time(t, 0.25)),
                              s = rep(c("VR", "VI"), each = length(t)))


ggplot(data = as_function_IRT) +
  geom_line(aes(x = t, y = p, color = s),
            size = 2) +
  theme_classic() +
  theme(aspect.ratio = 1,
        legend.position = "none") +
  xlab("前の反応からの経過時間") +
  ylab("報酬確率") +
  font_config

ggsave("./VI_VR_IRT.jpg")

r <- seq(0, 30, 0.5)
feedback_function <- data.frame(t = r,
                                r = c(VR_feedback(r, 0.25), VI_feedback(r, 0.25)),
                                s = rep(c("VR", "VI"), each = length(r)))

ggplot(data = feedback_function) +
  geom_line(aes(x = t, y = r, color = s),
            size = 2) +
  theme_classic() +
  theme(aspect.ratio = 1,
        legend.position = "none") +
  xlab("時間あたりの反応数") +
  ylab("時間あたりの報酬数") +
  font_config

ggsave("./VI_VR_feedback.jpg")
