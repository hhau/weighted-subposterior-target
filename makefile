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

# base things - do better at this in the future
NORM_NORM_EX = scripts/norm-norm-ex
NORM_STAN_FILES = $(NORM_NORM_EX)/stan-files

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
RDS_NO_U = rds/norm-norm-ex/no-u
PLOTS_NO_U = plots/norm-norm-ex/no-u
SCRIPTS_NO_U = scripts/norm-norm-ex/no-u

$(RDS_NO_U)/phi-samples-stage-one.rds : $(SCRIPTS_NO_U)/stage-one-sampler.R $(SIM_PARS) $(DATA_MODEL_ONE) $(NORM_STAN_FILES)/stage-one-target.stan
	$(RSCRIPT) $<

$(RDS_NO_U)/phi-samples-stage-two.rds : $(SCRIPTS_NO_U)/stage-two-sampler.R $(RDS_NO_U)/phi-samples-stage-one.rds $(SIM_PARS) $(DATA_MODEL_TWO)
	$(RSCRIPT) $<

$(PLOTS_NO_U)/stage-traces.pdf : $(SCRIPTS_NO_U)/plotter.R $(PLOT_SETTINGS) $(RDS_NO_U)/phi-samples-stage-one.rds $(RDS_NO_U)/phi-samples-stage-two.rds
	$(RSCRIPT) $<

# with-u melding
RDS_WITH_U = rds/norm-norm-ex/with-u
PLOTS_WITH_U = plots/norm-norm-ex/with-u
SCRIPTS_WITH_U = scripts/norm-norm-ex/with-u

$(RDS_WITH_U)/u-func-args.rds : $(SCRIPTS_WITH_U)/u-func-args.R $(DATA_MODEL_ONE) $(DATA_MODEL_TWO)
	$(RSCRIPT) $<

$(RDS_WITH_U)/phi-samples-stage-one.rds : $(SCRIPTS_WITH_U)/stage-one-sampler.R $(SIM_PARS) $(DATA_MODEL_ONE) $(RDS_WITH_U)/u-func-args.rds $(NORM_STAN_FILES)/augmented-stage-one-target.stan
	$(RSCRIPT) $<

$(RDS_WITH_U)/phi-samples-stage-two.rds : $(SCRIPTS_WITH_U)/stage-two-sampler.R $(SIM_PARS) $(DATA_MODEL_TWO) $(RDS_WITH_U)/u-func-args.rds $(RDS_WITH_U)/phi-samples-stage-one.rds
	$(RSCRIPT) $<

$(PLOTS_WITH_U)/stage-traces.pdf : $(SCRIPTS_WITH_U)/plotter.R $(RDS_WITH_U)/phi-samples-stage-one.rds $(RDS_WITH_U)/phi-samples-stage-two.rds
	$(RSCRIPT) $<

# direct sampling of the joint
RDS_JOINT = rds/norm-norm-ex/joint
PLOTS_JOINT = plots/norm-norm-ex/joint
SCRIPTS_JOINT = scripts/norm-norm-ex/joint

$(RDS_JOINT)/phi-samples-joint.rds : $(SCRIPTS_JOINT)/joint-sampler.R $(SIM_PARS) $(DATA_MODEL_ONE) $(DATA_MODEL_TWO) $(NORM_STAN_FILES)/melded-posterior.stan
	$(RSCRIPT) $<

$(PLOTS_JOINT)/trace.pdf : $(SCRIPTS_JOINT)/plotter.R $(RDS_JOINT)/phi-samples-joint.rds
	$(RSCRIPT) $<

# compare the joint at the augmented
plots/norm-norm-ex/joint-augmented-compare.pdf : scripts/norm-norm-ex/04-compare-with-u-and-joint.R $(PLOT_SETTINGS) $(RDS_JOINT)/phi-samples-joint.rds rds/norm-norm-ex/with-u-2/phi-samples-stage-two.rds
	$(RSCRIPT) $<

# with-u-2
RDS_WITH_U_2 = rds/norm-norm-ex/with-u-2
PLOTS_WITH_U_2 = plots/norm-norm-ex/with-u-2
SCRIPTS_WITH_U_2 = scripts/norm-norm-ex/with-u-2

$(RDS_WITH_U_2)/phi-samples-model-one.rds : $(SCRIPTS_WITH_U_2)/model-one-sampler.R $(SIM_PARS) $(DATA_MODEL_ONE) $(NORM_STAN_FILES)/stage-one-target.stan
	$(RSCRIPT) $<

$(RDS_WITH_U_2)/phi-samples-model-two.rds : $(SCRIPTS_WITH_U_2)/model-two-sampler.R $(SIM_PARS) $(DATA_MODEL_TWO) $(NORM_STAN_FILES)/stage-one-target.stan
	$(RSCRIPT) $<

$(RDS_WITH_U_2)/u-func-args.rds : $(SCRIPTS_WITH_U_2)/u-function-args.R $(RDS_WITH_U_2)/phi-samples-model-one.rds $(RDS_WITH_U_2)/phi-samples-model-two.rds
	$(RSCRIPT) $<

$(RDS_WITH_U_2)/phi-samples-stage-one.rds : $(SCRIPTS_WITH_U_2)/augmented-stage-one-sampler.R $(SIM_PARS) $(DATA_MODEL_ONE) $(RDS_WITH_U_2)/u-func-args.rds $(NORM_STAN_FILES)/augmented-stage-one-target-two.stan
	$(RSCRIPT) $<

$(RDS_WITH_U_2)/phi-samples-stage-two.rds : $(SCRIPTS_WITH_U_2)/stage-two-sampler.R $(SIM_PARS) $(DATA_MODEL_TWO) $(RDS_WITH_U_2)/u-func-args.rds $(RDS_WITH_U_2)/phi-samples-stage-one.rds
	$(RSCRIPT) $<

$(PLOTS_WITH_U_2)/stage-traces.pdf : $(SCRIPTS_WITH_U_2)/plotter.R $(PLOT_SETTINGS) $(RDS_WITH_U_2)/phi-samples-stage-one.rds $(RDS_WITH_U_2)/phi-samples-stage-two.rds
	$(RSCRIPT) $<