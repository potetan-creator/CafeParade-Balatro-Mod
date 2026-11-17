-- Native challenge rules keep these restrictions confined to their own runs.
local members = {'kamiya', 'shinonome', 'aslan', 'makio', 'saki'}

local function modifiers(values)
    local result = {}
    for _, id in ipairs({'dollars', 'hands', 'discards', 'hand_size', 'joker_slots', 'consumable_slots'}) do
        if values[id] ~= nil then result[#result + 1] = {id = id, value = values[id]} end
    end
    return result
end

local function solo(member, options)
    local banned = {{id = 'j_cp_satan'}}
    for _, other in ipairs(members) do
        if other ~= member then banned[#banned + 1] = {id = 'j_cp_' .. other} end
    end
    local jokers = {{id = 'j_cp_' .. member, eternal = true}}
    for _, support in ipairs(options.support or {}) do jokers[#jokers + 1] = {id = support} end
    local custom = {{id = 'cp_solo_member'}, {id = 'cp_finale_unlock'}}
    for _, rule in ipairs(options.custom or {}) do custom[#custom + 1] = rule end
    SMODS.Challenge {
        key = 'solo_' .. member,
        unlocked = function() return true end,
        rules = {custom = custom, modifiers = modifiers(options.modifiers)},
        jokers = jokers,
        deck = options.deck or {type = 'Challenge Deck'},
        consumeables = options.consumeables or {},
        vouchers = {},
        restrictions = {banned_cards = banned, banned_tags = {}, banned_other = {}},
    }
end

solo('kamiya', {
    support = {'j_splash'},
    custom = {{id = 'no_interest'}},
    modifiers = {dollars = 4, hands = 4, discards = 2, hand_size = 8, joker_slots = 4},
})

local pair_deck = {}
for _, suit in ipairs({'H', 'D', 'C', 'S'}) do
    for _, rank in ipairs({'2', '3', '4', '5', '6', '7', '8', '9', 'T', 'A'}) do
        pair_deck[#pair_deck + 1] = {s = suit, r = rank}
    end
end
solo('shinonome', {
    support = {'j_cp_plain_cakeroll'},
    custom = {{id = 'cp_no_faces'}},
    modifiers = {dollars = 4, hands = 4, discards = 1, hand_size = 7, joker_slots = 3},
    deck = {type = 'Challenge Deck', cards = pair_deck},
})

solo('aslan', {
    support = {'j_marble'},
    modifiers = {dollars = 4, hands = 4, discards = 0, hand_size = 9, joker_slots = 3},
    consumeables = {{id = 'c_magician'}},
})

solo('makio', {
    support = {'j_cp_cake_set'},
    modifiers = {dollars = 4, hands = 3, discards = 2, hand_size = 6, joker_slots = 4},
    consumeables = {{id = 'c_mercury'}},
})

solo('saki', {
    support = {'j_cp_cake_set'},
    modifiers = {dollars = 4, hands = 3, discards = 2, hand_size = 8, joker_slots = 4, consumable_slots = 1},
    consumeables = {{id = 'c_lovers'}},
})

local function finale_unlocked()
    local profile = G and G.PROFILES and G.SETTINGS and G.PROFILES[G.SETTINGS.profile]
    local completed = profile and profile.challenge_progress and profile.challenge_progress.completed
    if not completed then return false end
    for _, member in ipairs(members) do
        if not completed['c_cp_solo_' .. member] then return false end
    end
    return true
end

local finale_jokers = {}
for _, member in ipairs(members) do
    finale_jokers[#finale_jokers + 1] = {id = 'j_cp_' .. member, eternal = true}
end
finale_jokers[#finale_jokers + 1] = {id = 'j_cp_satan', eternal = true}

local finale_bans = {}
for _, id in ipairs({
    'v_antimatter', 'c_ectoplasm', 'c_ankh', 'c_judgement', 'c_wraith', 'c_soul',
    'p_buffoon_normal_1', 'p_buffoon_normal_2', 'p_buffoon_jumbo_1', 'p_buffoon_mega_1',
}) do finale_bans[#finale_bans + 1] = {id = id} end
local finale_tags = {}
for _, id in ipairs({'tag_buffoon', 'tag_top_up', 'tag_uncommon', 'tag_rare', 'tag_negative', 'tag_foil', 'tag_holo', 'tag_polychrome'}) do
    finale_tags[#finale_tags + 1] = {id = id}
end

SMODS.Challenge {
    key = 'finale',
    unlocked = finale_unlocked,
    rules = {
        custom = {
            {id = 'cp_finale_roster'}, {id = 'cp_finale_scaling'},
            {id = 'scaling', value = 3, no_ui = true},
            {id = 'no_shop_jokers'}, {id = 'no_interest'}, {id = 'no_extra_hand_money'},
        },
        -- Satan provides the sixth slot. Six base slots would leave a free seventh.
        modifiers = modifiers({dollars = 4, hands = 2, discards = 1, hand_size = 7, joker_slots = 5}),
    },
    jokers = finale_jokers,
    deck = {type = 'Challenge Deck'},
    consumeables = {},
    vouchers = {},
    restrictions = {
        banned_cards = finale_bans,
        banned_tags = finale_tags,
        -- All six Jokers are Eternal, so selling to disable the Leaf is impossible.
        banned_other = {{id = 'bl_final_leaf', type = 'blind'}},
    },
}
