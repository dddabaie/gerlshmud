-define(PID(Value), {pid, Value}).

-define(UNIVERSAL_HANDLERS, erlmud_handler_set_child_property).

-define(ROOM_HANDLERS, {handlers, [erlmud_handler_room_inject_self,
                                   erlmud_handler_room_inv,
                                   erlmud_handler_room_look,
                                   erlmud_handler_room_move,
                                   ?UNIVERSAL_HANDLERS]}).

-define(CHARACTER_HANDLERS, {handlers, [erlmud_handler_char_attack,
                                        erlmud_handler_char_look,
                                        erlmud_handler_char_inv,
                                        erlmud_handler_char_move,
                                        erlmud_handler_char_inject_self,
                                        erlmud_handler_char_enter_world,
                                        %erlmud_handler_counterattack,
                                        ?UNIVERSAL_HANDLERS]}).

-define(ITEM_HANDLERS, {handlers, [erlmud_handler_item_attack,
                                   erlmud_handler_item_look,
                                   erlmud_handler_item_inv,
                                   erlmud_handler_item_inject_self,
                                   ?UNIVERSAL_HANDLERS]}).

-define(CONN_HANDLERS, {handlers, [erlmud_handler_conn_enter_world,
                                   erlmud_handler_conn_move,
                                   erlmud_handler_conn_send,
                                   ?UNIVERSAL_HANDLERS]}).

-define(BODY_PART_HANDLERS, {handlers, [erlmud_handler_body_part_look,
                                        erlmud_handler_body_part_inv,
                                        erlmud_handler_body_part_inject_self,
                                        ?UNIVERSAL_HANDLERS]}).

-define(ATTRIBUTE_HANDLERS, {handlers, [erlmud_handler_attribute_look,
                                        erlmud_handler_attribute_attack,
                                        ?UNIVERSAL_HANDLERS]}).

-define(EXIT_HANDLERS, {handlers, [erlmud_handler_exit_move,
                                   ?UNIVERSAL_HANDLERS]}).

-define(HITPOINTS_HANDLERS, {handlers, [erlmud_handler_hitpoints_attack,
                                        ?UNIVERSAL_HANDLERS]}).

-define(LIFE_HANDLERS, {handlers, [erlmud_handler_life_attack,
                                   ?UNIVERSAL_HANDLERS]}).

-define(STAT_HANDLERS, {handlers, [erlmud_handler_stat_look,
                                   ?UNIVERSAL_HANDLERS]}).

-define(RESOURCE_HANDLERS, {handlers, [erlmud_handler_resource_inject_self,
                                       erlmud_handler_resource_tick,
                                       erlmud_handler_resource_reserve,
                                       ?UNIVERSAL_HANDLERS]}).

-define(TEST_CONN_HANDLERS, {handlers, [erlmud_handler_test_connection_attack,
                                        ?UNIVERSAL_HANDLERS]}).

-define(WORLD_1, [{room_nw, [{exit, exit_ns}, {exit, exit_ew}, {character, player}, ?ROOM_HANDLERS]},
                  {room_s, [{exit, exit_ns}, ?ROOM_HANDLERS]},
                  {room_e, [{exit, exit_ew}, ?ROOM_HANDLERS]},
                  {player, [{owner, room_nw}, ?CHARACTER_HANDLERS]},
                  {exit_ns, [{{room, n}, room_nw}, {{room, s}, room_s}, ?EXIT_HANDLERS]},
                  {exit_ew, [{{room, w}, room_nw}, {{room, e}, room_e}, {is_locked, true}, ?EXIT_HANDLERS]}]).

-define(WORLD_2, [{room, [{player, player}, {item, sword}, {item, apple}, ?ROOM_HANDLERS]},
                  {player, [{owner, room}, {item, helmet}, ?CHARACTER_HANDLERS]},
                  {sword, [{owner, room}, {name, <<"sword">>}, ?ITEM_HANDLERS]},
                  {helmet, [{owner, player}, {name, <<"helmet">>}, ?ITEM_HANDLERS]},
                  {apple, [{owner, room}, {name, <<"apple">>}, ?ITEM_HANDLERS]}]).

-define(WORLD_3, [{room, [{character, player},
                          {character, zombie},
                          ?ROOM_HANDLERS]},

                  {player, [{owner, room},
                            {hitpoints, p_hp},
                            {life, p_life},
                            {attribute, dexterity0},
                            {attack_types, [hand]},
                            %% TODO: why is stamina a first class property
                            %% instead of just an attribute?
                            {stamina, p_stamina},
                            {body_part, p_hand},
                            ?CHARACTER_HANDLERS]},
                  {p_hp, [{hitpoints, 1000},
                          {owner, player},
                          ?HITPOINTS_HANDLERS]},
                  {p_life, [{is_alive, true},
                            {owner, player},
                            ?LIFE_HANDLERS]},
                  {p_hand, [{name, <<"hand0">>},
                            {item, p_fist},
                            {owner, player},
                            {max_items, 1},
                            {body_part, hand},
                            ?BODY_PART_HANDLERS]},
                  {p_fist, [{attack_damage_modifier, 5},
                            {attack_hit_modifier, 1},
                            {owner, p_hand},
                            {character, player},
                            {wielding_body_parts, [hand]},
                            {body_part, {?PID(p_hand), hand}},
                            {is_attack, true},
                            {resources, [{stamina, 5}]},
                            ?ITEM_HANDLERS]},
                  {dexterity0, [{attack_hit_modifier, 1},
                                {defence_hit_modifier, 99},
                                {owner, player},
                                {character, player},
                                ?ATTRIBUTE_HANDLERS]},
                  {p_stamina, [{owner, player},
                               {type, stamina},
                               {per_tick, 1},
                               {tick_time, 10},
                               {max, 10},
                               ?RESOURCE_HANDLERS]},

                  {zombie, [{owner, room},
                            {attack_wait, 10},
                            {name, <<"zombie">>},
                            {hitpoints, z_hp},
                            {life, z_life},
                            {attribute, dexterity1},
                            {body_part, z_hand},
                            %% TODO Do something with this
                            %% "melee" can even be an attack command that's
                            %% more specific than just attack:
                            %% "spell zombie"
                            %% "melee zombie"
                            %% "shoot zombie"
                            {attack_types, [melee]},
                            {stamina, z_stamina},
                            ?CHARACTER_HANDLERS]},

                  {z_hand, [{name, <<"left hand">>},
                            {owner, zombie},
                            {body_part, hand},
                            {max_items, 1},
                            {item, sword},
                            ?BODY_PART_HANDLERS]},

                  {z_hp, [{hitpoints, 10},
                          {owner, zombie},
                          ?HITPOINTS_HANDLERS]},

                  {z_life, [{is_alive, true},
                            {owner, zombie},
                            ?LIFE_HANDLERS]},

                  {dexterity1, [{attack_hit_modifier, 1},
                                {owner, zombie},
                                {character, zombie},
                                ?ATTRIBUTE_HANDLERS]},

                  {z_stamina, [{owner, zombie},
                               {type, stamina},
                               {per_tick, 1},
                               {tick_time, 10},
                               {max, 10},
                               {current, 0},
                               ?RESOURCE_HANDLERS]},

                  {sword, [{attack_damage_modifier, 5},
                           {owner, zombie},
                           {character, zombie},
                           {is_attack, true},
                           {is_auto_attack, true},
                           {resources, [{stamina, 5}]},
                           {wielding_body_parts, [hand]},
                           {body_part, {?PID(z_hand), hand}},
                           ?ITEM_HANDLERS]}]).

-define(WORLD_4, [{room, [{player, player}, ?ROOM_HANDLERS]},
                  {player, [{owner, room},
                            {item, helmet},
                            {body_part, head1},
                            ?CHARACTER_HANDLERS]},
                  {head1, [{name, <<"head">>},
                           {body_part, head},
                           {owner, player}, ?BODY_PART_HANDLERS]},
                  {helmet, [{name, <<"helmet">>},
                            {owner, player},
                            {character, player},
                            {attribute, dex_buff},
                            {body_parts, [head]}, ?ITEM_HANDLERS]},
                  {dex_buff, [{name, <<"dex_buff">>},
                              {owner, helmet},
                              ?ATTRIBUTE_HANDLERS]}]).

-define(WORLD_5, [{player, [{item, helmet},
                            {body_part, head1},
                            {body_part, finger1},
                            ?CHARACTER_HANDLERS]},
                  {head1, [{name, <<"head">>},
                           {owner, player},
                           {body_part, head},
                           ?BODY_PART_HANDLERS]},
                  {finger1, [{name, <<"finger">>},
                             {owner, player},
                             {body_part, finger},
                             ?BODY_PART_HANDLERS]},
                  {helmet, [{owner, player},
                            {name, <<"helmet">>},
                            {body_parts, [head, hand]},
                            ?ITEM_HANDLERS]}]).

-define(WORLD_6, [{player, [{body_part, finger1},
                            {body_part, finger2},
                            {item, ring1},
                            {item, ring2},
                            ?CHARACTER_HANDLERS]},
                  {finger1, [{name, <<"finger1">>},
                             {owner, player},
                             {max_items, 1},
                             {body_part, finger},
                             ?BODY_PART_HANDLERS]},
                  {finger2, [{name, <<"finger2">>},
                             {owner, player},
                             {max_items, 1},
                             {body_part, finger},
                             ?BODY_PART_HANDLERS]},
                  {ring1, [{owner, player},
                           {name, <<"ring1">>},
                           {body_parts, [finger]},
                           ?ITEM_HANDLERS]},
                  {ring2, [{owner, player},
                           {name, <<"ring2">>},
                           {body_parts, [finger]},
                           ?ITEM_HANDLERS]}]).

-define(WORLD_7, [{room, [{character, giant},
                          {name, <<"room">>},
                          {desc, <<"an empty space">>},
                          {item, bread},
                          ?ROOM_HANDLERS]},

                  {player, [{name, <<"Bob">>},
                            {attribute, height0},
                            {attribute, weight0},
                            {attribute, gender0},
                            {attribute, race0},
                            ?CHARACTER_HANDLERS]},

                  {height0, [{owner, player},
                             {type, height},
                             {value, <<"2.2">>},
                             {desc, [value, <<"m tall">>]},
                             ?ATTRIBUTE_HANDLERS]},

                  {weight0, [{owner, player},
                             {type, weight},
                             {value, <<"128">>},
                             {desc, [<<"weighs ">>, value, <<"kg">>]},
                             ?ATTRIBUTE_HANDLERS]},

                  {gender0, [{owner, player},
                             {type, gender},
                             {value, <<"female">>},
                             {desc, [value]},
                             ?ATTRIBUTE_HANDLERS]},

                  {race0, [{owner, player},
                           {type, race},
                           {value, <<"human">>},
                           {desc, [value]},
                           ?ATTRIBUTE_HANDLERS]},

                  {giant, [{owner, room},
                           {name, <<"Pete">>},
                           {item, pants},
                           {item, sword},
                           {item, scroll},
                           {body_part, legs0},
                           {body_part, hands0},
                           {attribute, height1},
                           {attribute, weight1},
                           {attribute, gender1},
                           {attribute, race1},
                           ?CHARACTER_HANDLERS]},

                  {height1, [{owner, giant},
                             {type, height},
                             {value, <<"4.0">>},
                             {desc, [value, <<"m tall">>]},
                             ?ATTRIBUTE_HANDLERS]},

                  {weight1, [{owner, giant},
                             {type, weight},
                             {value, <<"400.0">>},
                             {desc, [<<"weighs ">>, value, <<"kg">>]},
                             ?ATTRIBUTE_HANDLERS]},

                  {gender1, [{owner, giant},
                             {type, gender},
                             {value, <<"male">>},
                             {desc, [value]},
                             ?ATTRIBUTE_HANDLERS]},

                  {race1, [{owner, giant},
                           {type, race},
                           {value, <<"giant">>},
                           {desc, [value]},
                           ?ATTRIBUTE_HANDLERS]},

                  {legs0, %% if we name this 'legs' then 'legs' will be known as
                          %% as an object ID. If 'legs' is an object identifier
                          %% then a {body_part, legs} property on a body_part,
                          %% i.e. the type of the body part, will be changed
                          %% into {body_part, <PID OF LEGS OBJECT>}
                          [{name, <<"legs">>},
                           {owner, giant},
                           {max_items, 1},
                           {body_part, legs},
                           ?BODY_PART_HANDLERS]},
                  {hands0, [{name, <<"hands">>},
                            {owner, giant},
                            {max_items, 1},
                            {body_part, hands},
                            ?BODY_PART_HANDLERS]},

                  {pants, [{owner, giant},
                           {body_parts, [legs]},
                           {name, <<"pants_">>},
                           {desc, <<"pants">>},
                           ?ITEM_HANDLERS]},
                  {sword, [{owner, giant},
                           {body_parts, [hands]},
                           {name, <<"sword_">>},
                           {desc, <<"sword">>},
                           ?ITEM_HANDLERS]},
                  {scroll, [{owner, giant},
                            {body_parts, []},
                            {name, <<"scroll_">>},
                            {desc, <<"scroll">>},
                            ?ITEM_HANDLERS]},
                  {shoes, [{owner, giant},
                           {body_parts, [feet]},
                           {name, <<"shoes_">>},
                           {desc, <<"shoes">>},
                           ?ITEM_HANDLERS]},
                  {bread, [{owner, room},
                           {name, <<"bread_">>},
                           {desc, <<"a loaf of bread">>},
                           ?ITEM_HANDLERS]}
                 ]).

-define(WORLD_8, [{room, [{is_room, true},
                          {character, giant},
                          {character, player},
                          {item, shield},
                          {item, force_field},
                          {name, <<"room">>},
                          {desc, <<"an empty space">>},
                          ?ROOM_HANDLERS]},

                  {player, [{name, <<"Bob">>},
                            {owner, room},
                            {hitpoints, p_hp},
                            {life, p_life},
                            {attribute, strength0},
                            {attribute, dexterity0},
                            {stamina, p_stamina},
                            {body_part, p_back},
                            {body_part, hand0},
                            {body_part, hand1},
                            {race, race0},
                            ?CHARACTER_HANDLERS]},


                  {p_hp, [{hitpoints, 10},
                          {owner, player},
                          ?HITPOINTS_HANDLERS]},

                  {p_life, [{is_alive, true},
                            {owner, player},
                            ?LIFE_HANDLERS]},

                  {force_field, [{owner, player},
                                 {body_parts, [back]},
                                 {wielding_body_parts, [back]},
                                 {name, <<"force field">>},
                                 {desc, [name]},
                                 {defence_damage_modifier, 100},
                                 {is_defence, true},
                                 ?ITEM_HANDLERS]},

                  {shield, [{owner, player},
                            {body_parts, [hand]},
                            {wielding_body_parts, [hand]},
                            {name, <<"shield">>},
                            {desc, [name]},
                            {defence_hit_modifier, 100},
                            {is_defence, true},
                            ?ITEM_HANDLERS]},

                  {strength0, [{owner, player},
                               {type, strength},
                               {value, 17},
                               {attack_damage_modifier, 100},
                               {desc, [<<"strength ">>, value]},
                               ?ATTRIBUTE_HANDLERS]},

                  {dexterity0, [{owner, player},
                                {type, dexterity},
                                {value, 15},
                                {attack_hit_modifier, 100},
                                {desc, [<<"dexterity ">>, value]},
                                ?ATTRIBUTE_HANDLERS]},

                  {p_stamina, [{owner, player},
                               {type, stamina},
                               {per_tick, 1},
                               {tick_time, 10},
                               {max, 10},
                               ?RESOURCE_HANDLERS]},

                  {hand0,   [{name, <<"left hand">>},
                             {owner, player},
                             {body_part, hand},
                             {max_items, 1},
                             {item, p_fist},
                             ?BODY_PART_HANDLERS]},

                  {hand1,   [{name, <<"right hand">>},
                             {owner, player},
                             {body_part, hand},
                             {max_items, 1},
                             ?BODY_PART_HANDLERS]},

                  {p_fist, [{name, <<"left fist">>},
                            {attack_damage_modifier, 50},
                            {attack_hit_modifier, 1},
                            {owner, p_hand},
                            {character, player},
                            {wielding_body_parts, [hand]},
                            {body_part, {?PID(hand0), hand}},
                            {is_attack, true},
                            {is_auto_attack, true},
                            {resources, [{stamina, 5}]},
                            ?ITEM_HANDLERS]},

                  {p_back,   [{name, <<"back">>},
                             {owner, player},
                             {body_part, back},
                             {max_items, 2},
                             ?BODY_PART_HANDLERS]},

                  {giant, [{owner, room},
                           {name, <<"Pete">>},
                           {hitpoints, g_hp},
                           {life, g_life},
                           {body_part, g_hand_r},
                           {attribute, strength1},
                           {attribute, dexterity1},
                           {attribute, race},
                           {stamina, g_stamina},
                           ?CHARACTER_HANDLERS]},

                  {g_hp, [{hitpoints, 310},
                          {owner, giant},
                          ?HITPOINTS_HANDLERS]},

                  {g_life, [{is_alive, true},
                            {owner, giant},
                            ?LIFE_HANDLERS]},

                  {g_hand_r, [{name, <<"right hand">>},
                              {owner, giant},
                              {body_part, hand},
                              {item, g_club},
                              ?BODY_PART_HANDLERS]},

                  {strength1, [{owner, giant},
                               {type, strength},
                               {value, 17},
                               {attack_damage_modifier, 50},
                               {desc, [<<"strength ">>, value]},
                               ?ATTRIBUTE_HANDLERS]},

                  {dexterity1, [{owner, player},
                                {type, dexterity},
                                {value, 15},
                                {attack_hit_modifier, 50},
                                {defence_hit_modifier, 50},
                                {desc, [<<"dexterity ">>, value]},
                                ?ATTRIBUTE_HANDLERS]},

                  {g_stamina, [{owner, giant},
                               {type, stamina},
                               {per_tick, 1},
                               {tick_time, 10},
                               {max, 10},
                               ?RESOURCE_HANDLERS]},

                  {race0, [{owner, giant},
                           {defence_damage_modifier, 50},
                           {desc, [<<"giant">>]},
                           ?ATTRIBUTE_HANDLERS]},

                  {g_club, [{name, <<"giant club">>},
                            {attack_damage_modifier, 50},
                            {attack_hit_modifier, 5},
                            {owner, g_hand_r},
                            {character, giant},
                            {wielding_body_parts, [hand]},
                            {body_part, {?PID(g_hand_r), hand}},
                            {is_attack, true},
                            {is_auto_attack, true},
                            {resources, [{stamina, 5}]},
                            ?ITEM_HANDLERS]}
                 ]).

-define(WORLD_9, [{room, [{character, dog},
                          {item, collar},
                          ?ROOM_HANDLERS]},

                  {dog, [{owner, room},
                         ?CHARACTER_HANDLERS]},

                  {collar, [{owner, room},
                            {item, transmitter},
                            ?ITEM_HANDLERS]},

                  {transmitter, [{owner, collar},
                                 {attribute, stealth},
                                 ?ITEM_HANDLERS]},

                  {stealth, [{owner, transmitter},
                             ?ATTRIBUTE_HANDLERS]} ]).

-define(WORLD_10, [{room, [{character, player},
                           {item, rifle},
                           ?ROOM_HANDLERS]},

                   {player, [{owner, room},
                             ?CHARACTER_HANDLERS]},

                   {rifle, [{owner, room},
                            {name, <<"rifle">>},
                            {item, suppressor},
                            {item, grip},
                            {item, clip},
                            ?ITEM_HANDLERS]},

                   {suppressor, [{owner, rifle},
                                 {name, <<"suppressor">>},
                                 {top_item, rifle},
                                 ?ITEM_HANDLERS]},

                   {grip, [{owner, rifle},
                           {name, <<"grip">>},
                           {top_item, rifle},
                           ?ITEM_HANDLERS]},

                   {clip, [{owner, rifle},
                           {name, <<"clip">>},
                           {top_item, rifle},
                           {item, bullet},
                           ?ITEM_HANDLERS]},

                   {bullet, [{owner, clip},
                             {name, <<"bullet">>},
                             {top_item, rifle},
                             ?ITEM_HANDLERS]} ]).
