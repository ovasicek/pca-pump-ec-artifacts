% ----------------------------------------------------------------------------------------------------------------------
% starting a clinician requested bolus
% X5.3.0(1)

    % if requested, then start bolus
    or_happens(clinician_bolus_delivery_started(DurationMinutes), T) :- happens(clinician_bolus_requested_valid(DurationMinutes), T).
