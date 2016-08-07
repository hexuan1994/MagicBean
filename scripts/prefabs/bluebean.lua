--local bean = require("prefabs/bean")

local assets = {
    Asset("ANIM", "anim/bean.zip"),

    Asset("ATLAS", "images/inventoryimages/bluebean.xml"),
    Asset("IMAGE", "images/inventoryimages/bluebean.tex"),
}

local function blueoneatfn(inst, eater)
    if eater:HasTag("player") then
        if eater.components and
            eater.components.beantag then
                eater.components.beantag:ActiveOneTime("bluebean")
        end
    end
end

local function blue()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("bean")
    inst.AnimState:SetBuild("bean")
    inst.AnimState:PlayAnimation("bluebean")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "bluebean"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/bluebean.xml"

    inst:AddComponent("edible")
    inst.components.edible.foodtype = "MEAT"
    inst.components.edible:SetOnEatenFn(blueoneatfn)
  
    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("common/inventory/bluebean", blue, assets, prefabs)
