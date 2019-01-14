%% Copyright (c) 2019, Chris Maguire <cwmaguire@gmail.com>
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
-module(erlmud_handler_attribute_look).

-behaviour(erlmud_handler).

-include("include/erlmud.hrl").

%% object behaviour
-export([attempt/1]).
-export([succeed/1]).
-export([fail/1]).

attempt({#parents{owner = Owner},
         Props,
         {Source, describe, Owner, with, Context}}) ->
    Log = [{source, Source},
           {type, describe},
           {target, Owner},
           {context, Context}],
    {succeed, true, Props, Log};
% TODO WHAT THE CRAP? This second pattern will never match
% Remove and make sure tests pass
attempt({#parents{owner = Owner},
         Props,
         {Source, describe, Owner, with, Context}}) ->
    Log = [{source, Source},
           {type, describe},
           {target, Owner},
           {context, Context}],
    ShouldSubscribe = _AttributeIsRace = race == proplists:get_value(type, Props),
    {succeed, ShouldSubscribe, Props, Log};
attempt(_) ->
    undefined.

succeed({Props, {Source, describe, Self, with, Context}}) when Self == self() ->
    Log = [{source, Source},
           {type, describe},
           {target, Self},
           {context, Context}],
    Props2 = describe(Source, Props, Context, deep),
    {Props2, Log};
succeed({Props, {Source, describe, Target, with, Context}}) ->
    Log = [{source, Source},
           {type, describe},
           {target, Target},
           {context, Context}],
    _ = case is_owner(Target, Props) of
            true ->
                describe(Source, Props, Context, shallow);
            _ ->
                ok
        end,
    {Props, Log};
succeed({Props, _Msg}) ->
    {Props, _Log = []}.

-spec fail({proplist(), any(), tuple()}) -> {proplist(), proplist()}.
fail({Props, _Reason, _Msg}) ->
    {Props, _Log = []}.

describe(Source, Props, Context, shallow) ->
    send_description(Source, Props, Context);
describe(Source, Props, Context, deep) ->
    send_description(Source, Props, Context),
    Name = proplists:get_value(name, Props),
    NewContext = <<Context/binary, Name/binary, " -> ">>,
    erlmud_object:attempt(Source, {Source, describe, self(), with, NewContext}).

send_description(Source, Props, Context) ->
    Description = description(Props),
    erlmud_object:attempt(Source, {send, Source, [<<Context/binary>>, Description]}).

is_owner(MaybeOwner, Props) when is_pid(MaybeOwner) ->
    MaybeOwner == proplists:get_value(owner, Props);
is_owner(_, _) ->
    false.

description(Props) when is_list(Props) ->
    Type = proplists:get_value(type, Props),
    DescTemplate = erlmud_config:desc_template(Type),
    log([{desc_template, DescTemplate}, {props, Props}]),
    [[description_part(Props, Part)] || Part <- DescTemplate].

description_part(_, RawText) when is_binary(RawText) ->
    RawText;
description_part(Props, DescProp) ->
    log([{char_desc_part, DescProp}, {props, Props}]),
    prop_description(proplists:get_value(DescProp, Props, <<"??">>)).

prop_description(undefined) ->
    [];
prop_description(Value) when not is_pid(Value) ->
    Value.

log(Proplist) ->
    erlmud_event_log:log(debug, [{module, ?MODULE} | Proplist]).
