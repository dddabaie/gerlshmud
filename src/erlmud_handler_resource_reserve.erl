%% Copyright (c) 2017, Chris Maguire <cwmaguire@gmail.com>
%%
%% Permission to use, copy, modify, and/or distribute this software for any
%% purpose with or without fee is hereby granted, provided that the above
%% copyright notice and this permission notice appear in all copies.
%%
%% THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
%% WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
%% MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
%% ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
%% WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
%% ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
%% OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
-module(erlmud_handler_resource_reserve).
-behaviour(erlmud_handler).

-export([attempt/1]).
-export([succeed/1]).
-export([fail/1]).

% if something reserves us and we have the same owner
attempt({Owner, Props, {Owner, reserve, Self, for, _Proc}})
  when Self == self() ->
    {succeed, true, Props};
attempt({Owner, Props, {Owner, unreserve, Self, for, _Proc}})
  when Self == self() ->
    {succeed, true, Props};
attempt(_) ->
    undefined.

succeed({Props, {_Owner, reserve, Self, for, Proc}})
  when Self == self() ->
    log(debug, [<<"Reserving ">>, Self, <<" for ">>, Proc, <<"\n">>]),
    % If we send this to ourself then we can't handle it until after the
    % new reservation property is set
    erlmud_object:attempt(Self, {Self, update_tick}),
    Reservations = proplists:get(reservations, Props, []),
    [{reservations, Reservations ++ [Proc]} | proplists:delete(reservations, Props)];
succeed({Props, {_Owner, unreserve, Self, for, Proc}})
  when Self == self() ->
    log(debug, [<<"Unreserving ">>, Self, <<" for ">>, Proc, <<"\n">>]),
    % If we send this to ourself then we can't handle it until after the
    % new reservation property is set
    erlmud_object:attempt(Self, {Self, update_tick}),
    Reservations = proplists:get(reservations, Props, []),
    [{reservations, lists:delete(Proc, Reservations)} | proplists:delete(reservations, Props)];
succeed({Props, _}) ->
    Props.

fail({Props, _, _}) ->
    Props.

log(Level, IoData) ->
    erlmud_event_log:log(Level, [list_to_binary(atom_to_list(?MODULE)) | IoData]).
