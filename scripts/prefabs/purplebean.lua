--local bean = require("prefabs/bean")

local assets = {
    Asset("ANIM", "anim/bean.zip"),

    Asset("ATLAS", "images/inventoryimages/purplebean.xml"),
    Asset("IMAGE", "images/inventoryimages/purplebean.tex"),
}

local function purpleoneatfn(inst, eater)
    if eater:HasTag("player") then
        if eater.components and
            eater.components.beantag then
                eater.components.beantag:ActiveOneTime("purplebean")
        end
    end
end

local function purple()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("bean")
    inst.AnimState:SetBuild("bean")
    inst.AnimState:PlayAnimation("purplebean")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "purplebean"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/purplebean.xml"

    inst:AddComponent("edible")
    inst.components.edible.hungervalue = 500
    inst.components.edible.healthvalue = 500
    inst.components.edible.sanityvalue = 500
    inst.components.edible.foodtype = "MEAT"
    inst.components.edible:SetOnEatenFn(purpleoneatfn)
  
    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("common/inventory/purplebean", purple, assets, prefabs)
