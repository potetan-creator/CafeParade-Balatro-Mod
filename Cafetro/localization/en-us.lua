return {
  descriptions = {
    Mod = {
      CafeParade = {name = "Cafetro!", text = {
        "Adds Jokers inspired by CafeParade,",
        "the idol unit from THE IDOLM@STER SideM,",
        "along with new challenges and",
        "custom playing card designs.",
        "This mod was created with help from",
        "ChatGPT-6.1Sol Codex.",
        "Art:Potetan",
      }},
    },
    Joker = {
      j_cp_goldpeople = {name = "Goldpeople", text = {
        "{C:blue}Common{} Jokers no longer",
        "appear in {C:attention}Buffoon Packs{}",
      }},
      j_cp_embossing = {name = "Embossing Joker", text = {
        "Each played {C:attention}Enhanced{} card",
        "gives {C:mult}+#1#{} Mult when scored",
      }},
      j_cp_sunsun = {name = "SUNSUN", text = {
        "Retrigger each played",
        "{C:attention}6{} an additional {C:attention}#1#{} times",
        "{C:inactive,s:0.6}[Fan art of PUPPET SUNSUN (Unofficial)]",
      }},
      j_cp_kamiya = {name = "Yukihiro Kamiya", text = {
        "If scored cards cover {C:attention}#1# suits{},",
        "earn {C:money}$#2#{} and a {C:green}#3# in #4#{} chance",
        "for a {C:tarot}Tarot{} {C:inactive}(must have room)",
      }},
      j_cp_shinonome = {name = "Soichiro Shinonome", text = {
        "Hands with a {C:attention}Pair{} give {C:mult}+#1#{} Mult",
        "and this Joker gains",
        "{X:mult,C:white} X#2# {} Mult after scoring",
        "{C:inactive}(Currently {X:mult,C:white} X#3# {C:inactive} Mult)",
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
        "{C:attention}Leftmost played card{} becomes",
        "a {C:attention}Wild Card{} if unenhanced",
        "and included in the {C:attention}scoring hand{}",
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
        "Gives {X:mult,C:white} X#3# {} Mult per",
        "{C:attention}Café Parade{} member",
        "Defeat a {C:attention}Boss Blind{}: gain",
        "{X:mult,C:white} X#4# {} Mult per member",
        "{C:inactive}(Currently {X:mult,C:white} X#5# {C:inactive} Mult)",
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
      ch_c_cp_no_faces = {"Start with {C:attention}40 cards{} and no face cards"},
      ch_c_cp_finale_roster = {
        "{C:attention}All five members and Satan{} are Eternal",
        "No additional Jokers can be obtained",
      },
      ch_c_cp_finale_scaling = {"Required scores scale as in {C:attention}Purple Stake{}"},
    },
  },
}
