%% based on https://github.com/sarat-chandra-varanasi/event-calculus-scasp/blob/main/train_example/bec_theory.lp

can_terminatesOrReleases(Event, Fluent) :- can_releases(Event, Fluent).
can_terminatesOrReleases(Event, Fluent) :- can_terminates(Event, Fluent).
can_initiatesOrReleases(Event, Fluent) :- can_releases(Event, Fluent).
can_initiatesOrReleases(Event, Fluent) :- can_initiates(Event, Fluent).

%-----------------------------------------------------------------------------------------------------------------------

%% MODIFIED BASIC EVENT CALCULUS (BEC) THEORY 

%% ALWAYS USE A MAX_TIME USING max_time(MaxTime)
%% USE holdsAt(F, T) TO QUERY FLUENTS, AND not_holdsAt(F, T) TO QUERY NEGATIONS


% #show happens/2, holdsAt/2, initiallyN/1, initiallyP/1.
% #show initiates/3, terminates/3, releases/3, stoppedIn/3, startedIn/3, trajectory/4.

%%max_time(100).

%% to get around cache issues
happens(E, T) :- or_happens(E, T).
not_happens(E, T) :- or_not_happens(E, T).
not_happensIn(E, T1, T2) :- or_not_happensIn(E, T1, T2).
not_happensInInc(E, T1, T2) :- or_not_happensInInc(E, T1, T2).
not__happens(E, T) :- or_not__happens(E, T).
holdsAt(Fluent, T) :- or_holdsAt(Fluent, T).
not_holdsAt(Fluent, T) :- or_not_holdsAt(Fluent, T).
stoppedIn(T1, Fluent, T2) :- or_stoppedIn(T1, Fluent, T2).
startedIn(T1, Fluent, T2) :- or_startedIn(T1, Fluent, T2).
not_stoppedIn(T1, Fluent, T2) :- or_not_stoppedIn(T1, Fluent, T2).
not_startedIn(T1, Fluent, T2) :- or_not_startedIn(T1, Fluent, T2).
trajectory(Fluent1, T1, Fluent2, T2) :- or_trajectory(Fluent1, T1, Fluent2, T2).
initiates(Event, Fluent, T) :- or_initiates(Event, Fluent, T).
terminates(Event, Fluent, T) :- or_terminates(Event, Fluent, T).
releases(Event, Fluent, T) :- or_releases(Event, Fluent, T).
not_clipped(T1, Fluent, T2) :- or_not_clipped(T1, Fluent, T2).
not_declipped(T1, Fluent, T2) :- or_not_declipped(T1, Fluent, T2).

%% BEC1 - StoppedIn(t1,f,t2)
or_stoppedIn(T1, Fluent, T2) :-
    T1 .<. T, T .<. T2,
    max_time(T3), T2 .=<. T3,
    can_terminates(Event, Fluent),
    happens(Event, T),
    terminates(Event, Fluent, T).

or_stoppedIn(T1, Fluent, T2) :-
    T1 .<. T, T .<. T2,
    max_time(T3), T2 .=<. T3,
    can_releases(Event, Fluent),
    happens(Event, T),
    releases(Event, Fluent, T).


%% BEC2 - StartedIn(t1,f,t2)
or_startedIn(T1, Fluent, T2) :-
    T1 .<. T, T .<. T2,
    max_time(T3), T2 .=<. T3,
    can_initiates(Event, Fluent),
    happens(Event, T),
    initiates(Event, Fluent, T).
    
or_startedIn(T1, Fluent, T2) :-
    max_time(T3), T2 .=<. T3,
    T1 .<. T, T .<. T2,
    can_releases(Event, Fluent),
    happens(Event, T),
    releases(Event, Fluent, T).


%% BEC4 - holdsAt(f,t)
or_holdsAt(Fluent, T) :-
    T .>=. 0,
    max_time(T3), T .<. T3,
    initiallyP(Fluent),
    not_stoppedIn(0, Fluent, T).
 
% NEW AXIOM -- initiallyR
or_holdsAt(Fluent2, T2) :-
    T2 .>=. 0,
    max_time(T3), T2 .=<. T3,
    can_trajectory(Fluent1, 0, Fluent2, T2),
    initiallyP(Fluent1),
    initiallyR(Fluent2),
    trajectory(Fluent1, 0, Fluent2, T2),
    not_stoppedIn(0, Fluent1, T2).

%% BEC3 - holdsAt(f,t)
or_holdsAt(Fluent2, T2) :-
    T1 .>. 0, T1 .<. T2,
    max_time(T3), T2 .=<. T3,
    can_trajectory(Fluent1, T1, Fluent2, T2),
    can_initiates(Event, Fluent1),
    happens(Event, T1),
    initiates(Event, Fluent1, T1),
    trajectory(Fluent1, T1, Fluent2, T2),
    not_stoppedIn(T1, Fluent1, T2).

% new axiom -- holdsAt/3
% - third parameter Fluent1 tries to say to only ever consider a specified trajectory
holdsAt(Fluent2, T2, Fluent1) :-
    T1 .>. 0, T1 .<. T2,
    max_time(T3), T2 .=<. T3,
    can_trajectory(Fluent1, T1, Fluent2, T2),
    can_initiates(Event, Fluent1),
    happens(Event, T1),
    initiates(Event, Fluent1, T1),
    trajectory(Fluent1, T1, Fluent2, T2),
    not_stoppedIn(T1, Fluent1, T2).


%% BEC6 - holdsAt(f,t)
or_holdsAt(Fluent, T2) :-
    T1 .>. 0, T1 .<. T2,
    max_time(T3), T2 .=<. T3,
    can_initiates(Event, Fluent),
    happens(Event, T1),
    initiates(Event, Fluent, T1),
    not_stoppedIn(T1, Fluent, T2).


%% BEC5 - not holdsAt(f,t)
or_not_holdsAt(Fluent, T) :-
    T .>=. 0,
    max_time(T3), T .<. T3,
    initiallyN(Fluent),
    not_startedIn(0, Fluent, T).


%% BEC7 - not holdsAt(f,t)
or_not_holdsAt(Fluent, T2) :-
    T1 .>. 0,
    T1 .<. T2,
    max_time(T3), T2 .=<. T3,
    can_terminates(Event, Fluent),
    happens(Event, T1),
    terminates(Event, Fluent, T1),
    not_startedIn(T1, Fluent, T2).



%% Helper for BEC1
or_not_stoppedIn(T1, Fluent, T2) :-
    %T1 .>=. 0,
    max_time(T3), T2 .=<. T3,
    findall(E, can_terminatesOrReleases(E, Fluent), EventList),
    not_terminated(Fluent, EventList, T1, T2),
    not_released(Fluent, EventList, T1, T2).

not_released(Fluent, [H|X], T1, T2) :-
    findall(T,rel(H,Fluent,T, T1, T2),List),
    no_release(List, T1, T2),
    not_released(Fluent, X, T1, T2).

not_released(_, [], _, _).

released(Event, Fluent, T1, T2) :-
    T1 .<. T, T .<. T2,
    can_releases(Event, Fluent),
    happens(Event, T),
    releases(Event, Fluent, T).

rel(E, F, T, T1, T2) :-
    can_releases(E, F),
    T .>. T1, T .<. T2,
    happens(E, T),
    releases(E, F, T).
    
no_release([H|T], T1, T2) :- H .=<. T1, no_release(T, T1, T2).
no_release([H|T], T1, T2) :- H .>=. T2, no_release(T, T1, T2).
no_release([], _, _).



not_terminated(Fluent, [H|X], T1, T2) :-
    findall(T, term(H, Fluent, T, T1, T2),List),
    no_terminate(List, T1, T2),
    not_terminated(Fluent, X, T1, T2).

not_terminated(_, [], _, _).

terminated(Event, Fluent, T1, T2) :-
    T1 .>=. 0,  T1 .<. T, T .<. T2,
    can_terminates(Event, Fluent),
    happens(Event, T),
    terminates(Event, Fluent, T).

term(E, F, T, T1, T2) :-
    can_terminates(E, F),
    T .>. T1, T .<. T2,
    happens(E, T),
    terminates(E, F, T).

no_terminate([H|T], T1, T2) :- H .=<. T1, no_terminate(T, T1, T2).
no_terminate([H|T], T1, T2) :- H .>=. T2, no_terminate(T, T1, T2).
no_terminate([], _, _).


%% Helper for BEC2
or_not_startedIn(T1, Fluent, T2) :-
    %T1 .>=. 0,
    max_time(T3), T2 .=<. T3,
    findall(E, can_initiatesOrReleases(E, Fluent), EventList),
    not_initiated(Fluent, EventList, T1, T2),
    not_released(Fluent, EventList, T1, T2).

not_initiated(Fluent, [H|X], T1, T2) :-
    findall(T, init(H,Fluent,T, T1, T2), List),
    no_initiate(List, T1, T2),
    not_initiated(Fluent, X, T1, T2).
    
not_initiated(_, [], _, _).    

initiated(Event, Fluent, T1, T2) :-
    T1 .>=. 0,  T1 .<. T, T .<. T2,
    can_initiates(Event, Fluent),
    happens(Event, T),
    initiates(Event, Fluent, T).

init(E, F, T, T1, T2) :-
    can_initiates(E, F),
    T .>. T1, T .<. T2,
    happens(E, T),
    initiates(E, F, T).

no_initiate([H|T], T1, T2) :- H .=<. T1, no_initiate(T, T1, T2).
no_initiate([H|T], T1, T2) :- H .>=. T2, no_initiate(T, T1, T2).
no_initiate([], _, _).
