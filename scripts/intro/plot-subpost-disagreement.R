library(dplyr)
source("scripts/common/plot-settings.R")

p_df <- data.frame(
  x = seq(from = -5, to = 11, length.out = 2)
)

p1 <- ggplot(p_df, aes(x = x)) +
  stat_function(fun = dnorm, aes(col = "p1"), n = 501) +
  stat_function(fun = dnorm, args = list(mean = 6), aes(col = "p2"), n = 501) +
  stat_function(fun = dnorm, args = list(mean = 3, sd = 0.5), aes(col = "pmeld"), n = 501) +
  stat_function(fun = dnorm, args = list(mean = 3, sd = 0.9), aes(col = "pz1_w1"), n = 501) +
  scale_colour_manual(
    labels = parsed_map(c(
      "p1" = "'p'[1](phi~'|'~'Y'[1])",
      "p2" = "'p'[2](phi~'|'~'Y'[2])",
      "pmeld" = "'p'['meld'](phi~'|'~'Y'[2],'Y'[1])",
      "pz1_w1" = "'p'[1](phi~'|'~'Y'[1])~'u'[1](phi~';'~eta[1])"
    )),
    values = c(
      "p1" = blues['mid'] %>% as.character(),
      "p2" = blues['dark'] %>% as.character(),
      "pmeld" = highlight_col,
      "pz1_w1" = greens[2]
    )
  ) +
  scale_linetype_manual( # this does nothing
    values = c(
      "p1" = "solid",
      "p2" = "solid",
      "pmeld" = "solid",
      "pz1_w1" = "dashed"
    )
  ) +
  labs(col = "Density") +
  ylab("") + 
  xlab(expression(phi)) +
  NULL

ggsave_halfheight(
  filename = "plots/intro/subpost-disagreement.pdf",
  plot = p1
)