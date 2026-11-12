-- バランス数値はここだけで調整する。個体の成長値は ability.extra に保存。
return {
    kamiya = {rarity = 2, cost = 6, dollars = 3, suits = 3, odds = 4},
    shinonome = {rarity = 2, cost = 6, mult = 8, initial = 1, growth = 0.05},
    aslan = {rarity = 3, cost = 8, xmult = 1.25},
    makio = {rarity = 3, cost = 8, targets = 2, repetitions = 1},
    saki = {rarity = 3, cost = 8, xmult = 1.20,
        makeup_colour = {235/255, 110/255, 165/255, 1}, makeup_sound = 'tarot1'},
    satan = {rarity = 4, cost = 20, slots = 1, base = 2, per_member = 0.25, growth = 0.15},
}
