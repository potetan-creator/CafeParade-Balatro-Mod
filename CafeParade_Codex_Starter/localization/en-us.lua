return {
  descriptions = {
    Joker = {
      j_cp_kamiya = {name = "Yukihiro Kamiya", text = {
        "If scored cards cover {C:attention}#1# suits{},",
        "earn {C:money}$#2#{} and a {C:green}#3# in #4#{} chance",
        "for a {C:tarot}Tarot{} {C:inactive}(must have room)",
        "{C:inactive}(Once per blind; #6#)",
      }},
      j_cp_shinonome = {name = "Soichiro Shinonome", text = {
        "{X:mult,C:white} X#3# {} Mult",
        "Hands with a {C:attention}Pair{}: {C:mult}+#1#{} Mult,",
        "then gain {C:attention}#2#{} XMult after scoring",
      }},
      j_cp_aslan = {name = "Aslan BB II", text = {
        "Each scored {C:attention}Enhanced{} card",
        "gives {X:mult,C:white} X#1# {} Mult",
      }},
      j_cp_makio = {name = "Makio Uzuki", text = {
        "Retrigger scored {C:attention}Pair{} cards",
        "{C:attention}#2#{} additional time",
        "{C:inactive}(Up to #1# cards, from the left)",
      }},
      j_cp_saki = {name = "Saki Mizushima", text = {
        "Each played {C:attention}Wild Card{} gives",
        "{X:mult,C:white} X#1# {} Mult when scored",
        "{C:attention}First played card{} becomes",
        "a {C:attention}Wild Card{} if unenhanced",
        "{C:inactive}(Once per blind; #3#)",
      }},
      j_cp_three_one_five = {name = "THREE ONE FIVE", text = {
        "{X:mult,C:white} X#1# {} Mult if played hand",
        "contains a {C:attention}3{} and a {C:attention}5{}, and",
        "at least one of them scores",
        "{C:inactive,s:0.6}アイドルマスターSideM×FiFS展 THREE ONE FIVE",
      }},
      j_cp_plain_cakeroll = {name = "Plain cakeroll", text = {
        "If exactly {C:attention}#2#{} cards score,",
        "each gives {C:chips}+#1#{} Chips",
        "when scored",
      }},
      j_cp_chocolate_spacial = {name = "Chocolate Spacial", text = {
        "With a {C:attention}Flush House{}, create",
        "up to {C:attention}#1#{} random {C:spectral}Spectral{} cards",
        "{C:inactive}(Must have room)",
      }},
      j_cp_cake_set = {name = "Cake Set", text = {
        "When playing exactly a {C:attention}Pair{},",
        "ignore Boss Blind {C:attention}suit debuffs{}",
        "during scoring",
      }},
      j_cp_satan = {name = "Satan", text = {
        "{C:attention}+#1#{} Joker slot; base {X:mult,C:white} X#2# {} Mult",
        "{C:attention}+#3#{} XMult per member",
        "{C:attention}Boss defeated{}: grow {C:attention}#4#{} per member",
        "{C:inactive}(#5# members; +#6# growth)",
        "{C:inactive}(Currently {X:mult,C:white} X#7# {C:inactive} Mult)",
      }},
    },
    Other = {
      cp_suits = {name = "Counting suits", text = {"Each Wild counts as one suit", "Suit changes are respected"}},
      cp_pair = {name = "Scored pairs", text = {"Two or more scored cards of one rank", "Stone Cards excluded"}},
      cp_makio = {name = "Retrigger targets", text = {"Use the leftmost matching rank", "Up to two cards total"}},
      cp_members = {name = "Café Parade members", text = {"Kamiya, Shinonome, Aslan, Makio, Saki", "Each active kind counts once", "Boss growth survives lost members"}},
    },
  },
  misc = {
    v_dictionary = {a_cp_growth = "Upgraded! X#1#"},
    dictionary = {
      k_cp_wild = "Makeup!",
      k_cp_suit_relief = "Suit debuffs lifted",
      k_cp_unused = "Ready",
      k_cp_used = "Used",
    },
    challenge_names = {
      c_cp_practice = "Café Parade: Practice Live",
      c_cp_solo_kamiya = "Kamiya: Three-Suit Hospitality",
      c_cp_solo_shinonome = "Shinonome: A Pair at a Time",
      c_cp_solo_aslan = "Aslan: Dark Patisserie",
      c_cp_solo_makio = "Makio: Cake for Two",
      c_cp_solo_saki = "Saki: Makeup! One Stage",
      c_cp_finale = "Café Parade: Devil's Full Course",
    },
    v_text = {
      ch_c_cp_solo_member = {
        "Your featured member is {C:attention}Eternal{}",
        "Other members and Satan cannot appear",
      },
      ch_c_cp_finale_unlock = {
        "Beat all five solo challenges to unlock",
        "{C:attention}Devil's Full Course{}",
      },
      ch_c_cp_no_faces = {"Start with {C:attention}40 cards{} and no face cards"},
      ch_c_cp_finale_roster = {
        "{C:attention}All five members and Satan{} are Eternal",
        "No additional Jokers can be obtained",
      },
      ch_c_cp_finale_scaling = {"Required scores scale as in {C:attention}Purple Stake{}"},
      ch_c_cp_practice = {
        "Start with all six Café Parade Jokers",
        "All eight deck cards fit in the opening hand",
      },
    },
  },
}
