local count = 0
local function eq(actual, expected, label)
    assert(actual == expected, (label or '') .. ': expected ' .. tostring(expected) .. ', got ' .. tostring(actual))
    count = count + 1
end
local function near(a,b) assert(math.abs(a-b)<1e-9); count=count+1 end
local function clone(t)
    if type(t)~='table' then return t end
    local r={} for k,v in pairs(t) do r[k]=clone(v) end return r
end
local defs, events, challenges, atlases = {}, {}, {}, {}
Blind = {debuff_card = function() end}
G = {GAME={round_resets={ante=1},round=1,hands_played=1,
    blind={config={blind={key='bl_small'}}},consumeable_buffer=0},
    jokers={cards={},config={card_limit=5}}, play={}, hand={},
    consumeables={cards={},config={card_limit=2}}, P_CENTERS={m_wild={key='m_wild'}}, C={MULT={}}}
SMODS = {current_mod={}, Suit={obj_buffer={'Hearts','Diamonds','Clubs','Spades'}},
    load_file=function(path) return loadfile(ROOT..'/'..path) end,
    Atlas=function(d) atlases[d.key]=d end, DeckSkin=function() end, Joker=function(d) defs[d.key]=d end,
    Challenge=function(d) challenges[d.key]=d end,
    has_no_rank=function(c) return c.stone end, has_no_suit=function(c) return c.stone end,
    get_enhancements=function(c) return c.enhanced and {[c.enhanced]=true} or {} end,
    has_enhancement=function(c,k) return c.enhanced==k end,
    get_probability_vars=function(_,n,d) return n,d end,
    pseudorandom_probability=function() return true end,
    add_card=function() table.insert(G.consumeables.cards,{}) end}
local dictionary = dofile(ROOT .. '/localization/ja.lua').misc.dictionary
function localize(key) return dictionary[key] or key end
function Event(e) return e end
G.E_MANAGER={add_event=function(_,e) events[#events+1]=e end}
function delay(seconds)
    G.E_MANAGER:add_event(Event({trigger='after',delay=seconds,func=function() return true end}))
end
local function flush() for _,e in ipairs(events) do assert(e.func()) end events={} end
local function step() local event=table.remove(events,1); assert(event.func()); return event end
dofile(ROOT..'/main.lua')
local cp=SMODS.current_mod.cafeparade
eq(defs.satan.atlas,'jokers','Satan retains the common base atlas')
eq(defs.satan.pos.x,5); eq(defs.satan.pos.y,0)
eq(defs.satan.soul_atlas,'satan_top','foreground uses a separate native soul atlas')
eq(defs.satan.soul_pos.x,0); eq(defs.satan.soul_pos.y,0)
eq(defs.satan.soul_pos.draw,nil,'use the standard legendary floating draw step')
eq(atlases.satan_top.path,'cafeparade_satan_top.png')
eq(atlases.satan_top.px,71); eq(atlases.satan_top.py,95)
for id,def in pairs(defs) do
    if id~='satan' then eq(def.soul_atlas,nil); eq(def.soul_pos,nil) end
end
local function joker(id)
    local d=defs[id]
    return {ability=clone(d.config or {}), config={center={key='j_cp_'..id}},sort_id=id}
end
local function play(rank,suits,enhanced)
    return {rank=rank,suits=suits or {'Hearts'},enhanced=enhanced,visible_enhanced=enhanced,
        get_id=function(self) return self.rank end,
        is_suit=function(self,suit) for _,s in ipairs(self.suits) do if s==suit then return true end end return false end,
        set_ability=function(self,center,initial,delay_sprites)
            self.enhanced=center.key
            local function sprites() self.visible_enhanced=center.key; return true end
            if delay_sprites then G.E_MANAGER:add_event(Event({func=sprites})) else sprites() end
        end}
end
local function calc(id,card,ctx)
    if card.debuff then return end -- engine dispatch guard
    return defs[id]:calculate(card,ctx)
end
local a,b,c,d,e=play(2),play(3),play(3),play(2),play(3)
eq(#cp.pair_cards({a,b,c,d,e}),2,'two-pair leftmost group')
eq(cp.pair_cards({a,b,c,d,e})[2],d)
a.stone=true; eq(cp.pair_cards({a,b,c,d,e})[1],b); a.stone=nil
eq(#cp.pair_cards({a}),0)
eq(#cp.pair_cards({b,c,e}),3)
local wild=play(9,SMODS.Suit.obj_buffer,'m_wild')
eq(cp.suits({wild},3),false,'one wild is one suit')
eq(cp.suits({wild,play(2,{'Hearts'}),play(3,{'Hearts'})},3),false)
eq(cp.suits({wild,play(2,{'Hearts'}),play(3,{'Diamonds'})},3),true,'augmenting path')
eq(cp.suits({play(2,{'Hearts','Diamonds'}),play(3,{'Hearts','Diamonds'}),play(4,{'Clubs','Spades'})},3),true,'smeared candidates')
wild.stone=true; eq(cp.suits({wild},1),false); wild.stone=nil
local kamiya=joker('kamiya')
local hand={play(2,{'Hearts'}),play(3,{'Diamonds'}),play(4,{'Clubs'})}
eq(calc('kamiya',kamiya,{after=true,scoring_hand=hand}).dollars,3)
eq(calc('kamiya',kamiya,{after=true,scoring_hand=hand}),nil)
eq(G.GAME.consumeable_buffer,1)
local bp={sort_id=42}
eq(calc('kamiya',kamiya,{after=true,scoring_hand=hand,blueprint=1,blueprint_card=bp}).dollars,3)
eq(calc('kamiya',kamiya,{after=true,scoring_hand=hand,blueprint=1,blueprint_card=bp}),nil)
flush(); eq(#G.consumeables.cards,2); eq(G.GAME.consumeable_buffer,0)
G.GAME.round=2
eq(calc('kamiya',kamiya,{after=true,scoring_hand=hand}).dollars,3,'full slots still pay')
eq(#events,0)
local saved=clone(kamiya.ability)
kamiya=joker('kamiya'); kamiya.ability=saved
eq(calc('kamiya',kamiya,{after=true,scoring_hand=hand}),nil,'used flag restored')
local sh=joker('shinonome')
local pair={a,d}
calc('shinonome',sh,{before=true,scoring_hand=pair,blueprint=1})
near(sh.ability.extra.xmult,1)
calc('shinonome',sh,{before=true,scoring_hand=pair})
calc('shinonome',sh,{before=true,scoring_hand=pair})
calc('shinonome',sh,{before=true,scoring_hand=pair,retrigger_joker=true})
near(sh.ability.extra.xmult,1.05)
eq(calc('shinonome',sh,{joker_main=true,scoring_hand=pair}).mult,8)
near(calc('shinonome',sh,{joker_main=true,scoring_hand={a},blueprint=1}).xmult,1.05)
G.GAME.hands_played=2
calc('shinonome',sh,{before=true,scoring_hand=pair}); near(sh.ability.extra.xmult,1.10)
local aslan=joker('aslan')
eq(calc('aslan',aslan,{individual=true,cardarea=G.hand,other_card=wild}),nil)
near(calc('aslan',aslan,{individual=true,cardarea=G.play,other_card=wild}).xmult,1.25)
eq(calc('aslan',aslan,{individual=true,cardarea=G.play,other_card=a}),nil)
for _,target in ipairs({a,d}) do
    eq(calc('makio',joker('makio'),{repetition=true,cardarea=G.play,scoring_hand={a,b,c,d,e},other_card=target,blueprint=1}).repetitions,1)
end
eq(calc('makio',joker('makio'),{repetition=true,cardarea=G.play,scoring_hand={a,b,c,d,e},other_card=b}),nil)
eq(calc('makio',joker('makio'),{individual=true,cardarea=G.play,scoring_hand=pair,other_card=a}),nil,'no recursive scoring trigger')
local saki=joker('saki')
eq(calc('saki',saki,{before=true,scoring_hand={wild}}),nil)
eq(saki.ability.extra.changed_blind,nil,'no target preserves chance')
eq(calc('saki',saki,{before=true,scoring_hand=pair,blueprint=1}),nil); eq(a.enhanced,nil)
eq(calc('saki',saki,{after=true,scoring_hand=pair}),nil,'no late transformation')
a.seal='Red'; a.edition='foil'
local makeup = calc('saki',saki,{before=true,scoring_hand=pair})
eq(a.enhanced,nil,'selection leaves card unchanged until effect resolution')
eq(makeup.message,'Makeup!')
eq(makeup.message_card,a,'popup selects the leftmost unenhanced scoring card')
eq(makeup.juice_card,a,'animate the selected playing card')
eq(makeup.card,saki,'retain the source Joker')
eq(makeup.colour,cp.config.saki.makeup_colour)
eq(makeup.sound,'tarot1')
eq(#events,0,'selection does not schedule a premature sprite change')
eq(calc('saki',saki,{before=true,scoring_hand={d}}),nil,'reserve use before resolution')
-- Model SMODS's message -> func resolution and set_ability's delayed sprites.
G.E_MANAGER:add_event(Event({func=function()
    eq(a.visible_enhanced,nil,'Makeup popup precedes the visible Wild Card')
    return true
end}))
makeup.func()
eq(a.enhanced,'m_wild','ability is ready for this hand before visual events')
eq(a.visible_enhanced,nil,'Wild sprite is deferred')
eq(a.seal,'Red'); eq(a.edition,'foil')
eq(saki.ability.extra.changed_blind,cp.blind_id())
near(calc('saki',saki,{individual=true,cardarea=G.play,other_card=a,blueprint=1}).xmult,1.2)
near(calc('aslan',aslan,{individual=true,cardarea=G.play,other_card=a}).xmult,1.25)
G.E_MANAGER:add_event(Event({func=function()
    eq(a.visible_enhanced,'m_wild','Wild sprite precedes the scoring animation')
    return true
end}))
step() -- Makeup!
eq(a.visible_enhanced,nil,'still unenhanced while Makeup is displayed')
eq(step().delay,cp.config.saki.makeup_delay,'pause before visible transformation')
eq(a.visible_enhanced,nil)
step() -- delayed set_ability sprites
eq(a.visible_enhanced,'m_wild')
step() -- scoring
eq(#events,0)
eq(calc('saki',saki,{before=true,scoring_hand={d}}),nil,'no second Makeup in the same blind'); eq(d.enhanced,nil)
local restored_saki=joker('saki'); restored_saki.ability=clone(saki.ability)
eq(calc('saki',restored_saki,{before=true,scoring_hand={d}}),nil,'used flag survives save/load')
local saki_retrigger = joker('saki')
eq(calc('saki',saki_retrigger,{before=true,scoring_hand={d},retrigger_joker=true}),nil,'retrigger does not produce Makeup')
eq(d.enhanced,nil)
local second_saki=joker('saki')
local second_makeup=calc('saki',second_saki,{before=true,scoring_hand=pair})
eq(second_makeup.message_card,d,'second Saki skips the first transformation')
second_makeup.func(); flush()
eq(d.enhanced,'m_wild')
local invalid_hand={play(2,nil,'m_bonus'),play(3),play(4),play(5),play(6)}
invalid_hand[2].removed=true; invalid_hand[3].shattered=true; invalid_hand[4].destroyed=true
local guarded_saki=joker('saki')
local guarded_makeup=calc('saki',guarded_saki,{before=true,scoring_hand=invalid_hand})
eq(guarded_makeup.message_card,invalid_hand[5],'skip enhanced and destroyed cards')
guarded_makeup.func(); flush()
eq(invalid_hand[1].enhanced,'m_bonus','do not overwrite other enhancements')
for i=2,4 do eq(invalid_hand[i].enhanced,nil) end
eq(invalid_hand[5].enhanced,'m_wild')
local no_target_saki=joker('saki')
eq(calc('saki',no_target_saki,{before=true,scoring_hand={invalid_hand[1],invalid_hand[2]}}),nil)
eq(no_target_saki.ability.extra.changed_blind,nil)
local debuffed_saki=joker('saki'); debuffed_saki.debuff=true
eq(calc('saki',debuffed_saki,{before=true,scoring_hand={play(7)}}),nil)
eq(debuffed_saki.ability.extra.changed_blind,nil)
G.GAME.round=G.GAME.round+1
local next_blind=calc('saki',saki,{before=true,scoring_hand={play(8)}})
eq(next_blind.message,'Makeup!','new blind restores the transformation')
next_blind.func(); flush()
local satan=joker('satan')
local member=joker('kamiya'); local dup=joker('kamiya'); local inactive=joker('saki'); inactive.debuff=true
G.jokers.cards={satan,member,dup,inactive,joker('aslan'),joker('makio')}
eq(cp.members(),3)
defs.satan:add_to_deck(satan); defs.satan:add_to_deck(satan); eq(G.jokers.config.card_limit,6)
defs.satan:remove_from_deck(satan,true); eq(G.jokers.config.card_limit,5)
defs.satan:add_to_deck(satan,true); eq(G.jokers.config.card_limit,6)
local loaded=joker('satan'); loaded.ability=clone(satan.ability)
defs.satan:load(loaded,{added_to_deck=true,debuff=false})
eq(G.jokers.config.card_limit,6,'load does not add')
defs.satan:remove_from_deck(loaded); eq(G.jokers.config.card_limit,5,'loaded card removes once')
defs.satan:remove_from_deck(loaded); eq(G.jokers.config.card_limit,5)
local physical_copy=joker('satan'); physical_copy.ability=clone(satan.ability)
defs.satan:add_to_deck(physical_copy); eq(G.jokers.config.card_limit,6,'physical copy adds its own slot')
local ctx={end_of_round=true,beat_boss=true}
calc('satan',satan,{end_of_round=true,beat_boss=true,blueprint=1}); near(satan.ability.extra.growth,0)
for i=1,5 do G.GAME.round=i+2; calc('satan',satan,ctx); calc('satan',satan,ctx) end
near(satan.ability.extra.growth,2.25)
near(calc('satan',satan,{joker_main=true,blueprint=1}).xmult,5)
G.jokers.cards={satan}; near(calc('satan',satan,{joker_main=true}).xmult,4.25)
local restored=joker('satan'); restored.ability=clone(satan.ability)
calc('satan',restored,ctx); near(restored.ability.extra.growth,2.25)
-- お題のカード構成と通常の能力との接続を確認。
local practice = assert(challenges.practice)
eq(practice:unlocked(),true)
eq(#practice.jokers,6)
local seen = {}
for _,j in ipairs(practice.jokers) do
    assert(j.id:match('^j_cp_') and defs[j.id:sub(6)])
    assert(not seen[j.id]); seen[j.id]=true
    eq(j.eternal,nil,'selling allowed in practice')
end
eq(#practice.deck.cards,8)
local modifiers = {}
for _,rule in ipairs(practice.rules.modifiers) do modifiers[rule.id]=rule.value end
eq(modifiers.hand_size,#practice.deck.cards,'all cards fit in opening hand')
eq(modifiers.joker_slots,8)
eq(#practice.consumeables,0,'Tarot slots start empty')
local opening = {}
local suit_names={H='Hearts',D='Diamonds',C='Clubs',S='Spades'}
for i,control in ipairs(practice.deck.cards) do
    local suits=control.e=='m_wild' and SMODS.Suit.obj_buffer or {assert(suit_names[control.s])}
    opening[i]=play(assert(tonumber(control.r)),suits,control.e)
    opening[i].seal=control.g
end
local fullhouse={opening[1],opening[2],opening[3],opening[4],opening[5]}
eq(cp.suits(fullhouse,3),true)
eq(#cp.pair_cards(fullhouse),3)
eq(cp.pair_cards(fullhouse)[1],opening[1])
eq(cp.pair_cards(fullhouse)[2],opening[2])
eq(opening[5].seal,'Red')
for _,i in ipairs({3,4,5}) do eq(cp.enhanced(opening[i]),true) end
eq(opening[8].enhanced,'m_steel')
-- 8枚以外のカードが必須にならないこと、全メンバーが実際に登録済みであること。
G.jokers.cards={}
for _,j in ipairs(practice.jokers) do table.insert(G.jokers.cards,joker(j.id:sub(6))) end
eq(cp.members(),5)
local practice_satan=G.jokers.cards[6]
near(calc('satan',practice_satan,{joker_main=true}).xmult,3.25)

-- Collection/menu tooltips must work without an active run.
G.GAME={}
for id,def in pairs(defs) do
    local loc=def:loc_vars({},joker(id)); assert(type(loc.vars)=='table'); count=count+1
end
for _,lang in ipairs({'ja','en-us'}) do
    local loc=dofile(ROOT..'/localization/'..lang..'.lua')
    for id,def in pairs(defs) do
        local entry=assert(loc.descriptions.Joker['j_cp_'..id])
        local queue={}
        local variables=def:loc_vars(queue,joker(id)).vars
        for _,line in ipairs(entry.text) do
            for index in line:gmatch('#(%d+)#') do assert(variables[tonumber(index)]~=nil) end
        end
        for _,info in ipairs(queue) do
            if info.set=='Other' then assert(loc.descriptions.Other[info.key]) end
        end
        count=count+1
    end
    assert(loc.misc.dictionary.k_cp_wild=='Makeup!')
    assert(loc.misc.challenge_names.c_cp_practice)
    assert(loc.misc.v_text.ch_c_cp_practice)
end
print('Contract assertions passed: '..count)
