-- Development test run, explicitly requested for checking Amehiko in-game.
SMODS.Challenge {
    key = 'amehiko_test',
    unlocked = function() return true end,
    rules = {
        custom = {{id = 'cp_amehiko_test'}},
        modifiers = {
            {id = 'dollars', value = 50},
            {id = 'hands', value = 6},
            {id = 'discards', value = 6},
            {id = 'hand_size', value = 8},
            {id = 'joker_slots', value = 5},
            {id = 'consumable_slots', value = 2},
        },
    },
    jokers = {
        {id = 'j_cp_amehiko', edition = 'negative'},
        {id = 'j_joker', edition = 'negative'},
        {id = 'j_jolly'},
    },
    consumeables = {
        {id = 'c_strength', edition = 'negative'},
        {id = 'c_pluto', edition = 'negative'},
        {id = 'c_hanged_man'},
    },
    -- All eight cards fit in the first hand, including the Negative Heart 2.
    deck = {type = 'Challenge Deck', cards = {
        {s = 'H', r = '2', d = 'negative'},
        {s = 'D', r = '2'}, {s = 'C', r = '2'}, {s = 'S', r = '2'},
        {s = 'H', r = '3'}, {s = 'D', r = '3'},
        {s = 'C', r = '4'}, {s = 'S', r = '5'},
    }},
    vouchers = {},
    restrictions = {banned_cards = {}, banned_tags = {}, banned_other = {}},
    apply = function()
        local run = G.GAME
        -- Vanilla challenge starters ignore consumable edition fields. Wait
        -- without blocking their spawn events, then apply the two editions.
        G.E_MANAGER:add_event(Event({blocking = false, blockable = false, func = function()
            if G.GAME ~= run or run.challenge ~= 'c_cp_amehiko_test'
                or run.cp_amehiko_test_editions then return true end
            local found = {}
            for _, card in ipairs(G.consumeables and G.consumeables.cards or {}) do
                local key = card.config.center.key
                if key == 'c_strength' or key == 'c_pluto' then
                    if not (card.edition and card.edition.negative) then
                        card:set_edition({negative = true}, true, true)
                    end
                    found[key] = true
                end
            end
            if found.c_strength and found.c_pluto then
                run.cp_amehiko_test_editions = true
                return true
            end
            return false
        end}))
    end,
}
