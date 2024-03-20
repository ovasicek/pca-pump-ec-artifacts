% ----------------------------------------------------------------------------------------------------------------------
% hard coded constants from the specification   ------------------------------------------------------------------------
initiallyP(basal_flow_rate_min_MlperHour(1)).   % R5.1.0(2)
initiallyP(basal_flow_rate_max_MlperHour(10)).  % R5.1.0(2)
initiallyP(kvo_flow_rate_MlperHour(1)).         % R5.1.0(5)

initiallyP(low_reservoir_treshold(1)).
initiallyP(empty_reservoir_treshold(1/2)).

% ----------------------------------------------------------------------------------------------------------------------
% system fluents                ----------------------------------------------------------------------------------------
% basic
    fluent(pump_running).
    fluent(pump_not_running).
    fluent(drug_flow_rate(X)).
    fluent(initial_drug_flow_rate(X)).
    fluent(pump_flow_rate_max(X)).
    fluent(total_drug_delivered(X)).
    fluent(initial_total_drug_delivered(X)).
    fluent(total_bolus_drug_delivered(X)).
    fluent(initial_total_bolus_drug_delivered(X)).

% R5.1.0(1)
    fluent(basal_flow_rate(X)).
% R5.1.0(2)
    fluent(basal_flow_rate_min(X)).
    fluent(basal_flow_rate_max(X)).
% R5.1.0(5)
    fluent(kvo_flow_rate(X)).

% R5.2.0(2)
    fluent(patient_bolus_flow_rate(X)).
% R5.2.0(3)
    fluent(min_t_between_patient_bolus(X)).
% X5.2.0(1), R5.2.0(4), R5.2.0(5)
    fluent(vtbi(X)).
    fluent(vtbi_hard_max(X)).
    fluent(vtbi_hard_limit_over_time(X, TimePeriodMinutes)).

% R6.8.0(1), R6.8.0(2)
    fluent(initial_drug_reservoir_contents(X)).
    fluent(drug_reservoir_contents(X)).

% TODO
    fluent(low_reservoir_treshold(X)).
    fluent(empty_reservoir_treshold(X)).


% ----------------------------------------------------------------------------------------------------------------------
% flow in ml/hour but one timestep is a minute  ------------------------------------------------------------------------
    initiallyP(basal_flow_rate_min(MlperMin))     :- initiallyP(basal_flow_rate_min_MlperHour(MlperHour)), MlperMin .=. MlperHour / 60.
    initiallyP(basal_flow_rate_max(MlperMin))     :- initiallyP(basal_flow_rate_max_MlperHour(MlperHour)), MlperMin .=. MlperHour / 60.                    
    initiallyP(basal_flow_rate(MlperMin))         :- initiallyP(basal_flow_rate_MlperHour(MlperHour)), MlperMin .=. MlperHour / 60.                         
    initiallyP(kvo_flow_rate(MlperMin))           :- initiallyP(kvo_flow_rate_MlperHour(MlperHour)), MlperMin .=. MlperHour / 60.
    initiallyP(pump_flow_rate_max(MlperMin))      :- initiallyP(pump_flow_rate_max_MlperHour(MlperHour)), MlperMin .=. MlperHour / 60.
    initiallyP(patient_bolus_flow_rate(MlperMin)) :- initiallyP(patient_bolus_flow_rate_MlperHour(MlperHour)), MlperMin .=. MlperHour / 60.

    fluent(basal_flow_rate_MlperHour(X)).
    fluent(basal_flow_rate_min_MlperHour(X)).
    fluent(basal_flow_rate_max_MlperHour(X)).
    fluent(kvo_flow_rate_MlperHour(X)).
    fluent(patient_bolus_flow_rate_MlperHour(X)).
    fluent(pump_flow_rate_max_MlperHour(X)).