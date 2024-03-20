% ----------------------------------------------------------------------------------------------------------------------
% utils                         ----------------------------------------------------------------------------------------

min(A,B,A) :- A .=<. B.
min(A,B,B) :- B .<. A.


max(A,B,A) :- A .>=. B.
max(A,B,B) :- B .>. A.

length([], 0).
length([H|T], Res) :- length(T, TRes), Res .=. TRes + 1.


countHappensIn(E, T1, T2, Res) :- 
    findall(T, countHappensInFindall(E, T, T1, T2), List),
    length(List, Res).

    countHappensInFindall(E, T, T1, T2) :-
        T .>. T1, T .<. T2,
        happens(E, T).


or_not_happensIn(E, T1, T2) :-  
    %T1 .>. 0,
    %T1 .<. T2,
    findall(T, not_happensInFindall(E, T, T1, T2), List),
    outside(List, T1, T2).

    not_happensInFindall(E, T, T1, T2) :- 
        T .>. T1, T .<. T2,
        happens(E, T).

    outside([H|T], T1, T2) :- 
        H .=<. T1,  
        outside(T, T1, T2).
    outside([H|T], T1, T2) :-
        H .>=. T2, 
        outside(T, T1, T2).
    outside([], _, _).


or_not_happens(E, T) :- not_happensInInc(E, T, T).


or_not_happensInInc(E, T1, T2) :-     % TODO check the inequalities
    %T1 .>. 0,
    %T1 .<. T2,
    findall(T, not_happensInIncFindall(E, T, T1, T2), List),
    outsideInc(List, T1, T2).

    not_happensInIncFindall(E, T, T1, T2) :- 
        T .>=. T1, T .=<. T2,
        happens(E, T).

    outsideInc([H|T], T1, T2) :- 
        H .<. T1,  
        outsideInc(T, T1, T2).
    outsideInc([H|T], T1, T2) :-
        H .>. T2, 
        outsideInc(T, T1, T2).
    outsideInc([], _, _).



% Shotcut for copying all initiates/terminates/releases of one fluent to another fluent
% e.g. use like this: copy_fluent_manipulators(fluent_with_a_specific_value(_), fluent_that_says_there_is_a_value).
%      usefull for not_holdsAt queries of the flag fluent with a parameter
%initiates(E, FluentCopyTo, T) :- copy_fluent_manipulators(FluentCopyFrom, FluentCopyTo), initiates(E, FluentCopyFrom, T).
%terminates(E, FluentCopyTo, T) :- copy_fluent_manipulators(FluentCopyFrom, FluentCopyTo), terminates(E, FluentCopyFrom, T).
%releases(E, FluentCopyTo, T) :- copy_fluent_manipulators(FluentCopyFrom, FluentCopyTo), releases(E, FluentCopyFrom, T).
%can_initiates(E, FluentCopyTo) :- copy_fluent_manipulators(FluentCopyFrom, FluentCopyTo), can_initiates(E, FluentCopyFrom).
%can_terminates(E, FluentCopyTo) :- copy_fluent_manipulators(FluentCopyFrom, FluentCopyTo), can_terminates(E, FluentCopyFrom).
%can_releases(E, FluentCopyTo) :- copy_fluent_manipulators(FluentCopyFrom, FluentCopyTo), can_releases(E, FluentCopyFrom).