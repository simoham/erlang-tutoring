-module(serverecho).
-export([start_server/0, start_server/1, tcp_acceptor/1, handle_client/1, echo/2]).

-define(DEFAULT_PORT, 7677).

start_server() ->
	start_server(?DEFAULT_PORT).

start_server(Port) ->
    {ok, LSock} = gen_tcp:listen(Port, [binary, {packet, 0},
                                        {active, false}]),
    Pid = spawn(fun() -> tcp_acceptor(LSock) end),
    Pid.

tcp_acceptor(LSock) ->
    {ok, Sock} = gen_tcp:accept(LSock),
    spawn(fun() -> handle_client(Sock) end),
    tcp_acceptor(LSock).

handle_client(Sock) ->
    case gen_tcp:recv(Sock, 0) of
        {ok, B} ->
            echo(Sock, B),
	    io:format("~p ~p~n", [Sock, B]),
	    gen_tcp:close(Sock);
        {error, closed} -> ok
    end.

echo(Sock, Data) ->
	gen_tcp:send(Sock, Data).
