
@kwdef struct Equipment{T}
    year::Int = 0
    visual_level::Int = 0
    visual_tech_level_addition::Int = 0

    archetype::String = ""
    parent::String = ""
    priority::T = 0.
    model::String = ""

    is_archetype::Bool = false
    is_convertable::Bool = false
    picture::String = ""
    is_buildable::Bool = true
    family::String = ""
    can_convert_from::Vector{String} = String[]
    type::Union{String, Vector{String}} = ""
    group_by::String = ""

    sprite::String = "" # common missing
    air_map_icon_frame::Int = 0

    interface_category::String = ""
    alias::String = ""

    # Tactical bomber
    interface_overview_category_index::Int = 0

    upgrades::Vector{String} = String[]

    # Misc Abilities
    maximum_speed::T = 0.
    air_superiority::T = 0.
    reliability::T = 0.
    recon::T = 0.

    # Defensive Abilities
    defense::T = 0.
    breakthrough::T = 0.
    hardness::T = 0.
    armor_value::T = 0.

    # Offensive Abilities
    soft_attack::T = 0.
    hard_attack::T = 0.
    ap_attack::T = 0.
    air_attack::T = 0.

    # Air specific property
    air_range::T = 0.
    air_agility::T = 0.
    air_defence::T = 0.
    air_bombing::T = 0.
    air_ground_attack::T = 0.

    naval_strike_attack::T = 0.
    naval_strike_targetting::T = 0.

    # space taken in convoy
    lend_lease_cost::T = 0.

    build_cost_ic::T = 0.
    #resources::NamedTuple = NamedTuple()
    resources::Dict = Dict()

    manpower::T = 0. # common missing
    fuel_consumption::T = 0.

    # for ships
    active::Bool = false

    surface_detection::T = 0.
    sub_detection::T = 0.

    lg_armor_piercing::T = 0.
    surface_visibility::T = 0.
    torpedo_attack::T = 0.
    lg_attack::T = 0.
    naval_speed::T = 0.
    max_strength::T = 0.
    max_organisation::T = 0.
    anti_air_attack::T = 0.

    offensive_weapons::Bool = true

    module_slots::Union{Dict, String} = Dict()
    default_modules::Dict = Dict()

    carrier_size::T = 0.
    naval_range::T = 0.

    hg_armor_piercing::T = 0.
    hg_attack::T = 0.
    module_count_limit::Dict = Dict()
    sub_attack::T = 0.

    sub_visibility::T = 0.

    carrier_capable::Bool = false
    default_carrier_composition_weight::T = 0.
    can_license::Bool = true

    # for missiles
    one_use_only::Bool = false

end

function Equipment(type::Type, dict::Dict)
    dict_adapted = adapt(Equipment, dict)
    Equipment{type}(;dict_adapted...)
end

Equipment(dict::Dict) = Equipment(Float64, dict)