--local bean = require("prefabs/bean")

local assets = {
    Asset("ANIM", "anim/bean.zip"),

    Asset("ATLAS", "images/inventoryimages/redbean.xml"),
    Asset("IMAGE", "images/inventoryimages/redbean.tex"),
}

local function redoneatfn(inst, eater)
    if eater:HasTag("player") then
        if eater.components and
            eater.components.beantag then
                eater.components.beantag:ActiveOneTime("redbean")
        end
    end
end

local function red()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("bean")
    inst.AnimState:SetBuild("bean")
    inst.AnimState:PlayAnimation("redbean")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "redbean"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/redbean.xml"

    inst:AddComponent("edible")
    inst.components.edible.foodtype = "MEAT"
    inst.components.edible:SetOnEatenFn(redoneatfn)
  
    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("common/inventory/redbean", red, assets, prefabs)
