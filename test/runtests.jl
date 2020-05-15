
using Test
using JSON
@time using HOI4Parser
using HOI4Parser: extract, SubUnit, Equipment, adapt, type_adapt, get_unit_equip, LandUnit, DivisionTemplate, Division

root_unit = "common/units"
root_equip = "common/units/equipment"

println(readdir("."))

function read_file_from_dir(root)
    rd = Dict{String, String}()
    for name in readdir(root)
        p = joinpath(root, name)
        if isfile(p) & endswith(p, ".txt")
            f = open(p, "r")
            s = read(f, String)
            close(f)
            rd[name] = s
        end
    end
    return rd
end

unit_f_dict = read_file_from_dir(root_unit)
equip_f_dict = read_file_from_dir(root_equip)

unit_ast_dict = Dict{String, Expr}()
equip_ast_dict = Dict{String, Expr}()

for (name, s) in unit_f_dict
    println(name)
    unit_ast_dict[name] = Meta.parse(s |> strip)
end

for (name, s) in equip_f_dict
    println(name)
    equip_ast_dict[name] = Meta.parse(s |> strip)
end 


unit_extracted_dict = Dict{String, Dict}()
equip_extracted_dict = Dict{String, Dict}()

for (name, ast) in unit_ast_dict
    # println(name)
    unit_extracted_dict[name] = extract(ast)[2]
end

for (name, ast) in equip_ast_dict
    # println(name)
    equip_extracted_dict[name] = extract(ast)[2]
end

unit_dict = Dict{Symbol, SubUnit}()

for (name, extracted) in unit_extracted_dict
    println(name)
    for (unit_name, ud) in extracted
        println(unit_name)
        #global ud2 = ud
        sub_unit = SubUnit(adapt(SubUnit, ud))
        unit_dict[unit_name] = sub_unit
    end
end

equip_dict = Dict{Symbol, Equipment}()
adapt_dict = Dict{Symbol, Dict}()

non_archetype_list = Symbol[]

for (name, extracted) in equip_extracted_dict
    println(name)
    for (equip_name, ud) in extracted
        println(equip_name)
        # equip = Equipment(ud)
        # equip_dict[equip_name] = equip
        ad = adapt(Equipment, ud)
        adapt_dict[equip_name] = ad
        if :archetype in keys(ad)
            push!(non_archetype_list, equip_name)
        else
            equip_dict[equip_name] = Equipment(ad)
        end
    end
end

for equip_name in non_archetype_list
    ad_child = adapt_dict[equip_name]
    ad_archetype = adapt_dict[Symbol(ad_child[:archetype])]
    equip_dict[equip_name] = Equipment(merge(ad_archetype, ad_child))
end

@testset "test infantry parsing" begin 
    @test equip_dict[:infantry_equipment_0].soft_attack == 3.0
    @test unit_dict[:infantry].max_organisation == 60.0
end

equip_dict[:infantry_equipment_0] |> dump
unit_dict[:infantry] |> dump

json(equip_dict[:infantry_equipment_0], 2) |> println
json(unit_dict[:infantry], 2) |> println

loaded = get_unit_equip(root_unit)

unit_dict = loaded.unit_dict
equip_dict = loaded.equip_dict

infantry = LandUnit(unit_dict[:infantry], equip_dict[:infantry_equipment_0])
artillery = LandUnit(unit_dict[:artillery], equip_dict[:artillery_equipment_1]) # support
artillery_brigade = LandUnit(unit_dict[:artillery_brigade], equip_dict[:artillery_equipment_1])

dump(infantry)
artillery |> dump
artillery_brigade |> dump

inf7art2 = DivisionTemplate((infantry, 7), (artillery_brigade, 2))
inf5sup_art1 = DivisionTemplate([infantry, infantry, infantry, infantry, infantry, artillery])

div1 = Division(inf5sup_art1)
div2 = Division(inf7art2)

println(div1)
println(div2)
