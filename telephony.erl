-module(telephony).
-export([]).
-record(#telephone{number, status, who_is_calling}).

process_start(List) ->
        Pid = spawn(fun() -> process_manager([]) end).


add_process(PServer, Pid) ->
        PServer ! {self(), {add, Pid}},
        receive
                ok -> ok;
                _ -> error
        end.


process_manager([List]) ->
        receive
                {From, {add, Pid}} -> List1 = [Pid |List], process_manager(List1);
                {From, {remove, Pid}} -> List1 = lists:remove(List, Pid), process_manager(List1)
        end.

loop(State) ->
        receive
                {From, {calling, Number}} ->
                        case State#telephone.status of
                                calling -> From ! {self(), {busy, "Try later"}};
                                _ -> State1 = State#telephone{who=Number}, loop(State1);
                        end;
                {From, {check, status}} -> From ! {self(), {status, State#telephone.status}
        end.

