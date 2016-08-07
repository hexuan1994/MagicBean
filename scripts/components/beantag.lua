local easing = require("easing")

local beantag =  Class( function( self, inst )

-- 组件持有人
self.inst = inst

self.TAGTABLE = { }

function self:BeanTagInit()
    if next(self.TAGTABLE) == nil then
        self.TAGTABLE["redbean"] = { }
        self.TAGTABLE["orangebean"] = { }
        self.TAGTABLE["yellowbean"] = { }
        self.TAGTABLE["greenbean"] = { }
        self.TAGTABLE["bluebean"] = { }
        self.TAGTABLE["purplebean"] = { }
        self.TAGTABLE["pinkbean"] = { }
    end
    for tag, tag_data in pairs(self.TAGTABLE) do
        if next(tag_data) == nil then 
            tag_data.name = tag
            tag_data.num = 0
            tag_data.operation = { }
        end
    end

    self:redBeanfn()
    self:orangeBeanfn()
    self:yellowBeanfn()
    self:greenBeanfn()
    self:blueBeanfn()
    self:purpleBeanfn()
    self:pinkBeanfn()
    
    self.inst:ListenForEvent("cycleschanged", function() print("in cycleschanged") self:OnUpdate() end,TheWorld)
--    self.inst:ListenForEvent("respawnfromghost", function() self:OnUpdate() end)
end

function self:AddOperation(tag,opName,activeNum,doration,OnLoadfn,OnRemovefn,OnUpdatefn)
    if self.TAGTABLE[tag].operation[opName] == nil then self.TAGTABLE[tag].operation[opName] = { } end
    self.TAGTABLE[tag].operation[opName].active = false
    self.TAGTABLE[tag].operation[opName].activeNum = activeNum
    self.TAGTABLE[tag].operation[opName].startTime = 9999
    self.TAGTABLE[tag].operation[opName].doration = doration or 9999
    self.TAGTABLE[tag].operation[opName].OnLoadfn = OnLoadfn
    self.TAGTABLE[tag].operation[opName].OnRemovefn = OnRemovefn
    self.TAGTABLE[tag].operation[opName].OnUpdatefn = OnUpdatefn
end

--red bean
function self:redBeanfn()
    local function redOnLoadfn(inst, eatUpdate)
        inst:DoTaskInTime(1, function(player)
		    if player.components.talker and eatUpdate then player.components.talker:Say(STRINGS.BEAN.RED.PERM_L) end
		end)
        inst.components.locomotor:SetExternalSpeedMultiplier(inst, "redbean", 1.2)
    end

    local function redOnRemovefn(inst, eatUpdate)
        inst:DoTaskInTime(1, function(player)
		    if player.components.talker and eatUpdate then player.components.talker:Say(STRINGS.BEAN.RED.PERM_R) end
		end)
        inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "redbean")
    end

    local function redTempOnLoadfn(inst, eatUpdate)
        inst:DoTaskInTime(0.5, function(player)
		    if player.components.talker and eatUpdate then player.components.talker:Say(STRINGS.BEAN.RED.TEMP_L) end
		end)
        local function MyCalcDamage(self, target, weapon, multiplier)
            if target:HasTag("alwaysblock") then
                return 0
            end

            local basedamage
            local basemultiplier = (self.damagemultiplier or 1) * STRINGS.BEAN.RED.ATK
            local bonus = self.damagebonus --not affected by multipliers
            local playermultiplier = target ~= nil and target:HasTag("player")
            local pvpmultiplier = playermultiplier and self.inst:HasTag("player") and self.pvp_damagemod or 1

            --NOTE: playermultiplier is for damage towards players
            --      generally only applies for NPCs attacking players

            if weapon ~= nil then
                --No playermultiplier when using weapons
                basedamage = weapon.components.weapon.damage or 0
                playermultiplier = 1
            else
                basedamage = self.defaultdamage
                playermultiplier = playermultiplier and self.playerdamagepercent or 1

                if self.inst.components.rider ~= nil and self.inst.components.rider:IsRiding() then
                    local mount = self.inst.components.rider:GetMount()
                    if mount ~= nil and mount.components.combat ~= nil then
                        basedamage = mount.components.combat.defaultdamage
                        basemultiplier = mount.components.combat.damagemultiplier
                        bonus = mount.components.combat.damagebonus
                    end

                    local saddle = self.inst.components.rider:GetSaddle()
                    if saddle ~= nil and saddle.components.saddler ~= nil then
                        basedamage = basedamage + saddle.components.saddler:GetBonusDamage()
                    end
                end
            end

            return basedamage
                * (basemultiplier or 1)
                * (multiplier or 1)
                * playermultiplier
                * pvpmultiplier
                + (bonus or 0)
        end
        inst.components.combat.CalcDamage = MyCalcDamage
    end

    local function redTempOnRemovefn(inst, eatUpdate)
        inst:DoTaskInTime(0.5, function(player)
		    if player.components.talker and eatUpdate then player.components.talker:Say(STRINGS.BEAN.RED.TEMP_R) end
		end)
        local function MyCalcDamage(self, target, weapon, multiplier)
            if target:HasTag("alwaysblock") then
                return 0
            end

            local basedamage
            local basemultiplier = self.damagemultiplier
            local bonus = self.damagebonus --not affected by multipliers
            local playermultiplier = target ~= nil and target:HasTag("player")
            local pvpmultiplier = playermultiplier and self.inst:HasTag("player") and self.pvp_damagemod or 1

            --NOTE: playermultiplier is for damage towards players
            --      generally only applies for NPCs attacking players

            if weapon ~= nil then
                --No playermultiplier when using weapons
                basedamage = weapon.components.weapon.damage or 0
                playermultiplier = 1
            else
                basedamage = self.defaultdamage
                playermultiplier = playermultiplier and self.playerdamagepercent or 1

                if self.inst.components.rider ~= nil and self.inst.components.rider:IsRiding() then
                    local mount = self.inst.components.rider:GetMount()
                    if mount ~= nil and mount.components.combat ~= nil then
                        basedamage = mount.components.combat.defaultdamage
                        basemultiplier = mount.components.combat.damagemultiplier
                        bonus = mount.components.combat.damagebonus
                    end

                    local saddle = self.inst.components.rider:GetSaddle()
                    if saddle ~= nil and saddle.components.saddler ~= nil then
                        basedamage = basedamage + saddle.components.saddler:GetBonusDamage()
                    end
                end
            end

            return basedamage
                * (basemultiplier or 1)
                * (multiplier or 1)
                * playermultiplier
                * pvpmultiplier
                + (bonus or 0)
        end
        inst.components.combat.CalcDamage = MyCalcDamage
    end
    self:AddOperation("redbean","temp",1,STRINGS.BEAN.RED.DOR,redTempOnLoadfn,redTempOnRemovefn)
    self:AddOperation("redbean","perm",3,nil,redOnLoadfn,redOnRemovefn)
end

--orange bean
function self:orangeBeanfn()
    local function orangeOnLoadfn(inst, eatUpdate)
        inst:DoTaskInTime(1, function(player)
		    if player.components.talker and eatUpdate then player.components.talker:Say(STRINGS.BEAN.ORANGE.PERM_L) end
		end)
        inst.components.health:SetAbsorptionAmount(STRINGS.BEAN.ORANGE.DEF_PERM)
    end

    local function orangeOnRemovefn(inst, eatUpdate)
        inst:DoTaskInTime(1, function(player)
		    if player.components.talker and eatUpdate then player.components.talker:Say(STRINGS.BEAN.ORANGE.PERM_R) end
		end)
        inst.components.health:SetAbsorptionAmount(0)
    end

    local function orangeTempOnLoadfn(inst, eatUpdate)
        inst:DoTaskInTime(0.5, function(player)
		    if player.components.talker and eatUpdate then player.components.talker:Say(STRINGS.BEAN.ORANGE.TEMP_L) end
		end)
        inst.components.health:SetAbsorptionAmount(STRINGS.BEAN.ORANGE.DEF_TEMP)
    end

    local function orangeTempOnRemovefn(inst, eatUpdate)
        inst:DoTaskInTime(0.5, function(player)
		    if player.components.talker and eatUpdate then player.components.talker:Say(STRINGS.BEAN.ORANGE.TEMP_R) end
		end)
        if inst.components and
            inst.components.beantag and
            inst.components.beantag.TAGTABLE and
            inst.components.beantag.TAGTABLE["orange"] and
            inst.components.beantag.TAGTABLE["orange"].operation and
            inst.components.beantag.TAGTABLE["orange"].operation["perm"] and
            inst.components.beantag.TAGTABLE["orange"].operation["perm"].active then
            inst.components.health:SetAbsorptionAmount(0.6)
            return
        end
        inst.components.health:SetAbsorptionAmount(0)
    end
    self:AddOperation("orangebean","temp",1,STRINGS.BEAN.ORANGE.DOR,orangeTempOnLoadfn,orangeTempOnRemovefn)
    self:AddOperation("orangebean","perm",3,nil,orangeOnLoadfn,orangeOnRemovefn)
end

--yellow bean
function self:yellowBeanfn()
    local function yellowOnLoadfn(inst, eatUpdate)
        inst:DoTaskInTime(1, function(player)
		    if player.components.talker and eatUpdate then player.components.talker:Say(STRINGS.BEAN.YELLOW.PERM_L) end
		end)
        inst.components.health.fire_damage_scale = 0
        inst.components.temperature.maxtemp = 30
    end

    local function yellowOnRemovefn(inst, eatUpdate)
        inst:DoTaskInTime(1, function(player)
		    if player.components.talker and eatUpdate then player.components.talker:Say(STRINGS.BEAN.YELLOW.PERM_R) end
		end)
        inst.components.health.fire_damage_scale = 1
        inst.components.temperature.mintemp = TUNING.MIN_ENTITY_TEMP
    end

    local function yellowTempOnLoadfn(inst, eatUpdate)
        inst:DoTaskInTime(0.5, function(player)
		    if player.components.talker and eatUpdate then player.components.talker:Say(STRINGS.BEAN.YELLOW.TEMP_L) end
		end)
        if inst.Light == nil then
            inst.entity:AddLight()
        end
        inst.Light:Enable(false)
        inst.Light:Enable(true)
        inst.Light:SetRadius(STRINGS.BEAN.YELLOW.RADIUS)
        inst.Light:SetFalloff(.8)
        inst.Light:SetIntensity(.8)
        inst.Light:SetColour(255 / 255, 255 / 255, 112 / 255)
    end

    local function yellowTempOnRemovefn(inst, eatUpdate)
        inst:DoTaskInTime(0.5, function(player)
		    if player.components.talker and eatUpdate then player.components.talker:Say(STRINGS.BEAN.YELLOW.TEMP_R) end
		end)
        if inst.Light ~= nil then
            inst.Light:Enable(false)
        end
    end
    self:AddOperation("yellowbean","temp",1,STRINGS.BEAN.YELLOW.DOR,yellowTempOnLoadfn,yellowTempOnRemovefn)
    self:AddOperation("yellowbean","perm",3,nil,yellowOnLoadfn,yellowOnRemovefn)
end

--green bean
function self:greenBeanfn()
    local function greenOnLoadfn(inst, eatUpdate)
        inst:DoTaskInTime(1, function(player)
		    if player.components.talker and eatUpdate then player.components.talker:Say(STRINGS.BEAN.GREEN.PERM_L) end
		end)
--              目的使玩家的精神值上限提升50点
        if inst.components.sanity.sanityBuff == false then
            inst.components.sanity:SetMax(inst.components.sanity.max+STRINGS.BEAN.GREEN.SAN_MAX)
            inst.components.sanity.sanityBuff = true
        end
    end

    local function greenOnRemovefn(inst, eatUpdate)

    end

    local function greenTempOnLoadfn(inst, eatUpdate)
        inst:DoTaskInTime(0.5, function(player)
		    if player.components.talker and eatUpdate then player.components.talker:Say(STRINGS.BEAN.GREEN.TEMP_L) end
		end)

        local function MyRecalc(self, dt)
            local total_dapperness = self.dapperness or 0
            for k, v in pairs(self.inst.components.inventory.equipslots) do
                if v.components.equippable ~= nil then
                    total_dapperness = total_dapperness + v.components.equippable:GetDapperness(self.inst)
                end
            end

            total_dapperness = total_dapperness * self.dapperness_mult

            local dapper_delta = total_dapperness * TUNING.SANITY_DAPPERNESS

            local moisture_delta = easing.inSine(self.inst.components.moisture:GetMoisture(), 0, TUNING.MOISTURE_SANITY_PENALTY_MAX, self.inst.components.moisture:GetMaxMoisture())

            local light_delta
            if TheWorld.state.isday and not TheWorld:HasTag("cave") then
                light_delta = TUNING.SANITY_DAY_GAIN
            else
                local lightval = CanEntitySeeInDark(self.inst) and .9 or self.inst.LightWatcher:GetLightValue()
                light_delta =
                    (   (lightval > TUNING.SANITY_HIGH_LIGHT and TUNING.SANITY_NIGHT_LIGHT) or
                        (lightval < TUNING.SANITY_LOW_LIGHT and TUNING.SANITY_NIGHT_DARK) or
                        TUNING.SANITY_NIGHT_MID
                    ) * self.night_drain_mult
            end

            local aura_delta = 0
            local x, y, z = self.inst.Transform:GetWorldPosition()
            local ents = TheSim:FindEntities(x, y, z, TUNING.SANITY_EFFECT_RANGE, nil, { "FX", "NOCLICK", "DECOR","INLIMBO" })
            for i, v in ipairs(ents) do 
                if v.components.sanityaura ~= nil and v ~= self.inst then
                    local aura_val = v.components.sanityaura:GetAura(self.inst) / math.max(1, self.inst:GetDistanceSqToInst(v))
                    aura_delta = aura_delta + (aura_val < 0 and aura_val * self.neg_aura_mult or aura_val)
                end
            end

            local mount = self.inst.components.rider:IsRiding() and self.inst.components.rider:GetMount() or nil
            if mount ~= nil and mount.components.sanityaura ~= nil then
                local aura_val = mount.components.sanityaura:GetAura(self.inst)
                aura_delta = aura_delta + (aura_val < 0 and aura_val * self.neg_aura_mult or aura_val)
            end

            self:RecalcGhostDrain()
            local ghost_delta = TUNING.SANITY_GHOST_PLAYER_DRAIN * self.ghost_drain_mult

            self.rate = dapper_delta + moisture_delta + light_delta + aura_delta + ghost_delta

            if self.custom_rate_fn ~= nil then
                self.rate = self.rate + self.custom_rate_fn(self.inst)
            end
            self.rate = (self.rate + 0.5) * self.rate_modifier          --进行修改,使得实现自动回复san值
            self.ratescale =
                (self.rate > .2 and RATE_SCALE.INCREASE_HIGH) or
                (self.rate > .1 and RATE_SCALE.INCREASE_MED) or
                (self.rate > .01 and RATE_SCALE.INCREASE_LOW) or
                (self.rate < -.3 and RATE_SCALE.DECREASE_HIGH) or
                (self.rate < -.1 and RATE_SCALE.DECREASE_MED) or
                (self.rate < -.02 and RATE_SCALE.DECREASE_LOW) or
                RATE_SCALE.NEUTRAL

            --print (string.format("dapper: %2.2f light: %2.2f TOTAL: %2.2f", dapper_delta, light_delta, self.rate*dt))
            self:DoDelta(self.rate * dt, true)
        end
        inst.components.sanity.Recalc = MyRecalc
    end

    local function greenTempOnRemovefn(inst, eatUpdate)
        inst:DoTaskInTime(0.5, function(player)
		    if player.components.talker and eatUpdate then player.components.talker:Say(STRINGS.BEAN.GREEN.TEMP_R) end
		end)

        local function MyRecalc(self, dt)
            local total_dapperness = self.dapperness or 0
            for k, v in pairs(self.inst.components.inventory.equipslots) do
                if v.components.equippable ~= nil then
                    total_dapperness = total_dapperness + v.components.equippable:GetDapperness(self.inst)
                end
            end

            total_dapperness = total_dapperness * self.dapperness_mult

            local dapper_delta = total_dapperness * TUNING.SANITY_DAPPERNESS

            local moisture_delta = easing.inSine(self.inst.components.moisture:GetMoisture(), 0, TUNING.MOISTURE_SANITY_PENALTY_MAX, self.inst.components.moisture:GetMaxMoisture())

            local light_delta
            if TheWorld.state.isday and not TheWorld:HasTag("cave") then
                light_delta = TUNING.SANITY_DAY_GAIN
            else
                local lightval = CanEntitySeeInDark(self.inst) and .9 or self.inst.LightWatcher:GetLightValue()
                light_delta =
                    (   (lightval > TUNING.SANITY_HIGH_LIGHT and TUNING.SANITY_NIGHT_LIGHT) or
                        (lightval < TUNING.SANITY_LOW_LIGHT and TUNING.SANITY_NIGHT_DARK) or
                        TUNING.SANITY_NIGHT_MID
                    ) * self.night_drain_mult
            end

            local aura_delta = 0
            local x, y, z = self.inst.Transform:GetWorldPosition()
            local ents = TheSim:FindEntities(x, y, z, TUNING.SANITY_EFFECT_RANGE, nil, { "FX", "NOCLICK", "DECOR","INLIMBO" })
            for i, v in ipairs(ents) do 
                if v.components.sanityaura ~= nil and v ~= self.inst then
                    local aura_val = v.components.sanityaura:GetAura(self.inst) / math.max(1, self.inst:GetDistanceSqToInst(v))
                    aura_delta = aura_delta + (aura_val < 0 and aura_val * self.neg_aura_mult or aura_val)
                end
            end

            local mount = self.inst.components.rider:IsRiding() and self.inst.components.rider:GetMount() or nil
            if mount ~= nil and mount.components.sanityaura ~= nil then
                local aura_val = mount.components.sanityaura:GetAura(self.inst)
                aura_delta = aura_delta + (aura_val < 0 and aura_val * self.neg_aura_mult or aura_val)
            end

            self:RecalcGhostDrain()
            local ghost_delta = TUNING.SANITY_GHOST_PLAYER_DRAIN * self.ghost_drain_mult

            self.rate = dapper_delta + moisture_delta + light_delta + aura_delta + ghost_delta

            if self.custom_rate_fn ~= nil then
                self.rate = self.rate + self.custom_rate_fn(self.inst)
            end

            self.rate = self.rate * self.rate_modifier          --取消san值自动回复
            self.ratescale =
                (self.rate > .2 and RATE_SCALE.INCREASE_HIGH) or
                (self.rate > .1 and RATE_SCALE.INCREASE_MED) or
                (self.rate > .01 and RATE_SCALE.INCREASE_LOW) or
                (self.rate < -.3 and RATE_SCALE.DECREASE_HIGH) or
                (self.rate < -.1 and RATE_SCALE.DECREASE_MED) or
                (self.rate < -.02 and RATE_SCALE.DECREASE_LOW) or
                RATE_SCALE.NEUTRAL

            --print (string.format("dapper: %2.2f light: %2.2f TOTAL: %2.2f", dapper_delta, light_delta, self.rate*dt))
            self:DoDelta(self.rate * dt, true)
        end
        inst.components.sanity.Recalc = MyRecalc
    end
    self:AddOperation("greenbean","temp",1,10,greenTempOnLoadfn,greenTempOnRemovefn)
    self:AddOperation("greenbean","perm",3,nil,greenOnLoadfn,greenOnRemovefn)
end

function self:blueBeanfn()
    local function blueOnLoadfn(inst, eatUpdate)
        inst:DoTaskInTime(1, function(player)
		    if player.components.talker and eatUpdate then player.components.talker:Say(STRINGS.BEAN.BLUE.PERM_L) end
		end)
--              目的使玩家的饥饿值上限提升50点,
        if inst.components.hunger.hungerBuff == false then
            inst.components.hunger:SetMax(inst.components.hunger.max+STRINGS.BEAN.BLUE.FOOD_MAX)
            inst.components.hunger.hungerBuff = true
        end
    end

    local function blueOnRemovefn(inst)

    end

    local function blueTempOnLoadfn(inst, eatUpdate)
        inst:DoTaskInTime(0.5, function(player)
		    if player.components.talker and eatUpdate then player.components.talker:Say(STRINGS.BEAN.BLUE.TEMP_L) end
		end)
        local hungerrate = inst.components.hunger.hungerrate
        inst.components.hunger:SetRate(hungerrate * 0.2)        --饥饿速度降低为20%
    end

    local function blueTempOnRemovefn(inst, eatUpdate)
        inst:DoTaskInTime(0.5, function(player)
		    if player.components.talker and eatUpdate then player.components.talker:Say(STRINGS.BEAN.BLUE.TEMP_R) end
		end)
        local hungerrate = inst.components.hunger.hungerrate
        inst.components.hunger:SetRate(TUNING.WILSON_HUNGER_RATE)
    end
    self:AddOperation("bluebean","temp",1,STRINGS.BEAN.BLUE.DOR,blueTempOnLoadfn,blueTempOnRemovefn)
    self:AddOperation("bluebean","perm",3,nil,blueOnLoadfn,blueOnRemovefn)
end

function self:purpleBeanfn()
    local function purpleOnLoadfn(inst, eatUpdate)
        inst:DoTaskInTime(1, function(player)
		    if player.components.talker and eatUpdate then player.components.talker:Say(STRINGS.BEAN.PURPLE.PERM_L) end
		end)
        if self.inst and self.inst.components and self.inst.components.playerlightningtarget then
            self.inst.components.playerlightningtarget:SetHitChance(0)
        end
    end

    local function purpleOnRemovefn(inst)
        inst:DoTaskInTime(1, function(player)
		    if player.components.talker and eatUpdate then player.components.talker:Say(STRINGS.BEAN.PURPLE.PERM_R) end
		end)
    end

    local function purpleTempOnLoadfn(inst, eatUpdate)
        inst:DoTaskInTime(0.5, function(player)
		    if player.components.talker and eatUpdate then player.components.talker:Say(STRINGS.BEAN.PURPLE.TEMP_L) end
		end)
        
        local DoAttack_old = inst.components.combat.DoAttack
        inst.components.combat.DoAttack =  function (self, target_override, weapon, projectile, stimuli, instancemult)
            local targ = target_override or self.target
            local weapon = weapon or self:GetWeapon()
            if not self:CanHitTarget(targ, weapon) then
                return DoAttack_old(self, target_override, weapon, projectile, stimuli, instancemult)
            end
            if self.inst.components.beantag.TAGTABLE["purplebean"].operation["temp"].active and 
               targ.components and targ.components.lootdropper then
                targ.components.lootdropper.lootBuff = true
            else
                targ.components.lootdropper.lootBuff = false
            end
            return DoAttack_old(self, target_override, weapon, projectile, stimuli, instancemult)
        end
    end

    local function purpleTempOnRemovefn(inst)
        inst:DoTaskInTime(0.5, function(player)
		    if player.components.talker then player.components.talker:Say(STRINGS.BEAN.PURPLE.TEMP_R) end
		end)
    end
    self:AddOperation("purplebean","temp",1,2,purpleTempOnLoadfn,purpleTempOnRemovefn)
    self:AddOperation("purplebean","perm",3,nil,purpleOnLoadfn,purpleOnRemovefn)
end

--pink bean
function self:pinkBeanfn()
    local function pinkOnLoadfn(inst, eatUpdate)
        inst:DoTaskInTime(1, function(player)
		    if player.components.talker and eatUpdate then player.components.talker:Say(STRINGS.BEAN.PINK.PERM_L) end
		end)

--              目的使玩家的血量值上限提升50点,
        if inst.components.health.healthBuff == false then
            inst.components.health:SetMaxHealth(inst.components.health.maxhealth+STRINGS.BEAN.PINK.HEALTH_MAX)
            inst.components.health.healthBuff = true
        end
        inst.components.temperature.mintemp = 20
    end

    local function pinkOnRemovefn(inst, eatUpdate)

    end

    local function pinkTempOnLoadfn(inst, eatUpdate)
        inst:DoTaskInTime(0.5, function(player)
		    if player.components.talker and eatUpdate then player.components.talker:Say(STRINGS.BEAN.PINK.TEMP_L) end
		end)
        inst.components.health:StartRegen(1,2)         --增加自动回血
    end

    local function pinkTempOnRemovefn(inst, eatUpdate)
        inst:DoTaskInTime(0.5, function(player)
		    if player.components.talker and eatUpdate then player.components.talker:Say(STRINGS.BEAN.PINK.TEMP_R) end
		end)
        inst.components.health:StopRegen()
    end
    self:AddOperation("pinkbean","temp",1,STRINGS.BEAN.PINK.DOR,pinkTempOnLoadfn,pinkTempOnRemovefn)
    self:AddOperation("pinkbean","perm",3,nil,pinkOnLoadfn,pinkOnRemovefn)
end

--------------------------------------------------------------------------
--[[ Public member functions ]]
--------------------------------------------------------------------------


function self:ActiveOneTime(tag)
    if self.TAGTABLE[tag] then
        self.TAGTABLE[tag].num = self.TAGTABLE[tag].num + 1	            --激活次数加一

        self.TAGTABLE[tag].operation["temp"].active = true
        self.TAGTABLE[tag].operation["temp"].startTime = TheWorld.state.cycles  --激活临时效果
        self.TAGTABLE[tag].operation["temp"].OnLoadfn(self.inst,true)

        if self.TAGTABLE[tag].operation["perm"].active ~= true and self.TAGTABLE[tag].num >= self.TAGTABLE[tag].operation["perm"].activeNum then
            self.TAGTABLE[tag].operation["perm"].active = true
            self.TAGTABLE[tag].operation["perm"].startTime = TheWorld.state.cycles  --激活永久效果
            self.TAGTABLE[tag].operation["perm"].OnLoadfn(self.inst,true)
        end
    end
end

function self:GetBeanNum(bean)
    local num = 0
    if self.TAGTABLE[bean] and self.TAGTABLE[bean].num then
        num = self.TAGTABLE[bean].num
    end
    return num
end

function self:HasTag(tag)
	return self.TAGTABLE[tag] ~= nil
end

function self:RemoveTag(tag)
	if self.TAGTABLE[tag] and self.TAGTABLE[tag].operation then
		for opName, op_data in pairs(self.TAGTABLE[tag].operation) do
            op_data:OnRemovefn(self.inst)
        end
	end
	self.TAGTABLE[tag] = nil
end

function self:OnSave()
    local data = { }
    data["redbean"] = { }
    data["orangebean"] = { }
    data["yellowbean"] = { }
    data["greenbean"] = { }
    data["bluebean"] = { }
    data["purplebean"] = { }
    data["pinkbean"] = { }

    for tag, tag_data in pairs(data) do
        if next(tag_data) == nil then 
            tag_data.num = 0
            tag_data.operation = { }
        end
    end

	for tag,tag_data in pairs(self.TAGTABLE ) do
        if tag_data.num then
            data[tag].num = tag_data.num        --保存已食用数量
            if tag_data.operation then         --若operation存在
                for opName, op_data in pairs(self.TAGTABLE[tag].operation) do
                    if data[tag].operation[opName] == nil then data[tag].operation[opName] = { } end
                    data[tag].operation[opName].startTime = op_data.startTime       --保存效果开始时间      
                end
            end
        else
            data[tag].num = -1
        end
	end
	return data
end
 
function self:OnLoad( data )
    self:BeanTagInit()
    for tag, tag_data in pairs(data) do
        if type(tag_data) == "number" then
            self.TAGTABLE[tag].num = tag_data
        elseif tag_data.num then
            self.TAGTABLE[tag].num = tag_data.num
            if tag_data.operation then         --若operation存在
                for opName, op_data in pairs(tag_data.operation) do
                    self.TAGTABLE[tag].operation[opName].startTime = op_data.startTime       --保存效果开始时间      
                end
            end
        else
            self.TAGTABLE[tag] = -1
        end
    end
    self:OnUpdate(false) 
end

function self:OnUpdate()
	for tag,tag_data in pairs(self.TAGTABLE) do
        if tag_data.operation then
            for opName, op_data in pairs(tag_data.operation) do
                if self.TAGTABLE[tag].num >= op_data.activeNum then         --若激活次数大于该操作所需激活次数
                    if op_data.startTime <= TheWorld.state.cycles and op_data.startTime + op_data.doration > TheWorld.state.cycles then
                        op_data.active = true
                        op_data.OnLoadfn(self.inst)
                    end
                end
                if op_data.active and op_data.startTime + op_data.doration <= TheWorld.state.cycles then
--                    print("Close "..opName)
                    op_data.OnRemovefn(self.inst,true)
                    op_data.active = false
                end 
            end
        end
	end
end

-- end of return

end)

return beantag
