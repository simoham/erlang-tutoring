-module(random_reader).
-export([start/0, read_numbers/1, stop/1]).

%% Start the external process and begin reading
start() ->
    %% Command to run the Go executable
    Cmd = "./random_gen",

    %% Open the port to the external process
    Port = open_port({spawn, Cmd}, [stream, {line, 1024}, exit_status]),

    %% Start reading numbers
    read_numbers(Port).

%% Read numbers from the external process
read_numbers(Port) ->
    receive
        {Port, {data, {eof, _}}} ->
            io:format("External process terminated~n"),
            port_close(Port),
            ok;

        {Port, {data, {line, Line}}} ->
            %% Parse the number from the line
            Number = string:trim(Line, trailing, "\n"),
            case string:to_integer(Number) of
		{error, Reason} ->
                     io:format("Failed to parse number: ~s, Error: ~p~n", [Number, Reason]);
                {Int, _} ->
                    io:format("Received random number: ~p~n", [Int])
            end,
            %% Continue reading
            read_numbers(Port);

        {Port, {exit_status, Status}} ->
            io:format("Process exited with status: ~p~n", [Status]),
            port_close(Port),
            ok;

        Unexpected ->
            io:format("Unexpected message: ~p~n", [Unexpected]),
            read_numbers(Port)
    after 5000 ->
        %% Timeout after 5 seconds of no data
        io:format("Timeout - no data received~n"),
        port_close(Port),
        timeout
    end.

%% Stop the external process
stop(Port) ->
    port_close(Port),
    io:format("Stopped external process~n").
