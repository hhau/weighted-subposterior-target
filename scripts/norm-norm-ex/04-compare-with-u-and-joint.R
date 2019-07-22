library(tibble)
source("scripts/common/plot-settings.R")

joint_samples <- readRDS("rds/norm-norm-ex/joint/phi-samples-joint.rds")
with_u_stage_2_samples <- readRDS("rds/norm-norm-ex/with-u-2/phi-samples-stage-two.rds")

n_quantiles <- 100
quant_vec <- seq(from = 0, to = 1, length.out = n_quantiles)

joint_quantiles <- quantile(joint_samples, probs = quant_vec)
with_u_stage_2_quantiles <- quantile(with_u_stage_2_samples, probs = quant_vec)

plot_tbl <- tibble(
  joint_quaniltes = joint_quantiles,
  with_u_stage_2_quantiles = with_u_stage_2_quantiles  
)

p1 <- ggplot(plot_tbl, aes(x = joint_quantiles, y = with_u_stage_2_quantiles)) +
  geom_point() +
  geom_abline(slope = 1, intercept = 0) +
  xlab("Joint quantiles") +
  ylab("Augmented stage 1 target quantiles")

ggsave_halfheight(
  filename = "plots/norm-norm-ex/joint-augmented-compare.pdf",
  plot = p1
)