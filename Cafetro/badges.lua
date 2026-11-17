-- MOD名とイラスト制作者を、標準のバッジ2段で表示する。
return function(mod)
    function mod:set_mod_badge(obj)
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
            row(self.id, self.display_name),
            row(self.id .. '_art', 'Art:Potetan', HEX('D6AA60'), HEX('3C2C18'), true),
        }}
    end
end
