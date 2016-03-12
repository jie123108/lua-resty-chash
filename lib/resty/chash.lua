--[[
author: jie123108@163.com
date: 20151114
]]
local _M = {}


local crc32 = ngx.crc32_short
local hash_fn = function(key)
    local md5 = ngx.md5_bin(key) --nginx only
    return crc32(md5) --nginx only
end


--in-place quicksort
local function quicksort(t, start, endi)
    start, endi = start or 1, endi or #t
    --partition w.r.t. first element
    if(endi - start < 2) then return t end
    local pivot = start
    for i = start + 1, endi do
        if t[i][2] < t[pivot][2] then
            local temp = t[pivot + 1]
            t[pivot + 1] = t[pivot]
            if(i == pivot + 1) then
                t[pivot] = temp
            else
                t[pivot] = t[i]
                t[i] = temp
            end
            pivot = pivot + 1
        end
    end
    t = quicksort(t, start, pivot - 1)
    return quicksort(t, pivot + 1, endi)
end

local function chash_find(CONTINUUM, point)
    local mid, lo, hi = 1, 1, #CONTINUUM
    while 1 do
        if point <= CONTINUUM[lo][2] or point > CONTINUUM[hi][2] then
            return CONTINUUM[lo]
        end

        mid = math.floor(lo + (hi-lo)/2)
        if point <= CONTINUUM[mid][2] and point > (mid and CONTINUUM[mid-1][2] or 0) then
            return CONTINUUM[mid]
        end

        if CONTINUUM[mid][2] < point then
            lo = mid + 1
        else
            hi = mid - 1
        end
    end
end

local mt = { __index = _M }

function _M:new(consistent_buckets)
    if consistent_buckets == nil then
        consistent_buckets = 256
    end

    return setmetatable({ HASH_PEERS = {}, CONTINUUM = {}, BUCKETS = {}, 
            CONSISTENT_BUCKETS=consistent_buckets, initialized=false}, mt)
end

function _M:count()
    return #self.HASH_PEERS
end

function _M:add(item, weight)
    self.initialized = false
    weight = weight or 1
    table.insert(self.HASH_PEERS, {weight, item})
end

function _M:delete(item)
    self.initialized = false
    local dels = {}
    for i, x in ipairs(self.HASH_PEERS) do 
        if x[2] == item then
            table.insert(dels, i)
        end
    end
    for i, idx in ipairs(dels) do 
        table.remove(self.HASH_PEERS, idx)
    end    
end

function _M:items()
    local items = {}
    for i, x in ipairs(self.HASH_PEERS) do 
        table.insert(items, x[2])
    end
    return items
end

function _M:get(key)
    if not self.initialized then
        _M.init(self)
    end
    local point = math.floor(crc32(key)) 
    local tries = #self.HASH_PEERS
    point = point + (89 * tries)
    local bucket_idx = point % self.CONSISTENT_BUCKETS
    if bucket_idx == 0 then
        bucket_idx = 1
    end
    return self.BUCKETS[bucket_idx][1]
end

function _M:init()
    local n = #self.HASH_PEERS

    local ppn = math.floor(self.CONSISTENT_BUCKETS / n)
    if ppn == 0 then
        ppn = 1
    end

    local C = {}
    for i,peer in ipairs(self.HASH_PEERS) do
        for k=1, math.floor(ppn * peer[1]) do
            local hash_data = peer[2] .. "-"..tostring(math.floor(k - 1))
            table.insert(C, {peer[2], hash_fn(hash_data)})
        end
    end

    self.CONTINUUM = quicksort(C, 1, #C)

    local step = math.floor(0xFFFFFFFF / self.CONSISTENT_BUCKETS)

    self.BUCKETS = {}
    for i=1, self.CONSISTENT_BUCKETS do
        table.insert(self.BUCKETS, i, chash_find(self.CONTINUUM, math.floor(step * (i - 1))))
    end

    self.initialized = true
end

return _M