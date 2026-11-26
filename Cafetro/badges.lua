-- 対象のジョーカーにはMOD名の代わりにユニット名を表示する。
local cafeparade_cards = {
    j_cp_kamiya = true,
    j_cp_shinonome = true,
    j_cp_aslan = true,
    j_cp_makio = true,
    j_cp_saki = true,
    j_cp_satan = true,
}
local legenders_cards = {
    j_cp_sora = true,
    j_cp_koron = true,
    j_cp_amehiko = true,
}

return function(mod)
    local legenders_colour = HEX('6880A0')
    function mod:set_mod_badge(obj)
        local legenders = obj and legenders_cards[obj.key]
        local category = obj and cafeparade_cards[obj.key] and 'CafeParade' or self.display_name
        if legenders then category = 'Legenders' end
        local function row(id, text, colour, text_colour, no_shadow)
            -- コールバックを持たない表示用設定を渡し、再帰を避ける。
            return SMODS.create_mod_badge({
                id = id,
                display_name = text,
                badge_colour = colour or self.badge_colour,
                badge_text_colour = text_colour or self.badge_text_colour,
                badge_text_no_shadow = no_shadow or self.badge_text_no_shadow,
                no_marquee = true,
            }, obj)
        end
        return {n = G.UIT.C, config = {align = 'cm', padding = 0.03}, nodes = {
            row(self.id, category, legenders and legenders_colour),
            row(self.id .. '_art', 'Art:Potetan', HEX('D6AA60'), HEX('3C2C18'), true),
        }}
    end
end
