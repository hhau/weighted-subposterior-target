library(tibble)
library(dplyr)
source("scripts/common/plot-settings.R")

phi_samples <- readRDS("rds/norm-norm-ex/joint/phi-samples-joint.rds")

plot_tibble <- tibble(
  x = 1 : length(phi_samples),
  y = phi_samples,
  stage = "joint"
)

p1 <- ggplot(plot_tibble, aes(x = x, y = y)) +
  geom_line() +
  facet_wrap(. ~ stage) +
  xlab("Iteration") +
  ylab(expression(phi))

ggsave_halfheight(
  filename = "plots/norm-norm-ex/joint/trace.pdf",
  plot = p1
)
