
PrefabFiles =
{
    "redbean",
    "orangebean",
    "yellowbean",
    "greenbean",
    "bluebean",
    "purplebean",
    "pinkbean",
}

do
    -- auto load languages translate
    local support_languages = { chs = true, cht = true, zh_CN = "chs", TW = "cht", }
    local steam_support_languages = { schinese = "chs", tchinese = "cht", }
    modimport("String_en.lua")

    local steamlang = GLOBAL.TheNet:GetLanguageCode() or nil
    if steamlang and steam_support_languages[steamlang] then
        print("<Starting NovicePacks> Get your language from steam!")
        print(steamlang)
        modimport("String_"..steam_support_languages[steamlang])
    else
        local lang = GLOBAL.LanguageTranslator.defaultlang or nil
        if lang ~= nil and support_languages[lang] ~= nil then
            if support_languages[lang] ~= true then
                lang = support_languages[lang]
            end
            print("<Starting NovicePacks> Get your language from language mod!")
            modimport("String_"..lang)
        end
    end
end

GLOBAL.STRINGS.BEAN.BOSS_DROP = GetModConfigData("BOSS_DROP")

GLOBAL.STRINGS.BEAN.RED.ATK = GetModConfigData("RED_ATK")
GLOBAL.STRINGS.BEAN.RED.DOR = GetModConfigData("RED_DOR")

GLOBAL.STRINGS.BEAN.ORANGE.DEF_TEMP = GetModConfigData("ORANGE_DEF_TEMP")
GLOBAL.STRINGS.BEAN.ORANGE.DOR = GetModConfigData("ORANGE_DOR")
GLOBAL.STRINGS.BEAN.ORANGE.DEF_PERM = GetModConfigData("ORANGE_DEF_PERM")

GLOBAL.STRINGS.BEAN.YELLOW.RADIUS = GetModConfigData("YELLOW_RADIUS")
GLOBAL.STRINGS.BEAN.YELLOW.DOR = GetModConfigData("YELLOW_DOR")

GLOBAL.STRINGS.BEAN.GREEN.SAN_MAX = GetModConfigData("GREEN_SAN_MAX")
GLOBAL.STRINGS.BEAN.GREEN.DOR = GetModConfigData("GREEN_DOR")

GLOBAL.STRINGS.BEAN.BLUE.FOOD_MAX = GetModConfigData("BLUE_FOOD_MAX")
GLOBAL.STRINGS.BEAN.BLUE.DOR = GetModConfigData("BLUE_DOR")

GLOBAL.STRINGS.BEAN.PINK.HEALTH_MAX = GetModConfigData("PINK_HEALTH_MAX")
GLOBAL.STRINGS.BEAN.PINK.DOR = GetModConfigData("PINK_DOR")


--增加组件beantag
AddPlayerPostInit(function(inst)
    inst:AddComponent("beantag")
    inst.components.beantag:BeanTagInit()
end)


AddComponentPostInit("hunger",function(self, inst)
    local function MyOnMax(self, setmax)
        local hunger_percent = self:GetPercent()
        if self.hungerBuff then
--            print("MyOnMax: self.max = "..self.max)
            self._.max[1] = setmax + GLOBAL.STRINGS.BEAN.BLUE.FOOD_MAX
--            print("MyOnMax: after rawset, self.max = "..self.max)
        end
        self.inst.replica.hunger:SetMax(self.max)
        self:SetPercent(hunger_percent)
    end
    self._.max[2] = MyOnMax
    self.hungerBuff = false
end)

AddComponentPostInit("sanity",function(self, inst)
    local function MyOnMax(self, setmax)
        local sanity_percent = self:GetPercent()
        if self.sanityBuff then
--            print("MyOnMax: self.max = "..self.max)
            self._.max[1] = setmax + GLOBAL.STRINGS.BEAN.GREEN.SAN_MAX
--            print("MyOnMax: after rawset, self.max = "..self.max)
        end
        self.inst.replica.sanity:SetMax(self.max)
        self:SetPercent(sanity_percent)
    end
    self._.max[2] = MyOnMax
    self.sanityBuff = false
end)

AddComponentPostInit("health",function(self, inst)
    local function MyOnMaxHealth(self, setmax)
        local health_percent = self:GetPercent()
        if self.healthBuff then
--            print("MyOnMax: self.max = "..self.maxhealth)
            self._.maxhealth[1] = setmax + GLOBAL.STRINGS.BEAN.PINK.HEALTH_MAX
--            print("MyOnMax: after rawset, self.max = "..self.maxhealth)
        end
        self.inst.replica.health:SetMax(self.maxhealth)
        self.inst.replica.health:SetIsFull((self.currenthealth or self.maxhealth) >= self.maxhealth)
        if self.inst.components.combat ~= nil then
            self.inst.components.combat.panic_thresh = self.inst.components.combat.panic_thresh
        end
        self:SetPercent(health_percent)
    end
    self._.maxhealth[2] = MyOnMaxHealth
    self.healthBuff = false
end)

AddComponentPostInit("lootdropper", function(self)
    local GenerateLoot_old = self.GenerateLoot
	self.GenerateLoot = function (self)
        if self.lootBuff ~= true then
            return GenerateLoot_old(self)
        end
        local loots = { }
        local loots_old = GenerateLoot_old(self)
        for k,v in pairs(loots_old) do    
            table.insert(loots,v)
            if math.random() < 0.2 then
                table.insert(loots,v)
            end
        end
        return loots
 	end
    self.lootBuff = false
end)

AddPrefabPostInit("cookpot", function(inst)
    if inst.components.stewer == nil then
        return
    end
    -- using the same harvest logic and repeat the item giving step once
    local old_harvest = inst.components.stewer.Harvest
    inst.components.stewer.Harvest = function(self, harvester)
        if math.random() < 0.2 and 
           harvester and 
           harvester.components and
           harvester.components.beantag and
           harvester.components.beantag.TAGTABLE["purplebean"].operation["perm"].active then
            if self.done and self.product and harvester.components.inventory then
                local loot = GLOBAL.SpawnPrefab(self.product)
                if loot ~= nil then
                    if self.spoiltime ~= nil and loot.components.perishable ~= nil then
                        local spoilpercent = self:GetTimeToSpoil() / self.spoiltime
                        loot.components.perishable:SetPercent(self.product_spoilage * spoilpercent)
                        loot.components.perishable:StartPerishing()
                    end
                    harvester.components.inventory:GiveItem(loot, nil, self.inst:GetPosition())
                end
            end
        end
        return old_harvest(self, harvester)
    end
end)

--主机相关设置
if GLOBAL.TheNet and GLOBAL.TheNet:GetIsServer() then

--魔豆信息获取
function GetPlayerById(id)
	for k,v in ipairs(GLOBAL.AllPlayers) do
		if v ~= nil and v.userid and v.userid == id then
			return v
		end
	end
	return nil
end

local OldNetworking_Say = GLOBAL.Networking_Say
GLOBAL.Networking_Say = function(guid, userid, name, prefab, message, colour, whisper)
    OldNetworking_Say(guid, userid, name, prefab, message, colour, whisper)
    talker = GetPlayerById(userid)
    if whisper then
        if string.sub(message,1,5) == "#bean" or string.sub(message,1,6) == "#douzi" then
            if not talker.components.beantag then
                return
            end
            local redBeanStr = GLOBAL.STRINGS.NAMES.REDBEAN.." : "..talker.components.beantag:GetBeanNum("redbean").."\n"
            local orangeBeanStr = GLOBAL.STRINGS.NAMES.ORANGEBEAN.." : "..talker.components.beantag:GetBeanNum("orangebean").."\n"
            local yellowBeanStr = GLOBAL.STRINGS.NAMES.YELLOWBEAN.." : "..talker.components.beantag:GetBeanNum("yellowbean").."\n"
            local greenBeanStr = GLOBAL.STRINGS.NAMES.GREENBEAN.." : "..talker.components.beantag:GetBeanNum("greenbean").."\n"
            local blueBeanStr = GLOBAL.STRINGS.NAMES.BLUEBEAN.." : "..talker.components.beantag:GetBeanNum("bluebean").."\n"
            local purpleBeanStr = GLOBAL.STRINGS.NAMES.PURPLEBEAN.." : "..talker.components.beantag:GetBeanNum("purplebean").."\n"
            local pinkBeanStr = GLOBAL.STRINGS.NAMES.PINKBEAN.." : "..talker.components.beantag:GetBeanNum("pinkbean")
            talker.components.talker:Say(redBeanStr..orangeBeanStr..yellowBeanStr..greenBeanStr..blueBeanStr..purpleBeanStr..pinkBeanStr)
		end
    end
end

--增加魔豆掉落
--这里事先预置了七魔豆的掉落率

monsterTable = 
{
    { monster = "deerclops", c = 0.114 },
    { monster = "bearger", c = 0.114 },
    { monster = "dragonfly", c = 0.114 },
    { monster = "moose", c = 0.114 },
    { monster = "minotaur", c = 0.114},
}
--[[
beanTable = 
{
    { prefab = "redbean", chance = 1},
    { prefab = "orangebean", chance = 1},
    { prefab = "yellowbean", chance = 1},
    { prefab = "greenbean", chance = 1},
    { prefab = "bluebean", chance = 1},
    { prefab = "purplebean", chance = 1},
    { prefab = "pinkbean", chance = 1},
}

local function AddLootToMonster(mTable, bTable)
    for mk, mv in pairs(mTable) do

        AddPrefabPostInit(mv.monster,)
    end
end
]]

AddPrefabPostInit("deerclops", function (inst)
    local c = 0.114 * GLOBAL.STRINGS.BEAN.BOSS_DROP
    local beanTable = 
    {
        { prefab = "redbean", chance = 1},
        { prefab = "orangebean", chance = 1},
        { prefab = "yellowbean", chance = 1},
        { prefab = "greenbean", chance = 1},
        { prefab = "bluebean", chance = 1},
        { prefab = "purplebean", chance = 1},
        { prefab = "pinkbean", chance = 1},
    }
    for k,v in pairs(beanTable) do
        inst.components.lootdropper:AddChanceLoot(v.prefab,c * v.chance)
    end
end)

AddPrefabPostInit("bearger", function (inst)
    local c = 0.114 * GLOBAL.STRINGS.BEAN.BOSS_DROP
    local beanTable = 
    {
        { prefab = "redbean", chance = 1},
        { prefab = "orangebean", chance = 1},
        { prefab = "yellowbean", chance = 1},
        { prefab = "greenbean", chance = 1},
        { prefab = "bluebean", chance = 1},
        { prefab = "purplebean", chance = 1},
        { prefab = "pinkbean", chance = 1},
    }
    for k,v in pairs(beanTable) do
        inst.components.lootdropper:AddChanceLoot(v.prefab,c * v.chance)
    end
end)

AddPrefabPostInit("dragonfly", function (inst)
    local c = 0.114 * GLOBAL.STRINGS.BEAN.BOSS_DROP
    local beanTable = 
    {
        { prefab = "redbean", chance = 1},
        { prefab = "orangebean", chance = 1},
        { prefab = "yellowbean", chance = 1},
        { prefab = "greenbean", chance = 1},
        { prefab = "bluebean", chance = 1},
        { prefab = "purplebean", chance = 1},
        { prefab = "pinkbean", chance = 1},
    }
    for k,v in pairs(beanTable) do
        inst.components.lootdropper:AddChanceLoot(v.prefab,c * v.chance)
    end
end)

AddPrefabPostInit("moose", function (inst)
    local c = 0.114 * GLOBAL.STRINGS.BEAN.BOSS_DROP
    local beanTable = 
    {
        { prefab = "redbean", chance = 1},
        { prefab = "orangebean", chance = 1},
        { prefab = "yellowbean", chance = 1},
        { prefab = "greenbean", chance = 1},
        { prefab = "bluebean", chance = 1},
        { prefab = "purplebean", chance = 1},
        { prefab = "pinkbean", chance = 1},
    }
    for k,v in pairs(beanTable) do
        inst.components.lootdropper:AddChanceLoot(v.prefab,c * v.chance)
    end
end)

AddPrefabPostInit("minotaur", function (inst)
    local c = 0.114 * GLOBAL.STRINGS.BEAN.BOSS_DROP
    local beanTable = 
    {
        { prefab = "redbean", chance = 1},
        { prefab = "orangebean", chance = 1},
        { prefab = "yellowbean", chance = 1},
        { prefab = "greenbean", chance = 1},
        { prefab = "bluebean", chance = 1},
        { prefab = "purplebean", chance = 1},
        { prefab = "pinkbean", chance = 1},
    }
    for k,v in pairs(beanTable) do
        inst.components.lootdropper:AddChanceLoot(v.prefab,c * v.chance)
    end 
end)

end

--增加合成列表

beantab = AddRecipeTab("Bean", 956, "images/hud/beantab.xml", "beantab.tex", nil)

AddRecipe("redbean", {GLOBAL.Ingredient("purplebean", 1,"images/inventoryimages/purplebean.xml")}, 
    beantab, 
    GLOBAL.TECH.SCIENCE_TWO, 
    nil, nil, nil, nil, nil, 
    "images/inventoryimages/redbean.xml", "redbean.tex" )

AddRecipe("orangebean", {GLOBAL.Ingredient("purplebean", 1,"images/inventoryimages/purplebean.xml")}, 
    beantab, 
    GLOBAL.TECH.SCIENCE_TWO, 
    nil, nil, nil, nil, nil, 
    "images/inventoryimages/orangebean.xml", "orangebean.tex" )

AddRecipe("yellowbean", {GLOBAL.Ingredient("purplebean", 1,"images/inventoryimages/purplebean.xml")}, 
    beantab, 
    GLOBAL.TECH.SCIENCE_TWO, 
    nil, nil, nil, nil, nil, 
    "images/inventoryimages/yellowbean.xml", "yellowbean.tex" )

AddRecipe("greenbean", {GLOBAL.Ingredient("purplebean", 1,"images/inventoryimages/purplebean.xml")}, 
    beantab, 
    GLOBAL.TECH.SCIENCE_TWO, 
    nil, nil, nil, nil, nil, 
    "images/inventoryimages/greenbean.xml", "greenbean.tex" )

AddRecipe("bluebean", {GLOBAL.Ingredient("purplebean", 1,"images/inventoryimages/purplebean.xml")}, 
    beantab, 
    GLOBAL.TECH.SCIENCE_TWO, 
    nil, nil, nil, nil, nil, 
    "images/inventoryimages/bluebean.xml", "bluebean.tex" )

AddRecipe("pinkbean", {GLOBAL.Ingredient("purplebean", 1,"images/inventoryimages/purplebean.xml")}, 
    beantab, 
    GLOBAL.TECH.SCIENCE_TWO, 
    nil, nil, nil, nil, nil, 
    "images/inventoryimages/pinkbean.xml", "pinkbean.tex" )

 -- 主机相关设置