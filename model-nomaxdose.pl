% This version of the PCA pump model does not have any overdose protection measures

#include './model_sources/model-base.pl'.

% components of the model
#include './model_sources/06-max_dose-none.pl'.

#include './model_sources/06-selfend-complete_trigger-5_combine_1_2.pl'.
#include './model_sources/06-selfend-halt_trigger-5_combine_1_2.pl'.
