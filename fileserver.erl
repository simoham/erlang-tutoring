-module(fileserver).
-export([start/1, init/1, ls_files/1, fetch/2, loop/1]).

start(Dir) ->
	Res = case filelib:is_dir(Dir) of
                true -> spawn(?MODULE, init, [Dir]);
                _ -> error
       	      end,
	Res.

init(Arg) ->
	loop(Arg).

ls_files(Server) when is_pid(Server) ->
	Server ! {list_files, self()},
	receive 
		Data -> Data
	end.

fetch(Server, File) when is_pid(Server) ->
	Server ! {{get_file, File}, self()},
	receive
		Data -> Data
	end.

loop(Dir) ->
	receive
		{list_files, From} -> From ! list_files(Dir);
		{{get_file, File}, From} -> From ! get_file(File)
	end,
	loop(Dir).

list_files(Dir) ->
	case file:list_dir(Dir) of
		{ok, List} -> io:format("~p~n", [List]), List;
		_ -> error
	end.

get_file(File) ->
	case file:read_file(File) of
		{ok, BinFile} -> BinFile;
		_ -> error
	end.
