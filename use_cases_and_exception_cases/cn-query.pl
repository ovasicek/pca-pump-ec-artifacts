initiallyP(basal_flow_rate_MlperHour(6)).
initiallyP(basal_flow_rate(MlperMin)) :- initiallyP(basal_flow_rate_MlperHour(MlperHour)), MlperMin .=. MlperHour / 60.

?- not initiallyP(basal_flow_rate(X)).