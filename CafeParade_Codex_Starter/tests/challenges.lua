-- Registration and profile progression contracts; not a Balatro run simulation.
local count = 0
local function eq(actual, expected, label)
    assert(actual == expected, (label or '') .. ': expected ' .. tostring(expected) .. ', got ' .. tostring(actual))
    count = count + 1
end
local function indexed(items)
    local result = {}
    for _, item in ipairs(items) do
        assert(not result[item.id], 'duplicate entry ' .. item.id)
        result[item.id] = item
    end
    return result
end
local definitions = {}
SMODS = {Challenge = function(def)
    assert(not definitions[def.key], 'duplicate challenge key')
    def.id = 'c_cp_' .. def.key -- SMODS.Challenge prefixes keys before registration.
    definitions[def.key] = def
end}
G = nil
dofile(ROOT .. '/challenges/practice.lua')
dofile(ROOT .. '/challenges/member_challenges.lua')
local total = 0
for _ in pairs(definitions) do total = total + 1 end
eq(total,7,'existing practice plus five solos and finale')
local members = {'kamiya','shinonome','aslan','makio','saki'}
local expected = {
    kamiya = {support='j_splash',slots=4,hands=4,discards=2,hand_size=8},
    shinonome = {support='j_cp_plain_cakeroll',slots=3,hands=4,discards=1,hand_size=7},
    aslan = {support='j_marble',slots=3,hands=4,discards=0,hand_size=9,consumable='c_magician'},
    makio = {support='j_cp_cake_set',slots=4,hands=3,discards=2,hand_size=6,consumable='c_mercury'},
    saki = {support='j_cp_cake_set',slots=4,hands=3,discards=2,hand_size=8,consumable='c_lovers'},
}
for _, member in ipairs(members) do
    local challenge = assert(definitions['solo_' .. member])
    local spec = expected[member]
    eq(challenge:unlocked(),true,'solos available without prior clears')
    eq(#challenge.jokers,2)
    eq(challenge.jokers[1].id,'j_cp_' .. member)
    eq(challenge.jokers[1].eternal,true,'main member cannot be sold')
    eq(challenge.jokers[2].id,spec.support)
    eq(challenge.jokers[2].eternal,nil,'support can be replaced')
    local banned = indexed(challenge.restrictions.banned_cards)
    eq(#challenge.restrictions.banned_cards,5)
    eq(banned['j_cp_' .. member],nil,'main member is allowed')
    eq(banned['j_cp_satan'].id,'j_cp_satan')
    for _, other in ipairs(members) do
        if other ~= member then eq(banned['j_cp_' .. other].id,'j_cp_' .. other) end
    end
    local rules = indexed(challenge.rules.custom)
    eq(rules.cp_solo_member.id,'cp_solo_member')
    eq(rules.cp_finale_unlock,nil,'unlock hint is omitted from challenge descriptions')
    local params = indexed(challenge.rules.modifiers)
    eq(params.dollars.value,4)
    eq(params.joker_slots.value,spec.slots)
    eq(params.hands.value,spec.hands)
    eq(params.discards.value,spec.discards)
    eq(params.hand_size.value,spec.hand_size)
    eq(challenge.deck.type,'Challenge Deck')
    eq(#challenge.vouchers,0)
    if spec.consumable then
        eq(#challenge.consumeables,1)
        eq(challenge.consumeables[1].id,spec.consumable)
    else
        eq(#challenge.consumeables,0)
    end
end
eq(indexed(definitions.solo_kamiya.rules.custom).no_interest.id,'no_interest')
eq(indexed(definitions.solo_saki.rules.modifiers).consumable_slots.value,1)
local deck = definitions.solo_shinonome.deck.cards
eq(#deck,40,'face-free starting deck')
local seen, ranks, suits = {}, {}, {}
for _, card in ipairs(deck) do
    local key = card.s .. card.r
    eq(seen[key],nil,'no duplicated starting playing cards'); seen[key] = true
    eq(card.r=='J' or card.r=='Q' or card.r=='K',false,'no faces')
    eq(card.e,nil,'plain starting cards')
    ranks[card.r] = (ranks[card.r] or 0) + 1
    suits[card.s] = (suits[card.s] or 0) + 1
end
for _, rank in ipairs({'2','3','4','5','6','7','8','9','T','A'}) do eq(ranks[rank],4) end
for _, suit in ipairs({'H','D','C','S'}) do eq(suits[suit],10) end
for _, member in ipairs({'kamiya','aslan','makio','saki'}) do
    eq(definitions['solo_' .. member].deck.cards,nil,'default 52-card deck')
end

local finale = definitions.finale
eq(finale:unlocked(),false,'safe without G')
G = {}; eq(finale:unlocked(),false,'safe before profiles initialize')
G.SETTINGS={profile=1}; G.PROFILES={}
eq(finale:unlocked(),false,'missing active profile')
G.PROFILES[1]={}; eq(finale:unlocked(),false,'missing challenge progress')
G.PROFILES[1].challenge_progress={}; eq(finale:unlocked(),false,'missing completed table')
-- Every subset of solo clears: only all five unlock the finale.
for mask=0,31 do
    local completed = {c_cp_practice=true,c_omelette_1=true,c_cp_finale=true}
    for i,member in ipairs(members) do
        if math.floor(mask / 2^(i-1)) % 2 == 1 then completed['c_cp_solo_' .. member] = true end
    end
    G.PROFILES[1].challenge_progress.completed=completed
    eq(finale:unlocked(),mask==31,'completion subset ' .. mask)
end
local complete = G.PROFILES[1]
G.PROFILES[2]={challenge_progress={completed={}}}
G.SETTINGS.profile=2; eq(finale:unlocked(),false,'profile two remains locked')
G.SETTINGS.profile=1; eq(finale:unlocked(),true,'switching back restores unlocked state')
complete.challenge_progress.completed.c_cp_solo_saki=false
eq(finale:unlocked(),false,'false is not a clear')
complete.challenge_progress.completed.c_cp_solo_saki=1
eq(finale:unlocked(),true,'numeric completion records also work')
complete.challenge_progress.completed.c_cp_solo_saki=nil
eq(finale:unlocked(),false,'four clears stay locked')
complete.challenge_progress.completed.c_cp_solo_saki=true
eq(finale:unlocked(),true,'fifth clear unlocks without re-registering')
G.SETTINGS.profile=3; eq(finale:unlocked(),false,'unknown profile does not inherit progress')

eq(#finale.jokers,6)
for i, member in ipairs(members) do
    eq(finale.jokers[i].id,'j_cp_' .. member)
    eq(finale.jokers[i].eternal,true)
end
eq(finale.jokers[6].id,'j_cp_satan'); eq(finale.jokers[6].eternal,true)
local params = indexed(finale.rules.modifiers)
eq(params.hands.value,2); eq(params.discards.value,1); eq(params.hand_size.value,7)
eq(params.joker_slots.value,5,'base slots leave no spare after Satan adds one')
eq(params.dollars.value,4)
local custom = indexed(finale.rules.custom)
eq(custom.scaling.value,3,'native Purple Stake score progression')
eq(custom.scaling.no_ui,true,'localized explanation replaces the internal modifier')
eq(custom.no_shop_jokers.id,'no_shop_jokers')
eq(custom.no_interest.id,'no_interest')
eq(custom.no_extra_hand_money.id,'no_extra_hand_money')
local bans = indexed(finale.restrictions.banned_cards)
for _, id in ipairs({'v_antimatter','c_ectoplasm','c_ankh','c_judgement','c_wraith','c_soul',
    'p_buffoon_normal_1','p_buffoon_normal_2','p_buffoon_jumbo_1','p_buffoon_mega_1'}) do
    eq(bans[id].id,id,'prevent extra Jokers or slots')
end
local tags = indexed(finale.restrictions.banned_tags)
for _, id in ipairs({'tag_buffoon','tag_top_up','tag_uncommon','tag_rare','tag_negative','tag_foil','tag_holo','tag_polychrome'}) do
    eq(tags[id].id,id,'Joker-granting tags banned')
end
eq(finale.restrictions.banned_other[1].id,'bl_final_leaf')
eq(finale.restrictions.banned_other[1].type,'blind','avoid a boss requiring an impossible sale')
eq(#finale.consumeables,0); eq(#finale.vouchers,0)
eq(finale.deck.cards,nil,'full standard deck, no practice cards')
-- Use Satan's actual slot lifecycle with the intended six-card starting roster.
G.jokers={cards={},config={card_limit=params.joker_slots.value}}
local cp={config=dofile(ROOT .. '/config.lua')}
local satan=dofile(ROOT .. '/jokers/satan.lua')(cp)
for _, spec in ipairs(finale.jokers) do
    if spec.id=='j_cp_satan' then satan:add_to_deck({}) end
    table.insert(G.jokers.cards,spec)
    eq(#G.jokers.cards <= G.jokers.config.card_limit,true,'starting roster fits at each step')
end
eq(G.jokers.config.card_limit,#G.jokers.cards,'six slots, six Jokers')
-- All custom UI text and challenge names must exist in both languages.
for _, language in ipairs({'ja','en-us'}) do
    local loc=dofile(ROOT .. '/localization/' .. language .. '.lua').misc
    for _, challenge in pairs(definitions) do
        eq(type(loc.challenge_names[challenge.id]),'string','translated name')
        for _, rule in ipairs(challenge.rules.custom) do
            if rule.id:match('^cp_') and not rule.no_ui then
                eq(type(loc.v_text['ch_c_' .. rule.id]),'table','translated custom rule')
                eq(#loc.v_text['ch_c_' .. rule.id] > 0,true)
            end
        end
    end
end
print('Member challenge and finale progression assertions passed: ' .. count)
