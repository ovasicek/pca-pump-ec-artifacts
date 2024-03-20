% This version of the PCA pump model which no longer allows basal overdose

#include './model_sources/model-base.pl'.

% components of the model
#include './model_sources/06-max_dose-fixed.pl'.

#include './model_sources/06-selfend-complete_trigger-5_combine_1_2.pl'.
#include './model_sources/06-selfend-halt_trigger-5_combine_1_2.pl'.
