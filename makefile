RSCRIPT = Rscript

# if you wildcard the all-target, then nothing will happen if the target doesn't
# exist (no target). hard code the target.
WRITEUP = weighted-subposteriors.pdf

# I make way too many .tex files for this to function any other way
TEX_FILES = $(wildcard tex-input/*.tex) \
	$(wildcard tex-input/*/*.tex) \
	$(wildcard tex-input/*/*/*.tex)

PLOT_SETTINGS = scripts/common/plot-settings.R
PLOTS = plots/intro/subpost-disagreement.pdf \
	plots/norm-norm-ex/subposteriors.pdf \
	plots/norm-norm-ex/u-function-augmented-target.pdf \
	plots/norm-norm-ex/no-u/stage-traces.pdf \
	plots/norm-norm-ex/with-u/stage-traces.pdf \
	plots/norm-norm-ex/joint/trace.pdf \
	plots/norm-norm-ex/joint-augmented-compare.pdf \
	plots/norm-norm-ex/with-u-2/stage-traces.pdf

# intermediary rds files
SIM_PARS = rds/norm-norm-ex/sim-pars.rds
DATA_MODEL_ONE = rds/norm-norm-ex/data-model-one.rds
DATA_MODEL_TWO = rds/norm-norm-ex/data-model-two.rds


all : $(WRITEUP)

# knitr is becoming more picky about encoding, make it output utf-8
$(WRITEUP) : $(wildcard *.rmd) $(PLOTS) $(TEX_FILES)
	$(RSCRIPT) -e "rmarkdown::render(input = Sys.glob('*.rmd'), encoding = 'UTF-8')"

plots/intro/subpost-disagreement.pdf : scripts/intro/plot-subpost-disagreement.R $(PLOT_SETTINGS)
	$(RSCRIPT) $<

$(SIM_PARS) : scripts/norm-norm-ex/00-settings.R
	$(RSCRIPT) $<

$(DATA_MODEL_ONE) : scripts/norm-norm-ex/01-model-one-data-gen.R $(SIM_PARS)
	$(RSCRIPT) $<

$(DATA_MODEL_TWO) : scripts/norm-norm-ex/02-model-two-data-gen.R $(SIM_PARS)
	$(RSCRIPT) $<

plots/norm-norm-ex/subposteriors.pdf : scripts/norm-norm-ex/03-distribution-plotter.R $(DATA_MODEL_ONE) $(DATA_MODEL_TWO) $(SIM_PARS)
	$(RSCRIPT) $<

plots/norm-norm-ex/u-function-augmented-target.pdf	: plots/norm-norm-ex/subposteriors.pdf rds/norm-norm-ex/with-u-2/phi-samples-model-one.rds rds/norm-norm-ex/with-u-2/phi-samples-model-two.rds

# no-u melding
rds/norm-norm-ex/no-u/phi-samples-stage-one.rds : scripts/norm-norm-ex/no-u/stage-one-sampler.R $(SIM_PARS) $(DATA_MODEL_ONE) scripts/norm-norm-ex/stan-files/stage-one-target.stan
	$(RSCRIPT) $<

rds/norm-norm-ex/no-u/phi-samples-stage-two.rds : scripts/norm-norm-ex/no-u/stage-two-sampler.R rds/norm-norm-ex/no-u/phi-samples-stage-one.rds $(SIM_PARS) $(DATA_MODEL_TWO)
	$(RSCRIPT) $<

plots/norm-norm-ex/no-u/stage-traces.pdf : scripts/norm-norm-ex/no-u/plotter.R $(PLOT_SETTINGS) rds/norm-norm-ex/no-u/phi-samples-stage-one.rds rds/norm-norm-ex/no-u/phi-samples-stage-two.rds
	$(RSCRIPT) $<

# with-u melding
rds/norm-norm-ex/with-u/u-func-args.rds : scripts/norm-norm-ex/with-u/u-func-args.R $(DATA_MODEL_ONE) $(DATA_MODEL_TWO)
	$(RSCRIPT) $<

rds/norm-norm-ex/with-u/phi-samples-stage-one.rds : scripts/norm-norm-ex/with-u/stage-one-sampler.R $(SIM_PARS) $(DATA_MODEL_ONE) rds/norm-norm-ex/with-u/u-func-args.rds scripts/norm-norm-ex/stan-files/augmented-stage-one-target.stan
	$(RSCRIPT) $<

rds/norm-norm-ex/with-u/phi-samples-stage-two.rds : scripts/norm-norm-ex/with-u/stage-two-sampler.R $(SIM_PARS) $(DATA_MODEL_TWO) rds/norm-norm-ex/with-u/u-func-args.rds rds/norm-norm-ex/with-u/phi-samples-stage-one.rds
	$(RSCRIPT) $<

plots/norm-norm-ex/with-u/stage-traces.pdf : scripts/norm-norm-ex/with-u/plotter.R rds/norm-norm-ex/with-u/phi-samples-stage-one.rds rds/norm-norm-ex/with-u/phi-samples-stage-two.rds
	$(RSCRIPT) $<

# direct sampling of the joint
rds/norm-norm-ex/joint/phi-samples-joint.rds : scripts/norm-norm-ex/joint/joint-sampler.R $(SIM_PARS) $(DATA_MODEL_ONE) $(DATA_MODEL_TWO) scripts/norm-norm-ex/stan-files/melded-posterior.stan
	$(RSCRIPT) $<

plots/norm-norm-ex/joint/trace.pdf : scripts/norm-norm-ex/joint/plotter.R rds/norm-norm-ex/joint/phi-samples-joint.rds
	$(RSCRIPT) $<

# compare the joint at the augmented
plots/norm-norm-ex/joint-augmented-compare.pdf : scripts/norm-norm-ex/04-compare-with-u-and-joint.R $(PLOT_SETTINGS) rds/norm-norm-ex/joint/phi-samples-joint.rds rds/norm-norm-ex/with-u/phi-samples-stage-two.rds
	$(RSCRIPT) $<

# with-u-2
rds/norm-norm-ex/with-u-2/phi-samples-model-one.rds : scripts/norm-norm-ex/with-u-2/model-one-sampler.R $(SIM_PARS) $(DATA_MODEL_ONE) scripts/norm-norm-ex/stan-files/stage-one-target.stan
	$(RSCRIPT) $<

rds/norm-norm-ex/with-u-2/phi-samples-model-two.rds : scripts/norm-norm-ex/with-u-2/model-two-sampler.R $(SIM_PARS) $(DATA_MODEL_TWO) scripts/norm-norm-ex/stan-files/stage-one-target.stan
	$(RSCRIPT) $<

rds/norm-norm-ex/with-u-2/u-func-args.rds : scripts/norm-norm-ex/with-u-2/u-function-args.R rds/norm-norm-ex/with-u-2/phi-samples-model-one.rds rds/norm-norm-ex/with-u-2/phi-samples-model-two.rds
	$(RSCRIPT) $<

rds/norm-norm-ex/with-u-2/phi-samples-stage-one.rds : scripts/norm-norm-ex/with-u-2/augmented-stage-one-sampler.R $(SIM_PARS) $(DATA_MODEL_ONE) rds/norm-norm-ex/with-u-2/u-func-args.rds scripts/norm-norm-ex/stan-files/augmented-stage-one-target-two.stan
	$(RSCRIPT) $<

rds/norm-norm-ex/with-u-2/phi-samples-stage-two.rds : scripts/norm-norm-ex/with-u-2/stage-two-sampler.R $(SIM_PARS) $(DATA_MODEL_TWO) rds/norm-norm-ex/with-u-2/u-func-args.rds rds/norm-norm-ex/with-u-2/phi-samples-stage-one.rds
	$(RSCRIPT) $<

plots/norm-norm-ex/with-u-2/stage-traces.pdf : scripts/norm-norm-ex/with-u-2/plotter.R $(PLOT_SETTINGS) rds/norm-norm-ex/with-u-2/phi-samples-stage-one.rds rds/norm-norm-ex/with-u-2/phi-samples-stage-two.rds
	$(RSCRIPT) $<