% My attempt at implementing the PCA pump system based on its specification
%   - contains a basal overdose issue

#include './model_sources/model-base.pl'.

% components of the model
#include './model_sources/06-max_dose-original.pl'.

#include './model_sources/06-selfend-complete_trigger-5_combine_1_2.pl'.
#include './model_sources/06-selfend-halt_trigger-5_combine_1_2.pl'.