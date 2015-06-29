-define(WORLD_1, [{erlmud_room, room_n, [{exit, exit}, {player, player}]},
                  {erlmud_room, room_s, [{exit, exit}]},
                  {erlmud_player, player, [{room, room_n}]},
                  {erlmud_exit, exit, [{{room, n}, room_n}, {{room, s}, room_s}]}]).

-define(WORLD_2, [{erlmud_room, room, [{player, player}, {item, sword}, {item, apple}]},
                  {erlmud_player, player, [{room, room}, {item, helmet}]},
                  {erlmud_item, sword, [{owner, room}, {name, "sword"}]},
                  {erlmud_item, helmet, [{owner, player}, {name, "helmet"}]},
                  {erlmud_item, apple, [{owner, room}, {name, "apple"}]}]).

-define(WORLD_3, [{erlmud_room, room, [{player, player}, {ai, zombie}]},
                  {erlmud_player, player, [{room, room}, {attack_wait, 10}, {item, fist}]},
                  {erlmud_ai, zombie, [{hp, 10}, {room, room}, {name, "zombie"}]},
                  {erlmud_item, fist, [{dmg, 5}, {owner, player}]}]).

-define(WORLD_4, [{erlmud_room, room, [{player, player}]},
                  {erlmud_player, player, [{room, room},
                                           {item, helmet},
                                           {body_part, head}]},
                  {erlmud_body_part, head, [{name, "head"}, {owner, player}]},
                  {erlmud_item, helmet, [{owner, player}, {name, "helmet"}]}]).

-define(WORLD_5, [{erlmud_player, player, [{item, helmet},
                                           {body_part, head1},
                                           {body_part, finger1}]},
                  {erlmud_body_part, head1, [{name, "head"},
                                             {owner, player},
                                             {body_part, head}]},
                  {erlmud_body_part, finger1, [{name, "finger"},
                                               {owner, player},
                                               {body_part, finger}]},
                  {erlmud_item, helmet, [{owner, player},
                                         {name, "helmet"},
                                         {body_parts, [head, hand]}]}]).

-define(WORLD_6, [{erlmud_player, player, [{body_part, finger1},
                                           {body_part, finger2},
                                           {item, ring1},
                                           {item, ring2}]},
                  {erlmud_body_part, finger1, [{name, "finger1"},
                                               {owner, player},
                                               {max_items, 1},
                                               {body_part, finger}]},
                  {erlmud_body_part, finger2, [{name, "finger2"},
                                               {owner, player},
                                               {max_items, 1},
                                               {body_part, finger}]},
                  {erlmud_item, ring1, [{owner, player},
                                        {name, "ring1"},
                                        {body_parts, [finger]}]},
                  {erlmud_item, ring2, [{owner, player},
                                        {name, "ring2"},
                                        {body_parts, [finger]}]}]).

