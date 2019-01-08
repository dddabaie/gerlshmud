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

-include("include/erlmud.hrl").

-export([can_add/2]).

-export([attempt/1]).
-export([succeed/1]).
-export([fail/1]).

attempt({#parents{owner = Owner},
         Props,
         {Item, move, from, Self, to, Owner}})
  when Self == self(),
       is_pid(Item) ->
    {succeed, has_item_with_ref(Item, Props), Props};
attempt({#parents{owner = Owner},
         Props,
         {Item, move, from, Owner, to, Self}})
  when Self == self(),
       is_pid(Item) ->
    NewMessage = {Item, move, from, Owner, to, self(), limited, to, item_body_parts},
    Result = {resend, Owner, NewMessage},
    {Result, _Subscribe = true, Props};
% We know both the target body part and the valid body parts for the item so
% we can see if this body part has space and if this body part matches the item.
attempt({#parents{owner = Owner},
         Props,
         {Item, move, from, Owner, to, Self, limited, to, ItemBodyParts}})
  when Self == self(),
       is_pid(Item),
       is_list(ItemBodyParts) ->
    case can(add, Props, ItemBodyParts) of
        {false, Reason} ->
            {{fail, Reason}, _Subscribe = false, Props};
        _ ->
            BodyPartType = proplists:get_value(body_part, Props, undefined),
            NewMessage = {Item, move, from, Owner, to, self(), on, body_part, type, BodyPartType},
            Result = {resend, Owner, NewMessage},
            {Result, _Subscribe = true, Props}
    end;
%% The reason for "limited, to, item_body_parts" is that there are two conditions that have
%% to be met for an item to be added to a body part:
%% - the body part must have available space (e.g. an empty hand can hold a gun)
%% - the item must fit on that body part (e.g. an axe isn't going to be a hat)
%% This requires both the body part and the item each contribute to the message
%% before we can check if they are met. We add two placeholder flags to the message:
%% - 'first_available_body_part' if we don't know which part it will be yet
%% - 'limited', 'to', 'item_body_parts' if we don't know what body part types are valid
%%   for the body part.
attempt({#parents{owner = Owner},
         Props,
         {Item, move, from, Owner, to, first_available_body_part}})
  when is_pid(Item) ->
    NewMessage = {Item, move, from, Owner, to, first_available_body_part, limited, to, item_body_parts},
    Result = {resend, Owner, NewMessage},
    {Result, _Subscribe = true, Props};
attempt({#parents{owner = Owner},
         Props,
         {Item, move, from, Owner, to, first_available_body_part, limited, to, ItemBodyParts}})
  when is_pid(Item),
       is_list(ItemBodyParts) ->
    case can(add, Props, ItemBodyParts) of
        true ->
            BodyPartType = proplists:get_value(body_part, Props, undefined),
            NewMessage = {Item, move, from, Owner, to, self(), on, body_part, type, BodyPartType},
            Result = {resend, Owner, NewMessage},
            {Result, _Subscribe = true, Props};
        _ ->
            {succeed, _Subscribe = false, Props}
    end;
attempt({#parents{owner = Owner},
         Props,
         {_Item, move, from, Owner, to, Self, on, body_part, type, _BodyPartType}})
  when Self == self() ->
    {succeed, true, Props};
attempt(_) ->
    undefined.

succeed({Props, {Item, move, from, OldOwner, to, Self, on, body_part, type, BodyPartType}})
  when Self == self() ->
    log([{type, get_item}, {item, Item}, {from, OldOwner}]),
    ItemRef = make_ref(),
    erlmud_object:attempt(Item, {self(), set_child_property, body_part,
                                 #body_part{body_part = self(),
                                            type = BodyPartType,
                                            ref = ItemRef}}),
    [{item, {Item, ItemRef}} | Props];
succeed({Props, {Item, move, from, Self, to, NewOwner}})
  when Self == self() ->
    clear_child_body_part(Props, Item, NewOwner);
%% TODO I'm not sure if this gets used: _ItemBodyParts indicates this is an intermediate event
%% that should turn into a {BodyPart, BodyPartType} event
%succeed({Props, {move, Item, from, Self, to, NewOwner, _ItemBodyParts}})
  %when Self == self() ->
    %clear_child_body_part(Props, Item, NewOwner);
succeed({Props, _}) ->
    Props.

fail({Props, _, _}) ->
    Props.

has_item_with_ref(Item, Props) ->
    case [Item_ || {item, {Item_, _Ref}} <- Props, Item_ == Item] of
        [_ | _] ->
            true;
        _ ->
            false
    end.

can(add, Props, ItemBodyParts) ->
    can_add(Props, ItemBodyParts);
can(remove, Props, Item) ->
    can_remove(Props, Item).

can_add(Props, ItemBodyParts) ->
    can_add([fun has_matching_body_part/2,
             fun has_space/2],
            Props,
            ItemBodyParts,
            true).

can_add([], _, _, Result) ->
    log([{type, can_add}, {result, Result}]),
    Result;
can_add(_, _, _, {false, Reason}) ->
    log([{type, can_add}, {result, false}, {reason, Reason}]),
    {false, Reason};
can_add([Fun | Funs], Props, ItemBodyParts, true) ->
    can_add(Funs, Props, ItemBodyParts, Fun(Props, ItemBodyParts)).

can_remove(_Props, _Item) ->
    true.

has_matching_body_part(Props, ItemBodyParts) ->
    BodyPart = proplists:get_value(body_part, Props, any),
    case {BodyPart, lists:member(BodyPart, ItemBodyParts)} of
        {any, _} ->
            true;
        {_, true} ->
            true;
        {_, _} ->
            {false, <<"Item is not compatible with body part">>}
    end.

has_space(Props, _) ->
    NumItems = length(proplists:get_all_values(item, Props)),
    MaxItems = proplists:get_value(max_items, Props, infinite),
    log([{type, has_space}, {num_items, NumItems}, {max_items, MaxItems}]),
    case proplists:get_value(max_items, Props, infinite) of
        infinite ->
            true;
        MaxItems when NumItems < MaxItems ->
            true;
        _ ->
            {false, <<"Body part is full">>}
    end.

clear_child_body_part(Props, Item, Target) ->
    log([{type, give_item}, {to, Target}, {props, Props}]),
    BodyPartType = proplists:get_value(body_part, Props, undefined),
    ItemRef = item_ref(Item, Props),
    erlmud_object:attempt(Item, {Target,
                                 clear_child_property,
                                 body_part,
                                 'if',
                                 #body_part{body_part = self(),
                                            type = BodyPartType,
                                            ref = ItemRef}}),
    lists:keydelete({Item, ItemRef}, 2, Props).

item_ref(Item, Props) ->
    Items = proplists:get_all_values(item, Props),
    case [Ref || {Item_, Ref} <- Items, Item == Item_] of
        [] ->
            undefined;
        [Ref] ->
            Ref
    end.

log(IoData) ->
    erlmud_event_log:log(debug, [{module, ?MODULE} | IoData]).
