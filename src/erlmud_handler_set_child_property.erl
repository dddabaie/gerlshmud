%% Copyright (c) 2015, Chris Maguire <cwmaguire@gmail.com>
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
-module(erlmud_handler_set_child_property).
-behaviour(erlmud_handler).

%% @doc Only if the message has our owner do we set the character and
%% then propagate the message. Otherwise we are not a child of the
%% source process and the message shouldn't go any further, so we fail
%% it. Nothing should subscribe to the message.
%%
%% This should cause a cascade of messages that keep starting at the current
%% child and going out to children until it runs out of children.
%%
%% If we move an item from one character to another, one body_part to another
%% or one item to another then we might get a "clear" and "set" out of order.
%% If we're going to clear out a previous character, body_part or owner we
%% need to specify what value we're clearing out. If that value is already
%% set to something else then we should leave it as is.

-include("include/erlmud.hrl").

%% object behaviour
-export([attempt/1]).
-export([succeed/1]).
-export([fail/1]).

attempt({#parents{owner = Owner},
         Props,
         {Owner, set_child_property, Key, Value}}) ->
    Log = [{source, Owner},
           {type, set_child_property},
           {key, Key},
           {value, Value}],
    NewMessage = {self(), set_child_property, Key, Value},
    Props2 = lists:keystore(Key, 1, Props, {Key, Value}),
    {{broadcast, NewMessage}, false, Props2, Log};
attempt({#parents{owner = Owner},
         Props,
         {Owner, set_child_properties, ParentProps}}) ->
    Log = [{source, Owner},
           {type, set_child_properties}],
    NewMessage = {self(), set_child_properties, ParentProps},
    Props2 = lists:foldl(fun apply_parent_prop/2, Props, ParentProps),
    {{broadcast, NewMessage}, false, Props2, Log};
attempt({#parents{owner = Owner},
         Props,
         {Owner, clear_child_property, Key = top_item,
          'if', TopItem = #top_item{item = Item, ref = Ref}}}) ->
    Log = [{source, Owner},
           {type, clear_child_property},
           {key, Key}],
    NewMessage = {self(), clear_child_property, top_item, 'if', TopItem},
    %% Only clear the top item if our #top_item{} has the same ref.
    %% Otherwise another item (or this same item) may have already
    %% set our top_item to itself
    %% e.g. self() goes from Parent->NotParent->Parent
    %% In which case will unset and reset itself as the top item, but maybe
    %% not always in the right order (because of graph traversal)
    Props2 = case proplists:get_value(top_item, Props) of
                 #top_item{item = Item, ref = Ref} ->
                     lists:keydelete(top_item, 1, Props);
                 _ ->
                     Props
             end,
    {{broadcast, NewMessage}, false, Props2, Log};
attempt({#parents{owner = Owner},
         Props,
         {Owner, clear_child_property, Key, 'if', Value}}) ->
    Log = [{source, Owner},
           {type, clear_child_property},
           {key, Key},
           {value, Value}],
    NewMessage = {self(), clear_child_property, Key, 'if', Value},
    Props2 = case proplists:get_value(Key, Props) of
                 Value ->
                     lists:keydelete(Key, 1, Props);
                 _ ->
                     Props
             end,
    {{broadcast, NewMessage}, false, Props2, Log};
attempt({_, Props, {_, set_child_property, _, _}}) ->
    Log = [{type, set_child_property}],
    {{fail, not_a_child}, _Subscribe = false, Props, Log};
attempt(_) ->
    undefined.


succeed({Props, _Msg}) ->
    Props.

fail({Props, _, _}) ->
    Props.

apply_parent_prop({K, V}, Props) ->
    lists:keystore(K, 1, Props, {K, V}).
