return {
  descriptions = {
    Joker = {
      j_cp_kamiya = {name = "Yukihiro Kamiya", text = {
        "If scored cards cover {C:attention}#1# suits{},",
        "earn {C:money}$#2#{} and a {C:green}#3# in #4#{} chance",
        "to create a {C:tarot}Tarot{} card",
        "{C:inactive}(Must have room; once per blind)",
        "{C:inactive}(This blind: #6#)",
      }},
      j_cp_shinonome = {name = "Soichiro Shinonome", text = {
        "Played hands containing a {C:attention}Pair{}",
        "give {C:mult}+#1#{} Mult and increase",
        "this Joker's {X:mult,C:white} XMult {} by {C:attention}#2#{}",
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
        "Scored {C:attention}Wild Cards{} give {X:mult,C:white} X#1# {} Mult",
        "After scoring, turn the leftmost",
        "unenhanced scoring card into a {C:attention}Wild Card{}",
        "{C:inactive}(Once per blind; #3#)",
      }},
      j_cp_satan = {name = "Satan", text = {
        "{C:attention}+#1#{} Joker slot; starts at {X:mult,C:white} X#2# {} Mult",
        "Each member adds {C:attention}#3#{} to {X:mult,C:white} XMult {}",
        "Defeating a {C:attention}Boss Blind{} adds",
        "another {C:attention}#4#{} per member permanently",
        "{C:inactive}(#5# members; +#6# growth)",
        "{C:inactive}(Currently {X:mult,C:white} X#7# {C:inactive} Mult)",
      }},
    },
    Other = {
      cp_suits = {name = "Counting suits", text = {"Each Wild Card counts as one suit", "Suit-changing effects are respected"}},
      cp_pair = {name = "Scored pairs", text = {"At least two scored cards of one rank", "Stone Cards do not count"}},
      cp_makio = {name = "Retrigger targets", text = {"Choose the leftmost repeated rank", "At most two cards, even with Two Pair"}},
      cp_members = {name = "Café Parade members", text = {"Kamiya, Shinonome, Aslan, Makio and Saki", "Count each active kind once", "Duplicates and Satan do not add members", "Boss growth remains if members leave"}},
      cp_saki = {name = "Becoming Wild", text = {"Only unenhanced scoring cards can change", "Changes happen after all scoring", "No target means the use is preserved", "Copies only give the scoring Mult"}},
      cp_shinonome = {name = "Growing Mult", text = {"Grows once per hand", "Stored XMult applies even without a Pair", "Copies do not cause extra growth"}},
    },
  },
  misc = {
    dictionary = {
      k_cp_wild = "Wild!",
      k_cp_unused = "Ready",
      k_cp_used = "Used",
    },
    challenge_names = {c_cp_practice = "Café Parade: Practice Live"},
    v_text = {ch_c_cp_practice = {
      "Start with all six Café Parade Jokers",
      "All eight deck cards fit in the opening hand",
    }},
  },
}
