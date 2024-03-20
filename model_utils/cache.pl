#table_once happens/2.
#table_once not__happens/2.

#table_once holdsAt/2.
#table_once not_holdsAt/2.

#table_once trajectory/4.

#table_once not_happens/2.
#table_once not_happensIn/3.
#table_once not_happensInInc/3.

#table_once not_startedIn/3.
#table_once not_stoppedIn/3.        
#table_once startedIn/3.
#table_once stoppedIn/3.  

#table_once initiallyN/1.
#table_once initiallyP/1.

#table_once initiates/3.
#table_once terminates/3.
#table_once releases/3.

#table_once selfend_trajectory/4.
#table_once holdsAt/3.

% useful oneliners to make sure that each predicate is only implied by up to one rule or one fact.
%   for rules
%     X=happens; grep -r "^[ ]*$X(.*:-" | sed "s|:-.*$||" | sed "s|^[^:]*: *||" | sed "s| T[0-9]| T|g" | sort | uniq -c | sort -nr
%
%   maybe for facts (not working well)
%     X=initiates; grep -r "^[ ]*$X([^.:]*)[ ]*\." | sed "s|^[^:]*: *||" | sed "s|\..*$|.|" | sed "s| T[0-9]| T|g" | sort | uniq
%     X=initiates; grep -r "^[ ]*$X([^.:]*)[ ]*\." | sed "s|^[^:]*: *||" | sed "s|\..*$|.|" | sed "s| T[0-9]| T|g" | sort | uniq | uniq -c | sort -nr
%     grep -ro "initiates([^,(]*" | sed "s|^[^:]*:||" | sort | uniq -c | sort -nr