initiallyP(flow_rate_PerHour(6)).
initiallyP(flow_rate(PerMin)) :- initiallyP(flow_rate_PerHour(PerHour)), PerMin .=. PerHour / 60.

?- not initiallyP(flow_rate(X)).

%?- initiallyP(flow_rate(X)).
