% ----------------------------------------------------------------------------------------------------------------------
% drug reservoir                ----------------------------------------------------------------------------------------

% NOTE
% - avoiding infinite loops by using the self-ending trajectory approach (similar to triggering bolus completed)
% - unfortunately, reasoning about reservoir warning/alarm was causing a masive slowdown --> decided to make it optional and usable in a two run approach
%   - the two run approach splits the trigger and the effect of the warning/alarm and achieves a huge speedup


% R6.8.0(2) -- measure the amout of drug in drug reservoir
    or_holdsAt(drug_reservoir_contents(DrugLeft), T) :-
        initiallyP(initial_drug_reservoir_contents(StartingDrug)), holdsAt(total_drug_delivered(UsedDrug), T),
        DrugLeft .=. StartingDrug - UsedDrug.

% R6.8.0(10), R7.2.0(7)
    event(empty_reservoir_alarm_EFFECT).
    or_happens(empty_reservoir_alarm_EFFECT, T) :- %incremental_start_time(INCREMENT_T), T .>=. INCREMENT_T,
        empty_reservoir_reasoning_enabled, happens(empty_reservoir_alarm, T).

    %or_happens(alarm_to_off, T) :- happens(empty_reservoir_alarm, T). % this is not in the model on purpose -- would cause loops in a single run query

    % empty reservoir at start % TODO
    or_happens(empty_reservoir_alarm, T) :- %incremental_start_time(INCREMENT_T), T .>=. INCREMENT_T,
        happens(start_button_pressed_valid, T), initiallyP(empty_reservoir_treshold(Threshold)), DrugLeft .=<. Threshold, holdsAt(drug_reservoir_contents(DrugLeft), T).

    %! avoiding infinite loops by using the self-ending trajectory approach (similar to triggering bolus completed)
    % empty reservoir during kvo delivery (there always has to be a switch to KVO due to a low reservoir warning)
    or_happens(kvo_halted_empty_reservoir, T) :- %incremental_start_time(INCREMENT_T), T .>=. INCREMENT_T,
        T2 .<. T,
        happens(low_reservoir_warning_EFFECT, T2),
        initiallyP(empty_reservoir_treshold(Threshold)),
        initiallyP(initial_drug_reservoir_contents(StartingDrug)),
        Threshold .=. StartingDrug - UsedDrug,
        holdsAt(total_drug_delivered(UsedDrug), T, kvo_delivery_enabled).
        
    or_happens(empty_reservoir_alarm, T) :- %incremental_start_time(INCREMENT_T), T .>=. INCREMENT_T,
        happens(kvo_halted_empty_reservoir, T).
    or_happens(kvo_delivery_stopped, T) :- %incremental_start_time(INCREMENT_T), T .>=. INCREMENT_T,
        happens(empty_reservoir_alarm_EFFECT, T).
    or_happens(pump_stopped, T) :- %incremental_start_time(INCREMENT_T), T .>=. INCREMENT_T,
        happens(empty_reservoir_alarm_EFFECT, T).


% R6.8.0(9)
    event(low_reservoir_warning_EFFECT).
    event(basal_halted_low_reservoir_EFFECT).
    event(patient_bolus_halted_low_reservoir_EFFECT).
    event(clinician_bolus_halted_low_reservoir_EFFECT).
    event(kvo_low_reservoir_EFFECT).
    or_happens(basal_halted_low_reservoir_EFFECT, T) :- %incremental_start_time(INCREMENT_T), T .>=. INCREMENT_T,
        low_reservoir_reasoning_enabled, happens(basal_halted_low_reservoir, T).
    or_happens(patient_bolus_halted_low_reservoir_EFFECT, T) :- %incremental_start_time(INCREMENT_T), T .>=. INCREMENT_T,
        low_reservoir_reasoning_enabled, happens(patient_bolus_halted_low_reservoir, T).
    or_happens(clinician_bolus_halted_low_reservoir_EFFECT, T) :- %incremental_start_time(INCREMENT_T), T .>=. INCREMENT_T,
        low_reservoir_reasoning_enabled, happens(clinician_bolus_halted_low_reservoir, T).
    or_happens(kvo_low_reservoir_EFFECT, T) :- %incremental_start_time(INCREMENT_T), T .>=. INCREMENT_T,
        low_reservoir_reasoning_enabled, happens(kvo_low_reservoir, T).

    %or_happens(alarm_to_kvo, T) :- happens(low_reservoir_warning, T). % this is not in the model on purpose -- would cause loops in a single run query

    % low reservoir at start % TODO
    or_happens(low_reservoir_warning, T) :- %incremental_start_time(INCREMENT_T), T .>=. INCREMENT_T,
        happens(start_button_pressed_valid, T), initiallyP(empty_reservoir_treshold(EmptyThreshold)), initiallyP(low_reservoir_treshold(LowThreshold)),
        DrugLeft .=<. LowThreshold, DrugLeft .>. EmptyThreshold, holdsAt(drug_reservoir_contents(DrugLeft), T).  % TODO ".>." to not have low and empty at the same time --> is this correct?


    %! avoiding infinite loops by using the self-ending trajectory approach (similar to triggering bolus completed)
    % low reservoir during basal delivery
    or_happens(basal_halted_low_reservoir, T) :- %incremental_start_time(INCREMENT_T), T .>=. INCREMENT_T,
        initiallyP(low_reservoir_treshold(Threshold)),
        initiallyP(initial_drug_reservoir_contents(StartingDrug)),
        Threshold .=. StartingDrug - UsedDrug,
        holdsAt(total_drug_delivered(UsedDrug), T, basal_delivery_enabled).
        
    or_happens(low_reservoir_warning, T) :- %incremental_start_time(INCREMENT_T), T .>=. INCREMENT_T,
        happens(basal_halted_low_reservoir, T).
    or_happens(low_reservoir_warning_EFFECT, T) :- %incremental_start_time(INCREMENT_T), T .>=. INCREMENT_T,
        happens(basal_halted_low_reservoir_EFFECT, T).
    or_happens(basal_delivery_stopped, T) :- %incremental_start_time(INCREMENT_T), T .>=. INCREMENT_T,
        happens(basal_halted_low_reservoir_EFFECT, T).
    or_happens(kvo_delivery_started, T) :- %incremental_start_time(INCREMENT_T), T .>=. INCREMENT_T,
        happens(basal_halted_low_reservoir_EFFECT, T).
    

    % low reservoir during patient bolus delivery
    or_happens(patient_bolus_halted_low_reservoir, T) :- %incremental_start_time(INCREMENT_T), T .>=. INCREMENT_T,
        initiallyP(low_reservoir_treshold(Threshold)),
        initiallyP(initial_drug_reservoir_contents(StartingDrug)),
        Threshold .=. StartingDrug - UsedDrug,
        holdsAt(total_drug_delivered(UsedDrug), T, patient_bolus_delivery_enabled).
        
    or_happens(low_reservoir_warning, T) :- %incremental_start_time(INCREMENT_T), T .>=. INCREMENT_T,
        happens(patient_bolus_halted_low_reservoir, T).
    or_happens(low_reservoir_warning_EFFECT, T) :- %incremental_start_time(INCREMENT_T), T .>=. INCREMENT_T,
        happens(patient_bolus_halted_low_reservoir_EFFECT, T).
    or_happens(patient_bolus_delivery_stopped, T) :- %incremental_start_time(INCREMENT_T), T .>=. INCREMENT_T,
        happens(patient_bolus_halted_low_reservoir_EFFECT, T).
    or_happens(kvo_delivery_started, T) :- %incremental_start_time(INCREMENT_T), T .>=. INCREMENT_T,
        happens(patient_bolus_halted_low_reservoir_EFFECT, T).
    

    % low reservoir during clinician bolus delivery
    or_happens(clinician_bolus_halted_low_reservoir, T) :- %incremental_start_time(INCREMENT_T), T .>=. INCREMENT_T,
        initiallyP(low_reservoir_treshold(Threshold)),
        initiallyP(initial_drug_reservoir_contents(StartingDrug)),
        Threshold .=. StartingDrug - UsedDrug,
        holdsAt(total_drug_delivered(UsedDrug), T, clinician_bolus_delivery_enabled(_)).

    or_happens(low_reservoir_warning, T) :- %incremental_start_time(INCREMENT_T), T .>=. INCREMENT_T,
        happens(clinician_bolus_halted_low_reservoir, T).
    or_happens(low_reservoir_warning_EFFECT, T) :- %incremental_start_time(INCREMENT_T), T .>=. INCREMENT_T,
        happens(clinician_bolus_halted_low_reservoir_EFFECT, T).
    or_happens(clinician_bolus_delivery_stopped, T) :- %incremental_start_time(INCREMENT_T), T .>=. INCREMENT_T,
        happens(clinician_bolus_halted_low_reservoir_EFFECT, T).
    or_happens(kvo_delivery_started, T) :- %incremental_start_time(INCREMENT_T), T .>=. INCREMENT_T,
        happens(clinician_bolus_halted_low_reservoir_EFFECT, T).
    

    % low reservoir during kvo delivery
    or_happens(kvo_low_reservoir, T) :- %incremental_start_time(INCREMENT_T), T .>=. INCREMENT_T,
        initiallyP(low_reservoir_treshold(Threshold)),
        initiallyP(initial_drug_reservoir_contents(StartingDrug)),
        Threshold .=. StartingDrug - UsedDrug,
        holdsAt(total_drug_delivered(UsedDrug), T, kvo_delivery_enabled).
        
    or_happens(low_reservoir_warning, T) :- %incremental_start_time(INCREMENT_T), T .>=. INCREMENT_T,
        happens(kvo_low_reservoir, T).
    or_happens(low_reservoir_warning_EFFECT, T) :- %incremental_start_time(INCREMENT_T), T .>=. INCREMENT_T,
        happens(kvo_low_reservoir_EFFECT, T).
