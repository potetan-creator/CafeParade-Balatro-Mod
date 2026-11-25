local deck = {}
for _, rank in ipairs({'2', '3', '4'}) do
    for _, suit in ipairs({'H', 'D', 'C', 'S'}) do
        deck[#deck + 1] = {s = suit, r = rank, d = rank == '2' and suit == 'D' and 'negative' or nil}
    end
end
deck[#deck + 1] = {s = 'H', r = '5', g = 'Red'}

SMODS.Challenge {
    key = 'sora_test',
    unlocked = function() return true end,
    rules = {
        custom = {{id = 'cp_sora_test'}},
        modifiers = {
            {id = 'dollars', value = 50},
            {id = 'hands', value = 8},
            {id = 'hand_size', value = #deck},
            {id = 'joker_slots', value = 5},
        },
    },
    jokers = {
        {id = 'j_blueprint'}, {id = 'j_cp_sora'}, {id = 'j_cp_amehiko'},
    },
    deck = {type = 'Challenge Deck', cards = deck},
}
