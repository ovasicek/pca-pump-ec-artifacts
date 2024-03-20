% This version of the PCA pump model which no longer allows basal overdose
%! the base model does not work on its own -- use ../model-fixed.pl or ../model-original.pl !

% event calculus axioms
#include '../ec_theory/bec_scasp-pca_pump.pl'.

% components of the model
#include './01-fluents.pl'.
#include './01-continuous_fluents.pl'.
#include './02-io_events.pl'.
#include './03-io_events-validity.pl'.
#include './04-basal_delivery_trajectory.pl'.
#include './04-clinician_bolus_trajectory.pl'.
#include './04-kvo_delivery_trajectory.pl'.
#include './04-patient_bolus_trajectory.pl'.
#include './04-pump_state.pl'.
#include './05-suspending_patient_bolus_request.pl'.
#include './06-total_drug_in_time_window.pl'.
#include './07-alarms.pl'.
#include './08-drug_reservoir.pl'.

% optional constraint rules to check narrative validity
% - make everything slower, and only check the narrative -- better to check narrative once and then reason without these
%#include './optional-check_inputs.pl'.
%#include './optional-restrict_input_events.pl'.

% preprocessed can_* rules
#include './model-base.pl-preprocessed.pl'.

% utility predicates/rules
#include '../model_utils/general_utils.pl'.
#include '../model_utils/narrative_check_queries.pl'.

% which predicates to show in the result model
#show happens/2.
#show holdsAt/2, initiallyN/1, initiallyP/1.
#show not_happens/2, not_holdsAt/2, not_happensIn/3, not_happensInInc/3.
#show trajectory/4.
#show selfend_trajectory/4.
%#show stoppedIn/3, startedIn/3, trajectory/4.
%#show initiates/3, terminates/3, releases/3.