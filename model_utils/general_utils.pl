% ----------------------------------------------------------------------------------------------------------------------
% utils                         ----------------------------------------------------------------------------------------

min(A,B,A) :- A .=<. B.
min(A,B,B) :- B .<. A.


max(A,B,A) :- A .>=. B.
max(A,B,B) :- B .>. A.


% prove that E did not happen in a time interval (excluding the edges)
or_not_happensIn(E, T1, T2) :-  
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


% prove that E did not happen at T
or_not_happens(E, T) :- not_happensInInc(E, T, T).


% prove that E did not happen in a time interval (including the edges)
or_not_happensInInc(E, T1, T2) :-
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


% prove not_holdsAt over a time interval, if F not_holds at T1
not_holdsIn(F, T1, T2) :-  
    not_holdsAt(F, T1),
    not_declipped(T1, F, T2).

% prove not_holdsAt over a time interval, if F is terminated at T1
not_holdsIn(F, T1, T2) :-  
    can_terminates(Event, F),
    happens(Event, T1),
    terminates(Event, F, T1),
    not_startedIn(T1, F, T2).


% prove not_holdsAt starting at T1 and after, if F not_holds at T1
not_holdsAfter(F, T1) :-
    max_time(T2),
    not_holdsAt(F, T1),
    not_declipped(T1, F, T2).

% prove not_holdsAt starting at T1 and after, if F is terminated at T1
not_holdsAfter(F, T1) :-  
    max_time(T2),
    can_terminates(Event, F),
    happens(Event, T1),
    terminates(Event, F, T1),
    not_startedIn(T1, F, T2).


% prove holdsAt over a time interval, if F holds at T1
holdsIn(F, T1, T2) :-  
    holdsAt(F, T1),
    not_clipped(T1, F, T2).

% prove holdsAt over a time interval, if F is initiated at T1
holdsIn(F, T1, T2) :-  
    can_initiates(Event, F),
    happens(Event, T1),
    initiates(Event, F, T1),
    not_stoppedIn(T1, F, T2).


% prove holdsAt starting at T1 and after, if F not_holds at T1
holdsAfter(F, T1) :-  
    max_time(T2),
    holdsAt(F, T1),
    not_clipped(T1, F, T2).

% prove holdsAt starting at T1 and after, if F is initiated at T1
holdsAfter(F, T1) :-  
    max_time(T2),
    can_initiates(Event, F),
    happens(Event, T1),
    initiates(Event, F, T1),
    not_stoppedIn(T1, F, T2).




% not_clipped (not_stoppedIn includign events at T1)
not_clipped(T1, Fluent, T2) :-
    %T1 .>=. 0,
    max_time(T3), T2 .=<. T3,
    findall(E, can_terminatesOrReleases(E, Fluent), EventList),
    not_terminated_IncT1(Fluent, EventList, T1, T2),
    not_released_IncT1(Fluent, EventList, T1, T2).

not_released_IncT1(Fluent, [H|X], T1, T2) :-
    findall(T,rel_IncT1(H,Fluent,T, T1, T2),List),
    no_release_IncT1(List, T1, T2),
    not_released_IncT1(Fluent, X, T1, T2).

not_released_IncT1(_, [], _, _).

released_IncT1(Event, Fluent, T1, T2) :-
    T1 .=<. T, T .<. T2,
    can_releases(Event, Fluent),
    happens(Event, T),
    releases(Event, Fluent, T).

rel_IncT1(E, F, T, T1, T2) :-
    can_releases(E, F),
    T .>=. T1, T .<. T2,
    happens(E, T),
    releases(E, F, T).
    
no_release_IncT1([H|T], T1, T2) :- H .<. T1, no_release_IncT1(T, T1, T2).
no_release_IncT1([H|T], T1, T2) :- H .>=. T2, no_release_IncT1(T, T1, T2).
no_release_IncT1([], _, _).



not_terminated_IncT1(Fluent, [H|X], T1, T2) :-
    findall(T, term_IncT1(H, Fluent, T, T1, T2),List),
    no_terminate_IncT1(List, T1, T2),
    not_terminated_IncT1(Fluent, X, T1, T2).

not_terminated_IncT1(_, [], _, _).

terminated_IncT1(Event, Fluent, T1, T2) :-
    T1 .>=. 0,  T1 .=<. T, T .<. T2,
    can_terminates(Event, Fluent),
    happens(Event, T),
    terminates(Event, Fluent, T).

term_IncT1(E, F, T, T1, T2) :-
    can_terminates(E, F),
    T .>=. T1, T .<. T2,
    happens(E, T),
    terminates(E, F, T).

no_terminate_IncT1([H|T], T1, T2) :- H .<. T1, no_terminate_IncT1(T, T1, T2).
no_terminate_IncT1([H|T], T1, T2) :- H .>=. T2, no_terminate_IncT1(T, T1, T2).
no_terminate_IncT1([], _, _).


% not_declipped (not_stoppedIn includign events at T1)
not_declipped(T1, Fluent, T2) :-
    %T1 .>=. 0,
    max_time(T3), T2 .=<. T3,
    findall(E, can_initiatesOrReleases(E, Fluent), EventList),
    not_initiated_IncT1(Fluent, EventList, T1, T2),
    not_released_IncT1(Fluent, EventList, T1, T2).

not_initiated_IncT1(Fluent, [H|X], T1, T2) :-
    findall(T, init_IncT1(H,Fluent,T, T1, T2), List),
    no_initiate_IncT1(List, T1, T2),
    not_initiated_IncT1(Fluent, X, T1, T2).
    
not_initiated_IncT1(_, [], _, _).    

initiated_IncT1(Event, Fluent, T1, T2) :-
    T1 .>=. 0,  T1 .=<. T, T .<. T2,
    can_initiates(Event, Fluent),
    happens(Event, T),
    initiates(Event, Fluent, T).

init_IncT1(E, F, T, T1, T2) :-
    can_initiates(E, F),
    T .>=. T1, T .<. T2,
    happens(E, T),
    initiates(E, F, T).

no_initiate_IncT1([H|T], T1, T2) :- H .<. T1, no_initiate_IncT1(T, T1, T2).
no_initiate_IncT1([H|T], T1, T2) :- H .>=. T2, no_initiate_IncT1(T, T1, T2).
no_initiate_IncT1([], _, _).
