library(tibble)
library(dplyr)
source("scripts/common/plot-settings.R")

stage_one_samples <- readRDS("rds/norm-norm-ex/no-u/phi-samples-stage-one.rds")
stage_two_samples <- readRDS("rds/norm-norm-ex/no-u/phi-samples-stage-two.rds")

plot_one_tibble <- tibble(
  x = 1 : length(stage_one_samples),
  y = stage_one_samples,
  stage = "one"
)

plot_two_tibble <- tibble(
  x = 1 : length(stage_two_samples),
  y = stage_two_samples,
  stage = "two"
)

combined_tibble <- bind_rows(
  plot_one_tibble,
  plot_two_tibble
)

p1 <- ggplot(combined_tibble, aes(x = x, y = y)) +
  geom_line() +
  facet_wrap(. ~ stage) +
  xlab("Iteration") +
  ylab(expression(phi))

ggsave_halfheight(
  filename = "plots/norm-norm-ex/no-u/stage-traces.pdf",
  plot = p1
)