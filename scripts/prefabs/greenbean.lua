--local bean = require("prefabs/bean")

local assets = {
    Asset("ANIM", "anim/bean.zip"),

    Asset("ATLAS", "images/inventoryimages/greenbean.xml"),
    Asset("IMAGE", "images/inventoryimages/greenbean.tex"),
}

local function greenoneatfn(inst, eater)
    if eater:HasTag("player") then
        if eater.components and
            eater.components.beantag then
                eater.components.beantag:ActiveOneTime("greenbean")
        end
    end
end

local function green()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("bean")
    inst.AnimState:SetBuild("bean")
    inst.AnimState:PlayAnimation("greenbean")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "greenbean"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/greenbean.xml"

    inst:AddComponent("edible")
    inst.components.edible.foodtype = "MEAT"
    inst.components.edible:SetOnEatenFn(greenoneatfn)
  
    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("common/inventory/greenbean", green, assets, prefabs)
