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
local growth_feedback, sounds = {}, {}
Blind = {debuff_card = function() end}
G = {GAME={round_resets={ante=1},round=1,hands_played=1,
    blind={config={blind={key='bl_small'}}},consumeable_buffer=0},
    jokers={cards={},config={card_limit=5}}, play={}, hand={},
    consumeables={cards={},config={card_limit=2}}, P_CENTERS={m_wild={key='m_wild'}}, C={MULT={},WHITE={1,1,1,1}}}
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
local localization = dofile(ROOT .. '/localization/ja.lua').misc
function localize(key)
    if type(key)=='table' then
        local text=assert(localization.v_dictionary[key.key])
        for i,value in ipairs(key.vars or {}) do text=text:gsub('#'..i..'#',tostring(value)) end
        return text
    end
    return localization.dictionary[key] or key
end
function attention_text(args)
    growth_feedback[#growth_feedback+1]={args=args,xmult=args.major.ability.extra.xmult}
end
function play_sound(sound) sounds[#sounds+1]=sound end
function Event(e) return e end
G.E_MANAGER={add_event=function(_,e) events[#events+1]=e end}
function delay(seconds)
    G.E_MANAGER:add_event(Event({trigger='after',delay=seconds,func=function() return true end}))
end
local function flush() for _,e in ipairs(events) do assert(e.func()) end events={} end
local function step() local event=table.remove(events,1); assert(event.func()); return event end
dofile(ROOT..'/main.lua')
local cp=SMODS.current_mod.cafeparade
eq(defs.plain_cakeroll.rarity,1)
eq(defs.plain_cakeroll.cost,4)
eq(defs.plain_cakeroll.pos.x,3); eq(defs.plain_cakeroll.pos.y,1)
eq(defs.plain_cakeroll.blueprint_compat,true)
eq(defs.chocolate_spacial.rarity,3)
eq(defs.chocolate_spacial.cost,8)
eq(defs.chocolate_spacial.pos.x,2); eq(defs.chocolate_spacial.pos.y,1)
eq(defs.chocolate_spacial.blueprint_compat,true)
eq(defs.satan.atlas,'jokers','Satan retains the common base atlas')
eq(defs.satan.pos.x,0); eq(defs.satan.pos.y,1)
eq(defs.three_one_five.rarity,3); eq(defs.three_one_five.cost,8)
eq(defs.three_one_five.blueprint_compat,true)
for i,id in ipairs({'kamiya','shinonome','aslan','makio','saki','satan','cake_set','chocolate_spacial','plain_cakeroll','three_one_five'}) do
    eq(defs[id].pos.x,(i-1)%5,'registration column')
    eq(defs[id].pos.y,math.floor((i-1)/5),'registration row')
end
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
    return {ability=clone(d.config or {}), config={center={key='j_cp_'..id}},sort_id=id,
        juice_up=function(self) self.juice_count=(self.juice_count or 0)+1 end}
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
-- THREE ONE FIVE checks actual scoring ranks, once in the Joker stage.
local three_one_five=joker('three_one_five')
for rank=2,14 do
    local result=calc('three_one_five',three_one_five,{joker_main=true,scoring_hand={play(rank)}})
    if rank==3 or rank==5 then near(result.xmult,3.15) else eq(result,nil,'other ranks') end
end
local threes_and_fives={play(3),play(3),play(5),play(5),play(5)}
near(calc('three_one_five',three_one_five,{joker_main=true,scoring_hand=threes_and_fives}).xmult,3.15)
for _,target in ipairs(threes_and_fives) do
    eq(calc('three_one_five',three_one_five,{individual=true,cardarea=G.play,other_card=target,scoring_hand=threes_and_fives}),nil,'no per-card XMult')
end
eq(calc('three_one_five',three_one_five,{joker_main=true,scoring_hand={play(9)},full_hand={play(3),play(9)}}),nil,'unscored 3 ignored')
eq(calc('three_one_five',three_one_five,{joker_main=true}),nil)
eq(calc('three_one_five',three_one_five,{joker_main=true,scoring_hand={}}),nil)
for _,flag in ipairs({'debuff','stone'}) do
    local target=play(3); target[flag]=true
    eq(calc('three_one_five',three_one_five,{joker_main=true,scoring_hand={target}}),nil,flag..' 3 excluded')
    near(calc('three_one_five',three_one_five,{joker_main=true,scoring_hand={target,play(5)}}).xmult,3.15)
    target=play(5); target[flag]=true
    eq(calc('three_one_five',three_one_five,{joker_main=true,scoring_hand={target}}),nil,flag..' 5 excluded')
end
near(calc('three_one_five',three_one_five,{joker_main=true,scoring_hand={play(3,nil,'m_wild')}}).xmult,3.15)
near(calc('three_one_five',three_one_five,{joker_main=true,blueprint=1,scoring_hand={play(5)}}).xmult,3.15)
near(calc('three_one_five',three_one_five,{joker_main=true,retrigger_joker=true,scoring_hand={play(3)}}).xmult,3.15,'Joker retriggers follow the engine')
for _,phase in ipairs({'before','after','repetition'}) do
    eq(calc('three_one_five',three_one_five,{[phase]=true,scoring_hand=threes_and_fives}),nil)
end
eq(calc('three_one_five',three_one_five,{individual=true,cardarea=G.hand,other_card=play(3)}),nil,'held cards ignored')
three_one_five.debuff=true
eq(calc('three_one_five',three_one_five,{joker_main=true,scoring_hand=threes_and_fives}),nil)
three_one_five.debuff=nil
near(calc('three_one_five',three_one_five,{joker_main=true,scoring_hand={play(5)}}).xmult,3.15,'next hand remains usable')
G.jokers.cards={three_one_five}; eq(cp.members(),0,'not a Cafe Parade member'); G.jokers.cards={}
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
near(sh.ability.extra.xmult,1,'no growth before scoring')
eq(calc('shinonome',sh,{joker_main=true,scoring_hand=pair}).mult,8)
near(calc('shinonome',sh,{joker_main=true,scoring_hand=pair}).xmult,1)
eq(calc('shinonome',sh,{after=true,scoring_hand=pair,blueprint=1}),nil)
eq(calc('shinonome',sh,{after=true,scoring_hand=pair,retrigger_joker=true}),nil)
local growth=calc('shinonome',sh,{after=true,scoring_hand=pair})
near(sh.ability.extra.xmult,1,'reserve growth without silently applying it')
near(sh.ability.extra.pending_growth.xmult,1.05)
eq(calc('shinonome',sh,{after=true,scoring_hand=pair}),nil,'no duplicate growth before animation')
local saved_growth=clone(sh.ability)
local loaded_sh=joker('shinonome'); loaded_sh.ability=saved_growth
defs.shinonome:load(loaded_sh,{})
near(loaded_sh.ability.extra.xmult,1.05,'pending growth survives a save before animation')
eq(loaded_sh.ability.extra.pending_growth,nil)
defs.shinonome:load(loaded_sh,{})
near(loaded_sh.ability.extra.xmult,1.05,'load applies earned growth only once')
eq(calc('shinonome',loaded_sh,{after=true,scoring_hand=pair}),nil,'saved used flag prevents another growth')
G.E_MANAGER:add_event(Event({func=function()
    near(sh.ability.extra.xmult,1,'scoring visuals finish before growth')
    return true
end}))
growth.func()
eq(#events,2)
eq(events[2].delay,cp.config.shinonome.growth_delay)
eq(#growth_feedback,0)
step()
near(sh.ability.extra.xmult,1)
step()
near(sh.ability.extra.xmult,1.05)
eq(sh.ability.extra.pending_growth,nil)
eq(#growth_feedback,1)
near(growth_feedback[1].xmult,1.05,'popup sees the new value in the same event')
eq(growth_feedback[1].args.text,'成長！X1.05')
eq(growth_feedback[1].args.major,sh)
eq(sounds[1],'tarot1')
eq(sh.juice_count,1)
eq(calc('shinonome',sh,{after=true,scoring_hand=pair}),nil,'no duplicate growth after animation')
near(calc('shinonome',sh,{joker_main=true,scoring_hand={a},blueprint=1}).xmult,1.05)
G.GAME.hands_played=2
calc('shinonome',sh,{before=true,scoring_hand=pair}); near(sh.ability.extra.xmult,1.05)
calc('shinonome',sh,{after=true,scoring_hand=pair}).func(); flush()
near(sh.ability.extra.xmult,1.10)
eq(growth_feedback[2].args.text,'成長！X1.10')
G.GAME.hands_played=3
eq(calc('shinonome',sh,{after=true,scoring_hand={a}}),nil,'no pair means no growth')
near(sh.ability.extra.xmult,1.10)
local aslan=joker('aslan')
eq(calc('aslan',aslan,{individual=true,cardarea=G.hand,other_card=wild}),nil)
near(calc('aslan',aslan,{individual=true,cardarea=G.play,other_card=wild}).xmult,1.25)
eq(calc('aslan',aslan,{individual=true,cardarea=G.play,other_card=a}),nil)
for _,target in ipairs({a,d}) do
    eq(calc('makio',joker('makio'),{repetition=true,cardarea=G.play,scoring_hand={a,b,c,d,e},other_card=target,blueprint=1}).repetitions,1)
end
eq(calc('makio',joker('makio'),{repetition=true,cardarea=G.play,scoring_hand={a,b,c,d,e},other_card=b}),nil)
eq(calc('makio',joker('makio'),{individual=true,cardarea=G.play,scoring_hand=pair,other_card=a}),nil,'no recursive scoring trigger')
local roll=joker('plain_cakeroll')
local function roll_score(target,scoring_hand,area,flags)
    local context=flags or {}
    context.individual=true; context.cardarea=area or G.play
    context.other_card=target; context.scoring_hand=scoring_hand
    return calc('plain_cakeroll',roll,context)
end
local played={a,b,c,d,e}
local total=0
for _,target in ipairs(pair) do
    local effect=roll_score(target,pair,G.play,{full_hand=played})
    eq(effect.chips,30,'two scored cards qualify even when five cards were played')
    total=total+effect.chips
end
eq(total,60,'each scored card gets its own chips')
for size=0,5 do
    local scoring={}
    for i=1,size do scoring[i]=played[i] end
    local effect=roll_score(a,scoring)
    if size==2 then eq(effect.chips,30) else eq(effect,nil,'exactly two scored cards required') end
end
eq(roll_score(a,nil),nil)
eq(roll_score(a,pair,G.hand),nil,'held cards do not receive chips')
eq(roll_score(a,pair,'unscored'),nil)
eq(roll_score(b,pair),nil,'unscored card in the played area does not receive chips')
for _,context in ipairs({{before=true},{after=true},{joker_main=true},{repetition=true}}) do
    context.cardarea=G.play; context.scoring_hand=pair; context.other_card=a
    eq(calc('plain_cakeroll',roll,context),nil,'only individual scoring grants chips')
end
eq(roll_score(a,pair,G.play,{blueprint=1}).chips,30,'Blueprint copies the card-scoring effect')
local retrigger_total=0
for _=1,3 do retrigger_total=retrigger_total+roll_score(a,pair).chips end
eq(retrigger_total,90,'each scoring retrigger grants another thirty chips')
local stone=play(7); stone.stone=true
eq(roll_score(stone,{a,stone}).chips,30,'two scored cards need not be a Pair')
eq(roll_score(a,{a,d,stone}),nil,'a third scored Stone Card prevents activation')
roll.debuff=true; eq(roll_score(a,pair),nil,'debuffed Joker is inactive')
roll.debuff=nil; eq(roll_score(a,pair).chips,30)
G.jokers.cards={roll}
eq(cp.members(),0,'roll cake does not count as an idol member')
local saki=joker('saki')
local function saki_before(source, full_hand, scoring_hand, flags)
    local context=flags or {}
    context.before=true; context.full_hand=full_hand; context.scoring_hand=scoring_hand or full_hand
    return calc('saki',source,context)
end
eq(saki_before(saki,{wild}),nil)
eq(saki.ability.extra.changed_blind,nil,'no target preserves chance')
eq(saki_before(saki,pair,pair,{blueprint=1}),nil); eq(a.enhanced,nil)
eq(calc('saki',saki,{after=true,scoring_hand=pair}),nil,'no late transformation')
a.seal='Red'; a.edition='foil'
local makeup = saki_before(saki,pair)
eq(a.enhanced,nil,'selection leaves card unchanged until effect resolution')
eq(makeup.message,'Makeup!')
eq(makeup.message_card,a,'popup selects the leftmost played card')
eq(makeup.juice_card,a,'animate the selected playing card')
eq(makeup.card,saki,'retain the source Joker')
eq(makeup.colour,cp.config.saki.makeup_colour)
eq(makeup.sound,'tarot1')
eq(#events,0,'selection does not schedule a premature sprite change')
eq(saki_before(saki,{d}),nil,'reserve use before resolution')
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
eq(saki_before(saki,{d}),nil,'no second Makeup in the same blind'); eq(d.enhanced,nil)
local restored_saki=joker('saki'); restored_saki.ability=clone(saki.ability)
eq(saki_before(restored_saki,{d}),nil,'used flag survives save/load')
local saki_retrigger = joker('saki')
eq(saki_before(saki_retrigger,{d},{d},{retrigger_joker=true}),nil,'retrigger does not produce Makeup')
eq(d.enhanced,nil)
local second_saki=joker('saki')
eq(saki_before(second_saki,pair),nil,'second Saki cannot skip the newly Wild leftmost card')
eq(second_saki.ability.extra.changed_blind,nil,'second Saki retains its use')
eq(d.enhanced,nil)
G.GAME.hands_played=G.GAME.hands_played+1
local second_makeup=saki_before(second_saki,{d,a})
eq(second_makeup.message_card,d,'reordering on the next hand permits the new leftmost card')
second_makeup.func(); flush()
eq(d.enhanced,'m_wild')
-- A scoring card in the middle or on the right must never become a fallback.
for _,position in ipairs({2,3}) do
    local layout={play(2,nil,'m_bonus'),play(3,nil,'m_mult'),play(4,nil,'m_steel')}
    local target=play(5); layout[position]=target
    local source=joker('saki')
    eq(saki_before(source,layout,{target}),nil,'plain card is not at the left edge')
    eq(target.enhanced,nil)
    eq(source.ability.extra.changed_blind,nil)
    eq(#events,0,'no Makeup animation when the leftmost card is enhanced')
    -- Move the same card to the left on a later hand of this blind.
    G.GAME.hands_played=G.GAME.hands_played+1
    local moved=saki_before(source,{target,layout[1]},{target})
    eq(moved.message_card,target)
    moved.func(); flush()
    eq(target.enhanced,'m_wild')
end
for _,enhancement in ipairs({'m_wild','m_bonus','m_mult','m_steel','m_glass','m_stone'}) do
    local left,right=play(2,nil,enhancement),play(3)
    local source=joker('saki')
    eq(saki_before(source,{left,right},{right}),nil,'leftmost enhancement blocks transformation')
    eq(left.enhanced,enhancement)
    eq(right.enhanced,nil)
    eq(source.ability.extra.changed_blind,nil)
end
for _,state in ipairs({'removed','shattered','destroyed'}) do
    local left,right=play(2),play(3); left[state]=true
    local source=joker('saki')
    eq(saki_before(source,{left,right},{right}),nil,'invalid leftmost card cannot be skipped')
    eq(right.enhanced,nil)
    eq(source.ability.extra.changed_blind,nil)
end
local played_left,scoring_right=play(7),play(8)
local layout_saki=joker('saki')
local left_makeup=saki_before(layout_saki,{played_left,scoring_right},{scoring_right})
eq(left_makeup.message_card,played_left,'use played-card order, not scoring-hand order')
left_makeup.func(); flush()
eq(played_left.enhanced,'m_wild','an unscored leftmost played card can be selected')
eq(scoring_right.enhanced,nil)
local no_target_saki=joker('saki')
eq(saki_before(no_target_saki,{}, {play(2)}),nil,'empty played hand must not use the scoring hand')
eq(calc('saki',no_target_saki,{before=true,scoring_hand={play(2)}}),nil,'missing full hand has no target')
eq(no_target_saki.ability.extra.changed_blind,nil)
local debuffed_saki=joker('saki'); debuffed_saki.debuff=true
eq(saki_before(debuffed_saki,{play(7)}),nil)
eq(debuffed_saki.ability.extra.changed_blind,nil)
G.GAME.round=G.GAME.round+1
local next_blind=saki_before(saki,{play(8)})
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
    assert(loc.misc.v_dictionary.a_cp_growth)
    assert(loc.misc.challenge_names.c_cp_practice)
    assert(loc.misc.v_text.ch_c_cp_practice)
    eq(loc.descriptions.Joker.j_cp_three_one_five.text[3],
        '{C:inactive,s:0.6}アイドルマスターSideM×FiFS展 THREE ONE FIVE','small gray source footer')
end
print('Contract assertions passed: '..count)
