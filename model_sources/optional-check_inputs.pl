% this is an optional extension which tells scasp that input fluents can only have certain values and user input events can only have certain p
%   - usefull as a validation of user narrative
%   - might also be usefull for abduction of initial values of input fluents %TODO

:- initiallyP(pump_flow_rate_max_MlperHour(X)), X .=<. 0.
:- initiallyP(basal_flow_rate_min_MlperHour(X)), X .=<. 0.
:- initiallyP(basal_flow_rate_max_MlperHour(X)), X .=<. 0.
:- initiallyP(basal_flow_rate_MlperHour(X)), initiallyP(basal_flow_rate_min_MlperHour(Min)), X .<. Min. % R5.1.0(2)
:- initiallyP(basal_flow_rate_MlperHour(X)), initiallyP(basal_flow_rate_max_MlperHour(Max)), X .>. Max. % R5.1.0(2)
:- initiallyP(kvo_flow_rate_MlperHour(X)), X .<>. 1.
:- initiallyP(patient_bolus_flow_rate_MlperHour(X)), X .=<. 0.
%:- initiallyP(patient_bolus_flow_rate_MlperHour(X)), initiallyP(vtbi_hard_max(Max)), X .>. Max.  % R5.2.0(4) % TODO ??
:- initiallyP(min_t_between_patient_bolus(X)), X .=<. 0.
:- initiallyP(vtbi(X)), X .=<. 0. 
:- initiallyP(vtbi(X)), initiallyP(vtbi_hard_max(Max)), X .>. Max.   % R5.2.0(4)
:- initiallyP(vtbi_hard_max(X)), X .=<. 0.
:- initiallyP(vtbi_hard_limit_over_time(X, TimePeriodMinutes)), X .=<. 0.
:- initiallyP(vtbi_hard_limit_over_time(X, TimePeriodMinutes)), TimePeriodMinutes .=<. 0.
:- initiallyP(initial_drug_reservoir_contents(X)), X .=<. 0.

:- initiallyP(initial_total_drug_delivered(X)), X .<>. 0.
:- initiallyP(initial_total_bolus_drug_delivered(X)), X .<>. 0.
:- initiallyP(initial_drug_flow_rate(X)), X .<>. 0.

% basal rate on its own without any boluses must not cause overdose (MaxDose volume must be large enough or
% BasalRate*MaxDosePeriod must be small enough so that a full period of basal delivery fits into the max dose)
:- initiallyP(vtbi_hard_limit_over_time(MaxDose, MaxDosePeriod)), MaxDose .<. BasalRate * MaxDosePeriod, initiallyP(basal_flow_rate(BasalRate)). %! TODO my own addition (not in the specification) 

% the max dose time period must be bigger than the patient bolus duration
:- initiallyP(vtbi_hard_limit_over_time(_, MaxDosePeriod)), shortcut_patient_bolus_duration(BolusDuration), MaxDosePeriod .<. BolusDuration. %! TODO my own addition (not in the specification) 
