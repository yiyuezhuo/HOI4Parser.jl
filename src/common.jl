
@enum State init reading comment quoted

"""
Remove comment, split source to list of symbols.
"""
function split_word(s::String)
    state = init
    word_list = String[]
    char_list = Char[]
    for c in s
        if state == init
            if c == '#'
                state = comment
            elseif c in [' ', '\n', '\t', '\r']
            elseif c == '"'
                state = quoted
            else
                push!(char_list, c)
                state = reading
            end
        elseif state == reading
            if c == '#'
                push!(word_list, join(char_list))
                char_list = Char[]
                state = comment
            elseif c in [' ', '\n', '\t', '\r']
                push!(word_list, join(char_list))
                char_list = Char[]
                state = init
            elseif c == '}'
                push!(word_list, join(char_list))
                push!(word_list, "}")
                char_list = Char[]
                state = init
            else
                push!(char_list, c)
            end
        elseif state == comment
            if c == '\n'
                state = init
            end
        elseif state == quoted
            if c == '"'
                push!(word_list, join(char_list))
                char_list = Char[]
                state = init
            else
                push!(char_list, c)
            end
        end     
    end

    if state == reading
        push!(word_list, join(char_list))
    end
    return word_list
end

struct AssignExpr
    left_value::Any
    right_value::Any
end

struct Tree
    stack::Vector{Union{String, AssignExpr, Tree}}
end
Tree() = Tree(Union{String, AssignExpr, Tree}[])

# Base.pop!(tree::Tree) = pop!(tree.stack)
# Base.push!(tree::Tree, el::Union{String, AssignExpr}) = push!(tree.stack, el)
function add!(tree::Tree, el::Union{String, AssignExpr, Tree})
    if length(tree.stack) > 0 && tree.stack[end] == "="
        pop!(tree.stack) # remove "="
        left_value = pop!(tree.stack)
        push!(tree.stack, AssignExpr(left_value, el))
    else
        push!(tree.stack, el)
    end
end


"""
Rearrange word_list and return last accessed point 
"""
function build_tree(word_list::Vector{String}, idx::Int)
    tree = Tree()
    while idx <= length(word_list)
        word = word_list[idx]
        if word == "{"
            sub_tree, idx = build_tree(word_list, idx+1)
            add!(tree, sub_tree)
        elseif word == "}"
            return tree, idx
        else
            add!(tree, word)
        end
        idx += 1
    end
    return tree, idx
end

build_tree(word_list::Vector{String}) = build_tree(word_list, 1)[1]

function format(tree::Tree, space::Int)
    println("")
    for el in tree.stack
        print(" " ^ space)
        format(el, space+1)
        println("")
    end
end

format(s::String, space::Int) = print(s)

function format(ex::AssignExpr, space::Int)
    format(ex.left_value, space)
    print(" = ")
    format(ex.right_value, space)
end

format(el) = format(el, 0)

function extract(tree::Tree)
    is_dict = false
    el_list = Any[]
    for el in tree.stack
        if el isa AssignExpr
            is_dict = true
        end
        push!(el_list, extract(el))
    end
    if is_dict
        res = Dict{Symbol, Any}()
        for (key, value) in el_list
            res[Symbol(key)] = value
        end
        return res
    end
    return el_list
end

function extract(s::String)
    if s == "yes"
        return true
    elseif s == "no"
        return false
    elseif tryparse(Float64, s) !== nothing
        return parse(Float64, s)
    end
    return s
end

extract(s::AssignExpr) = (extract(s.left_value), extract(s.right_value))
