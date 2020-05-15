"""
Here we will focus on interested properties only.
"""

@kwdef struct LandUnit
    HP::Float64
    Org::Float64
    Recov::Float64
    Suppr::Float64
    Weight::Float64
    Supply::Float64
    Width::Float64
    Manpower::Int64
    MapIconCategory::String
    Categories::Vector{String}
    Speed::Float64 # 8.0/10.0/12.0 -> 8.0
    SoftAtk::Float64
    HardAtk::Float64
    AirAtk::Float64
    Defense::Float64
    Breakthr::Float64
    Armor::Float64 # 10/15/20 -> 10
    Pierce::Float64
    Hardness::Float64 # 64% -> 0.64
    FuelUsage::Float64
    ProdCost::Float64
end

function LandUnit(sub_unit::SubUnit, equip::Equipment)
    @assert Symbol(equip.archetype) in keys(sub_unit.need)

    LandUnit(
        HP = sub_unit.max_strength,
        Org = sub_unit.max_organisation,
        Recov = sub_unit.default_morale,
        Suppr = sub_unit.suppression,
        Weight = sub_unit.weight,
        Supply = sub_unit.supply_consumption,
        Width = sub_unit.combat_width,
        Manpower = sub_unit.manpower,
        MapIconCategory = sub_unit.map_icon_category,
        Categories = sub_unit.categories,
        Speed = sub_unit.maximum_speed,
        SoftAtk = (1. + sub_unit.soft_attack) * equip.soft_attack,
        HardAtk = (1. + sub_unit.hard_attack) * equip.hard_attack,
        AirAtk = (1. + sub_unit.air_attack) * equip.air_attack,
        Defense = (1. + sub_unit.defense) * equip.defense,
        Breakthr = (1. + sub_unit.breakthrough) * equip.breakthrough,
        Armor = equip.armor_value,
        Pierce = (1. + sub_unit.ap_attack) * equip.ap_attack,
        Hardness = equip.hardness,
        FuelUsage = equip.fuel_consumption,
        ProdCost = equip.build_cost_ic
    )
end


