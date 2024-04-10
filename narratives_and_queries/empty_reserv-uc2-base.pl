% demonstrating the slowdown caused by full drug reservoir reasoning using a narrative basedo nthe fixed version of ec20b

#include './init-partial-base.pl'.
#include './init-partial-maxdose.pl'.

initiallyP(initial_drug_reservoir_contents(8.5)).     % set contents so that it runs out at the right time

% narrative                     ----------------------------------------------------------------------------------------
or_happens(start_button_pressed,                    60).    % UC2
or_happens(patient_bolus_requested,                 120).   % UC2

or_happens(stop_button_pressed,                     6000).  % added for completeness

