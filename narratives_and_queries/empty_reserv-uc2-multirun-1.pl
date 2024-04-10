#include './empty_reserv-uc2-base.pl'.

% first run query  ---------------------------------------------------------
%#TO FACT HAPPENS# basal_halted_low_reservoir
%#TO FACT HAPPENS# patient_bolus_halted_low_reservoir
%#TO FACT HAPPENS# clinician_bolus_halted_low_reservoir
%#TO FACT HAPPENS# clinician_bolus_halted_low_reservoir
    query :- happens(low_reservoir_warning, T).

    ?- query. % runtime: 
