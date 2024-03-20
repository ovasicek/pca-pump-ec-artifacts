% prescription / configuration  ----------------------------------------------------------------------------------------
initiallyP(basal_flow_rate_MlperHour(6)).                  % prescription
% typical: ~10ml/h
% --> 6 for readability (means 0.1 per min)

initiallyP(vtbi(1)).                                       % prescription
% typical: single digints (1ml, 2ml, 0.5ml,...)
initiallyP(patient_bolus_flow_rate_MlperHour(60)).         % prescription
% typical: as quick as possible
% --> 60 for readability (means 1 per min)
% --> patient bolus will last for 1min

initiallyP(min_t_between_patient_bolus(30)).                % prescription
% typical: ~0.5h, 1hr, ...
% --> time between boluses is 30mins (max one bolus every 31mins --- startAt(0) + duration(1) + timeBetween(30))

initiallyP(vtbi_hard_limit_over_time(V, P)) :-      % drug library
    initiallyP(basal_flow_rate(BasalRate)), initiallyP(vtbi(VTBI)),
    NB .=. 2 + (1/2),   % how many boluses to allow
    P .=. 4*60,         % time period of 4 hours
    V .=. (P*BasalRate) + (NB*VTBI).    % max dose is full period of basal + allowed boluses
% --> a maximum of 2.5 boluses allowed per 4hours

initiallyP(vtbi_hard_max(60)).                             % drug library
initiallyP(pump_flow_rate_max_MlperHour(100)).             % made up


% starting initialization ----------------------------------------------------------------------------------------------
max_time(100000).
incremental_start_time(0).
initiallyN(Fluent) :- not initiallyP(Fluent), not initiallyR(Fluent).
initiallyP(initial_total_drug_delivered(0)).
initiallyP(initial_total_bolus_drug_delivered(0)).
initiallyP(initial_drug_flow_rate(0)).
initiallyP(pump_not_running).                              % initially stopped
