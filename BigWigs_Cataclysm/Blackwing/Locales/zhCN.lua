
local L = BigWigs:NewBossLocale("Magmaw", "zhCN")
if not L then return end
if L then
	L.stage2_yell_trigger = "难以置信"

	L.slump = "弱点"
	L.slump_desc = "当熔喉扑倒并暴露后脑时发出警报。需要骑乘。"
	L.slump_bar = "骑乘"
	L.slump_message = "嘿，快骑上它！"
	L.slump_emote_trigger = "%s向前倒下，暴露出他的钳子！"

	L.expose_emote_trigger = "将自己钉在刺上，露出了他的头"
end

L = BigWigs:NewBossLocale("Omnotron Defense System", "zhCN")
if L then
	L.nef = "维克多·奈法里奥斯勋爵"
	L.nef_desc = "当维克多·奈法里奥斯勋爵施放技能时发出警报。"

	L.pool = "奥术反冲"
end

L = BigWigs:NewBossLocale("Chimaeron", "zhCN")
if L then
	L.bileotron_engage = "胆汁喷洒机"

	L.next_system_failure = "下一系统当机"

	L.phase2_message = "即将 至死方休阶段！"
end

L = BigWigs:NewBossLocale("Atramedes", "zhCN")
if L then
	L.ground_phase = "地面阶段"
	L.ground_phase_desc = "当艾卓曼德斯着陆时发出警报。"
	L.air_phase = "空中阶段"
	L.air_phase_desc = "当艾卓曼德斯起飞时发出警报。"

	L.air_phase_trigger = "对，跑吧！每跑一步你的心跳都会加快。这心跳声，洪亮如雷，震耳欲聋。你逃不掉的！"

	L.obnoxious_soon = "即将 喧闹恶鬼！"

	L.searing_soon = "10秒后，灼热烈焰！"
end

L = BigWigs:NewBossLocale("Maloriak", "zhCN")
if L then
	--heroic
	L.sludge = "黑暗污泥"
	L.sludge_desc = "当你站在黑暗污泥上面时发出警报。"
	L.sludge_message = ">你< 黑暗污泥！"

	--normal
	L.final_phase = "最终阶段"
	L.final_phase_soon = "即将 最终阶段！"

	L.release_aberration_message = ">%s< 畸变怪剩余！"
	L.release_all = ">%s< 释放畸变怪！"

	L.phase = "阶段"
	L.phase_desc = "当进入不同阶段时发出警报。"
	L.next_phase = "下一阶段！"
	L.green_phase_bar = "绿色阶段"

	L.red_phase_trigger = "混合、搅拌、加热……"
	L.red_phase_emote_trigger = "红瓶"
	L.red_phase = "|cFFFF0000红瓶|r阶段"
	L.blue_phase_trigger = "凡人的躯壳能否经得住极端温度的转变，要弄清楚！为了科学！"
	L.blue_phase_emote_trigger = "蓝瓶"
	L.blue_phase = "|cFF809FFE蓝瓶|r阶段"
	L.green_phase_trigger = "这个有点儿不稳定，但不经过失败怎么会进步？"
	L.green_phase_emote_trigger = "绿瓶"
	L.green_phase = "|cFF33FF00绿瓶|r阶段"
	L.dark_phase_trigger = "你的混合剂太弱了，马洛拉克！他们需要更多的……“催化”！"
	L.dark_phase_emote_trigger = "黑暗"
	L.dark_phase = "|cFF660099黑暗|r阶段"
end

L = BigWigs:NewBossLocale("Nefarian", "zhCN")
if L then
	L.phase = "阶段"
	L.phase_desc = "当进入不同阶段时发出警报。"

	L.discharge_bar = "闪电倾泻"

	L.phase_two_trigger = "诅咒你们，凡人！你们丝毫不尊重他人财产的行为必须受到严厉处罚！"

	L.phase_three_trigger = "我一直在尝试扮演好客的主人，可你们就是不肯受死！该卸下伪装了……杀光你们！"

	L.crackle_trigger = "空气中激荡的电流噼啪作响！"
	L.crackle_message = "即将 通电！"

	L.shadowblaze_trigger = "血肉化为灰烬！"
	L.shadowblaze_message = ">你< 暗影爆燃！"

	L.onyxia_power_message = "即将 电荷过载！"

	L.chromatic_prototype = "原型多彩龙人" -- 3 adds name
end
