local count = 0
local function eq(actual, expected, label)
    assert(actual == expected, (label or '') .. ': expected ' .. tostring(expected) .. ', got ' .. tostring(actual))
    count = count + 1
end
local function clone(value)
    if type(value)~='table' then return value end
    local result={}; for key,item in pairs(value) do result[key]=clone(item) end; return result
end
local events, calls = {}, {}
G={GAME={round=1,hands_played=0,round_resets={ante=1},blind={config={blind={key='bl_small'}}}},
    consumeables={cards={},config={card_limit=2}},jokers={cards={}},
    C={SECONDARY_SET={Spectral={}}}}
SMODS={Suit={obj_buffer={'Hearts','Diamonds','Clubs','Spades'}},
    pseudorandom_probability=function() return true end,
    add_card=function(args)
        calls[#calls+1]=args
        args.area.cards[#args.area.cards+1]={set=args.set}
    end}
function Event(event) return event end
function localize(key) return key end
G.E_MANAGER={add_event=function(_,event) events[#events+1]=event end}
local cp=dofile(ROOT..'/common.lua')
cp.config=dofile(ROOT..'/config.lua')
local def=dofile(ROOT..'/jokers/chocolate_spacial.lua')(cp)
local function joker()
    return {ability=clone(def.config),config={center={key='j_cp_chocolate_spacial'}}}
end
local function reset(limit, existing, buffer)
    events,calls={},{}
    G.GAME.hands_played=G.GAME.hands_played+1
    G.GAME.consumeable_buffer=buffer
    G.consumeables.config.card_limit=limit
    G.consumeables.cards={}
    for _=1,existing or 0 do G.consumeables.cards[#G.consumeables.cards+1]={} end
end
local function flush()
    while #events>0 do local event=table.remove(events,1); eq(event.func(),true) end
end
local function calc(card, context)
    if not card.debuff then return def:calculate(card,context) end
end
local function house(extra)
    local context=extra or {}
    context.after=true; context.scoring_name='Flush House'
    return context
end

reset(2,0,0)
local card=joker()
eq(def:loc_vars({}).vars[1],2)
eq(calc(card,{before=true,scoring_name='Flush House'}),nil,'generate only after the hand')
eq(#events,0)
local effect=calc(card,house())
eq(effect.message,'k_plus_spectral')
eq(effect.colour,G.C.SECONDARY_SET.Spectral)
eq(G.GAME.consumeable_buffer,2,'reserve both free slots immediately')
eq(#G.consumeables.cards,0,'generation is queued after scoring')
eq(calc(card,house()),nil,'no duplicate evaluation before queued generation')
flush()
eq(#calls,2)
eq(#G.consumeables.cards,2)
eq(G.GAME.consumeable_buffer,0)
for _,args in ipairs(calls) do
    eq(args.set,'Spectral')
    eq(args.key,nil,'let the seeded Spectral pool choose each card')
    eq(args.key_append,'cp_chocolate_spacial')
    eq(args.area,G.consumeables)
end
local restored=joker(); restored.ability=clone(card.ability)
eq(calc(restored,house()),nil,'restored hand flag does not recreate the reward')

for _,name in ipairs({'High Card','Pair','Two Pair','Three of a Kind','Straight','Flush',
    'Full House','Four of a Kind','Straight Flush','Five of a Kind','Flush Five','Custom Flush House'}) do
    reset(2,0,0)
    eq(calc(joker(),{after=true,scoring_name=name,poker_hands={['Flush House']={{}}}}),nil,name..' must not trigger')
    eq(#events,0)
    eq(G.GAME.consumeable_buffer,0)
end

for _,case in ipairs({{2,0,0,2},{2,1,0,1},{2,2,0,0},{4,1,1,2},{2,0,1,1},
    {2,0,2,0},{1,0,0,1},{0,0,0,0}}) do
    local limit,existing,buffer,wanted=unpack(case)
    reset(limit,existing,buffer)
    local result=calc(joker(),house())
    eq(result~=nil,wanted>0)
    eq(G.GAME.consumeable_buffer,buffer+wanted)
    flush()
    eq(#calls,wanted)
    eq(#G.consumeables.cards,existing+wanted)
    eq(G.GAME.consumeable_buffer,buffer,'release only this Joker reservation')
end

reset(6,0,0)
card=joker()
local first_copy={sort_id=42}; local second_copy={sort_id=43}
eq(calc(card,house()).card,card)
eq(calc(card,house({blueprint=1,blueprint_card=first_copy})).card,first_copy)
eq(calc(card,house({blueprint=1,blueprint_card=first_copy})),nil,'each copier triggers once per hand')
eq(calc(card,house({blueprint=1,blueprint_card=second_copy})).card,second_copy)
eq(calc(card,house({retrigger_joker=true})),nil,'retrigger must not duplicate reserved rewards')
eq(G.GAME.consumeable_buffer,6)
flush(); eq(#G.consumeables.cards,6); eq(G.GAME.consumeable_buffer,0)

reset(3,0,0)
calc(joker(),house()); calc(joker(),house())
eq(G.GAME.consumeable_buffer,3,'multiple Jokers share the reservation buffer')
flush(); eq(#G.consumeables.cards,3); eq(G.GAME.consumeable_buffer,0)

reset(2,0,0)
card=joker(); card.debuff=true
eq(calc(card,house()),nil); eq(#events,0)

reset(2,0,0)
card=joker(); calc(card,house()); flush()
reset(2,0,0)
eq(calc(card,house())~=nil,true,'another Flush House in the same blind triggers again')
flush(); eq(#calls,2)

reset(2,0,0)
calc(joker(),house())
G.consumeables.cards={{},{}}
flush(); eq(#G.consumeables.cards,2,'a changed area must not overflow'); eq(#calls,0)
eq(G.GAME.consumeable_buffer,0,'release the reservation when space is lost')

reset(2,0,nil)
calc(joker(),house()); flush()
eq(#calls,2,'missing buffer is treated as zero')
eq(G.GAME.consumeable_buffer,0)

reset(2,0,0)
local kamiya_def=dofile(ROOT..'/jokers/kamiya.lua')(cp)
local kamiya={ability=clone(kamiya_def.config)}
local hand={}
for _,suit in ipairs({'Hearts','Diamonds','Clubs'}) do
    local chosen=suit
    hand[#hand+1]={is_suit=function(_,s) return s==chosen end}
end
SMODS.has_no_suit=function() return false end
kamiya_def:calculate(kamiya,{after=true,scoring_hand=hand})
eq(G.GAME.consumeable_buffer,1)
calc(joker(),house())
eq(G.GAME.consumeable_buffer,2,'respect Kamiya reservation')
flush()
eq(#G.consumeables.cards,2)
eq(calls[1].set,'Tarot'); eq(calls[2].set,'Spectral')
eq(G.GAME.consumeable_buffer,0)
G.jokers.cards={joker()}
eq(cp.members(),0,'song Joker is not an idol member')
print('Chocolate Spacial generation checks passed: '..count)
