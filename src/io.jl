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

function get_unit_equip(root_unit::String, root_equip::String)

    unit_f_dict = read_file_from_dir(root_unit)
    equip_f_dict = read_file_from_dir(root_equip)

    unit_ast_dict = Dict{String, Expr}()
    equip_ast_dict = Dict{String, Expr}()

    for (name, s) in unit_f_dict
        #println(name)
        unit_ast_dict[name] = Meta.parse(s |> strip)
    end

    for (name, s) in equip_f_dict
        #println(name)
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
        #println(name)
        for (unit_name, ud) in extracted
            #println(unit_name)
            #global ud2 = ud
            sub_unit = SubUnit(adapt(SubUnit, ud))
            unit_dict[unit_name] = sub_unit
        end
    end

    equip_dict = Dict{Symbol, Equipment}()
    adapt_dict = Dict{Symbol, Dict}()

    non_archetype_list = Symbol[]

    for (name, extracted) in equip_extracted_dict
        #println(name)
        for (equip_name, ud) in extracted
            #println(equip_name)
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

    return (unit_dict=unit_dict, equip_dict=equip_dict, 
            unit_f_dict=unit_f_dict, equip_f_dict=equip_f_dict,
            unit_ast_dict=unit_ast_dict, equip_ast_dict=equip_ast_dict,
            unit_extracted_dict=unit_extracted_dict, equip_extracted_dict=equip_extracted_dict)
end

get_unit_equip(root_unit::String) = get_unit_equip(root_unit, joinpath(root_unit, "equipment"))
