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
eq(challenges.practice,nil,'diagnostic challenge is not registered in production')
dofile(TEST_ROOT..'/fixtures/practice.lua')
local cp=SMODS.current_mod.cafeparade
eq(defs.goldpeople.rarity,3); eq(defs.goldpeople.cost,8)
eq(defs.goldpeople.blueprint_compat,false)
for _,id in ipairs({'cake_set','plain_cakeroll'}) do
    eq(defs[id].pools.Food,true)
    eq(defs[id].eternal_compat,false)
    eq(defs[id].perishable_compat,true)
end
eq(defs.makio.eternal_compat,true,'other Jokers keep the registration default')
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
for i,id in ipairs({'kamiya','shinonome','aslan','makio','saki','satan','cake_set','chocolate_spacial','plain_cakeroll','three_one_five','embossing','sunsun','goldpeople'}) do
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
-- Embossing gives +4 on each scored Enhanced-card hit.
eq(defs.embossing.rarity,1); eq(defs.embossing.cost,4)
eq(defs.embossing.blueprint_compat,true)
local embossing=joker('embossing')
for _,enhancement in ipairs({'m_bonus','m_mult','m_wild','m_glass','m_steel','m_stone','m_gold','m_lucky'}) do
    local target=play(6,nil,enhancement)
    eq(calc('embossing',embossing,{individual=true,cardarea=G.play,other_card=target}).mult,4,enhancement)
    eq(calc('embossing',embossing,{individual=true,cardarea=G.hand,other_card=target}),nil)
end
local plain=play(6); plain.seal='Red'; plain.edition='foil'
eq(calc('embossing',embossing,{individual=true,cardarea=G.play,other_card=plain}),nil,'seal and edition alone are not enhancements')
local enhanced_six=play(6,nil,'m_bonus')
local total=0
for i=1,3 do total=total+calc('embossing',embossing,{individual=true,cardarea=G.play,other_card=enhanced_six}).mult end
eq(total,12,'original plus two retriggers')
eq(calc('embossing',embossing,{individual=true,cardarea=G.play,other_card=enhanced_six,blueprint=1}).mult,4)
for _,phase in ipairs({'before','after','joker_main','repetition'}) do
    eq(calc('embossing',embossing,{[phase]=true,cardarea=G.play,other_card=enhanced_six}),nil)
end
embossing.debuff=true
eq(calc('embossing',embossing,{individual=true,cardarea=G.play,other_card=enhanced_six}),nil)
embossing.debuff=nil
-- SUNSUN grants two additional hits only to scoring ranked sixes.
eq(defs.sunsun.rarity,2); eq(defs.sunsun.cost,6)
eq(defs.sunsun.blueprint_compat,true)
local sunsun=joker('sunsun')
local function sun(target,scoring,flags)
    local context=flags or {}; context.repetition=true; context.cardarea=G.play
    context.other_card=target; context.scoring_hand=scoring
    return calc('sunsun',sunsun,context)
end
for rank=2,14 do
    local target=play(rank)
    local effect=sun(target,{target})
    if rank==6 then eq(effect.repetitions,2); eq(effect.message,'k_again_ex'); eq(effect.card,sunsun)
    else eq(effect,nil,'only rank 6') end
end
local six=play(6)
eq(sun(six,{}),nil,'unscored six excluded')
eq(sun(six,{play(9)}),nil,'scoring card identity must match')
eq(sun(six,nil),nil,'missing scoring hand excluded')
local stone=play(6,nil,'m_stone'); stone.stone=true
eq(sun(stone,{stone}),nil,'Stone has no rank')
for _,enhancement in ipairs({'m_bonus','m_wild','m_glass','m_steel','m_gold','m_lucky'}) do
    local target=play(6,nil,enhancement)
    eq(sun(target,{target}).repetitions,2,'ranked Enhanced six retriggers')
end
local copied=sun(six,{six},{blueprint=1,blueprint_card={sort_id=901}})
eq(copied.repetitions,2); eq(copied.card.sort_id,901)
for _,phase in ipairs({'before','after','joker_main','individual'}) do
    eq(calc('sunsun',sunsun,{[phase]=true,cardarea=G.play,other_card=six,scoring_hand={six}}),nil)
end
eq(calc('sunsun',sunsun,{repetition=true,cardarea=G.hand,other_card=six,scoring_hand={six}}),nil)
sunsun.debuff=true; eq(sun(six,{six}),nil); sunsun.debuff=nil
for _,target in ipairs({six,enhanced_six}) do
    eq(sun(target,{six,enhanced_six}).repetitions,2,'each scored six')
end
G.jokers.cards={embossing,sunsun}; eq(cp.members(),0); G.jokers.cards={}
-- THREE ONE FIVE needs both played ranks and at least one scoring 3/5.
local three_one_five=joker('three_one_five')
local function three_calc(scoring,played,extra)
    local context={joker_main=true,scoring_hand=scoring,full_hand=played or scoring}
    for key,value in pairs(extra or {}) do context[key]=value end
    return calc('three_one_five',three_one_five,context)
end
for rank=2,14 do
    eq(three_calc({play(rank)}),nil,'a single rank never meets both ranks')
end
local threes={play(3),play(3)}
local fives={play(5),play(5)}
local threes_and_fives={threes[1],threes[2],fives[1],fives[2],play(5)}
near(three_calc(threes,threes_and_fives).xmult,3.15,'only the 3 pair scores')
near(three_calc(fives,threes_and_fives).xmult,3.15,'only the 5 pair scores')
near(three_calc(threes_and_fives).xmult,3.15,'multiple matching cards give one XMult')
-- The other rank must be played, rather than merely held in hand.
eq(three_calc(threes),nil,'scoring 3 without a played 5')
eq(three_calc(fives),nil,'scoring 5 without a played 3')
G.hand.cards={play(5)}; eq(three_calc(threes),nil,'held 5 does not count')
G.hand.cards={play(3)}; eq(three_calc(fives),nil,'held 3 does not count'); G.hand.cards=nil
local nines={play(9),play(9)}
eq(three_calc(nines,{nines[1],nines[2],play(3),play(5)}),nil,'both ranks played but neither scores')
eq(three_calc({},threes_and_fives),nil,'no scoring cards')
eq(calc('three_one_five',three_one_five,{joker_main=true,scoring_hand=threes_and_fives}),nil,'missing played hand')
eq(calc('three_one_five',three_one_five,{joker_main=true,full_hand=threes_and_fives}),nil,'missing scoring hand')
for _,rank in ipairs({3,5}) do
    local target=play(rank)
    local other=play(rank==3 and 5 or 3)
    target.debuff=true
    eq(three_calc({target},{target,other}),nil,'debuffed scoring rank cannot trigger')
    near(three_calc({other},{target,other}).xmult,3.15,'debuffed other rank still present in played hand')
    other.debuff=true
    eq(three_calc({target,other}),nil,'both scoring ranks debuffed')
    target.debuff=nil; other.debuff=nil
    target.stone=true
    eq(three_calc({other},{target,other}),nil,'Stone cannot supply the missing played rank')
    eq(three_calc({target},{target,other,play(rank)}),nil,'Stone cannot count as scoring rank')
    near(three_calc({other},{target,other,play(rank)}).xmult,3.15,'real ranked card supplies missing rank')
end
local enhanced={play(3,nil,'m_wild'),play(5,nil,'m_glass')}
near(three_calc({enhanced[1]},enhanced).xmult,3.15,'Wild 3 keeps its rank')
near(three_calc({enhanced[2]},enhanced).xmult,3.15,'enhanced 5 keeps its rank')
near(three_calc(threes,threes_and_fives,{blueprint=1}).xmult,3.15)
near(three_calc(fives,threes_and_fives,{retrigger_joker=true}).xmult,3.15,'Joker retriggers follow the engine')
for _,target in ipairs(threes_and_fives) do
    eq(calc('three_one_five',three_one_five,{individual=true,cardarea=G.play,other_card=target,scoring_hand=threes_and_fives,full_hand=threes_and_fives}),nil,'no per-card XMult')
end
for _,phase in ipairs({'before','after','repetition'}) do
    eq(calc('three_one_five',three_one_five,{[phase]=true,scoring_hand=threes_and_fives,full_hand=threes_and_fives}),nil)
end
eq(calc('three_one_five',three_one_five,{individual=true,cardarea=G.hand,other_card=play(3)}),nil,'held cards cannot trigger')
three_one_five.debuff=true
eq(three_calc(threes_and_fives),nil)
three_one_five.debuff=nil
near(three_calc(fives,threes_and_fives).xmult,3.15,'next hand remains usable')
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
-- Kamiya can pay on consecutive hands in the same blind, but only once per evaluation.
local old_round=G.GAME.round
G.consumeables.config.card_limit=0
for i=1,4 do
    G.GAME.hands_played=G.GAME.hands_played+1
    eq(calc('kamiya',kamiya,{after=true,scoring_hand=hand}).dollars,3,'qualifying hand '..i)
    eq(calc('kamiya',kamiya,{after=true,scoring_hand=hand}),nil,'duplicate hand does not pay twice')
    eq(G.GAME.round,old_round,'same blind is reused')
end
local legacy_kamiya=joker('kamiya')
legacy_kamiya.ability.extra={blind=cp.blind_id(),used={original=true}}
eq(calc('kamiya',legacy_kamiya,{after=true,scoring_hand=hand}).dollars,3,'legacy blind limit no longer blocks income')
eq(calc('kamiya',legacy_kamiya,{after=true,scoring_hand=hand}),nil,'migrated hand is guarded')
local fail_probability=SMODS.pseudorandom_probability
SMODS.pseudorandom_probability=function() return false end
G.GAME.hands_played=G.GAME.hands_played+1
G.consumeables.cards={}; G.consumeables.config.card_limit=2
eq(calc('kamiya',kamiya,{after=true,scoring_hand=hand}).dollars,3,'failed Tarot roll still pays')
eq(#events,0); eq(G.GAME.consumeable_buffer,0)
SMODS.pseudorandom_probability=fail_probability
G.GAME.hands_played=G.GAME.hands_played+1
local one_suit={play(2,{'Hearts'}),play(3,{'Hearts'}),play(4,{'Hearts'})}
eq(calc('kamiya',kamiya,{after=true,scoring_hand=one_suit}),nil,'non-qualifying hand does not pay')
eq(calc('kamiya',kamiya,{after=true,scoring_hand=hand,retrigger_joker=true}),nil)
eq(calc('kamiya',kamiya,{before=true,scoring_hand=hand}),nil)
eq(calc('kamiya',kamiya,{after=true,scoring_hand=hand}).dollars,3,'invalid evaluation does not consume hand')
for _,copy in ipairs({{sort_id=42},{sort_id=43}}) do
    local context={after=true,scoring_hand=hand,blueprint=1,blueprint_card=copy}
    eq(calc('kamiya',kamiya,context).dollars,3,'each ability copy can pay')
    eq(calc('kamiya',kamiya,context),nil,'each copy has its own duplicate guard')
end
eq(G.GAME.consumeable_buffer,2,'copies share reserved Tarot slots')
flush(); eq(#G.consumeables.cards,2); eq(G.GAME.consumeable_buffer,0)
G.GAME.hands_played=G.GAME.hands_played+1
eq(calc('kamiya',kamiya,{after=true,scoring_hand=hand}).dollars,3,'next hand pays again with full slots')
eq(#events,0)
kamiya.debuff=true
G.GAME.hands_played=G.GAME.hands_played+1
eq(calc('kamiya',kamiya,{after=true,scoring_hand=hand}),nil,'debuffed Kamiya is inactive')
kamiya.debuff=nil
G.consumeables.cards={}; G.GAME.hands_played=1
local probability_vars=SMODS.get_probability_vars
SMODS.get_probability_vars=function(_,n,d) return 2*n,d end
local odds=defs.kamiya:loc_vars({},kamiya).vars
eq(odds[3],2,'probability changes are reflected in the tooltip')
eq(odds[4],4)
SMODS.get_probability_vars=probability_vars
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
    eq(effect.chips,50,'two scored cards qualify even when five cards were played')
    total=total+effect.chips
end
eq(total,100,'each scored card gets its own chips')
for size=0,5 do
    local scoring={}
    for i=1,size do scoring[i]=played[i] end
    local effect=roll_score(a,scoring)
    if size==2 then eq(effect.chips,50) else eq(effect,nil,'exactly two scored cards required') end
end
eq(roll_score(a,nil),nil)
eq(roll_score(a,pair,G.hand),nil,'held cards do not receive chips')
eq(roll_score(a,pair,'unscored'),nil)
eq(roll_score(b,pair),nil,'unscored card in the played area does not receive chips')
for _,context in ipairs({{before=true},{after=true},{joker_main=true},{repetition=true}}) do
    context.cardarea=G.play; context.scoring_hand=pair; context.other_card=a
    eq(calc('plain_cakeroll',roll,context),nil,'only individual scoring grants chips')
end
eq(roll_score(a,pair,G.play,{blueprint=1}).chips,50,'Blueprint copies the card-scoring effect')
local retrigger_total=0
for _=1,3 do retrigger_total=retrigger_total+roll_score(a,pair).chips end
eq(retrigger_total,150,'each scoring retrigger grants another fifty chips')
local stone=play(7); stone.stone=true
eq(roll_score(stone,{a,stone}).chips,50,'two scored cards need not be a Pair')
eq(roll_score(a,{a,d,stone}),nil,'a third scored Stone Card prevents activation')
roll.debuff=true; eq(roll_score(a,pair),nil,'debuffed Joker is inactive')
roll.debuff=nil; eq(roll_score(a,pair).chips,50)
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
eq(saki_before(layout_saki,{played_left,scoring_right},{scoring_right}),nil,'unscored leftmost card cannot be selected')
eq(played_left.enhanced,nil)
eq(scoring_right.enhanced,nil)
eq(layout_saki.ability.extra.changed_blind,nil,'unscored target preserves use')
eq(#events,0,'no Makeup events for an unscored target')
-- A later valid hand in the same blind can still use the transformation.
G.GAME.hands_played=G.GAME.hands_played+1
local valid_makeup=saki_before(layout_saki,{scoring_right,played_left},{scoring_right})
eq(valid_makeup.message_card,scoring_right)
valid_makeup.func(); flush()
eq(scoring_right.enhanced,'m_wild')
eq(played_left.enhanced,nil,'the unscored card remains unchanged')
for _,scoring in ipairs({{}, {play(6),play(6)}}) do
    local left=play(9)
    local source=joker('saki')
    eq(saki_before(source,{left},scoring),nil,'leftmost must be present in the scoring hand')
    eq(left.enhanced,nil)
    eq(source.ability.extra.changed_blind,nil)
    eq(#events,0)
end
local missing_scoring=joker('saki')
local unverified=play(10)
eq(calc('saki',missing_scoring,{before=true,full_hand={unverified}}),nil,'missing scoring hand cannot select a target')
eq(missing_scoring.ability.extra.changed_blind,nil)
eq(unverified.enhanced,nil)
-- The leftmost played card remains the target even if another mod reorders scoring_hand.
local order_saki=joker('saki')
local first,other=play(4),play(4)
local ordered=saki_before(order_saki,{first,other},{other,first})
eq(ordered.message_card,first)
ordered.func(); flush()
eq(first.enhanced,'m_wild')
eq(other.enhanced,nil)
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
near(calc('satan',satan,{joker_main=true,blueprint=1}).xmult,5.5)
G.jokers.cards={satan}; near(calc('satan',satan,{joker_main=true}).xmult,4.75)
local restored=joker('satan'); restored.ability=clone(satan.ability)
calc('satan',restored,ctx); near(restored.ability.extra.growth,2.25)
-- A Legendary should have the new base even without any unit members.
for members=0,5 do
    G.jokers.cards={satan}
    local ids={'kamiya','shinonome','aslan','makio','saki'}
    for i=1,members do G.jokers.cards[#G.jokers.cards+1]=joker(ids[i]) end
    local fresh=joker('satan')
    near(calc('satan',fresh,{joker_main=true}).xmult,2.5+0.25*members)
    near(defs.satan:loc_vars({},fresh).vars[5],2.5+0.25*members,'tooltip matches actual Mult')
end
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
near(calc('satan',practice_satan,{joker_main=true}).xmult,3.75)

-- Collection/menu tooltips must work without an active run.
G.GAME={}
for id,def in pairs(defs) do
    local loc=def:loc_vars({},joker(id)); assert(type(loc.vars)=='table'); count=count+1
end
for _,lang in ipairs({'ja','en-us'}) do
    local loc=dofile(ROOT..'/localization/'..lang..'.lua')
    local description=assert(loc.descriptions.Mod.CafeParade)
    eq(description.name,'Cafetro!','localized MOD title stays branded')
    eq(#description.text > 1,true,'MOD description has explicit rows')
    eq(description.text[#description.text],'Art:Potetan','MOD description retains artist credit')
    eq(table.concat(description.text,' '):find('ChatGPT-6.1Sol Codex',1,true)~=nil,true,'generation credit retained')
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
    for id,variable in pairs({shinonome=3,satan=5}) do
        local lines=loc.descriptions.Joker['j_cp_'..id].text
        local last=lines[#lines]
        eq(last:find('{C:inactive}',1,true)~=nil,true,'current value is an inactive final row')
        eq(last:match('{X:mult,C:white}%s*X#'..variable..'#')~=nil,true,'current Mult uses native red box')
        eq(last:find(lang=='ja' and '現在 倍率' or 'Currently',1,true)~=nil,true)
        for i=1,#lines-1 do
            eq(lines[i]:find('#'..variable..'#',1,true),nil,'current value appears only in the last row')
        end
    end
    local sh_text=table.concat(loc.descriptions.Joker.j_cp_shinonome.text,' ')
    eq(sh_text:match('{X:mult,C:white}%s*X#2#%s*{}')~=nil,true,'growth uses a red XMult box')
    local satan_text=table.concat(loc.descriptions.Joker.j_cp_satan.text,' ')
    for _,variable in ipairs({3,4}) do
        eq(satan_text:match('{X:mult,C:white}%s*X#'..variable..'#%s*{}')~=nil,true)
    end
    local kamiya_text=table.concat(loc.descriptions.Joker.j_cp_kamiya.text,' ')
    eq(kamiya_text:find('#6#',1,true),nil,'no obsolete blind state')
    eq(table.concat(loc.descriptions.Joker.j_cp_saki.text,' '):find(lang=='ja' and '一番左' or 'Leftmost',1,true)~=nil,true)
    eq(loc.descriptions.Joker.j_cp_sunsun.text[3],
        '{C:inactive,s:0.6}[Fan art of PUPPET SUNSUN (Unofficial)]','SUNSUN fan art footer')
    assert(loc.misc.dictionary.k_cp_wild=='Makeup!')
    assert(loc.misc.v_dictionary.a_cp_growth)
    eq(loc.descriptions.Joker.j_cp_three_one_five.text[4],
        '{C:inactive,s:0.6}アイドルマスターSideM×FiFS展 THREE ONE FIVE','small gray source footer')
end

-- Unit badges are scoped to the six character Jokers, without renaming the MOD.
local badge_mod=SMODS.current_mod
badge_mod.id='CafeParade'
badge_mod.display_name='Cafetro!'
badge_mod.badge_colour='unit-purple'
badge_mod.badge_text_colour='white'
G.UIT={C='column'}
function HEX(value) return value end
SMODS.create_mod_badge=function(def,obj)
    assert(def.set_mod_badge==nil,'display-only settings avoid recursive badge callbacks')
    return {badge=def,obj=obj}
end
local character_badges={kamiya=true,shinonome=true,aslan=true,makio=true,saki=true,satan=true}
for id in pairs(defs) do
    local obj={key='j_cp_'..id,set='Joker'}
    local rows=badge_mod:set_mod_badge(obj).nodes
    eq(rows[1].badge.display_name,character_badges[id] and 'CafeParade' or 'Cafetro!','category for '..id)
    eq(rows[1].badge.badge_colour,'unit-purple','unit colour preserved')
    eq(rows[2].badge.display_name,'Art:Potetan','artist badge preserved')
    eq(rows[2].badge.badge_colour,'D6AA60','artist badge background preserved')
    eq(rows[2].obj,obj,'same card passed through')
end
eq(badge_mod:set_mod_badge({key='c_cp_finale',set='Challenge'}).nodes[1].badge.display_name,'Cafetro!')
eq(badge_mod:set_mod_badge(nil).nodes[1].badge.display_name,'Cafetro!')
eq(badge_mod.display_name,'Cafetro!','badge rendering does not mutate global display name')
print('Contract assertions passed: '..count)
