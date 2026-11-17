-- 効果確認専用。通常ランのルール・カード能力は変更しない。
SMODS.Challenge {
    key = 'practice',
    unlocked = function() return true end,
    rules = {
        custom = {{id = 'cp_practice'}},
        modifiers = {
            {id = 'dollars', value = 20},
            {id = 'hands', value = 6},
            {id = 'discards', value = 6},
            {id = 'hand_size', value = 8},
            {id = 'joker_slots', value = 8},
        },
    },
    jokers = {
        {id = 'j_cp_kamiya'}, {id = 'j_cp_shinonome'}, {id = 'j_cp_aslan'},
        {id = 'j_cp_makio'}, {id = 'j_cp_saki'}, {id = 'j_cp_satan'},
    },
    -- 全8枚が初手にそろう。フルハウスで6枚の連携を確認できる。
    deck = {type = 'Challenge Deck', cards = {
        {s = 'H', r = '2'},
        {s = 'D', r = '2'},
        {s = 'C', r = '2', e = 'm_wild'},
        {s = 'H', r = '3', e = 'm_bonus'},
        {s = 'S', r = '3', e = 'm_mult', g = 'Red'},
        {s = 'D', r = '4'},
        {s = 'S', r = '4'},
        {s = 'C', r = '5', e = 'm_steel'},
    }},
    consumeables = {},
    vouchers = {},
    restrictions = {banned_cards = {}, banned_tags = {}, banned_other = {}},
}
