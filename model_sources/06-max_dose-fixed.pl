%! a fixed version which uses the information about total_bolus_drug_delivered and assumes a full window of basal delivery
%  other source files needed to be extended with the logic for the total_bolus_drug_delivered(X) fluent

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


%----------------------------------------------------------------------------------------------------------------------%
% used to halt an in-progress clinician bolus
% TODO many different rules for different versions of the halt trigger rule

% used in 06-selfend-halt_trigger-0_loop.pl
shortcut_total_drug_in_max_dose_window_reaches_max_dose_during_clinician_bolus__0_loop(T1, BolusDurationMinutes, T2) :-
    % split based on diference between T1 and T2 -- crucial to avoid non termination
    initiallyP(vtbi_hard_limit_over_time(VtbiLimit, VtbiLimitTimePeriod)),
    T2 .=<. T1 + VtbiLimitTimePeriod,
    % this is the trigger itself
    shortcut_total_drug_in_vtbi_window_assume_basal(T2, TotalBolus, VtbiLimitTimePeriod, TotalDuringVtbiPeriod),        %! <<< diff
    TotalDuringVtbiPeriod .=. VtbiLimit,
    holdsAt(total_bolus_drug_delivered(TotalBolus), T2).                                                                %! <<< diff
shortcut_total_drug_in_max_dose_window_reaches_max_dose_during_clinician_bolus__0_loop(T1, BolusDurationMinutes, T2) :-
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
    holdsAt(total_bolus_drug_delivered(TotalBolusDrugAtStartPeriod), TstartVtbiPeriodCropped),                          %! <<< diff
    holdsAt(total_bolus_drug_delivered(TotalBolus), T2).                                                                %! <<< diff


% used in 06-selfend-halt_trigger-1_dedicated_fluent.pl
shortcut_total_drug_in_max_dose_window_reaches_max_dose_during_clinician_bolus__1_dedicated_fluent(T1, BolusDurationMinutes, T2) :-
    % split based on diference between T1 and T2 -- crucial to avoid non termination
    initiallyP(vtbi_hard_limit_over_time(VtbiLimit, VtbiLimitTimePeriod)),
    T2 .=<. T1 + VtbiLimitTimePeriod,
    % this is the trigger itself
    shortcut_total_drug_in_vtbi_window_assume_basal(T2, TotalBolus, VtbiLimitTimePeriod, TotalDuringVtbiPeriod),        %! <<< diff
    TotalDuringVtbiPeriod .=. VtbiLimit,
    % approach 1 -- using a dedicated fluent
    holdsAt(clinician_bolus_total_bolus_drug_delivered(TotalBolus), T2). % dedicated fluent                             %! <<< diff
shortcut_total_drug_in_max_dose_window_reaches_max_dose_during_clinician_bolus__1_dedicated_fluent(T1, BolusDurationMinutes, T2) :-
    % split based on diference between T1 and T2 -- crucial to avoid non termination
    initiallyP(vtbi_hard_limit_over_time(VtbiLimit, VtbiLimitTimePeriod)),
    T2 .>. T1 + VtbiLimitTimePeriod,
    % this is the trigger itself
    % needs a different implementation of "shortcut_total_drug_in_vtbi_window_assume_basal"
        initiallyP(basal_flow_rate(BasalRate)),                                                                         %! <<< diff
        % figure out clinician_bolus_total_bolus_drug_delivered at the start of the max dose window
        TstartVtbiPeriod .=. T2 - VtbiLimitTimePeriod,
        max(TstartVtbiPeriod, 0, TstartVtbiPeriodCropped),
        TotalBolusDuringVtbiPeriod .=. TotalBolus - TotalBolusDrugAtStartPeriod,
        % assume a full window of basal delivery
        AssumedBasalDeliveredInVtbiPeriod .=. VtbiLimitTimePeriod * BasalRate,                                          %! <<< diff
        % put numbers together
        TotalDuringVtbiPeriod .=. TotalBolusDuringVtbiPeriod + AssumedBasalDeliveredInVtbiPeriod,                       %! <<< diff
    TotalDuringVtbiPeriod .=. VtbiLimit,
    % approach 1 -- using dedicated fluents
    holdsAt(clinician_bolus_total_bolus_drug_delivered(TotalBolusDrugAtStartPeriod), TstartVtbiPeriodCropped), % dedicated fluent %! <<< diff
    holdsAt(clinician_bolus_total_bolus_drug_delivered(TotalBolus), T2). % dedicated fluent                             %! <<< diff


% used in 06-selfend-halt_trigger-2_plan_into_future.pl
shortcut_total_drug_in_max_dose_window_reaches_max_dose_during_clinician_bolus__2_plan_into_future(T1, BolusDurationMinutes, T2) :-
    % split based on diference between T1 and T2 -- crucial to avoid non termination
    initiallyP(vtbi_hard_limit_over_time(VtbiLimit, VtbiLimitTimePeriod)),
    T2 .=<. T1 + VtbiLimitTimePeriod,
    % approach 2 -- using a trajectory definition to look into the future
    trajectory(clinician_bolus_delivery_enabled(BolusDurationMinutes), T1, total_bolus_drug_delivered(TotalBolus), T2), %! <<< diff  %//NO_PREPROCESS
    % this is the trigger itself
    shortcut_total_drug_in_vtbi_window_assume_basal(T2, TotalBolus, VtbiLimitTimePeriod, TotalDuringVtbiPeriod),        %! <<< diff
    TotalDuringVtbiPeriod .=. VtbiLimit,
    holdsAt(total_bolus_drug_delivered(TotalBolus), T2).                              %! <<< diff
shortcut_total_drug_in_max_dose_window_reaches_max_dose_during_clinician_bolus__2_plan_into_future(T1, BolusDurationMinutes, T2) :-
    % split based on diference between T1 and T2 -- crucial to avoid non termination
    initiallyP(vtbi_hard_limit_over_time(VtbiLimit, VtbiLimitTimePeriod)),
    T2 .>. T1 + VtbiLimitTimePeriod,
    % approach 2 -- using a trajectory definition to look into the future
    trajectory(clinician_bolus_delivery_enabled(BolusDurationMinutes), T1, total_bolus_drug_delivered(TotalBolus), T2), %! <<< diff  %//NO_PREPROCESS
    % this is the trigger itself
    % needs a different implementation of "shortcut_total_drug_in_vtbi_window_assume_basal"
        initiallyP(basal_flow_rate(BasalRate)),                                                                         %! <<< diff
        % figure out total_bolus_drug_delivered at the start of the max dose window
        TstartVtbiPeriod .=. T2 - VtbiLimitTimePeriod,
        max(TstartVtbiPeriod, 0, TstartVtbiPeriodCropped),
        % approach 2 -- using a trajectory definition to look into the future
        trajectory(clinician_bolus_delivery_enabled(BolusDurationMinutes), T1, total_bolus_drug_delivered(TotalBolusDrugAtStartPeriod), TstartVtbiPeriodCropped), %! <<< diff  %//NO_PREPROCESS 
        TotalBolusDuringVtbiPeriod .=. TotalBolus - TotalBolusDrugAtStartPeriod,
        % assume a full window of basal delivery
        AssumedBasalDeliveredInVtbiPeriod .=. VtbiLimitTimePeriod * BasalRate,                                          %! <<< diff
        % put numbers together
        TotalDuringVtbiPeriod .=. TotalBolusDuringVtbiPeriod + AssumedBasalDeliveredInVtbiPeriod,                       %! <<< diff
    TotalDuringVtbiPeriod .=. VtbiLimit,
    holdsAt(total_bolus_drug_delivered(TotalBolusDrugAtStartPeriod), TstartVtbiPeriodCropped), %! <<< diff
    holdsAt(total_bolus_drug_delivered(TotalBolus), T2).                              %! <<< diff


% used in 06-selfend-halt_trigger-3_selfend_trigger_axiom.pl
shortcut_total_drug_in_max_dose_window_reaches_max_dose_during_clinician_bolus__3_selfed_trigger_axiom(T1, BolusDurationMinutes, T2) :-
    % split based on diference between T1 and T2 -- crucial to avoid non termination
    initiallyP(vtbi_hard_limit_over_time(VtbiLimit, VtbiLimitTimePeriod)),
    T2 .=<. T1 + VtbiLimitTimePeriod,
    % approach 3 -- trajectory definition, and then no holdsAt at the end is needed
    trajectory(clinician_bolus_delivery_enabled(BolusDurationMinutes), T1, total_bolus_drug_delivered(TotalBolus), T2), %! <<< diff  %//NO_PREPROCESS
    shortcut_total_drug_in_vtbi_window_assume_basal(T2, TotalBolus, VtbiLimitTimePeriod, TotalDuringVtbiPeriod),        %! <<< diff
    TotalDuringVtbiPeriod .=. VtbiLimit.
shortcut_total_drug_in_max_dose_window_reaches_max_dose_during_clinician_bolus__3_selfed_trigger_axiom(T1, BolusDurationMinutes, T2) :-
    % split based on diference between T1 and T2 -- crucial to avoid non termination
    initiallyP(vtbi_hard_limit_over_time(VtbiLimit, VtbiLimitTimePeriod)),
    T2 .>. T1 + VtbiLimitTimePeriod,
    % trajectory and then no holdsAt
    trajectory(clinician_bolus_delivery_enabled(BolusDurationMinutes), T1, total_bolus_drug_delivered(TotalBolus), T2), %! <<< diff  %//NO_PREPROCESS
    % needs a different implementation of "shortcut_total_drug_in_vtbi_window_assume_basal"
        initiallyP(basal_flow_rate(BasalRate)),                                                                         %! <<< diff
        % figure out total_bolus_drug_delivered at the start of the max dose window
        TstartVtbiPeriod .=. T2 - VtbiLimitTimePeriod,
        max(TstartVtbiPeriod, 0, TstartVtbiPeriodCropped),
        % approach 3 -- trajectory definition, and then no holdsAt at the end is needed
        trajectory(clinician_bolus_delivery_enabled(BolusDurationMinutes), T1, total_bolus_drug_delivered(TotalBolusDrugAtStartPeriod), TstartVtbiPeriodCropped), %! <<< diff  %//NO_PREPROCESS 
        TotalBolusDuringVtbiPeriod .=. TotalBolus - TotalBolusDrugAtStartPeriod,
        % assume a full window of basal delivery
        AssumedBasalDeliveredInVtbiPeriod .=. VtbiLimitTimePeriod * BasalRate,                                          %! <<< diff
        % put numbers together
        TotalDuringVtbiPeriod .=. TotalBolusDuringVtbiPeriod + AssumedBasalDeliveredInVtbiPeriod,                       %! <<< diff
    TotalDuringVtbiPeriod .=. VtbiLimit.


% used in 06-selfend-halt_trigger-4_holdsAt3_axiom.pl
shortcut_total_drug_in_max_dose_window_reaches_max_dose_during_clinician_bolus__4_holdsAt3_axiom(T1, BolusDurationMinutes, T2) :-
    % split based on diference between T1 and T2 -- crucial to avoid non termination
    initiallyP(vtbi_hard_limit_over_time(VtbiLimit, VtbiLimitTimePeriod)),
    T2 .=<. T1 + VtbiLimitTimePeriod,
    % this is the trigger itself
    shortcut_total_drug_in_vtbi_window_assume_basal(T2, TotalBolus, VtbiLimitTimePeriod, TotalDuringVtbiPeriod),        %! <<< diff
    TotalDuringVtbiPeriod .=. VtbiLimit,
    holdsAt(total_bolus_drug_delivered(TotalBolus), T2, clinician_bolus_delivery_enabled(_)).                              %! <<< diff
shortcut_total_drug_in_max_dose_window_reaches_max_dose_during_clinician_bolus__4_holdsAt3_axiom(T1, BolusDurationMinutes, T2) :-
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


% used in 06-selfend-halt_trigger-5_combine_1_2.pl
%   - order of last two goals is crucial to avoid non-termination
%   - querying holdsAt of dedicated fluent is crucial to avoid non-termination
shortcut_total_drug_in_max_dose_window_reaches_max_dose_during_clinician_bolus__5_combine_1_2(T1, BolusDurationMinutes, T2) :-
    % split based on diference between T1 and T2 -- crucial to avoid non termination
    initiallyP(vtbi_hard_limit_over_time(VtbiLimit, VtbiLimitTimePeriod)),
    T2 .=<. T1 + VtbiLimitTimePeriod,
    % approach 2 -- using a trajectory definition to look into the future
    trajectory(clinician_bolus_delivery_enabled(BolusDurationMinutes), T1, clinician_bolus_total_bolus_drug_delivered(TotalBolus), T2), %! <<< diff  %//NO_PREPROCESS
    % this is the trigger itself
    shortcut_total_drug_in_vtbi_window_assume_basal(T2, TotalBolus, VtbiLimitTimePeriod, TotalDuringVtbiPeriod),        %! <<< diff
    TotalDuringVtbiPeriod .=. VtbiLimit,
    % approach 1 -- using a dedicated fluent
    holdsAt(clinician_bolus_total_bolus_drug_delivered(TotalBolus), T2). % dedicated fluent                             %! <<< diff
shortcut_total_drug_in_max_dose_window_reaches_max_dose_during_clinician_bolus__5_combine_1_2(T1, BolusDurationMinutes, T2) :-
    % split based on diference between T1 and T2 -- crucial to avoid non termination
    initiallyP(vtbi_hard_limit_over_time(VtbiLimit, VtbiLimitTimePeriod)),
    T2 .>. T1 + VtbiLimitTimePeriod,
    % approach 2 -- using a trajectory definition to look into the future
    trajectory(clinician_bolus_delivery_enabled(BolusDurationMinutes), T1, clinician_bolus_total_bolus_drug_delivered(TotalBolus), T2), %! <<< diff  %//NO_PREPROCESS
    % this is the trigger itself
    % needs a different implementation of "shortcut_total_drug_in_vtbi_window_assume_basal"
        initiallyP(basal_flow_rate(BasalRate)),                                                                         %! <<< diff
        % figure out clinician_bolus_total_bolus_drug_delivered at the start of the max dose window
        TstartVtbiPeriod .=. T2 - VtbiLimitTimePeriod,
        max(TstartVtbiPeriod, 0, TstartVtbiPeriodCropped),
        % approach 2 -- using a trajectory definition to look into the future
        trajectory(clinician_bolus_delivery_enabled(BolusDurationMinutes), T1, clinician_bolus_total_bolus_drug_delivered(TotalBolusDrugAtStartPeriod), TstartVtbiPeriodCropped), %! <<< diff  %//NO_PREPROCESS 
        TotalBolusDuringVtbiPeriod .=. TotalBolus - TotalBolusDrugAtStartPeriod,
        % assume a full window of basal delivery
        AssumedBasalDeliveredInVtbiPeriod .=. VtbiLimitTimePeriod * BasalRate,                                          %! <<< diff
        % put numbers together
        TotalDuringVtbiPeriod .=. TotalBolusDuringVtbiPeriod + AssumedBasalDeliveredInVtbiPeriod,                       %! <<< diff
    TotalDuringVtbiPeriod .=. VtbiLimit,
    % approach 1 -- using dedicated fluents
    holdsAt(clinician_bolus_total_bolus_drug_delivered(TotalBolusDrugAtStartPeriod), TstartVtbiPeriodCropped), % dedicated fluent %! <<< diff
    holdsAt(clinician_bolus_total_bolus_drug_delivered(TotalBolus), T2). % dedicated fluent                             %! <<< diff


% used in 06-selfend-halt_trigger-6_combine_1_3.pl
shortcut_total_drug_in_max_dose_window_reaches_max_dose_during_clinician_bolus__6_combine_1_3(T1, BolusDurationMinutes, T2) :-
    % split based on diference between T1 and T2 -- crucial to avoid non termination
    initiallyP(vtbi_hard_limit_over_time(VtbiLimit, VtbiLimitTimePeriod)),
    T2 .=<. T1 + VtbiLimitTimePeriod,
    % approach 3 -- trajectory definition, and then no holdsAt at the end is needed
    trajectory(clinician_bolus_delivery_enabled(BolusDurationMinutes), T1, clinician_bolus_total_bolus_drug_delivered(TotalBolus), T2), %! <<< diff  %//NO_PREPROCESS
    shortcut_total_drug_in_vtbi_window_assume_basal(T2, TotalBolus, VtbiLimitTimePeriod, TotalDuringVtbiPeriod),        %! <<< diff
    TotalDuringVtbiPeriod .=. VtbiLimit.
shortcut_total_drug_in_max_dose_window_reaches_max_dose_during_clinician_bolus__6_combine_1_3(T1, BolusDurationMinutes, T2) :-
    % split based on diference between T1 and T2 -- crucial to avoid non termination
    initiallyP(vtbi_hard_limit_over_time(VtbiLimit, VtbiLimitTimePeriod)),
    T2 .>. T1 + VtbiLimitTimePeriod,
    % trajectory and then no holdsAt
    trajectory(clinician_bolus_delivery_enabled(BolusDurationMinutes), T1, clinician_bolus_total_bolus_drug_delivered(TotalBolus), T2), %! <<< diff  %//NO_PREPROCESS
    % needs a different implementation of "shortcut_total_drug_in_vtbi_window_assume_basal"
        initiallyP(basal_flow_rate(BasalRate)),                                                                         %! <<< diff
        % figure out clinician_bolus_total_bolus_drug_delivered at the start of the max dose window
        TstartVtbiPeriod .=. T2 - VtbiLimitTimePeriod,
        max(TstartVtbiPeriod, 0, TstartVtbiPeriodCropped),
        % approach 3 -- trajectory definition, and then no holdsAt at the end is needed
        trajectory(clinician_bolus_delivery_enabled(BolusDurationMinutes), T1, clinician_bolus_total_bolus_drug_delivered(TotalBolusDrugAtStartPeriod), TstartVtbiPeriodCropped), %! <<< diff  %//NO_PREPROCESS 
        TotalBolusDuringVtbiPeriod .=. TotalBolus - TotalBolusDrugAtStartPeriod,
        % assume a full window of basal delivery
        AssumedBasalDeliveredInVtbiPeriod .=. VtbiLimitTimePeriod * BasalRate,                                          %! <<< diff
        % put numbers together
        TotalDuringVtbiPeriod .=. TotalBolusDuringVtbiPeriod + AssumedBasalDeliveredInVtbiPeriod,                       %! <<< diff
    TotalDuringVtbiPeriod .=. VtbiLimit.


% used in 06-selfend-halt_trigger-7_combine_1_4.pl
shortcut_total_drug_in_max_dose_window_reaches_max_dose_during_clinician_bolus__7_combine_1_4(T1, BolusDurationMinutes, T2) :-
    % split based on diference between T1 and T2 -- crucial to avoid non termination
    initiallyP(vtbi_hard_limit_over_time(VtbiLimit, VtbiLimitTimePeriod)),
    T2 .=<. T1 + VtbiLimitTimePeriod,
    % this is the trigger itself
    shortcut_total_drug_in_vtbi_window_assume_basal(T2, TotalBolus, VtbiLimitTimePeriod, TotalDuringVtbiPeriod),        %! <<< diff
    TotalDuringVtbiPeriod .=. VtbiLimit,
    holdsAt(clinician_bolus_total_bolus_drug_delivered(TotalBolus), T2, clinician_bolus_delivery_enabled(_)).                              %! <<< diff
shortcut_total_drug_in_max_dose_window_reaches_max_dose_during_clinician_bolus__7_combine_1_4(T1, BolusDurationMinutes, T2) :-
    % split based on diference between T1 and T2 -- crucial to avoid non termination
    initiallyP(vtbi_hard_limit_over_time(VtbiLimit, VtbiLimitTimePeriod)),
    T2 .>. T1 + VtbiLimitTimePeriod,
    % this is the trigger itself
    % needs a different implementation of "shortcut_total_drug_in_vtbi_window_assume_basal"
        initiallyP(basal_flow_rate(BasalRate)),                                                                         %! <<< diff
        % figure out clinician_bolus_total_bolus_drug_delivered at the start of the max dose window
        TstartVtbiPeriod .=. T2 - VtbiLimitTimePeriod,
        max(TstartVtbiPeriod, 0, TstartVtbiPeriodCropped),
        TotalBolusDuringVtbiPeriod .=. TotalBolus - TotalBolusDrugAtStartPeriod,
        % assume a full window of basal delivery
        AssumedBasalDeliveredInVtbiPeriod .=. VtbiLimitTimePeriod * BasalRate,                                          %! <<< diff
        % put numbers together
        TotalDuringVtbiPeriod .=. TotalBolusDuringVtbiPeriod + AssumedBasalDeliveredInVtbiPeriod,                       %! <<< diff
    TotalDuringVtbiPeriod .=. VtbiLimit,
    holdsAt(clinician_bolus_total_bolus_drug_delivered(TotalBolusDrugAtStartPeriod), TstartVtbiPeriodCropped, clinician_bolus_delivery_enabled(_)), %! <<< diff
    holdsAt(clinician_bolus_total_bolus_drug_delivered(TotalBolus), T2, clinician_bolus_delivery_enabled(_)).                              %! <<< diff
