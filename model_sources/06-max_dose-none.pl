%! a version which does not have any overdose protection measures (or rather they do not do anything usefull, to pretend that they dont exist)

%----------------------------------------------------------------------------------------------------------------------%
% used to deny an requested patient bolus
shortcut_total_drug_in_max_dose_window_if_the_patient_bolus_would_be_delivered_starting_at_T(T, VtbiLimitTimePeriod, ResTotalDuringVtbiPeriodWithCurrentBolus) :-
    initiallyP(vtbi_hard_limit_over_time(VtbiLimit, VtbiLimitTimePeriod)),
    % deny will not happen when ResTotalDuringVtbiPeriodWithCurrentBolus .=<. VtbiLimit
    % --> return exactly equal so that deny never happens
    ResTotalDuringVtbiPeriodWithCurrentBolus .=. VtbiLimit.


%----------------------------------------------------------------------------------------------------------------------%
% used to halt an in-progress clinician bolus
% TODO many different rules for different versions of the halt trigger rule

shortcut_total_drug_in_max_dose_window_reaches_max_dose_during_clinician_bolus__X :-
    0 = 1. % will always fail

% used in 06-selfend-halt_trigger-0_loop.pl
shortcut_total_drug_in_max_dose_window_reaches_max_dose_during_clinician_bolus__0_loop(T1, BolusDurationMinutes, T2) :-
    shortcut_total_drug_in_max_dose_window_reaches_max_dose_during_clinician_bolus__X.

% used in 06-selfend-halt_trigger-1_dedicated_fluent.pl
shortcut_total_drug_in_max_dose_window_reaches_max_dose_during_clinician_bolus__1_dedicated_fluent(T1, BolusDurationMinutes, T2) :-
    shortcut_total_drug_in_max_dose_window_reaches_max_dose_during_clinician_bolus__X.


% used in 06-selfend-halt_trigger-2_plan_into_future.pl
shortcut_total_drug_in_max_dose_window_reaches_max_dose_during_clinician_bolus__2_plan_into_future(T1, BolusDurationMinutes, T2) :-
    shortcut_total_drug_in_max_dose_window_reaches_max_dose_during_clinician_bolus__X.


% used in 06-selfend-halt_trigger-3_selfend_trigger_axiom.pl
shortcut_total_drug_in_max_dose_window_reaches_max_dose_during_clinician_bolus__3_selfed_trigger_axiom(T1, BolusDurationMinutes, T2) :-
    shortcut_total_drug_in_max_dose_window_reaches_max_dose_during_clinician_bolus__X.


% used in 06-selfend-halt_trigger-4_holdsAt3_axiom.pl
shortcut_total_drug_in_max_dose_window_reaches_max_dose_during_clinician_bolus__4_holdsAt3_axiom(T1, BolusDurationMinutes, T2) :-
    shortcut_total_drug_in_max_dose_window_reaches_max_dose_during_clinician_bolus__X.


% used in 06-selfend-halt_trigger-5_combine_1_2.pl
%   - order of last two goals is crucial to avoid non-termination
%   - querying holdsAt of dedicated fluent is crucial to avoid non-termination
shortcut_total_drug_in_max_dose_window_reaches_max_dose_during_clinician_bolus__5_combine_1_2(T1, BolusDurationMinutes, T2) :-
    shortcut_total_drug_in_max_dose_window_reaches_max_dose_during_clinician_bolus__X.


% used in 06-selfend-halt_trigger-6_combine_1_3.pl
shortcut_total_drug_in_max_dose_window_reaches_max_dose_during_clinician_bolus__6_combine_1_3(T1, BolusDurationMinutes, T2) :-
    shortcut_total_drug_in_max_dose_window_reaches_max_dose_during_clinician_bolus__X.


% used in 06-selfend-halt_trigger-7_combine_1_4.pl
shortcut_total_drug_in_max_dose_window_reaches_max_dose_during_clinician_bolus__7_combine_1_4(T1, BolusDurationMinutes, T2) :-
    shortcut_total_drug_in_max_dose_window_reaches_max_dose_during_clinician_bolus__X.