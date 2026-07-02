--- Deterministic, dependency-free pseudo-random generator for the DATA stage.
---
--- The data stage runs independently on every client, so anything that varies the generated
--- prototypes must be reproducible from shared inputs (mods + startup settings). `math.random`
--- is NOT seeded consistently across clients here, so we use an explicit Park-Miller (MINSTD)
--- LCG seeded by a startup setting. Pure arithmetic (no bit ops), and products stay well within
--- double precision, so results are identical on every machine.
local prng = {}

local MODULUS = 2147483647 -- 2^31 - 1

---@param seed integer
---@return { next: fun(): integer, float: fun(): number }
function prng.new(seed)
    local state = math.floor(seed or 0) % MODULUS
    if state <= 0 then
        state = state + (MODULUS - 1)
    end
    local self = {}
    function self.next()
        state = (state * 16807) % MODULUS
        return state
    end
    function self.float()
        return (self.next() - 1) / (MODULUS - 1)
    end
    return self
end

---Return a deterministic shuffle of `list` (Fisher-Yates), driven by `seed`. Does not mutate
---the input. Calling with the same list+seed always yields the same order, so taking the first
---N elements gives a stable, cumulative sample as N grows.
---@generic T
---@param list T[]
---@param seed integer
---@return T[]
function prng.shuffled(list, seed)
    local out = {}
    for i, v in ipairs(list) do
        out[i] = v
    end
    local gen = prng.new(seed)
    for i = #out, 2, -1 do
        local j = (gen.next() % i) + 1
        out[i], out[j] = out[j], out[i]
    end
    return out
end

return prng
