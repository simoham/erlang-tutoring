-module(udp_server).
-export([start/1, start/0]).

%% Start server: udp_server:start(8080).
%%
start() ->
    start(8080).

start(Port) ->
    {ok, Socket} = gen_udp:open(Port, [binary, {active, true}]),
    io:format("UDP Server listening on ~p~n", [Port]),
    spawn(fun() -> loop(Socket) end).

loop(Socket) ->
    receive
        {udp, Socket, Host, Port, Bin} ->
            io:format("Received ~p from ~p:~p~n", [Bin, Host, Port]),
            %% Non-blocking send
	    BinHash=crypto:hash(md5, Bin),
            gen_udp:send(Socket, Host, Port, <<"ACK: ", BinHash/binary >>),
            loop(Socket);
        {udp_error, Socket, Error} ->
            io:format("UDP Error: ~p~n", [Error]),
            loop(Socket);
        Other ->
            io:format("Other: ~p~n", [Other]),
            loop(Socket)
    end.
