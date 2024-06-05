-- 自用素材包
-- 作者：houshuu
-- 素材来自于各个地方无法一一列举了
-- 可以自己複製對應語言的一行代碼來模仿添加自己的材質哦~！
local LSM = LibStub("LibSharedMedia-3.0")
local region = 128
if GetLocale() == 'zhCN' then region = 4 end
if GetLocale() == 'zhTW' then region = 8 end

-- English 例子
-- LSM:Register("font", "Vistor", [[Interface\Addons\WindMedia\font\EN_Vistor.ttf]], region) 

-- 简体 例子
if region == 4 then
	-- LSM:Register("font", "思源黑体 Heavy", [[Interface\Addons\WindMedia\font\CN_Siyuan_Heavy.ttf]], region)
end
-- 正體  例子
if region == 8 then
	-- LSM:Register("font", "思源黑體 Heavy", [[Interface\Addons\WindMedia\font\CN_Siyuan_Heavy.ttf]], region) 
end

-- 状态条材质
-- ElvUI_CustomMedia
LSM:Register("statusbar", "ElvUI_01", [[Interface\Addons\WindMedia\statusbar\ElvUI A.tga]]) 
LSM:Register("statusbar", "ElvUI_02", [[Interface\Addons\WindMedia\statusbar\ElvUI B.tga]]) 
LSM:Register("statusbar", "ElvUI_03", [[Interface\Addons\WindMedia\statusbar\ElvUI C.tga]]) 
LSM:Register("statusbar", "ElvUI_04", [[Interface\Addons\WindMedia\statusbar\ElvUI D.tga]]) 
LSM:Register("statusbar", "ElvUI_05", [[Interface\Addons\WindMedia\statusbar\ElvUI E.tga]]) 
LSM:Register("statusbar", "ElvUI_06", [[Interface\Addons\WindMedia\statusbar\ElvUI F.tga]]) 
LSM:Register("statusbar", "ElvUI_07", [[Interface\Addons\WindMedia\statusbar\ElvUI G.tga]]) 
LSM:Register("statusbar", "ElvUI_08", [[Interface\Addons\WindMedia\statusbar\ElvUI H.tga]]) 
LSM:Register("statusbar", "ElvUI_09", [[Interface\Addons\WindMedia\statusbar\ElvUI I.tga]]) 
LSM:Register("statusbar", "ElvUI_10", [[Interface\Addons\WindMedia\statusbar\ElvUI J.tga]]) 
LSM:Register("statusbar", "ElvUI_11", [[Interface\Addons\WindMedia\statusbar\ElvUI K.tga]]) 
LSM:Register("statusbar", "ElvUI_12", [[Interface\Addons\WindMedia\statusbar\ElvUI L.tga]]) 
LSM:Register("statusbar", "ElvUI_13", [[Interface\Addons\WindMedia\statusbar\ElvUI M.tga]]) 
LSM:Register("statusbar", "ElvUI_14", [[Interface\Addons\WindMedia\statusbar\ElvUI N.tga]]) 
LSM:Register("statusbar", "ElvUI_15", [[Interface\Addons\WindMedia\statusbar\ElvUI O.tga]]) 
LSM:Register("statusbar", "ElvUI_16", [[Interface\Addons\WindMedia\statusbar\ElvUI P.tga]])
-- FreeUI.Fluffy
LSM:Register("statusbar", "ElvUI_17", [[Interface\Addons\WindMedia\statusbar\FF_Angelique.tga]]) 
LSM:Register("statusbar", "ElvUI_18", [[Interface\Addons\WindMedia\statusbar\FF_Antonia.tga]]) 
LSM:Register("statusbar", "ElvUI_19", [[Interface\Addons\WindMedia\statusbar\FF_Bettina.tga]]) 
LSM:Register("statusbar", "ElvUI_20", [[Interface\Addons\WindMedia\statusbar\FF_Jasmin.tga]]) 
LSM:Register("statusbar", "ElvUI_21", [[Interface\Addons\WindMedia\statusbar\FF_Larissa.tga]]) 
LSM:Register("statusbar", "ElvUI_22", [[Interface\Addons\WindMedia\statusbar\FF_Lisa.tga]])
LSM:Register("statusbar", "ElvUI_23", [[Interface\Addons\WindMedia\statusbar\FF_Sam.tga]])
LSM:Register("statusbar", "ElvUI_24", [[Interface\Addons\WindMedia\statusbar\FF_Stella.tga]])
-- 风行丨GG @ NGA
LSM:Register("statusbar", "FXGG_1", [[Interface\Addons\WindMedia\statusbar\FX_001.tga]])
LSM:Register("statusbar", "FXGG_2", [[Interface\Addons\WindMedia\statusbar\FX_002.tga]])
LSM:Register("statusbar", "FXGG_3", [[Interface\Addons\WindMedia\statusbar\FX_003.tga]])
LSM:Register("statusbar", "FXGG_4", [[Interface\Addons\WindMedia\statusbar\FX_004.tga]])
-- 自作
LSM:Register("statusbar", "Wind_1", [[Interface\Addons\WindMedia\statusbar\WindTools_1.tga]])
-- 随便收集的
LSM:Register("statusbar", "Wind_2", [[Interface\Addons\WindMedia\statusbar\WindTools_2.tga]])