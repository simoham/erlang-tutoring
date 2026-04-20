-module(serverechomsg).
-export([start_server/0, start_server/1, tcp_acceptor/1, handle_client/1, echo/2]).

-define(DEFAULT_PORT, 7677).

start_server() ->
	start_server(?DEFAULT_PORT).

start_server(Port) ->
    {ok, LSock} = gen_tcp:listen(Port, [binary, {packet, 0},
                                        {active, true}]),
    Pid = spawn(fun() -> tcp_acceptor(LSock) end),
    Pid.

tcp_acceptor(LSock) ->
    {ok, Sock} = gen_tcp:accept(LSock),
    Pid = spawn(fun() -> handle_client(Sock) end),
    gen_tcp:controlling_process(Sock, Pid),
    tcp_acceptor(LSock).

handle_client(Sock) ->
  receive
    {tcp, Sock, Data} ->
      io:format("Received: ~p~n", [Data]),
        handle_client(Sock);
    {tcp_closed, Sock} ->
            io:format("Socket closed~n")
  end.

echo(Sock, Data) ->
	gen_tcp:send(Sock, Data).
