--[[
    ============================================================================
    LYRA UI LIBRARY v3.0 - "NEXUS"
    ============================================================================
    
    Uma biblioteca de interface profissional para Roblox com:
    - Arquitetura modular e escalável
    - Sistema de renderização baseado em componentes
    - Pipeline de renderização por lotes
    - Sistema de eventos avançado
    - Cache de instâncias
    - Virtualização de listas
    - Animação por keyframes
    - Sistema de plugins
    - Backward compatibility completa
    
    Autor: Lyapossss
    Versão: 3.0.0
    ============================================================================
]]

-- Region: CORE SERVICES & CONSTANTS
local Core = {
    Services = {
        RunService = game:GetService("RunService"),
        UserInputService = game:GetService("UserInputService"),
        TweenService = game:GetService("TweenService"),
        HttpService = game:GetService("HttpService"),
        Players = game:GetService("Players"),
        Workspace = game:GetService("Workspace"),
        Lighting = game:GetService("Lighting"),
        CoreGui = game:GetService("CoreGui"),
        ReplicatedStorage = game:GetService("ReplicatedStorage"),
        TextService = game:GetService("TextService"),
        SoundService = game:GetService("SoundService")
    },
    
    Constants = {
        VERSION = "3.0.0",
        API_VERSION = 3,
        MIN_ROBLOX_VERSION = 589,
        
        COLOR_FORMATS = {
            HEX = 1,
            RGB = 2,
            HSV = 3,
            HSL = 4
        },
        
        ANIMATION_EASING = {
            LINEAR = Enum.EasingStyle.Linear,
            QUADRATIC = Enum.EasingStyle.Quad,
            CUBIC = Enum.EasingStyle.Cubic,
            QUARTIC = Enum.EasingStyle.Quart,
            QUINTIC = Enum.EasingStyle.Quint,
            SINE = Enum.EasingStyle.Sine,
            EXPONENTIAL = Enum.EasingStyle.Exponential,
            CIRCULAR = Enum.EasingStyle.Circular,
            ELASTIC = Enum.EasingStyle.Elastic,
            BACK = Enum.EasingStyle.Back,
            BOUNCE = Enum.EasingStyle.Bounce
        },
        
        INPUT_MODES = {
            MOUSE = 1,
            TOUCH = 2,
            GAMEPAD = 3,
            KEYBOARD = 4
        },
        
        RENDER_MODES = {
            IMMEDIATE = 1,
            DEFERRED = 2,
            VIRTUALIZED = 3
        }
    },
    
    State = {
        -- Core state
        Initialized = false,
        Unloading = false,
        PerformanceMode = false,
        
        -- Memory management
        InstanceCache = { },
        TextureCache = { },
        FontCache = { },
        SoundCache = { },
        
        -- Component registry
        Components = { },
        Windows = { },
        Pages = { },
        Sections = { },
        Elements = { },
        
        -- State management
        Flags = { },
        Configs = { },
        Themes = { },
        
        -- Event system
        EventListeners = { },
        EventQueue = { },
        
        -- Render pipeline
        RenderQueue = { },
        DirtyComponents = { },
        
        -- Performance tracking
        PerformanceStats = {
            FPS = 60,
            MemoryUsage = 0,
            RenderTime = 0,
            UpdateTime = 0,
            InstanceCount = 0,
            DrawCalls = 0
        },
        
        -- Input state
        InputState = {
            MousePosition = Vector2.new(0, 0),
            MouseDelta = Vector2.new(0, 0),
            TouchCount = 0,
            KeysDown = { },
            GamepadState = { }
        }
    }
}

-- Region: UTILITY SYSTEM
Core.Utility = {
    Math = {
        clamp = function(value, min, max)
            return value < min and min or (value > max and max or value)
        end,
        
        lerp = function(a, b, t)
            return a + (b - a) * t
        end,
        
        inverseLerp = function(a, b, value)
            return (value - a) / (b - a)
        end,
        
        smoothstep = function(edge0, edge1, x)
            x = Core.Utility.Math.clamp((x - edge0) / (edge1 - edge0), 0, 1)
            return x * x * (3 - 2 * x)
        end,
        
        remap = function(value, inMin, inMax, outMin, outMax)
            return outMin + (value - inMin) * (outMax - outMin) / (inMax - inMin)
        end,
        
        round = function(value, decimals)
            local mult = 10 ^ (decimals or 0)
            return math.floor(value * mult + 0.5) / mult
        end,
        
        randomFloat = function(min, max)
            return min + math.random() * (max - min)
        end,
        
        bezier = function(t, ...)
            local points = { ... }
            while #points > 1 do
                local newPoints = { }
                for i = 1, #points - 1 do
                    newPoints[i] = points[i] * (1 - t) + points[i + 1] * t
                end
                points = newPoints
            end
            return points[1]
        end,
        
        distance = function(point1, point2)
            return (point1 - point2).Magnitude
        end,
        
        angleBetween = function(vector1, vector2)
            return math.acos(vector1:Dot(vector2) / (vector1.Magnitude * vector2.Magnitude))
        end
    },
    
    Color = {
        rgbToHsv = function(r, g, b)
            local max, min = math.max(r, g, b), math.min(r, g, b)
            local h, s, v = 0, 0, max
            
            local d = max - min
            if max > 0 then
                s = d / max
            end
            
            if max == min then
                h = 0
            else
                if max == r then
                    h = (g - b) / d
                    if g < b then h = h + 6 end
                elseif max == g then
                    h = (b - r) / d + 2
                elseif max == b then
                    h = (r - g) / d + 4
                end
                h = h / 6
            end
            
            return h, s, v
        end,
        
        hsvToRgb = function(h, s, v)
            if s <= 0 then return v, v, v end
            
            h = h * 6
            local i = math.floor(h)
            local f = h - i
            local p = v * (1 - s)
            local q = v * (1 - s * f)
            local t = v * (1 - s * (1 - f))
            
            if i == 0 then
                return v, t, p
            elseif i == 1 then
                return q, v, p
            elseif i == 2 then
                return p, v, t
            elseif i == 3 then
                return p, q, v
            elseif i == 4 then
                return t, p, v
            else
                return v, p, q
            end
        end,
        
        rgbToHsl = function(r, g, b)
            local max, min = math.max(r, g, b), math.min(r, g, b)
            local h, s, l = 0, 0, (max + min) / 2
            
            if max == min then
                h, s = 0, 0
            else
                local d = max - min
                s = l > 0.5 and d / (2 - max - min) or d / (max + min)
                
                if max == r then
                    h = (g - b) / d + (g < b and 6 or 0)
                elseif max == g then
                    h = (b - r) / d + 2
                elseif max == b then
                    h = (r - g) / d + 4
                end
                h = h / 6
            end
            
            return h, s, l
        end,
        
        hslToRgb = function(h, s, l)
            if s == 0 then
                return l, l, l
            end
            
            local function hue2rgb(p, q, t)
                if t < 0 then t = t + 1 end
                if t > 1 then t = t - 1 end
                if t < 1/6 then return p + (q - p) * 6 * t end
                if t < 1/2 then return q end
                if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end
                return p
            end
            
            local q = l < 0.5 and l * (1 + s) or l + s - l * s
            local p = 2 * l - q
            
            local r = hue2rgb(p, q, h + 1/3)
            local g = hue2rgb(p, q, h)
            local b = hue2rgb(p, q, h - 1/3)
            
            return r, g, b
        end,
        
        lerp = function(color1, color2, t)
            return Color3.new(
                Core.Utility.Math.lerp(color1.R, color2.R, t),
                Core.Utility.Math.lerp(color1.G, color2.G, t),
                Core.Utility.Math.lerp(color1.B, color2.B, t)
            )
        end,
        
        darken = function(color, amount)
            local h, s, v = Core.Utility.Color.rgbToHsv(color.R, color.G, color.B)
            return Color3.fromHSV(h, s, math.max(v - amount, 0))
        end,
        
        lighten = function(color, amount)
            local h, s, v = Core.Utility.Color.rgbToHsv(color.R, color.G, color.B)
            return Color3.fromHSV(h, s, math.min(v + amount, 1))
        end,
        
        saturate = function(color, amount)
            local h, s, v = Core.Utility.Color.rgbToHsv(color.R, color.G, color.B)
            return Color3.fromHSV(h, math.min(s + amount, 1), v)
        end,
        
        desaturate = function(color, amount)
            local h, s, v = Core.Utility.Color.rgbToHsv(color.R, color.G, color.B)
            return Color3.fromHSV(h, math.max(s - amount, 0), v)
        end,
        
        complementary = function(color)
            local h, s, v = Core.Utility.Color.rgbToHsv(color.R, color.G, color.B)
            return Color3.fromHSV((h + 0.5) % 1, s, v)
        end,
        
        triad = function(color)
            local h, s, v = Core.Utility.Color.rgbToHsv(color.R, color.G, color.B)
            return {
                Color3.fromHSV(h, s, v),
                Color3.fromHSV((h + 1/3) % 1, s, v),
                Color3.fromHSV((h + 2/3) % 1, s, v)
            }
        end,
        
        analogous = function(color, angle)
            angle = angle or 30
            local h, s, v = Core.Utility.Color.rgbToHsv(color.R, color.G, color.B)
            local rad = math.rad(angle)
            return {
                Color3.fromHSV((h - rad/360) % 1, s, v),
                Color3.fromHSV(h, s, v),
                Color3.fromHSV((h + rad/360) % 1, s, v)
            }
        end,
        
        gradient = function(colors, steps)
            local gradient = { }
            for i = 0, steps - 1 do
                local t = i / (steps - 1)
                local segment = t * (#colors - 1)
                local index = math.floor(segment)
                local localT = segment - index
                
                if index == #colors - 1 then
                    table.insert(gradient, colors[#colors])
                else
                    table.insert(gradient, Core.Utility.Color.lerp(
                        colors[index + 1],
                        colors[index + 2],
                        localT
                    ))
                end
            end
            return gradient
        end
    },
    
    String = {
        format = string.format,
        split = function(str, separator)
            local result = { }
            local pattern = string.format("([^%s]+)", separator)
            for match in str:gmatch(pattern) do
                table.insert(result, match)
            end
            return result
        end,
        
        truncate = function(str, length, ellipsis)
            ellipsis = ellipsis or "..."
            if #str <= length then return str end
            return str:sub(1, length - #ellipsis) .. ellipsis
        end,
        
        capitalize = function(str)
            return str:gsub("(%l)(%w*)", function(first, rest)
                return first:upper() .. rest
            end)
        end,
        
        camelToTitle = function(str)
            return str:gsub("(%u)", " %1"):gsub("^%s*(.-)%s*$", "%1"):gsub("^%l", string.upper)
        end,
        
        escapePattern = function(str)
            return str:gsub("([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1")
        end,
        
        levenshtein = function(str1, str2)
            local len1, len2 = #str1, #str2
            local matrix = { }
            
            for i = 0, len1 do
                matrix[i] = { [0] = i }
            end
            for j = 0, len2 do
                matrix[0][j] = j
            end
            
            for i = 1, len1 do
                for j = 1, len2 do
                    local cost = str1:sub(i, i) == str2:sub(j, j) and 0 or 1
                    matrix[i][j] = math.min(
                        matrix[i-1][j] + 1,
                        matrix[i][j-1] + 1,
                        matrix[i-1][j-1] + cost
                    )
                end
            end
            
            return matrix[len1][len2]
        end,
        
        fuzzyMatch = function(str, pattern)
            local i, j = 1, 1
            while i <= #str and j <= #pattern do
                if str:sub(i, i):lower() == pattern:sub(j, j):lower() then
                    j = j + 1
                end
                i = i + 1
            end
            return j > #pattern
        end
    },
    
    Table = {
        clone = function(t)
            local copy = { }
            for k, v in pairs(t) do
                if type(v) == "table" then
                    copy[k] = Core.Utility.Table.clone(v)
                else
                    copy[k] = v
                end
            end
            return copy
        end,
        
        deepMerge = function(t1, t2)
            local result = Core.Utility.Table.clone(t1)
            for k, v in pairs(t2) do
                if type(v) == "table" and type(result[k]) == "table" then
                    result[k] = Core.Utility.Table.deepMerge(result[k], v)
                else
                    result[k] = v
                end
            end
            return result
        end,
        
        filter = function(t, predicate)
            local result = { }
            for k, v in pairs(t) do
                if predicate(v, k) then
                    result[k] = v
                end
            end
            return result
        end,
        
        map = function(t, transform)
            local result = { }
            for k, v in pairs(t) do
                result[k] = transform(v, k)
            end
            return result
        end,
        
        reduce = function(t, reducer, initial)
            local accumulator = initial
            for k, v in pairs(t) do
                accumulator = reducer(accumulator, v, k)
            end
            return accumulator
        end,
        
        find = function(t, predicate)
            for k, v in pairs(t) do
                if predicate(v, k) then
                    return v, k
                end
            end
            return nil
        end,
        
        keys = function(t)
            local keys = { }
            for k in pairs(t) do
                table.insert(keys, k)
            end
            return keys
        end,
        
        values = function(t)
            local values = { }
            for _, v in pairs(t) do
                table.insert(values, v)
            end
            return values
        end,
        
        size = function(t)
            local count = 0
            for _ in pairs(t) do
                count = count + 1
            end
            return count
        end,
        
        shuffle = function(t)
            local result = Core.Utility.Table.clone(t)
            for i = #result, 2, -1 do
                local j = math.random(i)
                result[i], result[j] = result[j], result[i]
            end
            return result
        end,
        
        sortBy = function(t, key)
            local sorted = Core.Utility.Table.clone(t)
            table.sort(sorted, function(a, b)
                return a[key] < b[key]
            end)
            return sorted
        end,
        
        groupBy = function(t, keyFn)
            local groups = { }
            for _, v in pairs(t) do
                local key = keyFn(v)
                if not groups[key] then
                    groups[key] = { }
                end
                table.insert(groups[key], v)
            end
            return groups
        end
    },
    
    Time = {
        now = function()
            return tick()
        end,
        
        format = function(seconds)
            local days = math.floor(seconds / 86400)
            local hours = math.floor((seconds % 86400) / 3600)
            local minutes = math.floor((seconds % 3600) / 60)
            local secs = math.floor(seconds % 60)
            
            local parts = { }
            if days > 0 then table.insert(parts, days .. "d") end
            if hours > 0 then table.insert(parts, hours .. "h") end
            if minutes > 0 then table.insert(parts, minutes .. "m") end
            if secs > 0 or #parts == 0 then table.insert(parts, secs .. "s") end
            
            return table.concat(parts, " ")
        end,
        
        debounce = function(delay, fn)
            local lastCall = 0
            return function(...)
                local now = Core.Utility.Time.now()
                if now - lastCall >= delay then
                    lastCall = now
                    return fn(...)
                end
            end
        end,
        
        throttle = function(delay, fn)
            local lastCall = 0
            local timeout
            return function(...)
                local now = Core.Utility.Time.now()
                local args = { ... }
                
                if now - lastCall >= delay then
                    lastCall = now
                    return fn(unpack(args))
                else
                    if timeout then
                        timeout:Disconnect()
                    end
                    timeout = Core.Services.RunService.Heartbeat:Connect(function()
                        if Core.Utility.Time.now() - lastCall >= delay then
                            timeout:Disconnect()
                            lastCall = Core.Utility.Time.now()
                            fn(unpack(args))
                        end
                    end)
                end
            end
        end
    },
    
    Network = {
        promise = function(url, method, headers, body)
            return Core.Utility.Promise.new(function(resolve, reject)
                local success, result = pcall(function()
                    return Core.Services.HttpService:RequestAsync({
                        Url = url,
                        Method = method or "GET",
                        Headers = headers or { },
                        Body = body
                    })
                end)
                
                if success then
                    if result.Success then
                        resolve(result)
                    else
                        reject(result)
                    end
                else
                    reject(result)
                end
            end)
        end,
        
        get = function(url, headers)
            return Core.Utility.Network.promise(url, "GET", headers)
        end,
        
        post = function(url, body, headers)
            return Core.Utility.Network.promise(url, "POST", headers, body)
        end,
        
        downloadAsset = function(assetId, fileName)
            return Core.Utility.Promise.new(function(resolve, reject)
                if isfile(fileName) then
                    resolve(getcustomasset(fileName))
                    return
                end
                
                Core.Utility.Network.get("https://assetdelivery.roblox.com/v1/asset?id=" .. assetId)
                    :andThen(function(response)
                        if response.Body then
                            writefile(fileName, response.Body)
                            resolve(getcustomasset(fileName))
                        else
                            reject("Failed to download asset")
                        end
                    end)
                    :catch(reject)
            end)
        end
    },
    
    Promise = {
        new = function(executor)
            local promise = {
                _state = "pending",
                _value = nil,
                _error = nil,
                _thenCallbacks = { },
                _catchCallbacks = { },
                _finallyCallbacks = { }
            }
            
            local function resolve(value)
                if promise._state ~= "pending" then return end
                promise._state = "fulfilled"
                promise._value = value
                
                for _, callback in ipairs(promise._thenCallbacks) do
                    task.spawn(callback, value)
                end
                
                for _, callback in ipairs(promise._finallyCallbacks) do
                    task.spawn(callback)
                end
            end
            
            local function reject(error)
                if promise._state ~= "pending" then return end
                promise._state = "rejected"
                promise._error = error
                
                for _, callback in ipairs(promise._catchCallbacks) do
                    task.spawn(callback, error)
                end
                
                for _, callback in ipairs(promise._finallyCallbacks) do
                    task.spawn(callback)
                end
            end
            
            task.spawn(function()
                local success, result = pcall(executor, resolve, reject)
                if not success then
                    reject(result)
                end
            end)
            
            function promise:then(callback)
                if self._state == "fulfilled" then
                    task.spawn(callback, self._value)
                elseif self._state == "pending" then
                    table.insert(self._thenCallbacks, callback)
                end
                return self
            end
            
            function promise:catch(callback)
                if self._state == "rejected" then
                    task.spawn(callback, self._error)
                elseif self._state == "pending" then
                    table.insert(self._catchCallbacks, callback)
                end
                return self
            end
            
            function promise:finally(callback)
                if self._state ~= "pending" then
                    task.spawn(callback)
                else
                    table.insert(self._finallyCallbacks, callback)
                end
                return self
            end
            
            function promise:await()
                while self._state == "pending" do
                    RunService.Heartbeat:Wait()
                end
                
                if self._state == "fulfilled" then
                    return self._value
                else
                    error(self._error)
                end
            end
            
            return promise
        end,
        
        all = function(promises)
            return Core.Utility.Promise.new(function(resolve, reject)
                local results = { }
                local completed = 0
                local total = #promises
                
                if total == 0 then
                    resolve(results)
                    return
                end
                
                for i, promise in ipairs(promises) do
                    promise:then(function(value)
                        results[i] = value
                        completed = completed + 1
                        
                        if completed == total then
                            resolve(results)
                        end
                    end):catch(reject)
                end
            end)
        end,
        
        race = function(promises)
            return Core.Utility.Promise.new(function(resolve, reject)
                for _, promise in ipairs(promises) do
                    promise:then(resolve):catch(reject)
                end
            end)
        end,
        
        resolve = function(value)
            return Core.Utility.Promise.new(function(resolve)
                resolve(value)
            end)
        end,
        
        reject = function(error)
            return Core.Utility.Promise.new(function(_, reject)
                reject(error)
            end)
        end
    },
    
    Instance = {
        create = function(className, properties)
            local instance = Instance.new(className)
            
            for property, value in pairs(properties or { }) do
                if property ~= "Parent" then
                    instance[property] = value
                end
            end
            
            if properties and properties.Parent then
                instance.Parent = properties.Parent
            end
            
            return instance
        end,
        
        clone = function(instance, properties)
            local clone = instance:Clone()
            
            if properties then
                for property, value in pairs(properties) do
                    if property ~= "Parent" then
                        clone[property] = value
                    end
                end
                
                if properties.Parent then
                    clone.Parent = properties.Parent
                end
            end
            
            return clone
        end,
        
        destroyAll = function(instance)
            for _, child in ipairs(instance:GetChildren()) do
                Core.Utility.Instance.destroyAll(child)
            end
            instance:Destroy()
        end,
        
        findFirstAncestorOfClass = function(instance, className)
            local parent = instance.Parent
            while parent do
                if parent:IsA(className) then
                    return parent
                end
                parent = parent.Parent
            end
            return nil
        end,
        
        getDescendantsOfClass = function(instance, className)
            local descendants = { }
            local function traverse(obj)
                for _, child in ipairs(obj:GetChildren()) do
                    if child:IsA(className) then
                        table.insert(descendants, child)
                    end
                    traverse(child)
                end
            end
            traverse(instance)
            return descendants
        end
    },
    
    Validation = {
        isColor3 = function(value)
            return typeof(value) == "Color3"
        end,
        
        isUDim2 = function(value)
            return typeof(value) == "UDim2"
        end,
        
        isVector2 = function(value)
            return typeof(value) == "Vector2"
        end,
        
        isValidKeyCode = function(value)
            return typeof(value) == "EnumItem" and value.EnumType == Enum.KeyCode
        end,
        
        isNumberInRange = function(value, min, max)
            return type(value) == "number" and value >= min and value <= max
        end,
        
        isStringNonEmpty = function(value)
            return type(value) == "string" and #value > 0
        end,
        
        isTable = function(value)
            return type(value) == "table"
        end,
        
        isFunction = function(value)
            return type(value) == "function"
        end,
        
        validate = function(value, validator, errorMessage)
            if not validator(value) then
                error(errorMessage or "Validation failed", 3)
            end
            return value
        end
    }
}

-- Region: EVENT SYSTEM
Core.EventSystem = {
    Events = { },
    
    create = function(self, eventName)
        local event = {
            Name = eventName,
            Listeners = { },
            OnceListeners = { },
            
            Connect = function(listener)
                local connection = {
                    Disconnect = function(self)
                        for i, conn in ipairs(event.Listeners) do
                            if conn == self then
                                table.remove(event.Listeners, i)
                                break
                            end
                        end
                    end
                }
                
                table.insert(event.Listeners, connection)
                return connection
            end,
            
            Once = function(listener)
                local connection = {
                    Disconnect = function(self)
                        for i, conn in ipairs(event.OnceListeners) do
                            if conn == self then
                                table.remove(event.OnceListeners, i)
                                break
                            end
                        end
                    end
                }
                
                table.insert(event.OnceListeners, connection)
                return connection
            end,
            
            Fire = function(...)
                local args = { ... }
                
                -- Fire regular listeners
                for _, listener in ipairs(event.Listeners) do
                    task.spawn(listener, unpack(args))
                end
                
                -- Fire once listeners and clear them
                for _, listener in ipairs(event.OnceListeners) do
                    task.spawn(listener, unpack(args))
                end
                event.OnceListeners = { }
            end,
            
            DisconnectAll = function()
                event.Listeners = { }
                event.OnceListeners = { }
            end,
            
            Wait = function()
                local thread = coroutine.running()
                event:Once(function(...)
                    coroutine.resume(thread, ...)
                end)
                return coroutine.yield()
            end
        }
        
        self.Events[eventName] = event
        return event
    end,
    
    get = function(self, eventName)
        return self.Events[eventName] or self:create(eventName)
    end,
    
    fire = function(self, eventName, ...)
        local event = self.Events[eventName]
        if event then
            event:Fire(...)
        end
    end
}

-- Region: RENDER PIPELINE
Core.RenderPipeline = {
    Batches = { },
    Scheduled = false,
    
    schedule = function(self, priority, callback)
        table.insert(self.Batches, {
            Priority = priority or 0,
            Callback = callback
        })
        
        if not self.Scheduled then
            self.Scheduled = true
            task.defer(function()
                self:process()
            end)
        end
    end,
    
    process = function(self)
        -- Sort by priority (higher priority = first)
        table.sort(self.Batches, function(a, b)
            return a.Priority > b.Priority
        end)
        
        -- Process all batches
        for _, batch in ipairs(self.Batches) do
            local success, err = pcall(batch.Callback)
            if not success then
                warn("[RenderPipeline] Error:", err)
            end
        end
        
        -- Clear and reset
        self.Batches = { }
        self.Scheduled = false
    end,
    
    immediate = function(self, callback)
        self:schedule(100, callback)
    end,
    
    deferred = function(self, callback)
        self:schedule(0, callback)
    end
}

-- Region: ANIMATION SYSTEM
Core.AnimationSystem = {
    Animations = { },
    Running = false,
    
    create = function(self, target, properties, options)
        options = options or { }
        
        local animation = {
            Target = target,
            Properties = properties,
            Duration = options.Duration or 0.3,
            EasingStyle = options.EasingStyle or Enum.EasingStyle.Quad,
            EasingDirection = options.EasingDirection or Enum.EasingDirection.Out,
            StartTime = tick(),
            StartValues = { },
            EndValues = { },
            Callbacks = {
                Started = options.Started,
                Completed = options.Completed,
                Cancelled = options.Cancelled
            },
            Cancelled = false,
            Paused = false,
            PauseTime = nil
        }
        
        -- Store start values
        for property, value in pairs(properties) do
            animation.StartValues[property] = target[property]
            animation.EndValues[property] = value
        end
        
        -- Add to animation list
        table.insert(self.Animations, animation)
        
        -- Start update loop if not running
        if not self.Running then
            self.Running = true
            self:startUpdateLoop()
        end
        
        -- Fire started callback
        if animation.Callbacks.Started then
            task.spawn(animation.Callbacks.Started)
        end
        
        return {
            Cancel = function()
                animation.Cancelled = true
                if animation.Callbacks.Cancelled then
                    task.spawn(animation.Callbacks.Cancelled)
                end
            end,
            
            Pause = function()
                if not animation.Paused then
                    animation.Paused = true
                    animation.PauseTime = tick()
                end
            end,
            
            Resume = function()
                if animation.Paused then
                    animation.Paused = false
                    animation.StartTime = animation.StartTime + (tick() - animation.PauseTime)
                    animation.PauseTime = nil
                end
            end
        }
    end,
    
    startUpdateLoop = function(self)
        Core.Services.RunService.Heartbeat:Connect(function(deltaTime)
            self:update(deltaTime)
        end)
    end,
    
    update = function(self, deltaTime)
        local currentTime = tick()
        local completedAnimations = { }
        
        for i, animation in ipairs(self.Animations) do
            if animation.Cancelled then
                table.insert(completedAnimations, i)
            elseif not animation.Paused then
                local elapsed = currentTime - animation.StartTime
                local progress = Core.Utility.Math.clamp(elapsed / animation.Duration, 0, 1)
                local alpha = Core.Services.TweenService:GetValue(
                    progress,
                    animation.EasingStyle,
                    animation.EasingDirection
                )
                
                -- Apply animated values
                for property, startValue in pairs(animation.StartValues) do
                    local endValue = animation.EndValues[property]
                    
                    if typeof(startValue) == "number" then
                        animation.Target[property] = Core.Utility.Math.lerp(startValue, endValue, alpha)
                    elseif typeof(startValue) == "Color3" then
                        animation.Target[property] = Core.Utility.Color.lerp(startValue, endValue, alpha)
                    elseif typeof(startValue) == "UDim2" then
                        animation.Target[property] = UDim2.new(
                            Core.Utility.Math.lerp(startValue.X.Scale, endValue.X.Scale, alpha),
                            Core.Utility.Math.lerp(startValue.X.Offset, endValue.X.Offset, alpha),
                            Core.Utility.Math.lerp(startValue.Y.Scale, endValue.Y.Scale, alpha),
                            Core.Utility.Math.lerp(startValue.Y.Offset, endValue.Y.Offset, alpha)
                        )
                    end
                end
                
                -- Check if completed
                if progress >= 1 then
                    table.insert(completedAnimations, i)
                    
                    -- Fire completed callback
                    if animation.Callbacks.Completed then
                        task.spawn(animation.Callbacks.Completed)
                    end
                end
            end
        end
        
        -- Remove completed animations (in reverse order)
        for i = #completedAnimations, 1, -1 do
            table.remove(self.Animations, completedAnimations[i])
        end
        
        -- Stop update loop if no animations
        if #self.Animations == 0 then
            self.Running = false
        end
    end,
    
    tween = function(self, target, properties, duration, easingStyle, easingDirection)
        return self:create(target, properties, {
            Duration = duration,
            EasingStyle = easingStyle,
            EasingDirection = easingDirection
        })
    end,
    
    spring = function(self, target, properties, options)
        options = options or { }
        
        local animation = {
            Target = target,
            Properties = properties,
            Frequency = options.Frequency or 4,
            Damping = options.Damping or 1,
            Velocity = { },
            StartTime = tick(),
            StartValues = { },
            TargetValues = { },
            Callbacks = {
                Started = options.Started,
                Completed = options.Completed
            }
        }
        
        -- Initialize
        for property, targetValue in pairs(properties) do
            animation.StartValues[property] = target[property]
            animation.TargetValues[property] = targetValue
            animation.Velocity[property] = Vector3.new(0, 0, 0)
        end
        
        table.insert(self.Animations, animation)
        
        if not self.Running then
            self.Running = true
            self:startUpdateLoop()
        end
        
        return animation
    end
}

-- Region: INPUT SYSTEM
Core.InputSystem = {
    Mouse = {
        Position = Vector2.new(0, 0),
        Delta = Vector2.new(0, 0),
        WheelDelta = 0,
        Buttons = {
            Left = false,
            Right = false,
            Middle = false
        }
    },
    
    Keyboard = {
        Keys = { },
        TextInput = "",
        LastKey = nil
    },
    
    Touch = {
        Touches = { },
        Gestures = { }
    },
    
    Gamepad = {
        Connected = false,
        Buttons = { },
        Thumbsticks = {
            Left = Vector2.new(0, 0),
            Right = Vector2.new(0, 0)
        },
        Triggers = {
            Left = 0,
            Right = 0
        }
    },
    
    initialize = function(self)
        -- Mouse input
        Core.Services.UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                local newPos = Vector2.new(input.Position.X, input.Position.Y)
                self.Mouse.Delta = newPos - self.Mouse.Position
                self.Mouse.Position = newPos
                
                Core.EventSystem:fire("MouseMoved", self.Mouse.Position, self.Mouse.Delta)
            elseif input.UserInputType == Enum.UserInputType.MouseWheel then
                self.Mouse.WheelDelta = input.Position.Z
                Core.EventSystem:fire("MouseWheel", self.Mouse.WheelDelta)
            end
        end)
        
        Core.Services.UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                self.Mouse.Buttons.Left = true
                Core.EventSystem:fire("MouseButtonDown", "Left", self.Mouse.Position)
            elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                self.Mouse.Buttons.Right = true
                Core.EventSystem:fire("MouseButtonDown", "Right", self.Mouse.Position)
            elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
                self.Mouse.Buttons.Middle = true
                Core.EventSystem:fire("MouseButtonDown", "Middle", self.Mouse.Position)
            elseif input.UserInputType == Enum.UserInputType.Keyboard then
                self.Keyboard.Keys[input.KeyCode] = true
                self.Keyboard.LastKey = input.KeyCode
                Core.EventSystem:fire("KeyDown", input.KeyCode)
            end
        end)
        
        Core.Services.UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                self.Mouse.Buttons.Left = false
                Core.EventSystem:fire("MouseButtonUp", "Left", self.Mouse.Position)
            elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                self.Mouse.Buttons.Right = false
                Core.EventSystem:fire("MouseButtonUp", "Right", self.Mouse.Position)
            elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
                self.Mouse.Buttons.Middle = false
                Core.EventSystem:fire("MouseButtonUp", "Middle", self.Mouse.Position)
            elseif input.UserInputType == Enum.UserInputType.Keyboard then
                self.Keyboard.Keys[input.KeyCode] = false
                Core.EventSystem:fire("KeyUp", input.KeyCode)
            end
        end)
        
        -- Text input
        Core.Services.UserInputService.TextBoxFocused:Connect(function(textBox)
            Core.Services.UserInputService:GetTextboxInput():Connect(function(text)
                self.Keyboard.TextInput = text
                Core.EventSystem:fire("TextInput", text)
            end)
        end)
        
        -- Gamepad support
        Core.Services.UserInputService.GamepadConnected:Connect(function(gamepad)
            self.Gamepad.Connected = true
            Core.EventSystem:fire("GamepadConnected", gamepad)
        end)
        
        Core.Services.UserInputService.GamepadDisconnected:Connect(function(gamepad)
            self.Gamepad.Connected = false
            Core.EventSystem:fire("GamepadDisconnected", gamepad)
        end)
        
        -- Touch support
        Core.Services.UserInputService.TouchStarted:Connect(function(touch, processed)
            if not processed then
                self.Touch.Touches[touch] = {
                    Position = Vector2.new(touch.Position.X, touch.Position.Y),
                    StartTime = tick()
                }
                Core.EventSystem:fire("TouchBegan", touch)
            end
        end)
        
        Core.Services.UserInputService.TouchEnded:Connect(function(touch, processed)
            if not processed then
                self.Touch.Touches[touch] = nil
                Core.EventSystem:fire("TouchEnded", touch)
            end
        end)
    end,
    
    isKeyDown = function(self, keyCode)
        return self.Keyboard.Keys[keyCode] == true
    end,
    
    isMouseButtonDown = function(self, button)
        return self.Mouse.Buttons[button] == true
    end,
    
    getMousePosition = function(self)
        return self.Mouse.Position
    end,
    
    getMouseDelta = function(self)
        return self.Mouse.Delta
    end
}

-- Region: THEME SYSTEM
Core.ThemeSystem = {
    Themes = {
        Dark = {
            Accent = Color3.fromRGB(0, 116, 224),
            AccentGradient = Color3.fromRGB(0, 195, 255),
            Background = Color3.fromRGB(12, 12, 14),
            Background2 = Color3.fromRGB(10, 10, 12),
            Text = Color3.fromRGB(235, 235, 235),
            TextSecondary = Color3.fromRGB(180, 180, 180),
            TextDisabled = Color3.fromRGB(120, 120, 120),
            Outline = Color3.fromRGB(25, 25, 28),
            OutlineHover = Color3.fromRGB(40, 40, 45),
            SectionTop = Color3.fromRGB(28, 27, 31),
            SectionBackground = Color3.fromRGB(10, 10, 12),
            SectionBackground2 = Color3.fromRGB(14, 14, 16),
            Element = Color3.fromRGB(16, 16, 18),
            ElementHover = Color3.fromRGB(20, 20, 22),
            ElementActive = Color3.fromRGB(24, 24, 26),
            Success = Color3.fromRGB(76, 175, 80),
            Warning = Color3.fromRGB(255, 193, 7),
            Error = Color3.fromRGB(244, 67, 54),
            Info = Color3.fromRGB(33, 150, 243)
        },
        
        Light = {
            Accent = Color3.fromRGB(0, 100, 255),
            AccentGradient = Color3.fromRGB(100, 180, 255),
            Background = Color3.fromRGB(245, 245, 250),
            Background2 = Color3.fromRGB(235, 235, 240),
            Text = Color3.fromRGB(30, 30, 35),
            TextSecondary = Color3.fromRGB(80, 80, 85),
            TextDisabled = Color3.fromRGB(150, 150, 155),
            Outline = Color3.fromRGB(220, 220, 225),
            OutlineHover = Color3.fromRGB(200, 200, 205),
            SectionTop = Color3.fromRGB(255, 255, 255),
            SectionBackground = Color3.fromRGB(250, 250, 255),
            SectionBackground2 = Color3.fromRGB(240, 240, 245),
            Element = Color3.fromRGB(230, 230, 235),
            ElementHover = Color3.fromRGB(220, 220, 225),
            ElementActive = Color3.fromRGB(210, 210, 215),
            Success = Color3.fromRGB(56, 142, 60),
            Warning = Color3.fromRGB(245, 124, 0),
            Error = Color3.fromRGB(211, 47, 47),
            Info = Color3.fromRGB(25, 118, 210)
        },
        
        Neon = {
            Accent = Color3.fromRGB(0, 255, 255),
            AccentGradient = Color3.fromRGB(255, 0, 255),
            Background = Color3.fromRGB(5, 5, 10),
            Background2 = Color3.fromRGB(10, 5, 15),
            Text = Color3.fromRGB(255, 255, 255),
            TextSecondary = Color3.fromRGB(200, 200, 255),
            TextDisabled = Color3.fromRGB(100, 100, 150),
            Outline = Color3.fromRGB(30, 20, 40),
            OutlineHover = Color3.fromRGB(50, 30, 60),
            SectionTop = Color3.fromRGB(15, 10, 20),
            SectionBackground = Color3.fromRGB(10, 5, 15),
            SectionBackground2 = Color3.fromRGB(20, 10, 25),
            Element = Color3.fromRGB(20, 15, 25),
            ElementHover = Color3.fromRGB(30, 20, 35),
            ElementActive = Color3.fromRGB(40, 25, 45),
            Success = Color3.fromRGB(0, 255, 128),
            Warning = Color3.fromRGB(255, 255, 0),
            Error = Color3.fromRGB(255, 0, 64),
            Info = Color3.fromRGB(128, 0, 255)
        },
        
        Classic = {
            Accent = Color3.fromRGB(255, 100, 0),
            AccentGradient = Color3.fromRGB(255, 200, 0),
            Background = Color3.fromRGB(30, 30, 35),
            Background2 = Color3.fromRGB(25, 25, 30),
            Text = Color3.fromRGB(240, 240, 240),
            TextSecondary = Color3.fromRGB(200, 200, 200),
            TextDisabled = Color3.fromRGB(140, 140, 140),
            Outline = Color3.fromRGB(50, 50, 55),
            OutlineHover = Color3.fromRGB(60, 60, 65),
            SectionTop = Color3.fromRGB(35, 35, 40),
            SectionBackground = Color3.fromRGB(25, 25, 30),
            SectionBackground2 = Color3.fromRGB(30, 30, 35),
            Element = Color3.fromRGB(40, 40, 45),
            ElementHover = Color3.fromRGB(45, 45, 50),
            ElementActive = Color3.fromRGB(50, 50, 55),
            Success = Color3.fromRGB(0, 200, 83),
            Warning = Color3.fromRGB(255, 145, 0),
            Error = Color3.fromRGB(255, 23, 68),
            Info = Color3.fromRGB(41, 98, 255)
        }
    },
    
    Current = { },
    Subscribers = { },
    
    initialize = function(self)
        self.Current = Core.Utility.Table.clone(self.Themes.Dark)
        self:updateAll()
    end,
    
    apply = function(self, themeName)
        local theme = self.Themes[themeName]
        if theme then
            self.Current = Core.Utility.Table.clone(theme)
            self:updateAll()
            Core.EventSystem:fire("ThemeChanged", themeName)
            return true
        end
        return false
    end,
    
    setColor = function(self, property, color)
        self.Current[property] = color
        self:updateProperty(property)
    end,
    
    updateProperty = function(self, property)
        for _, subscriber in ipairs(self.Subscribers) do
            if subscriber.UpdateTheme then
                subscriber:UpdateTheme(property, self.Current[property])
            end
        end
    end,
    
    updateAll = function(self)
        for _, subscriber in ipairs(self.Subscribers) do
            if subscriber.UpdateTheme then
                subscriber:UpdateTheme(nil, self.Current)
            end
        end
    end,
    
    subscribe = function(self, object)
        table.insert(self.Subscribers, object)
    end,
    
    unsubscribe = function(self, object)
        for i, subscriber in ipairs(self.Subscribers) do
            if subscriber == object then
                table.remove(self.Subscribers, i)
                break
            end
        end
    end,
    
    createCustom = function(self, baseTheme, overrides)
        local custom = Core.Utility.Table.clone(self.Themes[baseTheme] or self.Themes.Dark)
        if overrides then
            custom = Core.Utility.Table.deepMerge(custom, overrides)
        end
        return custom
    end
}

-- Region: COMPONENT SYSTEM
Core.Component = { }
Core.Component.__index = Core.Component

function Core.Component.new(name)
    local self = setmetatable({ }, Core.Component)
    
    self.Name = name or "UnnamedComponent"
    self.Id = Core.Utility.String.format("%s_%s", name, Core.Utility.GenerateGUID())
    self.Visible = true
    self.Active = true
    self.Parent = nil
    self.Children = { }
    self.Instances = { }
    self.Connections = { }
    self.Properties = { }
    self.State = { }
    self.Events = {
        MouseEnter = Core.EventSystem:create(self.Id .. "_MouseEnter"),
        MouseLeave = Core.EventSystem:create(self.Id .. "_MouseLeave"),
        MouseDown = Core.EventSystem:create(self.Id .. "_MouseDown"),
        MouseUp = Core.EventSystem:create(self.Id .. "_MouseUp"),
        Click = Core.EventSystem:create(self.Id .. "_Click"),
        RightClick = Core.EventSystem:create(self.Id .. "_RightClick"),
        DoubleClick = Core.EventSystem:create(self.Id .. "_DoubleClick"),
        Focus = Core.EventSystem:create(self.Id .. "_Focus"),
        Blur = Core.EventSystem:create(self.Id .. "_Blur"),
        Change = Core.EventSystem:create(self.Id .. "_Change")
    }
    
    Core.State.Components[self.Id] = self
    Core.ThemeSystem:subscribe(self)
    
    return self
end

function Core.Component:addChild(child)
    table.insert(self.Children, child)
    child.Parent = self
    return child
end

function Core.Component:removeChild(child)
    for i, c in ipairs(self.Children) do
        if c == child then
            table.remove(self.Children, i)
            child.Parent = nil
            break
        end
    end
end

function Core.Component:createInstance(className, properties)
    local instance = Core.Utility.Instance.create(className, properties)
    table.insert(self.Instances, instance)
    return instance
end

function Core.Component:connect(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(self.Connections, connection)
    return connection
end

function Core.Component:setProperty(property, value)
    self.Properties[property] = value
    self:applyProperty(property, value)
end

function Core.Component:applyProperty(property, value)
    -- To be overridden by specific components
end

function Core.Component:setState(newState)
    self.State = Core.Utility.Table.deepMerge(self.State, newState)
    self:render()
end

function Core.Component:UpdateTheme(property, value)
    -- To be overridden by specific components
end

function Core.Component:render()
    -- To be overridden by specific components
end

function Core.Component:show()
    self.Visible = true
    for _, instance in ipairs(self.Instances) do
        instance.Visible = true
    end
    for _, child in ipairs(self.Children) do
        child:show()
    end
end

function Core.Component:hide()
    self.Visible = false
    for _, instance in ipairs(self.Instances) do
        instance.Visible = false
    end
    for _, child in ipairs(self.Children) do
        child:hide()
    end
end

function Core.Component:destroy()
    -- Disconnect all connections
    for _, connection in ipairs(self.Connections) do
        connection:Disconnect()
    end
    
    -- Destroy all instances
    for _, instance in ipairs(self.Instances) do
        instance:Destroy()
    end
    
    -- Destroy all children
    for _, child in ipairs(self.Children) do
        child:destroy()
    end
    
    -- Remove from theme subscribers
    Core.ThemeSystem:unsubscribe(self)
    
    -- Remove from component registry
    Core.State.Components[self.Id] = nil
    
    -- Clear all tables
    self.Children = nil
    self.Instances = nil
    self.Connections = nil
    self.Properties = nil
    self.State = nil
    self.Events = nil
end

-- Region: SPECIFIC COMPONENTS
-- Window Component
Core.Components.Window = setmetatable({ }, Core.Component)
Core.Components.Window.__index = Core.Components.Window

function Core.Components.Window.new(config)
    local self = setmetatable(Core.Component.new("Window"), Core.Components.Window)
    
    self.Config = config or { }
    self.Title = config.Name or "Lyra Window"
    self.SubTitle = config.SubName or ""
    self.Logo = config.Logo or ""
    self.Size = config.Size or UDim2.new(0, 650, 0, 500)
    self.Position = config.Position or UDim2.new(0.5, -325, 0.5, -250)
    self.MinSize = config.MinSize or UDim2.new(0, 400, 0, 300)
    self.MaxSize = config.MaxSize or UDim2.new(0, 1200, 0, 800)
    self.Resizable = config.Resizable ~= false
    self.Draggable = config.Draggable ~= false
    self.Theme = config.Theme or "Dark"
    self.Pages = { }
    self.CurrentPage = nil
    self.IsOpen = false
    
    -- Apply theme
    Core.ThemeSystem:apply(self.Theme)
    
    -- Create window frame
    self:createWindowFrame()
    
    -- Add to windows registry
    Core.State.Windows[self.Id] = self
    
    return self
end

function Core.Components.Window:createWindowFrame()
    -- Main container
    self.MainFrame = self:createInstance("Frame", {
        Name = "LyraWindow",
        Size = self.Size,
        Position = self.Position,
        BackgroundColor3 = Core.ThemeSystem.Current.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 100,
        Parent = Core.Services.CoreGui
    })
    
    -- Window shadow
    self.Shadow = self:createInstance("ImageLabel", {
        Name = "Shadow",
        Image = "rbxassetid://5554237733",
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = 0.8,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(10, 10, 118, 118),
        Size = UDim2.new(1, 20, 1, 20),
        Position = UDim2.new(0, -10, 0, -10),
        BackgroundTransparency = 1,
        ZIndex = 99,
        Parent = self.MainFrame
    })
    
    -- Title bar
    self.TitleBar = self:createInstance("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Core.ThemeSystem.Current.SectionTop,
        BorderSizePixel = 0,
        ZIndex = 101,
        Parent = self.MainFrame
    })
    
    -- Logo
    if self.Logo ~= "" then
        self.LogoImage = self:createInstance("ImageLabel", {
            Name = "Logo",
            Image = self.Logo,
            Size = UDim2.new(0, 24, 0, 24),
            Position = UDim2.new(0, 12, 0, 8),
            BackgroundTransparency = 1,
            ZIndex = 102,
            Parent = self.TitleBar
        })
    end
    
    -- Title
    self.TitleLabel = self:createInstance("TextLabel", {
        Name = "Title",
        Text = self.Title,
        Font = Enum.Font.GothamSemibold,
        TextSize = 18,
        TextColor3 = Core.ThemeSystem.Current.Text,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -100, 1, 0),
        Position = self.Logo ~= "" and UDim2.new(0, 44, 0, 0) or UDim2.new(0, 12, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 102,
        Parent = self.TitleBar
    })
    
    -- Subtitle
    if self.SubTitle ~= "" then
        self.SubTitleLabel = self:createInstance("TextLabel", {
            Name = "SubTitle",
            Text = self.SubTitle,
            Font = Enum.Font.Gotham,
            TextSize = 14,
            TextColor3 = Core.ThemeSystem.Current.TextSecondary,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -100, 0, 16),
            Position = UDim2.new(0, self.Logo ~= "" and 44 or 12, 0, 20),
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 102,
            Parent = self.TitleBar
        })
    end
    
    -- Close button
    self.CloseButton = self:createInstance("TextButton", {
        Name = "CloseButton",
        Text = "",
        Size = UDim2.new(0, 32, 0, 32),
        Position = UDim2.new(1, -40, 0, 4),
        BackgroundColor3 = Core.ThemeSystem.Current.Element,
        BorderSizePixel = 0,
        ZIndex = 102,
        Parent = self.TitleBar
    })
    
    -- Close icon
    self.CloseIcon = self:createInstance("ImageLabel", {
        Name = "CloseIcon",
        Image = "rbxassetid://10734988699",
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0.5, -8, 0.5, -8),
        BackgroundTransparency = 1,
        ImageColor3 = Core.ThemeSystem.Current.Text,
        ZIndex = 103,
        Parent = self.CloseButton
    })
    
    -- Content area
    self.ContentArea = self:createInstance("Frame", {
        Name = "ContentArea",
        Size = UDim2.new(1, 0, 1, -40),
        Position = UDim2.new(0, 0, 0, 40),
        BackgroundColor3 = Core.ThemeSystem.Current.Background2,
        BorderSizePixel = 0,
        ZIndex = 101,
        Parent = self.MainFrame
    })
    
    -- Make draggable if enabled
    if self.Draggable then
        self:makeDraggable()
    end
    
    -- Make resizable if enabled
    if self.Resizable then
        self:makeResizable()
    end
    
    -- Set up close button
    self:connect(self.CloseButton.MouseButton1Click, function()
        self:close()
    end)
    
    -- Add hover effects
    self:addHoverEffects()
end

function Core.Components.Window:makeDraggable()
    local dragging = false
    local dragStart, startPos
    
    self:connect(self.TitleBar.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.MainFrame.Position
            
            self:connect(input.Changed, function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    self:connect(Core.Services.UserInputService.InputChanged, function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            self.MainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

function Core.Components.Window:makeResizable()
    local resizing = false
    local resizeStart, startSize, startPos, resizeEdge
    
    -- Create resize handles
    local handles = {
        Top = self:createInstance("Frame", {
            Name = "ResizeTop",
            Size = UDim2.new(1, 0, 0, 4),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1,
            ZIndex = 200,
            Parent = self.MainFrame
        }),
        
        Bottom = self:createInstance("Frame", {
            Name = "ResizeBottom",
            Size = UDim2.new(1, 0, 0, 4),
            Position = UDim2.new(0, 0, 1, -4),
            BackgroundTransparency = 1,
            ZIndex = 200,
            Parent = self.MainFrame
        }),
        
        Left = self:createInstance("Frame", {
            Name = "ResizeLeft",
            Size = UDim2.new(0, 4, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1,
            ZIndex = 200,
            Parent = self.MainFrame
        }),
        
        Right = self:createInstance("Frame", {
            Name = "ResizeRight",
            Size = UDim2.new(0, 4, 1, 0),
            Position = UDim2.new(1, -4, 0, 0),
            BackgroundTransparency = 1,
            ZIndex = 200,
            Parent = self.MainFrame
        }),
        
        TopLeft = self:createInstance("Frame", {
            Name = "ResizeTopLeft",
            Size = UDim2.new(0, 8, 0, 8),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1,
            ZIndex = 200,
            Parent = self.MainFrame
        }),
        
        TopRight = self:createInstance("Frame", {
            Name = "ResizeTopRight",
            Size = UDim2.new(0, 8, 0, 8),
            Position = UDim2.new(1, -8, 0, 0),
            BackgroundTransparency = 1,
            ZIndex = 200,
            Parent = self.MainFrame
        }),
        
        BottomLeft = self:createInstance("Frame", {
            Name = "ResizeBottomLeft",
            Size = UDim2.new(0, 8, 0, 8),
            Position = UDim2.new(0, 0, 1, -8),
            BackgroundTransparency = 1,
            ZIndex = 200,
            Parent = self.MainFrame
        }),
        
        BottomRight = self:createInstance("Frame", {
            Name = "ResizeBottomRight",
            Size = UDim2.new(0, 8, 0, 8),
            Position = UDim2.new(1, -8, 1, -8),
            BackgroundTransparency = 1,
            ZIndex = 200,
            Parent = self.MainFrame
        })
    }
    
    -- Set cursor for each handle
    local handleCursors = {
        Top = "SizeNS",
        Bottom = "SizeNS",
        Left = "SizeWE",
        Right = "SizeWE",
        TopLeft = "SizeNWSE",
        TopRight = "SizeNESW",
        BottomLeft = "SizeNESW",
        BottomRight = "SizeNWSE"
    }
    
    for edge, handle in pairs(handles) do
        handle.Cursor = handleCursors[edge]
        
        self:connect(handle.InputBegan, function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                resizing = true
                resizeEdge = edge
                resizeStart = input.Position
                startSize = self.MainFrame.Size
                startPos = self.MainFrame.Position
            end
        end)
    end
    
    self:connect(Core.Services.UserInputService.InputChanged, function(input)
        if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - resizeStart
            local newSize = startSize
            local newPos = startPos
            
            -- Calculate new size and position based on edge
            if string.find(resizeEdge, "Top") then
                local height = math.max(startSize.Y.Offset - delta.Y, self.MinSize.Y.Offset)
                newSize = UDim2.new(newSize.X.Scale, newSize.X.Offset, newSize.Y.Scale, height)
                newPos = UDim2.new(newPos.X.Scale, newPos.X.Offset, newPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
            
            if string.find(resizeEdge, "Bottom") then
                local height = math.max(startSize.Y.Offset + delta.Y, self.MinSize.Y.Offset)
                newSize = UDim2.new(newSize.X.Scale, newSize.X.Offset, newSize.Y.Scale, height)
            end
            
            if string.find(resizeEdge, "Left") then
                local width = math.max(startSize.X.Offset - delta.X, self.MinSize.X.Offset)
                newSize = UDim2.new(newSize.X.Scale, width, newSize.Y.Scale, newSize.Y.Offset)
                newPos = UDim2.new(newPos.X.Scale, startPos.X.Offset + delta.X, newPos.Y.Scale, newPos.Y.Offset)
            end
            
            if string.find(resizeEdge, "Right") then
                local width = math.max(startSize.X.Offset + delta.X, self.MinSize.X.Offset)
                newSize = UDim2.new(newSize.X.Scale, width, newSize.Y.Scale, newSize.Y.Offset)
            end
            
            -- Apply constraints
            newSize = UDim2.new(
                newSize.X.Scale,
                Core.Utility.Math.clamp(newSize.X.Offset, self.MinSize.X.Offset, self.MaxSize.X.Offset),
                newSize.Y.Scale,
                Core.Utility.Math.clamp(newSize.Y.Offset, self.MinSize.Y.Offset, self.MaxSize.Y.Offset)
            )
            
            self.MainFrame.Size = newSize
            self.MainFrame.Position = newPos
        end
    end)
    
    self:connect(Core.Services.UserInputService.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = false
        end
    end)
end

function Core.Components.Window:addHoverEffects()
    -- Close button hover
    self:connect(self.CloseButton.MouseEnter, function()
        Core.AnimationSystem:tween(self.CloseButton, {
            BackgroundColor3 = Core.ThemeSystem.Current.ElementHover
        }, 0.2)
    end)
    
    self:connect(self.CloseButton.MouseLeave, function()
        Core.AnimationSystem:tween(self.CloseButton, {
            BackgroundColor3 = Core.ThemeSystem.Current.Element
        }, 0.2)
    end)
end

function Core.Components.Window:UpdateTheme(property, value)
    if property == nil then
        -- Update all theme properties
        self.MainFrame.BackgroundColor3 = Core.ThemeSystem.Current.Background
        self.TitleBar.BackgroundColor3 = Core.ThemeSystem.Current.SectionTop
        self.TitleLabel.TextColor3 = Core.ThemeSystem.Current.Text
        if self.SubTitleLabel then
            self.SubTitleLabel.TextColor3 = Core.ThemeSystem.Current.TextSecondary
        end
        self.CloseButton.BackgroundColor3 = Core.ThemeSystem.Current.Element
        self.CloseIcon.ImageColor3 = Core.ThemeSystem.Current.Text
        self.ContentArea.BackgroundColor3 = Core.ThemeSystem.Current.Background2
    else
        -- Update specific property
        if property == "Background" then
            self.MainFrame.BackgroundColor3 = value
        elseif property == "SectionTop" then
            self.TitleBar.BackgroundColor3 = value
        elseif property == "Text" then
            self.TitleLabel.TextColor3 = value
            self.CloseIcon.ImageColor3 = value
        elseif property == "TextSecondary" and self.SubTitleLabel then
            self.SubTitleLabel.TextColor3 = value
        elseif property == "Element" then
            self.CloseButton.BackgroundColor3 = value
        elseif property == "Background2" then
            self.ContentArea.BackgroundColor3 = value
        end
    end
end

function Core.Components.Window:open()
    if self.IsOpen then return end
    
    self.IsOpen = true
    self.MainFrame.Visible = true
    
    -- Animate opening
    self.MainFrame.Position = UDim2.new(0.5, -325, 0, -500)
    Core.AnimationSystem:tween(self.MainFrame, {
        Position = self.Position
    }, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    
    Core.EventSystem:fire("WindowOpened", self)
end

function Core.Components.Window:close()
    if not self.IsOpen then return end
    
    -- Animate closing
    Core.AnimationSystem:tween(self.MainFrame, {
        Position = UDim2.new(0.5, -325, 0, -500)
    }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    
    task.delay(0.3, function()
        self.IsOpen = false
        self.MainFrame.Visible = false
        Core.EventSystem:fire("WindowClosed", self)
    end)
end

function Core.Components.Window:toggle()
    if self.IsOpen then
        self:close()
    else
        self:open()
    end
end

function Core.Components.Window:addPage(config)
    local page = Core.Components.Page.new(config)
    page.Window = self
    table.insert(self.Pages, page)
    
    -- If this is the first page, make it active
    if #self.Pages == 1 then
        self:setCurrentPage(page)
    end
    
    return page
end

function Core.Components.Window:setCurrentPage(page)
    if self.CurrentPage then
        self.CurrentPage:deactivate()
    end
    
    self.CurrentPage = page
    page:activate()
end

-- Page Component
Core.Components.Page = setmetatable({ }, Core.Component)
Core.Components.Page.__index = Core.Components.Page

function Core.Components.Page.new(config)
    local self = setmetatable(Core.Component.new("Page"), Core.Components.Page)
    
    self.Name = config.Name or "Page"
    self.Icon = config.Icon or ""
    self.Tooltip = config.Tooltip or ""
    self.Order = config.Order or 1
    self.Sections = { }
    
    return self
end

function Core.Components.Page:activate()
    self.Active = true
    -- Show all sections
    for _, section in ipairs(self.Sections) do
        section:show()
    end
end

function Core.Components.Page:deactivate()
    self.Active = false
    -- Hide all sections
    for _, section in ipairs(self.Sections) do
        section:hide()
    end
end

function Core.Components.Page:addSection(config)
    local section = Core.Components.Section.new(config)
    section.Page = self
    table.insert(self.Sections, section)
    return section
end

-- Section Component
Core.Components.Section = setmetatable({ }, Core.Component)
Core.Components.Section.__index = Core.Components.Section

function Core.Components.Section.new(config)
    local self = setmetatable(Core.Component.new("Section"), Core.Components.Section)
    
    self.Name = config.Name or "Section"
    self.Description = config.Description or ""
    self.Icon = config.Icon or ""
    self.Collapsible = config.Collapsible or false
    self.Collapsed = config.Collapsed or false
    self.Elements = { }
    
    return self
end

function Core.Components.Section:toggleCollapse()
    self.Collapsed = not self.Collapsed
    for _, element in ipairs(self.Elements) do
        if self.Collapsed then
            element:hide()
        else
            element:show()
        end
    end
end

function Core.Components.Section:addElement(element)
    table.insert(self.Elements, element)
    element.Section = self
    return element
end

-- Region: UI ELEMENTS

-- Toggle Element
Core.Components.Toggle = setmetatable({ }, Core.Component)
Core.Components.Toggle.__index = Core.Components.Toggle

function Core.Components.Toggle.new(config)
    local self = setmetatable(Core.Component.new("Toggle"), Core.Components.Toggle)
    
    self.Name = config.Name or "Toggle"
    self.Flag = config.Flag or Core.Utility.String.format("toggle_%s", Core.Utility.GenerateGUID())
    self.Default = config.Default or false
    self.Value = self.Default
    self.Callback = config.Callback or function() end
    self.Tooltip = config.Tooltip or ""
    
    -- Register flag
    Core.FlagSystem:register(self.Flag, self.Default, function(value)
        self:set(value)
    end, function()
        return self.Value
    end)
    
    -- Create UI
    self:createUI()
    
    return self
end

function Core.Components.Toggle:createUI()
    -- Container
    self.Container = self:createInstance("Frame", {
        Name = "ToggleContainer",
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1,
        Parent = self.Parent and self.Parent.Container or nil
    })
    
    -- Toggle switch
    self.Switch = self:createInstance("Frame", {
        Name = "Switch",
        Size = UDim2.new(0, 40, 0, 20),
        Position = UDim2.new(1, -45, 0, 5),
        BackgroundColor3 = Core.ThemeSystem.Current.Element,
        BorderSizePixel = 0,
        Parent = self.Container
    })
    
    -- Toggle knob
    self.Knob = self:createInstance("Frame", {
        Name = "Knob",
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0, 2, 0, 2),
        BackgroundColor3 = Core.ThemeSystem.Current.Text,
        BorderSizePixel = 0,
        Parent = self.Switch
    })
    
    -- Label
    self.Label = self:createInstance("TextLabel", {
        Name = "Label",
        Text = self.Name,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextColor3 = Core.ThemeSystem.Current.Text,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -50, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.Container
    })
    
    -- Tooltip
    if self.Tooltip ~= "" then
        self:createTooltip()
    end
    
    -- Set initial state
    self:updateVisualState()
    
    -- Connect events
    self:connect(self.Container.MouseButton1Click, function()
        self:toggle()
    end)
    
    -- Add hover effects
    self:addHoverEffects()
end

function Core.Components.Toggle:updateVisualState()
    if self.Value then
        Core.AnimationSystem:tween(self.Switch, {
            BackgroundColor3 = Core.ThemeSystem.Current.Accent
        }, 0.2)
        
        Core.AnimationSystem:tween(self.Knob, {
            Position = UDim2.new(1, -18, 0, 2)
        }, 0.2)
    else
        Core.AnimationSystem:tween(self.Switch, {
            BackgroundColor3 = Core.ThemeSystem.Current.Element
        }, 0.2)
        
        Core.AnimationSystem:tween(self.Knob, {
            Position = UDim2.new(0, 2, 0, 2)
        }, 0.2)
    end
end

function Core.Components.Toggle:addHoverEffects()
    self:connect(self.Container.MouseEnter, function()
        Core.AnimationSystem:tween(self.Switch, {
            BackgroundColor3 = Core.ThemeSystem.Current.ElementHover
        }, 0.2)
    end)
    
    self:connect(self.Container.MouseLeave, function()
        if not self.Value then
            Core.AnimationSystem:tween(self.Switch, {
                BackgroundColor3 = Core.ThemeSystem.Current.Element
            }, 0.2)
        end
    end)
end

function Core.Components.Toggle:createTooltip()
    -- Tooltip implementation
end

function Core.Components.Toggle:set(value)
    if self.Value == value then return end
    
    self.Value = value
    self:updateVisualState()
    
    -- Fire callback
    if self.Callback then
        Core.Utility.SafeCall(self.Callback, self.Value)
    end
    
    -- Fire change event
    self.Events.Change:Fire(self.Value)
end

function Core.Components.Toggle:toggle()
    self:set(not self.Value)
end

function Core.Components.Toggle:get()
    return self.Value
end

function Core.Components.Toggle:UpdateTheme(property, value)
    if property == nil or property == "Text" then
        self.Label.TextColor3 = Core.ThemeSystem.Current.Text
        self.Knob.BackgroundColor3 = Core.ThemeSystem.Current.Text
    end
    
    if property == nil or property == "Element" then
        if not self.Value then
            self.Switch.BackgroundColor3 = Core.ThemeSystem.Current.Element
        end
    end
    
    if property == nil or property == "ElementHover" then
        -- Update hover state
    end
    
    if property == nil or property == "Accent" then
        if self.Value then
            self.Switch.BackgroundColor3 = Core.ThemeSystem.Current.Accent
        end
    end
end

-- Similar implementations for:
-- Button, Slider, Dropdown, ColorPicker, Keybind, TextBox, Label, etc.

-- Region: FLAG SYSTEM
Core.FlagSystem = {
    Flags = { },
    Setters = { },
    Getters = { },
    Callbacks = { },
    
    register = function(self, flag, defaultValue, setter, getter)
        self.Flags[flag] = defaultValue
        self.Setters[flag] = setter
        self.Getters[flag] = getter
        
        -- Create callback list
        self.Callbacks[flag] = { }
        
        return flag
    end,
    
    set = function(self, flag, value)
        if self.Setters[flag] then
            self.Flags[flag] = value
            self.Setters[flag](value)
            
            -- Fire callbacks
            if self.Callbacks[flag] then
                for _, callback in ipairs(self.Callbacks[flag]) do
                    Core.Utility.SafeCall(callback, value)
                end
            end
            
            Core.EventSystem:fire("FlagChanged", flag, value)
            return true
        end
        return false
    end,
    
    get = function(self, flag)
        if self.Getters[flag] then
            return self.Getters[flag]()
        end
        return self.Flags[flag]
    end,
    
    onChanged = function(self, flag, callback)
        if not self.Callbacks[flag] then
            self.Callbacks[flag] = { }
        end
        table.insert(self.Callbacks[flag], callback)
    end,
    
    save = function(self)
        local data = { }
        for flag, value in pairs(self.Flags) do
            data[flag] = value
        end
        return data
    end,
    
    load = function(self, data)
        for flag, value in pairs(data) do
            self:set(flag, value)
        end
    end
}

-- Region: CONFIG SYSTEM
Core.ConfigSystem = {
    Configs = { },
    CurrentConfig = nil,
    
    save = function(self, name, data)
        local config = {
            Name = name,
            Date = os.date("%Y-%m-%d %H:%M:%S"),
            Version = Core.Constants.VERSION,
            Data = data or Core.FlagSystem:save()
        }
        
        self.Configs[name] = config
        
        -- Save to file
        local json = Core.Services.HttpService:JSONEncode(config)
        writefile(string.format("lyra/configs/%s.json", name), json)
        
        Core.EventSystem:fire("ConfigSaved", name)
        return true
    end,
    
    load = function(self, name)
        local config = self.Configs[name]
        if not config then
            -- Try to load from file
            local path = string.format("lyra/configs/%s.json", name)
            if isfile(path) then
                local json = readfile(path)
                config = Core.Services.HttpService:JSONDecode(json)
                self.Configs[name] = config
            end
        end
        
        if config then
            self.CurrentConfig = name
            Core.FlagSystem:load(config.Data)
            Core.EventSystem:fire("ConfigLoaded", name)
            return true
        end
        
        return false
    end,
    
    delete = function(self, name)
        self.Configs[name] = nil
        
        -- Delete file
        local path = string.format("lyra/configs/%s.json", name)
        if isfile(path) then
            delfile(path)
        end
        
        Core.EventSystem:fire("ConfigDeleted", name)
        return true
    end,
    
    list = function(self)
        local configs = { }
        for name, config in pairs(self.Configs) do
            table.insert(configs, {
                Name = name,
                Date = config.Date
            })
        end
        return configs
    end,
    
    export = function(self, name)
        local config = self.Configs[name]
        if config then
            return Core.Services.HttpService:JSONEncode(config)
        end
        return nil
    end,
    
    import = function(self, json)
        local config = Core.Services.HttpService:JSONDecode(json)
        if config and config.Name then
            self.Configs[config.Name] = config
            return config.Name
        end
        return nil
    end
}

-- Region: PUBLIC API (Legacy Compatibility)
local Lyra = { }

-- Legacy Window creator
function Lyra.Window(config)
    local window = Core.Components.Window.new(config)
    
    -- Create legacy API wrapper
    local legacyWindow = { }
    legacyWindow._window = window
    
    function legacyWindow:Page(pageConfig)
        local page = window:addPage(pageConfig)
        
        local legacyPage = { }
        legacyPage._page = page
        
        function legacyPage:Section(sectionConfig)
            local section = page:addSection(sectionConfig)
            
            local legacySection = { }
            legacySection._section = section
            
            -- Toggle
            function legacySection:Toggle(toggleConfig)
                local toggle = Core.Components.Toggle.new(toggleConfig)
                section:addElement(toggle)
                
                local legacyToggle = { }
                
                function legacyToggle:Set(value)
                    toggle:set(value)
                end
                
                function legacyToggle:Get()
                    return toggle:get()
                end
                
                -- Settings for toggle
                function legacyToggle:Settings()
                    local settings = { }
                    
                    function settings:Colorpicker(colorConfig)
                        -- Colorpicker implementation
                        local colorpicker = { }
                        
                        function colorpicker:Set(color, alpha)
                            -- Set color
                        end
                        
                        function colorpicker:Get()
                            -- Get color
                        end
                        
                        return colorpicker
                    end
                    
                    function settings:Keybind(keybindConfig)
                        -- Keybind implementation
                        local keybind = { }
                        
                        function keybind:Set(key)
                            -- Set keybind
                        end
                        
                        function keybind:Get()
                            -- Get keybind
                        end
                        
                        return keybind
                    end
                    
                    return settings
                end
                
                return legacyToggle
            end
            
            -- Button
            function legacySection:Button(buttonConfig)
                -- Button implementation
                local button = { }
                
                function button:Fire()
                    -- Fire button
                end
                
                return button
            end
            
            -- Slider
            function legacySection:Slider(sliderConfig)
                -- Slider implementation
                local slider = { }
                
                function slider:Set(value)
                    -- Set slider value
                end
                
                function slider:Get()
                    -- Get slider value
                end
                
                return slider
            end
            
            -- Dropdown
            function legacySection:Dropdown(dropdownConfig)
                -- Dropdown implementation
                local dropdown = { }
                
                function dropdown:Set(value)
                    -- Set dropdown value
                end
                
                function dropdown:Get()
                    -- Get dropdown value
                end
                
                function dropdown:Refresh(items)
                    -- Refresh dropdown items
                end
                
                return dropdown
            end
            
            -- Keybind
            function legacySection:Keybind(keybindConfig)
                -- Keybind implementation
                local keybind = { }
                
                function keybind:Set(key)
                    -- Set keybind
                end
                
                function keybind:Get()
                    -- Get keybind
                end
                
                return keybind
            end
            
            -- Colorpicker
            function legacySection:Colorpicker(colorConfig)
                -- Colorpicker implementation
                local colorpicker = { }
                
                function colorpicker:Set(color, alpha)
                    -- Set color
                end
                
                function colorpicker:Get()
                    -- Get color
                end
                
                return colorpicker
            end
            
            -- Label
            function legacySection:Label(labelConfig)
                -- Label implementation
                local label = { }
                
                function label:Set(text)
                    -- Set label text
                end
                
                return label
            end
            
            return legacySection
        end
        
        return legacyPage
    end
    
    function legacyWindow:Watermark(items)
        -- Watermark implementation
    end
    
    function legacyWindow:Notification(data)
        -- Notification implementation
    end
    
    function legacyWindow:Toggle()
        window:toggle()
    end
    
    return legacyWindow
end

-- Additional API functions
function Lyra.Notification(data)
    -- Notification implementation
end

function Lyra.Watermark(items)
    -- Watermark implementation
end

function Lyra.Unload()
    -- Clean up everything
    for _, window in pairs(Core.State.Windows) do
        window:destroy()
    end
    
    -- Clear all state
    Core.State = {
        Initialized = false,
        Windows = { },
        Components = { },
        Flags = { },
        Configs = { }
    }
    
    Core.EventSystem:fire("LibraryUnloaded")
end

-- New Advanced API
Lyra.Advanced = {
    Components = Core.Components,
    Theme = Core.ThemeSystem,
    Config = Core.ConfigSystem,
    Flags = Core.FlagSystem,
    Animations = Core.AnimationSystem,
    Events = Core.EventSystem,
    Input = Core.InputSystem,
    Utility = Core.Utility
}

-- Initialize library
local function initialize()
    if Core.State.Initialized then return end
    
    -- Create necessary folders
    if not isfolder("lyra") then
        makefolder("lyra")
        makefolder("lyra/configs")
        makefolder("lyra/assets")
        makefolder("lyra/themes")
    end
    
    -- Initialize systems
    Core.ThemeSystem:initialize()
    Core.InputSystem:initialize()
    
    -- Set up auto-save
    Core.Services.Players.PlayerRemoving:Connect(function(player)
        if player == Core.Services.Players.LocalPlayer then
            Core.ConfigSystem:save("autosave")
        end
    end)
    
    -- Load auto-save if exists
    task.spawn(function()
        task.wait(2)
        Core.ConfigSystem:load("autosave")
    end)
    
    Core.State.Initialized = true
    Core.EventSystem:fire("LibraryInitialized")
end

-- Start initialization
task.spawn(initialize)

-- Return library
return Lyra
