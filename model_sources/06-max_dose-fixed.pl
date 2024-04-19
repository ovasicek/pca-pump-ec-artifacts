%! a fixed version which uses the information about total_bolus_drug_delivered and assumes a full window of basal delivery
%  other source files needed to be extended with the logic for the total_bolus_drug_delivered(X) fluent


%----------------------------------------------------------------------------------------------------------------------%
% used to deny an requested patient bolus
shortcut_total_drug_in_max_dose_window_if_the_patient_bolus_would_be_delivered_starting_at_T(T, VtbiLimitTimePeriod, ResTotalDuringVtbiPeriodWithCurrentBolus) :-
    % check how much drug was delivered in the VTBI window up till now
    shortcut_patient_bolus_duration(BolusDuration),
    VtbiLimitTimePeriodMinusBolus .=. VtbiLimitTimePeriod - BolusDuration,  % prediction of VTBI window contents will be added with the bolus
    holdsAt(total_bolus_drug_delivered(CurrentTotalBolusDrug), T),                                                                      %! <<< diff
    shortcut_total_drug_in_vtbi_window_assume_basal(T, CurrentTotalBolusDrug, VtbiLimitTimePeriodMinusBolus, TotalDuringVtbiPeriod),    %! <<< diff
    % add portion of VTBI window during the patient bolus
    initiallyP(vtbi(BolusToDeliver)),
    initiallyP(basal_flow_rate(BasalRate)),
    ResTotalDuringVtbiPeriodWithCurrentBolus .=. TotalDuringVtbiPeriod + BolusToDeliver + (BolusDuration * BasalRate).

or_happens(max_dose_warning, T) :- %incremental_start_time(INCREMENT_T), T .>=. INCREMENT_T,
    happens(patient_bolus_requested_valid, T),
    % preemptive boluse denials due to max dose, dont need to trigger max dose becasue overdose would have been in the future (not immediate) % TODO
    % find the last start button press
    TLast .<. T,
    happens(start_button_pressed_valid, TLast),
    not_happensIn(start_button_pressed_valid, TLast, T),
    % find the start of the max dose window when considering a patient bolus
    initiallyP(vtbi_hard_limit_over_time(_, VtbiLimitTimePeriod)),
    shortcut_patient_bolus_duration(BolusDuration),
    WindowStartT .=. (T + BolusDuration) - VtbiLimitTimePeriod,
    __or_happens_max_dose_warning_pbolus(TLast, WindowStartT, BolusDuration),
    % original trigger
    happens(patient_bolus_denied_max_dose, T).
__or_happens_max_dose_warning_pbolus(TLast, WindowStartT, BolusDuration) :-
    % either the start button happened outside of the window
        TLast .=<. WindowStartT.
__or_happens_max_dose_warning_pbolus(TLast, WindowStartT, BolusDuration) :-
    % or it happened inside but would be triggered by the non-preemtive approach as well
        TLast .>. WindowStartT,
        initiallyP(basal_flow_rate(BasalRate)),
        MissingBasalDuration .=. TLast - WindowStartT,
        MissingBasal .=. MissingBasalDuration * BasalRate,
        initiallyP(vtbi(BolusToDeliver)),
        ToDeliver .=. BolusToDeliver + (BolusDuration * BasalRate),
        ToDeliver .>. MissingBasal.


%----------------------------------------------------------------------------------------------------------------------%
% used to halt an in-progress clinician bolus

or_happens(max_dose_warning, T) :- %incremental_start_time(INCREMENT_T), T .>=. INCREMENT_T,
    % original trigger
    happens(clinician_bolus_halted_max_dose, T),
    % preemptive boluse denials due to max dose, dont need to trigger max dose becasue overdose would have been in the future (not immediate) % TODO
    initiallyP(vtbi_hard_limit_over_time(_, VtbiLimitTimePeriod)),
    T2 .=. T - VtbiLimitTimePeriod,
    max(T2, 0, CroppedT2),
    not_happensIn(start_button_pressed_valid, CroppedT2, T).

shortcut_total_drug_in_max_dose_window_reaches_max_dose_during_clinician_bolus(T1, BolusDurationMinutes, T2) :-
    % split based on diference between T1 and T2 -- crucial to avoid non termination
    initiallyP(vtbi_hard_limit_over_time(VtbiLimit, VtbiLimitTimePeriod)),
    T2 .=<. T1 + VtbiLimitTimePeriod,
    % this is the trigger itself
    shortcut_total_drug_in_vtbi_window_assume_basal(T2, TotalBolus, VtbiLimitTimePeriod, TotalDuringVtbiPeriod),        %! <<< diff
    TotalDuringVtbiPeriod .=. VtbiLimit,
    holdsAt(total_bolus_drug_delivered(TotalBolus), T2, clinician_bolus_delivery_enabled(_)).                              %! <<< diff
shortcut_total_drug_in_max_dose_window_reaches_max_dose_during_clinician_bolus(T1, BolusDurationMinutes, T2) :-
    % split based on diference between T1 and T2 -- crucial to avoid non termination
    initiallyP(vtbi_hard_limit_over_time(VtbiLimit, VtbiLimitTimePeriod)),
    T2 .>. T1 + VtbiLimitTimePeriod,
    % this is the trigger itself
    % needs a different implementation of "shortcut_total_drug_in_vtbi_window_assume_basal"
        initiallyP(basal_flow_rate(BasalRate)),                                                                         %! <<< diff
        % figure out total_bolus_drug_delivered at the start of the max dose window
        TstartVtbiPeriod .=. T2 - VtbiLimitTimePeriod,
        max(TstartVtbiPeriod, 0, TstartVtbiPeriodCropped),
        TotalBolusDuringVtbiPeriod .=. TotalBolus - TotalBolusDrugAtStartPeriod,
        % assume a full window of basal delivery
        AssumedBasalDeliveredInVtbiPeriod .=. VtbiLimitTimePeriod * BasalRate,                                          %! <<< diff
        % put numbers together
        TotalDuringVtbiPeriod .=. TotalBolusDuringVtbiPeriod + AssumedBasalDeliveredInVtbiPeriod,                       %! <<< diff
    TotalDuringVtbiPeriod .=. VtbiLimit,
    holdsAt(total_bolus_drug_delivered(TotalBolusDrugAtStartPeriod), TstartVtbiPeriodCropped, clinician_bolus_delivery_enabled(_)), %! <<< diff
    holdsAt(total_bolus_drug_delivered(TotalBolus), T2, clinician_bolus_delivery_enabled(_)).                              %! <<< diff
