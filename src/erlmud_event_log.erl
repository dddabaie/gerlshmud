-module(erlmud_event_log).

-behaviour(gen_server).

-export([start_link/0]).
-export([log/2]).
-export([log/3]).
-export([register/1]).

%% gen_server

-export([init/1]).
-export([handle_call/3]).
-export([handle_cast/2]).
-export([handle_info/2]).
-export([terminate/2]).
-export([code_change/3]).

-record(state, {log_file :: file:io_device(),
                html_file :: file:io_device(),
                loggers = [] :: [function()]}).

-define(DIV(X), "<div>"X"</div>").
-define(SPAN(Class), "<span class=\"" Class "\">~p</span>").
-define(SPAN, ?SPAN("~p")).

log(Level, Terms) when is_atom(Level) ->
    Self = self(),
    log(Self, Level, Terms).

log(Pid, Level, Terms) when is_atom(Level) ->
    case whereis(?MODULE) of
        undefined ->
            io:format(user,
                      "erlmud_event_log process not found~n"
                      "Pid: ~p, Level: ~p, Terms: ~p~n",
                      [Pid, Level, Terms]);
        _ ->
            gen_server:cast(?MODULE, {log, Pid, Level, Terms})
    end.

register(Logger) when is_function(Logger) ->
    gen_server:cast(?MODULE, {register, Logger}).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init([]) ->
    process_flag(priority, max),
    io:format("Starting logger (~p)~n", [self()]),
    LogPath = get_log_path(),
    {ok, LogFile} = file:open(LogPath ++ "/erlmud.log", [append]),
    {ok, HtmlFile} = file:open(LogPath ++ "/log.html", [append]),

    Line = lists:duplicate(80, $=),
    io:format(LogFile, "~n~n~s~n~p~n~s~n~n", [Line, os:timestamp(), Line]),
    io:format(user, "Logger:~n\tLog file: ~p~n\tHTML File: ~p~n",
              [LogFile, HtmlFile]),

    {ok, #state{log_file = LogFile,
                html_file = HtmlFile}}.

handle_call(Request, From, State) ->
    io:format(user, "erlmud_event_log:handle_call(~p, ~p, ~p)~n",
              [Request, From, State]),
    {reply, ignored, State}.

handle_cast({log, Pid, Level, Props}, State) when is_list(Props) ->
    try
        Props2 = [{process, Pid}, {level, Level} | Props],
        BinProps = [{K, json_friendly(V)} || {K, V} <- Props2],
        JSON = jsx:encode(BinProps)
        ok = file:write(State#state.log_file, <<JSON/binary, "\n">>)
    catch
        Error ->
            io:format(user, "~p caught error:~n\t~p~n", [?MODULE, Error])
    end,
    [call_logger(Logger, Level, JSON) || Logger <- State#state.loggers],
    {noreply, State};

handle_case({register, Logger}, State = #state{loggers = Loggers}) ->
    {noreply, State#state{loggers = [Logger | Loggers]}}.

handle_cast(Msg, State) ->
    io:format(user, "Unrecognized cast: ~p~n", [Msg]),
    {noreply, State}.

handle_info(Info, State) ->
    io:format(user, "~p:handle_info(~p, State)~n", [?MODULE, Info]),
    {noreply, State}.

terminate(_Reason, #state{html_file = HtmlFile}) ->
    io:format(HtmlFile,
              "<script language=\"JavaScript\">"
              "createClassCheckboxes();"
              "</script>\n"
              "</body>\n</html>\n",
              []),
    ok;
terminate(Reason, State) ->
    io:format(user, "Terminating erlmud_event_log: ~p~n~p~n", [Reason, State]).

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

props(Pid) ->
    case erlmud_object:props(Pid) of
        undefined ->
            io:format(user, "Pid ~p has no props!", [Pid]),
            [];
        Props ->
            Props
    end.

get_log_path() ->
    case os:getenv("ERLMUD_LOG_PATH") of
        false ->
            {ok, CWD} = file:get_cwd(),
            CWD;
        Path ->
            Path
    end.

maybe_name(Pid) when is_pid(Pid) ->
    {Pid, erlmud_index:get(Pid)};
maybe_name(NotPid) ->
    NotPid.

call_logger(Logger, Level, JSON) ->
    try
        Logger(Level, JSON)
    catch
        Error ->
            io:format(user,
                      "~p caught error calling Logger function:~n\t~p~n",
                      [?MODULE, Error])
    end.

to_binary(L) when is_list(L) ->
    lists:foldl(fun to_binary/2, <<>>, L);
to_binary(NotList) ->
    NotList.

json_friendly(List) -> when is_list(List) ->
    case is_string(List) of
        true ->
            l2b(List);
        false ->
            [json_friendly(E) || E <- List]
    end;
json_friendly(Timestamp = {Meg, Sec, Mic}) when is_int(Meg), is_int(Sec), is_int(Mic)  ->
    ts2b(Timestamp);
json_friendly(Tuple) when is_tuple(Tuple) ->
    json_friendly(tuple_to_list(Tuple));
json_friendly(Pid) when is_pid(Pid) ->
    p2b(Pid);
json_friendly(Any) ->
    Any.

is_string([]) ->
    true;
is_string([X | Rest]) when is_integer(X),
                           X > 9, X < 127 ->
    is_string(Rest);
is_string(_) ->
    false.

l2b(List) when is_list(List) ->
    list_to_binary(List).

p2b(Pid) when is_pid(Pid) ->
    list_to_binary(pid_to_list(Pid)).

a2b(Atom) when is_atom(Atom) ->
    list_to_binary(atom_to_list(Atom)).

i2b(Int) when is_integer(Int) ->
    integer_to_binary(Int).

ts2b({Meg, Sec, Mic}) ->
    MegBin = i2b(Meg),
    SecBin = i2b(Sec),
    MicBin = i2b(Mic),
    <<"{", MegBin/binary, ",", SecBin/binary, ",", MicBin/binary, "}">>.
