--local bean = require("prefabs/bean")

local assets = {
    Asset("ANIM", "anim/bean.zip"),

    Asset("ATLAS", "images/inventoryimages/orangebean.xml"),
    Asset("IMAGE", "images/inventoryimages/orangebean.tex"),
}

local function orangeoneatfn(inst, eater)
    if eater:HasTag("player") then
        if eater.components and
            eater.components.beantag then
                eater.components.beantag:ActiveOneTime("orangebean")
        end
    end
end

local function orange()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("bean")
    inst.AnimState:SetBuild("bean")
    inst.AnimState:PlayAnimation("orangebean")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "orangebean"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/orangebean.xml"

    inst:AddComponent("edible")
    inst.components.edible.foodtype = "MEAT"
    inst.components.edible:SetOnEatenFn(orangeoneatfn)
  
    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("common/inventory/orangebean", orange, assets, prefabs)
