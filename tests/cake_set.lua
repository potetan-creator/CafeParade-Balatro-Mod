-- Exercise the Joker through a Blind pipeline that retains non-suit debuffs.
local count = 0
local function eq(actual, expected, label)
    assert(actual == expected, (label or '') .. ': expected ' .. tostring(expected) .. ', got ' .. tostring(actual))
    count = count + 1
end
local defs, queue = {}, {}
G = {GAME={round=1,hands_played=1,round_resets={ante=1}},
    jokers={cards={}},play={cards={}},hand={cards={}},playing_cards={}}
Blind = {}
Card = {set_edition = function() end}
function Blind:debuff_card(card, from_blind)
    if card.fail then error('original pipeline failure') end
    card.pipeline_calls = (card.pipeline_calls or 0) + 1
    card.from_blind = from_blind
    local d = self.debuff or {}
    local blocked = not self.disabled and card.area ~= G.jokers and (
        (d.suit and (card.suit == d.suit or card.enhanced == 'm_wild'))
        or (d.is_face == 'face' and card.face)
        or (d.value and d.value == card.rank)
        or (self.config.blind.key == 'bl_pillar' and card.played_this_ante))
    card.debuffed_by_blind = not not blocked
    -- Equivalent source precedence is important: false cannot erase other sources.
    card.debuff = not not (blocked or card.external_debuff or card.forced_by_joker)
    return 'original result'
end
SMODS = {current_mod={},Suit={obj_buffer={'Hearts','Diamonds','Clubs','Spades'}},
    load_file=function(path) return loadfile(ROOT..'/'..path) end,
    Atlas=function() end,DeckSkin=function() end,Challenge=function() end,
    DrawStep=function() end, Seal=function() end,
    Joker=function(def) defs[def.key]=def end,
    recalc_debuff=function(card) return G.GAME.blind:debuff_card(card) end,
    get_enhancements=function(card) return card.enhanced and {[card.enhanced]=true} or {} end,
    has_enhancement=function(card,key) return card.enhanced==key end}
function Event(event) return event end
G.E_MANAGER={add_event=function(_,event) queue[#queue+1]=event end}
function delay(seconds) G.E_MANAGER:add_event(Event({func=function() return true end})) end
function localize(key) return key end
local function flush()
    while #queue>0 do local event=table.remove(queue,1); assert(event.func()) end
end
function HEX(value) return value end
dofile(ROOT..'/main.lua')
local cp=SMODS.current_mod.cafeparade
local function joker(id)
    return {ability={extra={}},config={center={key='j_cp_'..id}}}
end
local function playing(suit, enhancement)
    local card={suit=suit,enhanced=enhancement,area=G.play,ability={}}
    function card:set_ability(center, initial, delayed)
        self.enhanced=center.key
        SMODS.recalc_debuff(self)
    end
    return card
end
G.P_CENTERS={m_wild={key='m_wild'}}
local function setup(key, suit, cakes)
    flush()
    cp.cake_set_hand=nil
    G.GAME.hands_played=G.GAME.hands_played+1
    G.GAME.blind=setmetatable({config={blind={key=key}},debuff={suit=suit}}, {__index=Blind})
    G.jokers.cards=cakes or {joker('cake_set')}
    local normal=playing(suit)
    local wild=playing('Hearts','m_wild')
    local held=playing(suit,'m_steel'); held.area=G.hand
    G.play.cards={normal,wild}; G.hand.cards={held}
    G.playing_cards={normal,wild,held}
    for _,card in ipairs(G.playing_cards) do SMODS.recalc_debuff(card) end
    return normal,wild,held,G.GAME.blind
end
local function before(name, extra)
    local context=extra or {}
    context.before=true; context.scoring_name=name
    context.scoring_hand=G.play.cards
    if not context.poker_hands then
        context.poker_hands={Pair=name=='Pair' and {G.play.cards} or {}}
    end
    return defs.cake_set:calculate(G.jokers.cards[1],context)
end
local function after()
    return defs.cake_set:calculate(G.jokers.cards[1],{after=true})
end
eq(defs.cake_set.rarity,1,'Common')
eq(defs.cake_set.cost,4)
eq(defs.cake_set.pos.x,1,'wrapped atlas column')
eq(defs.cake_set.pos.y,1,'wrapped atlas row')
eq(defs.cake_set.blueprint_compat,false)

for key,suit in pairs({bl_club='Clubs',bl_goad='Spades',bl_window='Diamonds',bl_head='Hearts'}) do
    local normal,wild,held,blind=setup(key,suit)
    local original=blind.debuff
    eq(wild.debuff,true,'Wild initially affected by '..key)
    eq(before('Pair').message,'k_cp_suit_relief')
    for _,card in ipairs({normal,wild,held}) do eq(card.debuff,false,'remove suit debuff during Pair') end
    eq(blind.disabled,nil,'do not disable the Boss')
    eq(blind.debuff,original,'restore original debuff table identity')
    eq(blind.debuff.suit,suit,'retain the Boss suit setting')
    eq(blind:debuff_card(wild,true),'original result','still invoke the original pipeline')
    eq(wild.from_blind,true)
    eq(before('Pair'),nil,'duplicate Cake activation is harmless')
    after()
    eq(cp.cake_set_hand,nil,'clear hand state synchronously')
    eq(wild.debuff,false,'do not restore before scoring visuals finish')
    flush()
    eq(wild.debuff,true,'restore Boss restriction after scoring')
    eq(held.debuff,true,'restore held-card restrictions too')
end

for _,name in ipairs({'Two Pair','Three of a Kind','Full House',
    'Four of a Kind','Five of a Kind','Flush House','Flush Five','Custom Pair'}) do
    local normal,wild=setup('bl_head','Hearts')
    eq(before(name,{poker_hands={Pair={{normal,wild}}}}).message,'k_cp_suit_relief',name..' contains a Pair')
    eq(wild.debuff,false)
    after(); flush(); eq(wild.debuff,true)
end
for _,name in ipairs({'High Card','Straight','Flush','Straight Flush','Custom Hand','Pair'}) do
    local normal,wild=setup('bl_head','Hearts')
    eq(before(name,{poker_hands={Pair={}}}),nil,name..' without an evaluated Pair must not activate')
    eq(wild.debuff,true)
    eq(cp.cake_set_hand,nil)
end

for _,key in ipairs({'bl_plant','bl_pillar','bl_eye','bl_mouth','bl_ox','bl_water','bl_wall',
    'bl_final_leaf','bl_final_heart','bl_custom_suit'}) do
    local normal,wild,held,blind=setup(key,'Hearts')
    local original=blind.debuff
    eq(before('Pair'),nil,'other Bosses must retain every restriction')
    eq(wild.debuff,true)
    eq(blind.debuff,original)
end

local normal,wild,held,blind=setup('bl_head','Hearts')
wild.external_debuff=true; held.forced_by_joker=true
before('Pair')
eq(normal.debuff,false)
eq(wild.debuff,true,'external source is retained')
eq(held.debuff,true,'another Joker can still debuff the card')
blind.debuff.is_face='face'; normal.face=true
SMODS.recalc_debuff(normal)
eq(normal.debuff,true,'non-suit fields on the same Boss are retained')
normal.face=false; normal.rank=7; blind.debuff.value=7
SMODS.recalc_debuff(normal)
eq(normal.debuff,true,'rank restrictions on the same Boss are retained')
local original=blind.debuff
normal.fail=true
local ok,err=pcall(function() blind:debuff_card(normal) end)
eq(ok,false,'propagate original errors')
eq(not not tostring(err):find('original pipeline failure'),true)
eq(blind.debuff,original,'restore Boss data even when original code raises')
normal.fail=nil
after(); flush()

normal,wild=setup('bl_head','Hearts')
G.jokers.cards[1].debuff=true
eq(before('Pair'),nil,'debuffed Cake is inactive even in direct calls')
eq(wild.debuff,true)
G.jokers.cards[1].debuff=nil
G.GAME.blind.disabled=true
eq(before('Pair'),nil,'already disabled Boss needs no bypass')

normal,wild=setup('bl_head','Hearts')
eq(before('Pair',{blueprint=1}),nil)
eq(before('Pair',{retrigger_joker=true}),nil)
eq(wild.debuff,true)
G.jokers.cards={joker('saki')}
eq(cp.begin_cake_set({scoring_name='Pair',poker_hands={Pair={{normal,wild}}}}),false,'Cake must actually be held')

local first,second=joker('cake_set'),joker('cake_set')
normal,wild=setup('bl_head','Hearts',{first,second})
before('Pair')
defs.cake_set:remove_from_deck(first)
SMODS.recalc_debuff(wild)
eq(wild.debuff,false,'second active Cake keeps protection')
defs.cake_set:remove_from_deck(second)
eq(wild.debuff,true,'removing the last Cake immediately restores restrictions')
eq(cp.cake_set_hand,nil)
defs.cake_set:add_to_deck(first)
eq(not not before('Pair'),true,'re-added Cake can trigger normally')
after(); flush()

for _,cake_first in ipairs({true,false}) do
    normal,wild=setup('bl_head','Hearts')
    local saki=joker('saki'); G.jokers.cards[#G.jokers.cards+1]=saki
    if cake_first then before('Pair') end
    local makeup=defs.saki:calculate(saki,{before=true,full_hand=G.play.cards,scoring_hand={normal,wild}})
    makeup.func()
    if not cake_first then before('Pair') end
    eq(normal.enhanced,'m_wild','Saki still transforms')
    eq(normal.debuff,false,'new Wild protected regardless of Joker order')
    eq(defs.saki:calculate(saki,{individual=true,cardarea=G.play,other_card=normal}).xmult,1.2)
    after(); flush()
    eq(normal.debuff,true,'new Wild returns to usual Boss restriction')
end

normal,wild=setup('bl_head','Hearts')
before('Pair')
G.GAME.hands_played=G.GAME.hands_played+1
SMODS.recalc_debuff(wild)
eq(wild.debuff,true,'stale state cannot protect the next hand')
eq(before('Two Pair'),nil)
eq(cp.cake_set_hand,nil)
eq(cp.members(),0,'Cake does not count toward Satan members')
print('Cake Set suit-only Boss restriction checks passed: '..count)
