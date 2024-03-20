% R5.3.0(3) -- patient bolus has priority over clinician requested bolus (suspend the clinician bolus, and then resume after)

    % suspending a clinician bolus as a result of an allowed patient bolus request
    or_happens(clinician_bolus_suspended(OriginalDuration), T) :-
        happens(patient_bolus_delivery_started, T), holdsAt(clinician_bolus_delivery_enabled(OriginalDuration), T),
        not_happens(clinician_bolus_completed, T).    % treating events happening at the same time

    or_happens(clinician_bolus_delivery_stopped, T) :- happens(clinician_bolus_suspended(_), T).


    % flags to keep track of a suspended clinician bolus
    fluent(clinician_bolus_is_suspended(OriginalDuration)). % flag to know if a clinician bolus is currently suspended or no
        fluent(clinician_bolus_is_suspended).               % helper fluent
    fluent(clinician_bolus_suspended_drug_delivered(X)).    % remember how much drug did a clinician bolus deliver before it was suspended

    or_initiates(clinician_bolus_suspended(OriginalDuration), clinician_bolus_is_suspended(OriginalDuration), T).
    or_initiates(clinician_bolus_suspended(OriginalDuration), clinician_bolus_is_suspended, T).
    or_initiates(clinician_bolus_suspended(OriginalDuration), clinician_bolus_suspended_drug_delivered(DeliveredSoFar), T) :- holdsAt(clinician_bolus_drug_delivered(DeliveredSoFar), T).

    % clean clinician_bolus_suspended related fluents after patient bolus ends for any non standard reason (alarm, stop button, ...)
    or_terminates(patient_bolus_halted, clinician_bolus_is_suspended(OriginalDuration), T) :- holdsAt(clinician_bolus_is_suspended(OriginalDuration), T).
    or_terminates(patient_bolus_halted, clinician_bolus_is_suspended, T) :- holdsAt(clinician_bolus_is_suspended, T).
    or_terminates(patient_bolus_halted, clinician_bolus_suspended_drug_delivered(_), T) :- holdsAt(clinician_bolus_is_suspended(_), T).

    % resuming a clinician bolus when the patient bolus completed without any alarms etc.
    or_happens(clinician_bolus_delivery_started(OriginalDuration), T) :- happens(clinician_bolus_resumed(OriginalDuration), T). % TODO just renaming
    or_happens(clinician_bolus_resumed(OriginalDuration), T) :- happens(patient_bolus_completed, T),
        holdsAt(clinician_bolus_is_suspended(OriginalDuration), T).
