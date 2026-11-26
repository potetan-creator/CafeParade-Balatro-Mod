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
      j_cp_california_gurls = {name = "California Gurls", text = {
        "{C:green}#2# in #3#{} chance for {C:chips}+#1#{} Chips",
        "when you play a hand",
        "{C:green}#4# in #5#{} chance to leave",
        "at end of round",
        "{C:inactive,s:0.6}ｶﾘﾌｫ",
      }},
      j_cp_hazama = {name = "Michio Hazama", text = {
        "{X:mult,C:white} X#1# {} Mult if played",
        "card ranks total {C:attention}#2#{}",
        "{C:inactive}(A=1, J=11, Q=12, K=13)",
      }},
      j_cp_koron = {name = "Koron Chris", text = {
        "Each scored card with a {C:attention}Seal{}",
        "gives {C:chips}+#1#{} Chips",
      }},
      j_cp_sora = {name = "Sora Kitamura", text = {
        "After scoring, add a {C:attention}Chun-Chun Seal{} to",
        "{C:attention}unplayed cards{} of the leftmost card's {C:attention}rank{}",
        "and of {C:attention}different suits{}",
        "{C:inactive}(One per rank and suit)",
        "{C:inactive}(Up to #1# per round)",
      }},
      j_cp_amehiko = {name = "Amehiko Kuzunoha", text = {
        "Gives {X:mult,C:white} X#1# {} Mult for each",
        "{C:dark_edition}Negative{} card you own",
        "Always appears {C:dark_edition}Negative{}",
        "{C:inactive}(Currently {X:mult,C:white} X#2# {C:inactive} Mult)",
      }},
      j_cp_goldpeople = {name = "Goldpeople", text = {
        "{C:blue}Common{} Jokers no longer",
        "appear in {C:attention}Buffoon Packs{}",
      }},
      j_cp_embossing = {name = "Embossing Joker", text = {
        "Each scored {C:attention}Enhanced{} card",
        "gives {C:mult}+#1#{} Mult",
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
        "{C:green}#3# in #4#{} chance to be",
        "eaten at end of round",
      }},
      j_cp_chocolate_spacial = {name = "Chocolate Spacial", text = {
        "With a {C:attention}Flush House{}, create",
        "up to {C:attention}#1#{} random {C:spectral}Spectral{} cards",
        "{C:inactive}(Must have room)",
      }},
      j_cp_cake_set = {name = "Cake Set", text = {
        "If played hand contains a {C:attention}Pair{},",
        "ignore Boss Blind {C:attention}suit debuffs{}",
        "during scoring",
        "{C:green}#1# in #2#{} chance to be",
        "eaten at end of round",
      }},
      j_cp_satan = {name = "Satan", text = {
        "{C:attention}+#1#{} Joker slot; base {X:mult,C:white} X#2# {} Mult",
        "Gives {X:mult,C:white} X#3# {} Mult per {C:attention}Café Parade{} member",
        "Defeat a {C:attention}Boss{}: gain {X:mult,C:white} X#4# {} Mult per member",
        "{C:inactive}(Currently {X:mult,C:white} X#5# {C:inactive} Mult)",
      }},
    },
    Other = {
      cp_chun_chun_seal = {name = "Chun-Chun Seal", text = {
        "{C:mult}+#1#{} Mult when scored",
        "Counts as {C:dark_edition}Negative{}",
        "Expires at end of round",
      }},
      cp_suits = {name = "Counting suits", text = {"Each Wild counts as one suit", "Suit changes are respected"}},
      cp_pair = {name = "Scored pairs", text = {"Two or more scored cards of one rank", "Stone Cards excluded"}},
      cp_makio = {name = "Retrigger targets", text = {"Use the leftmost matching rank", "Up to two cards total"}},
      cp_members = {name = "Café Parade members", text = {"Kamiya, Shinonome, Aslan, Makio, Saki", "Each active kind counts once", "Boss growth survives lost members"}},
    },
  },
  misc = {
    labels = {cp_chun_chun_seal = "Chun-Chun Seal"},
    v_dictionary = {a_cp_growth = "Upgraded! X#1#"},
    dictionary = {
      k_cp_departed = "Departed!",
      k_cp_chun_chun = "Chun-Chun!",
      k_cp_wild = "Makeup!",
      k_cp_suit_relief = "Suit debuffs lifted",
      k_cp_unused = "Ready",
      k_cp_used = "Used",
    },
    challenge_names = {
      c_cp_sora_test = "Sora Kitamura: Chun-Chun Test",
      c_cp_amehiko_test = "Amehiko Kuzunoha: Negative Test",
      c_cp_solo_kamiya = "Kamiya: Three-Suit Hospitality",
      c_cp_solo_shinonome = "Shinonome: A Pair at a Time",
      c_cp_solo_aslan = "Aslan: Dark Patisserie",
      c_cp_solo_makio = "Makio: Cake for Two",
      c_cp_solo_saki = "Saki: Makeup! One Stage",
      c_cp_finale = "Café Parade: Devil's Full Course",
    },
    v_text = {
      ch_c_cp_sora_test = {
        "Play the 2, 3, and 4 of Hearts separately",
        "Check three seals per hand, up to nine",
        "Check Amehiko and seal expiry",
      },
      ch_c_cp_amehiko_test = {
        "{C:attention}Test run{}: start with {C:attention}5 Negative cards{}",
        "Amehiko starts at {X:mult,C:white} X2.25 {} Mult",
        "All {C:attention}8 playing cards{} fit in the first hand",
        "Sell, use or destroy cards to check {C:attention}Mult changes{}",
      },
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
