%% Copyright (c) 2016, Chris Maguire <cwmaguire@gmail.com>
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
-module(erlmud_handler_body_part_inv).
-behaviour(erlmud_handler).

-export([can_add/2]).

-export([attempt/1]).
-export([succeed/1]).
-export([fail/1]).

attempt({Owner, Props, {move, Item, from, Self, to, Owner}})
  when Self == self(),
       is_pid(Item) ->
    {succeed, has_item(Item, Props), Props};
attempt({Owner, Props, {move, Item, from, Owner, to, Self}})
  when Self == self(),
       is_pid(Item) ->
    NewMessage = {move, Item, from, Owner, to, Self, item_body_parts},
    Result = {resend, Owner, NewMessage},
    {Result, _Subscribe = true, Props};
attempt({Owner, Props, {move, Item, from, Owner, to, Self, ItemBodyParts}})
  when Self == self(),
       is_pid(Item),
       is_list(ItemBodyParts) ->
    case can(add, Props, ItemBodyParts) of
        {false, Reason} ->
            {{fail, Reason}, _Subscribe = false, Props};
        _ ->
            {succeed, _Subscribe = true, Props}
    end;
attempt(_) ->
    undefined.

succeed({Props, {move, Item, from, _OldOwner, to, Self, _ItemBodyParts}})
  when Self == self() ->
    [{item, Item} | Props];
succeed({Props, {move, Item, from, Self, to, _NewOwner}})
  when Self == self() ->
    lists:keydelete(Item, 2, Props);
succeed({Props, {move, Item, from, Self, to, _NewOwner, _ItemBodyParts}})
  when Self == self() ->
    lists:keydelete(Item, 2, Props);
succeed({Props, _}) ->
    Props.

fail({Props, _, _}) ->
    Props.

has_item(Item, Props) ->
    {item, Item} == lists:keyfind(Item, 2, Props).

can(add, Props, ItemBodyParts) ->
    can_add(Props, ItemBodyParts);
can(remove, Props, Item) ->
    can_remove(Props, Item).

can_add([], _, _, Result) ->
    log(debug, [<<"can_add([], _, _, ">>, Result ,<<")">>]),
    Result;
can_add(_, _, _, {false, Reason}) ->
    log(debug, [<<"can_add([_ | _], _, _, {false, ">>, list_to_binary(Reason),<<"})">>]),
    {false, Reason};
can_add([Fun | Funs], Props, ItemBodyParts, true) ->
    log(debug, [<<"can_add([">>, Fun, <<" | ">>,
                Funs, <<"], ">>, Props, <<", ">>,
                ItemBodyParts, <<", true)">>]),
    can_add(Funs, Props, ItemBodyParts, Fun(Props, ItemBodyParts)).

can_remove(_Props, _Item) ->
    true.

can_add(Props, ItemBodyParts) ->
    can_add([fun has_matching_body_part/2,
             fun has_space/2], Props, ItemBodyParts, true).

has_matching_body_part(Props, ItemBodyParts) ->
    BodyPart = proplists:get_value(body_part, Props, any),
    log(debug, [<<"has_matching_body_part(">>, BodyPart,
         <<", [">>, ItemBodyParts, <<"]):">>,
         lists:member(BodyPart, ItemBodyParts)]),
    case {BodyPart, lists:member(BodyPart, ItemBodyParts)} of
        {any, _} ->
            true;
        {_, true} ->
            true;
        {_, _} ->
            {false, "Item is not compatible with body part"}
    end.

has_space(Props, _) ->
    NumItems = length(proplists:get_all_values(item, Props)),
    MaxItems = proplists:get_value(max_items, Props, infinite),
    log(debug, [<<"has_space(">>, Props, <<") Num items: ">>, NumItems, <<" Max items: ">>, MaxItems]),
    case proplists:get_value(max_items, Props, infinite) of
        infinite ->
            true;
        MaxItems when NumItems < MaxItems ->
            true;
        _ ->
            {false, "Body part is full"}
    end.

log(Level, IoData) ->
    erlmud_event_log:log(Level, [list_to_binary(atom_to_list(?MODULE)) | IoData]).