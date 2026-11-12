return {
  descriptions = {
    Joker = {
      j_cp_kamiya = {name = "神谷幸広", text = {
        "得点したカードに{C:attention}#1#種類{}以上の",
        "スーツがある場合、{C:money}$#2#{}を得る",
        "{C:green}#4#分の#3#{}の確率で",
        "{C:tarot}タロット{}を1枚生成する",
        "{C:inactive}(空きが必要／ブラインドごとに1回)",
        "{C:inactive}(このブラインド：#6#)",
      }},
      j_cp_shinonome = {name = "東雲荘一郎", text = {
        "プレイしたハンドに{C:attention}ペア{}が",
        "含まれる場合、倍率{C:mult} +#1#{}",
        "さらに、このジョーカーは",
        "倍率{X:mult,C:white} X#2# {}を永続的に得る",
        "{C:inactive}(現在の倍率 {X:mult,C:white} X#3# {C:inactive})",
      }},
      j_cp_aslan = {name = "アスラン＝ベルゼビュートⅡ世", text = {
        "{C:attention}強化カード{}が得点されるたびに",
        "倍率{X:mult,C:white} X#1# {}",
      }},
      j_cp_makio = {name = "卯月巻緒", text = {
        "得点した{C:attention}ペア{}のカードを",
        "{C:attention}#2#回{}追加で発動させる",
        "{C:inactive}(左から#1#枚まで)",
      }},
      j_cp_saki = {name = "水嶋咲", text = {
        "{C:attention}ワイルドカード{}が得点されるたびに",
        "倍率{X:mult,C:white} X#1# {}",
        "得点後、左端の{C:attention}未強化カード{}を",
        "{C:attention}ワイルドカード{}に変える",
        "{C:inactive}(ブラインドごとに1回／#3#)",
      }},
      j_cp_satan = {name = "サタン", text = {
        "ジョーカースロット{C:attention} +#1#{}、倍率{X:mult,C:white} X#2# {}",
        "メンバー1人につき倍率{X:mult,C:white} X#3# {}を得る",
        "{C:attention}ボスブラインド{}を倒すたびに",
        "メンバー1人につき、さらに",
        "倍率{X:mult,C:white} X#4# {}を永続的に得る",
        "{C:inactive}(現在#5#人／成長 +#6#)",
        "{C:inactive}(現在の倍率 {X:mult,C:white} X#7# {C:inactive})",
      }},
    },
    Other = {
      cp_suits = {name = "スーツの数え方", text = {"ワイルドカード1枚は", "スーツ1種類分として数える", "スーツを同じ扱いにする効果も反映"}},
      cp_pair = {name = "得点したペア", text = {"得点カードに同じランクが", "2枚以上ある場合が対象", "ストーンカードは数えない"}},
      cp_makio = {name = "再発動の対象", text = {"同じランクが2枚以上ある組のうち", "最も左にあるカードの組を選ぶ", "ツーペアでも合計2枚まで"}},
      cp_members = {name = "Café Paradeメンバー", text = {"神谷・東雲・アスラン・巻緒・咲", "有効なカードを種類ごとに1人と数える", "同名2枚でも1人、サタンは数えない", "ボスで得た成長はメンバーが減っても残る"}},
      cp_saki = {name = "ワイルドへの変化", text = {"得点した未強化カードが対象", "変化はそのハンドの得点が終わってから", "対象がなければ次のハンドで再挑戦", "コピーできるのは倍率の効果のみ"}},
      cp_shinonome = {name = "倍率の成長", text = {"成長するのは1ハンドにつき1回", "成長した倍率はペア以外でも適用", "能力をコピーしても二重には成長しない"}},
    },
  },
  misc = {
    dictionary = {
      k_cp_wild = "Makeup!",
      k_cp_unused = "未使用",
      k_cp_used = "使用済み",
    },
    challenge_names = {c_cp_practice = "Café Parade：お試しライブ"},
    v_text = {ch_c_cp_practice = {
      "Café Paradeの6枚を所持してスタート",
      "デッキは8枚、最初の手札に全カードがそろう",
    }},
  },
}
