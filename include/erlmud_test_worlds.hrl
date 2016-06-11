-define(ROOM_HANDLERS, {handlers, [erlmud_handler_room_inject_self,
                                   erlmud_handler_room_inv,
                                   erlmud_handler_room_look,
                                   erlmud_handler_room_move]}).
-define(CHARACTER_HANDLERS, {handlers, [erlmud_handler_char_attack,
                                        erlmud_handler_char_look,
                                        erlmud_handler_char_inv,
                                        erlmud_handler_char_move]}).
-define(BODY_PART_HANDLERS, {handlers, [erlmud_handler_body_part_look,
                                        erlmud_handler_body_part_inv]}).
-define(ATTRIBUTE_HANDLERS, {handlers, [erlmud_handler_attribute_look]}).
-define(CONN_HANDLERS, {handlers, [erlmud_handler_conn_enter_world,
                                   erlmud_handler_conn_move,
                                   erlmud_handler_conn_send]}).
-define(EXIT_HANDLERS, {handlers, [erlmud_handler_exit_move]}).
-define(HITPOINTS_HANDLERS, {handlers, [erlmud_handler_hitpoints_attack]}).
-define(ITEM_HANDLERS, {handlers, [erlmud_handler_item_attack,
                                   erlmud_handler_item_look,
                                   erlmud_handler_item_inv,
                                   erlmud_handler_item_inject_self]}).
-define(LIFE_HANDLERS, {handlers, [erlmud_handler_life_attack]}).
-define(STAT_HANDLERS, {handlers, [erlmud_handler_stat_look]}).
-define(TEST_CONN_HANDLERS, {handlers, [erlmud_handler_test_connection_attack]}).

-define(WORLD_1, [{erlmud_room, room_nw, [{exit, exit_ns}, {exit, exit_ew}, {character, player}, ?ROOM_HANDLERS]},
                  {erlmud_room, room_s, [{exit, exit_ns}, ?ROOM_HANDLERS]},
                  {erlmud_room, room_e, [{exit, exit_ew}, ?ROOM_HANDLERS]},
                  {erlmud_character, player, [{owner, room_nw}]},
                  {erlmud_exit, exit_ns, [{{room, n}, room_nw}, {{room, s}, room_s}]},
                  {erlmud_exit, exit_ew, [{{room, w}, room_nw}, {{room, e}, room_e}, {is_locked, true}]}]).

-define(WORLD_2, [{erlmud_room, room, [{player, player}, {item, sword}, {item, apple}, ?ROOM_HANDLERS]},
                  {erlmud_character, player, [{owner, room}, {item, helmet}]},
                  {erlmud_item, sword, [{owner, room}, {name, <<"sword">>}]},
                  {erlmud_item, helmet, [{owner, player}, {name, <<"helmet">>}]},
                  {erlmud_item, apple, [{owner, room}, {name, <<"apple">>}]}]).

-define(WORLD_3, [{erlmud_room, room, [{character, player},
                                       {character, zombie},
                                       ?ROOM_HANLDERS]},

                  {erlmud_character, player, [{owner, room},
                                              {attack_wait, 10},
                                              {item, fist},
                                              {hitpoints, p_hp},
                                              {life, p_life}]},
                  {erlmud_hitpoints, p_hp, [{hitpoints, 1000},
                                            {owner, player}]},
                  {erlmud_life, p_life, [{is_alive, true},
                                         {owner, player}]},
                  {erlmud_item, fist, [{dmg, 5},
                                       {owner, player}]},

                  {erlmud_character, zombie, [{owner, room},
                                              {attack_wait, 10},
                                              {item, sword},
                                              {name, <<"zombie">>},
                                              {hitpoints, z_hp},
                                              {life, z_life}]},
                  {erlmud_hitpoints, z_hp, [{hitpoints, 10},
                                            {owner, zombie}]},
                  {erlmud_life, z_life, [{is_alive, true},
                                         {owner, zombie}]},
                  {erlmud_item, sword, [{dmg, 5},
                                        {owner, zombie}]}]).

-define(WORLD_4, [{erlmud_room, room, [{player, player}, ?ROOM_HANDLERS]},
                  {erlmud_character, player, [{owner, room},
                                              {item, helmet},
                                              {body_part, head}]},
                  {erlmud_body_part, head, [{name, <<"head">>}, {owner, player}]},
                  {erlmud_item, helmet, [{name, <<"helmet">>}, {owner, player}]}]).

-define(WORLD_5, [{erlmud_character, player, [{item, helmet},
                                              {body_part, head1},
                                              {body_part, finger1}]},
                  {erlmud_body_part, head1, [{name, <<"head">>},
                                             {owner, player},
                                             {body_part, head}]},
                  {erlmud_body_part, finger1, [{name, <<"finger">>},
                                               {owner, player},
                                               {body_part, finger}]},
                  {erlmud_item, helmet, [{owner, player},
                                         {name, <<"helmet">>},
                                         {body_parts, [head, hand]}]}]).

-define(WORLD_6, [{erlmud_character, player, [{body_part, finger1},
                                              {body_part, finger2},
                                              {item, ring1},
                                              {item, ring2}]},
                  {erlmud_body_part, finger1, [{name, <<"finger1">>},
                                               {owner, player},
                                               {max_items, 1},
                                               {body_part, finger}]},
                  {erlmud_body_part, finger2, [{name, <<"finger2">>},
                                               {owner, player},
                                               {max_items, 1},
                                               {body_part, finger}]},
                  {erlmud_item, ring1, [{owner, player},
                                        {name, <<"ring1">>},
                                        {body_parts, [finger]}]},
                  {erlmud_item, ring2, [{owner, player},
                                        {name, <<"ring2">>},
                                        {body_parts, [finger]}]}]).

-define(WORLD_7, [{erlmud_room, room, [{character, giant},
                                       {name, <<"room">>},
                                       {desc, <<"an empty space">>},
                                       {item, bread},
                                       ?ROOM_HANDLERS]},

                  {erlmud_character, player, [{name, <<"Bob">>},
                                              {attribute, height0},
                                              {attribute, weight0},
                                              {attribute, gender0},
                                              {attribute, race0}]},

                  {erlmud_attribute, height0, [{owner, player},
                                               {type, height},
                                               {value, <<"2.2">>},
                                               {desc, [value, <<"m tall">>]}]},

                  {erlmud_attribute, weight0, [{owner, player},
                                               {type, weight},
                                               {value, <<"128">>},
                                               {desc, <<"weighs ">>, value, <<"kg">>}]},

                  {erlmud_attribute, gender0, [{owner, player},
                                               {type, gender},
                                               {value, <<"female">>},
                                               {desc, [value]}]},

                  {erlmud_attribute, race0, [{owner, player},
                                             {type, race},
                                             {value, <<"human">>},
                                             {desc, [value]}]},

                  {erlmud_character, giant, [{owner, room},
                                             {name, <<"Pete">>},
                                             {item, pants},
                                             {item, sword},
                                             {item, scroll},
                                             {body_part, legs0},
                                             {body_part, hands0},
                                             {attribute, height1},
                                             {attribute, weight1},
                                             {attribute, gender1},
                                             {attribute, race1}]},

                  {erlmud_attribute, height1, [{owner, giant},
                                               {type, height},
                                               {value, <<"4.0">>},
                                               {desc, [value, <<"m tall">>]}]},

                  {erlmud_attribute, weight1, [{owner, giant},
                                               {type, weight},
                                               {value, <<"400.0">>},
                                               {desc, [<<"weighs ">>, value, <<"kg">>]}]},

                  {erlmud_attribute, gender1, [{owner, giant},
                                               {type, gender},
                                               {value, <<"male">>},
                                               {desc, [value]}]},

                  {erlmud_attribute, race1, [{owner, giant},
                                             {type, race},
                                             {value, <<"giant">>},
                                             {desc, [value]}]},

                  {erlmud_body_part, legs0, %% if we name this 'legs' then 'legs' will be known as
                                            %% as an object ID. If 'legs' is an object identifier
                                            %% then a {body_part, legs} property on a body_part,
                                            %% i.e. the type of the body part, will be changed
                                            %% into {body_part, <PID OF LEGS OBJECT>}
                                              [{name, <<"legs">>},
                                               {owner, giant},
                                               {max_items, 1},
                                               {body_part, legs}]},
                  {erlmud_body_part, hands0,   [{name, <<"hands">>},
                                                {owner, giant},
                                                {max_items, 1},
                                                {body_part, hands}]},

                  {erlmud_item, pants, [{owner, giant},
                                        {body_parts, [legs]},
                                        {name, <<"pants_">>},
                                        {desc, <<"pants">>}]},
                  {erlmud_item, sword, [{owner, giant},
                                        {body_parts, [hands]},
                                        {name, <<"sword_">>},
                                        {desc, <<"sword">>}]},
                  {erlmud_item, scroll, [{owner, giant},
                                         {body_parts, []},
                                         {name, <<"scroll_">>},
                                         {desc, <<"scroll">>}]},
                  {erlmud_item, shoes, [{owner, giant},
                                        {body_parts, [feet]},
                                        {name, <<"shoes_">>},
                                        {desc, <<"shoes">>}]},
                  {erlmud_item, bread, [{owner, room},
                                        {name, <<"bread_">>},
                                        {desc, <<"a loaf of bread">>}]}
                 ]).
