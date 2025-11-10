/*  

   Main file for Chess "mate in three" domain

*/


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOAD INDIGOLOG FRAMEWORK
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

:- dir(indigolog, F), consult(F).
:- dir(eval_bat, F), consult(F).    % must be loaded after the interpreter


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOAD APPLICATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

:- [chess].  


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ENVIRONMENT MANAGER ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

em_address(localhost, 8000).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ENVIRONMENTS/DEVICES TO LOAD
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load_devices([simulator]).

load_device(simulator, Host:Port, [pid(PID)]) :-
    dir(dev_simulator, File),
    ARGS = ['-e', 'swipl', '-t', 'start', File, '--host', Host, '--port', Port],
    logging(
        info(5, app), "Command to initialize device simulator: xterm -e ~w", [ARGS]),
    process_create(
        path(xterm), ARGS,
        [process(PID)]).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% HOW TO EXECUTE ACTIONS
%        how_to_execute(Action, Environment, Code)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

how_to_execute(Action, simulator, sense(Action)) :-
    sensing_action(Action, _).

how_to_execute(Action, simulator, Action) :-
    \+ sensing_action(Action, _).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SENSING TRANSLATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

translate_sensing(_, SR, SR).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MAIN PREDICATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

main :-
	findall(C,
		proc(
			control(C), _), LC),
	length(LC, N), repeat,
	format('Controllers available: ~w\n', [LC]),
	forall(
		(
			between(1, N, I),
			nth1(I, LC, C)),
		format('~d. ~w\n', [I, C])), nl, nl,
	write('Select controller: '),
	read(NC), nl,
	number(NC),
	nth1(NC, LC, C),
	format('Executing controller: *~w*\n', [C]), !,
	main(
		control(C)).

main(C) :-
	assert(
		control(C)),
	indigolog(C).

:- set_option(log_level, 5).
:- set_option(log_level, em(1)).
:- set_option(wait_step, 1).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LEGALITY AND PROJECTION TASKS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

/* Legality Task (read a sequence of actions from the terminal) */
legality_task :-
    format("Write sequence of actions:\n"),
    read(SEQ), nl,
    indigolog(SEQ).

/* Projection Task (read a condition and a sequence of actions) */
projection_task :-
    format("Choose condition to satisfy:\n"),
    read(COND), nl,
    format("Write sequence of actions:\n"),
    read(SEQ), nl,
    indigolog([SEQ, ?(COND)]).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EOF
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%