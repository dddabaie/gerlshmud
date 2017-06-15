-record(parents, {owner :: pid(),
                  character :: pid(),
                  top_item :: pid(),
                  body_part :: pid()}).

%-record(attack, {source :: pid(),
                 %target :: pid(),
                 %attack_types = [] :: [atom()],
                 %hit :: integer(),
                 %damage :: integer(),
                 %calc_type :: hit | damage | weight}).

-record(top_item, {item :: pid(),
                   is_active :: boolean(),
                   is_wielded :: boolean()}).
