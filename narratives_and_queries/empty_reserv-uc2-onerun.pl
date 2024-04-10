#include './empty_reserv-uc2-base.pl'.

% enable drug reservoir reasoning
low_reservoir_reasoning_enabled.                      
empty_reservoir_reasoning_enabled.


?- happens(low_reservoir_warning,                   125).                   
?- happens(empty_reservoir_alarm,                   155).

% query:
?-  holdsAt(total_drug_delivered(X),               1000).
