--[[ 
    🌟 MANO GUSTAVO UI - DIAMOND EDITION (V7.9.1 - BugFix)
    [Updates: Fixed Section Titles not updating color on Theme Change]
]]

return (function()
    --// SERVIÇOS //--
    local TweenService = game:GetService("TweenService")
    local UserInputService = game:GetService("UserInputService")
    local CoreGui = game:GetService("CoreGui")
    local RunService = game:GetService("RunService")
    local HttpService = game:GetService("HttpService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local Mouse = LocalPlayer:GetMouse()

    local Lib = {}
    
    --// SISTEMA DE DADOS (CONFIG & OPTIONS) //--
    Lib.Options = {} -- Armazena objetos dos componentes para controle externo
    Lib.Flags = {}   -- Armazena valores para Save/Load
    Lib.ThemeRegistry = {} -- Armazena objetos visuais para troca de tema em tempo real
    
    local ConfigFolder = "GustavoHub/Configs"
    local CurrentConfig = "default"
    
    --// CONFIGURAÇÕES VISUAIS & TEMAS //--
    local UIConfig = {
        MainColor = Color3.fromRGB(25, 25, 25),
        SecondaryColor = Color3.fromRGB(35, 35, 35),
        AccentColor = Color3.fromRGB(0, 110, 255),
        HoverColor = Color3.fromRGB(45, 45, 45),
        TextColor = Color3.fromRGB(240, 240, 240),
        StrokeColor = Color3.fromRGB(60, 60, 60),
        SectionColor = Color3.fromRGB(30, 30, 30),
        Font = Enum.Font.GothamMedium,
        Transparency = 0.1
    }

    local ScreenGui = Instance.new("ScreenGui")
    local GuiName = "GustavoHub_Hosted_V7"
    if CoreGui:FindFirstChild(GuiName) then CoreGui[GuiName]:Destroy() end
    ScreenGui.Name = GuiName
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    --// TOOLTIP GUI //--
    local Tooltip = Instance.new("TextLabel")
    Tooltip.Parent = ScreenGui
    Tooltip.Visible = false
    Tooltip.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Tooltip.TextColor3 = Color3.fromRGB(255, 255, 255)
    Tooltip.Size = UDim2.fromOffset(0, 0)
    Tooltip.Font = Enum.Font.Gotham
    Tooltip.TextSize = 12
    Tooltip.AutomaticSize = Enum.AutomaticSize.XY
    Tooltip.TextWrapped = false
    Tooltip.ZIndex = 100
    
    local TT_Stroke = Instance.new("UIStroke", Tooltip); TT_Stroke.Color = UIConfig.AccentColor; TT_Stroke.Thickness = 1
    local TT_Corner = Instance.new("UICorner", Tooltip); TT_Corner.CornerRadius = UDim.new(0, 4)
    local TT_Padding = Instance.new("UIPadding", Tooltip); TT_Padding.PaddingTop = UDim.new(0,5); TT_Padding.PaddingBottom=UDim.new(0,5); TT_Padding.PaddingLeft=UDim.new(0,8); TT_Padding.PaddingRight=UDim.new(0,8)

    RunService.RenderStepped:Connect(function()
        if Tooltip.Visible then
            local MP = UserInputService:GetMouseLocation()
            Tooltip.Position = UDim2.fromOffset(MP.X + 15, MP.Y + 15)
        end
    end)

    --// HELPER FUNCTIONS (UTILS) //--
    local function CreateInstance(cls, props)
        local inst = Instance.new(cls)
        for i,v in pairs(props) do inst[i] = v end
        return inst
    end
    
    -- Registro de Temas
    local function AddThemeObject(Obj, Prop, Type)
        if not Lib.ThemeRegistry[Type] then Lib.ThemeRegistry[Type] = {} end
        table.insert(Lib.ThemeRegistry[Type], {Object = Obj, Property = Prop})
        -- Aplica a cor atual imediatamente
        local Col
        if Type == "Main" then Col = UIConfig.MainColor 
        elseif Type == "Secondary" then Col = UIConfig.SecondaryColor
        elseif Type == "Accent" then Col = UIConfig.AccentColor
        elseif Type == "Hover" then Col = UIConfig.HoverColor
        elseif Type == "Text" then Col = UIConfig.TextColor
        elseif Type == "Stroke" then Col = UIConfig.StrokeColor
        elseif Type == "Section" then Col = UIConfig.SectionColor
        end
        if Col then Obj[Prop] = Col end
    end

    function Lib:SetTheme(NewTheme)
        if NewTheme.MainColor then UIConfig.MainColor = NewTheme.MainColor end
        if NewTheme.SecondaryColor then UIConfig.SecondaryColor = NewTheme.SecondaryColor end
        if NewTheme.AccentColor then UIConfig.AccentColor = NewTheme.AccentColor end
        if NewTheme.TextColor then UIConfig.TextColor = NewTheme.TextColor end
        
        -- Atualizar elementos existentes
        for Type, List in pairs(Lib.ThemeRegistry) do
            local NewCol
            if Type == "Main" then NewCol = UIConfig.MainColor 
            elseif Type == "Secondary" then NewCol = UIConfig.SecondaryColor
            elseif Type == "Accent" then NewCol = UIConfig.AccentColor
            elseif Type == "Text" then NewCol = UIConfig.TextColor
            elseif Type == "Stroke" then NewCol = UIConfig.StrokeColor
            end
            
            if NewCol then
                for _, Item in pairs(List) do
                    if Item.Object and Item.Object.Parent then
                        TweenService:Create(Item.Object, TweenInfo.new(0.3), {[Item.Property] = NewCol}):Play()
                    end
                end
            end
        end
        if TT_Stroke then TT_Stroke.Color = UIConfig.AccentColor end
    end

    local function MakeDraggable(frame, trigger)
        local dragging, dragStart, startPos, dragInput
        trigger.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true; dragStart = input.Position; startPos = frame.Position
                input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
            end
        end)
        trigger.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                local delta = input.Position - dragStart
                TweenService:Create(frame, TweenInfo.new(0.15), {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}):Play()
            end
        end)
    end
    
    local function AddTooltip(Obj, Text)
        if not Obj then return end
        Obj.MouseEnter:Connect(function()
            if UserInputService.TouchEnabled then return end -- Mobile Check
            Tooltip.Text = Text
            Tooltip.Visible = true
            TweenService:Create(Tooltip, TweenInfo.new(0.2), {TextTransparency = 0, BackgroundTransparency = 0}):Play()
        end)
        Obj.MouseLeave:Connect(function()
            Tooltip.Visible = false
            Tooltip.TextTransparency = 1
            Tooltip.BackgroundTransparency = 1
        end)
    end

    --// SAVE / LOAD SYSTEM //--
    function Lib:SaveConfig(Name)
        if not writefile then return end
        local Data = HttpService:JSONEncode(Lib.Flags)
        if not isfolder("GustavoHub") then makefolder("GustavoHub") end
        if not isfolder(ConfigFolder) then makefolder(ConfigFolder) end
        writefile(ConfigFolder .. "/" .. Name .. ".json", Data)
    end
    
    function Lib:LoadConfig(Name)
        if not readfile or not isfile(ConfigFolder .. "/" .. Name .. ".json") then return end
        local Content = readfile(ConfigFolder .. "/" .. Name .. ".json")
        local Data = HttpService:JSONDecode(Content)
        
        for FlagName, Value in pairs(Data) do
            if Lib.Options[FlagName] then
                Lib.Options[FlagName]:Set(Value)
            end
        end
    end
    
    function Lib:ResetConfig()
        if not isfolder(ConfigFolder) then return end
        Lib.Flags = {}
    end

    --// NOTIFICATION SYSTEM //--
    local NotifHolder = Instance.new("Frame", ScreenGui); NotifHolder.BackgroundTransparency = 1; NotifHolder.Position = UDim2.new(1, -20, 1, -20); NotifHolder.AnchorPoint = Vector2.new(1, 1); NotifHolder.Size = UDim2.new(0, 300, 1, 0)
    local NotifLayout = Instance.new("UIListLayout", NotifHolder); NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder; NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom; NotifLayout.Padding = UDim.new(0, 8)

    function Lib:Notification(Config)
        local Title, Text, Duration, Type = Config.Title or "Notification", Config.Text or "", Config.Duration or 5, Config.Type or "Info"
        local TypeData = {
            Success = {Col = Color3.fromRGB(100, 255, 100), Icon = "rbxassetid://11419719540"},
            Error   = {Col = Color3.fromRGB(255, 80, 80),   Icon = "rbxassetid://11419713314"},
            Warning = {Col = Color3.fromRGB(255, 200, 50),  Icon = "rbxassetid://11419716952"},
            Info    = {Col = UIConfig.AccentColor,          Icon = "rbxassetid://11419715764"}
        }
        local Sel = TypeData[Type] or TypeData.Info
        local F = CreateInstance("Frame", {Parent=NotifHolder, BackgroundColor3=Color3.fromRGB(30,30,30), Size=UDim2.new(1,0,0,0), ClipsDescendants=true, BackgroundTransparency=0.1})
        CreateInstance("UICorner", {Parent=F, CornerRadius=UDim.new(0,8)})
        CreateInstance("UIStroke", {Parent=F, Color=Sel.Col, Thickness=1, Transparency=0.5})
        CreateInstance("ImageLabel", {Parent=F, BackgroundTransparency=1, Position=UDim2.new(0,10,0,10), Size=UDim2.new(0,24,0,24), Image=Sel.Icon, ImageColor3=Sel.Col})
        CreateInstance("TextLabel", {Parent=F, BackgroundTransparency=1, Text=Title, TextColor3=Sel.Col, Font=Enum.Font.GothamBold, TextSize=14, Position=UDim2.new(0,42,0,12), Size=UDim2.new(1,-50,0,20), TextXAlignment=0})
        CreateInstance("TextLabel", {Parent=F, BackgroundTransparency=1, Text=Text, TextColor3=UIConfig.TextColor, Font=Enum.Font.Gotham, TextSize=12, Position=UDim2.new(0,42,0,32), Size=UDim2.new(1,-50,0,30), TextXAlignment=0, TextWrapped=true})
        local Bar = CreateInstance("Frame", {Parent=F, BackgroundColor3=Sel.Col, BorderSizePixel=0, Size=UDim2.new(1,0,0,2), Position=UDim2.new(0,0,1,-2)})
        TweenService:Create(F, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size=UDim2.new(1,0,0,70)}):Play()
        TweenService:Create(Bar, TweenInfo.new(Duration), {Size=UDim2.new(0,0,0,2)}):Play()
        task.delay(Duration, function() local t = TweenService:Create(F, TweenInfo.new(0.3), {Size=UDim2.new(1,100,0,0), Transparency=1}); t:Play(); t.Completed:Wait(); F:Destroy() end)
    end

    --// WINDOW SYSTEM //--
    function Lib:CreateWindow(Config)
        local OpenKey = Config.Keybind or Enum.KeyCode.RightControl
        local MainWin = CreateInstance("Frame", {Parent=ScreenGui, BackgroundColor3=UIConfig.MainColor, Position=UDim2.fromScale(0.5,0.5), Size=UDim2.fromOffset(500,360), AnchorPoint=Vector2.new(0.5,0.5), ClipsDescendants=true, BackgroundTransparency=UIConfig.Transparency})
        AddThemeObject(MainWin, "BackgroundColor3", "Main")
        
        CreateInstance("UICorner", {Parent=MainWin, CornerRadius=UDim.new(0,10)})
        local MainStroke = CreateInstance("UIStroke", {Parent=MainWin, Color=UIConfig.StrokeColor, Thickness=1}); AddThemeObject(MainStroke, "Color", "Stroke")

        local Topbar = CreateInstance("Frame", {Parent=MainWin, BackgroundColor3=Color3.fromRGB(30,30,30), Size=UDim2.new(1,0,0,38), BackgroundTransparency=0.1}); CreateInstance("UICorner", {Parent=Topbar, CornerRadius=UDim.new(0,10)})
        CreateInstance("TextLabel", {Parent=Topbar, BackgroundTransparency=1, Text="  "..(Config.Title or "Hub"), Size=UDim2.new(1,-90,1,0), Font=Enum.Font.GothamBold, TextSize=15, TextColor3=UIConfig.TextColor, TextXAlignment=0})
        MakeDraggable(MainWin, Topbar)
        
        -- Controls (Search, Close, Open)
        local CloseBtn = CreateInstance("ImageButton", {Parent=Topbar, BackgroundTransparency=1, Position=UDim2.new(1,-30,0,4), Size=UDim2.new(0,26,0,26), Image="rbxassetid://6031094678", ImageColor3=Color3.fromRGB(255,60,60)})
        local SearchBtn = CreateInstance("ImageButton", {Parent=Topbar, BackgroundTransparency=1, Position=UDim2.new(1,-60,0,4), Size=UDim2.new(0,26,0,26), Image="rbxassetid://6031154871", ImageColor3=Color3.fromRGB(200,200,200)})
        
        local OpenBtn = CreateInstance("ImageButton", {Parent=ScreenGui, Visible=false, BackgroundColor3=UIConfig.SecondaryColor, Position=UDim2.new(0,20,0.5,0), Size=UDim2.new(0,45,0,45), AutoButtonColor=false, BackgroundTransparency=0.2})
        AddThemeObject(OpenBtn, "BackgroundColor3", "Secondary")
        CreateInstance("UICorner", {Parent=OpenBtn, CornerRadius=UDim.new(0,10)})
        CreateInstance("UIStroke", {Parent=OpenBtn, Color=UIConfig.AccentColor, Thickness=2})
        CreateInstance("ImageLabel", {Parent=OpenBtn, BackgroundTransparency=1, Image="rbxassetid://6031068390", Size=UDim2.new(0,28,0,28), Position=UDim2.new(0.5,-14,0.5,-14), ImageColor3=UIConfig.AccentColor})
        MakeDraggable(OpenBtn, OpenBtn)

        local UI_Hidden = false
        local function ToggleUI(State) UI_Hidden = not State; MainWin.Visible = State; OpenBtn.Visible = not State end
        CloseBtn.MouseButton1Click:Connect(function() ToggleUI(false) end)
        OpenBtn.MouseButton1Click:Connect(function() ToggleUI(true) end)
        UserInputService.InputBegan:Connect(function(input, gp) if not gp and input.KeyCode == OpenKey then ToggleUI(UI_Hidden) end end)

        -- Search Logic
        local SearchBarBG = CreateInstance("Frame", {Parent=Topbar, BackgroundColor3=Color3.fromRGB(40,40,40), Position=UDim2.new(1,-60,0,4), Size=UDim2.new(0,0,0,26), BackgroundTransparency=0.2, ClipsDescendants=true, Visible=false}); CreateInstance("UICorner", {Parent=SearchBarBG, CornerRadius=UDim.new(0,5)})
        local SearchInput = CreateInstance("TextBox", {Parent=SearchBarBG, BackgroundTransparency=1, Position=UDim2.new(0,5,0,0), Size=UDim2.new(1,-10,1,0), Text="", PlaceholderText="Search...", Font=UIConfig.Font, TextSize=13, TextColor3=Color3.new(1,1,1), TextXAlignment=0})
        
        local PageHolder
        local function DoSearch(text)
            text = text:lower()
            if not PageHolder then return end
            for _, page in pairs(PageHolder:GetChildren()) do
                if page.Visible then
                    for _, item in pairs(page:GetDescendants()) do 
                        if item:IsA("TextButton") or item:IsA("Frame") then
                            if item:GetAttribute("IsElement") then
                                local label = item:FindFirstChildWhichIsA("TextLabel")
                                if label then
                                    item.Visible = string.find(label.Text:lower(), text)
                                end
                            end
                        end
                    end
                end
            end
        end
        SearchInput:GetPropertyChangedSignal("Text"):Connect(function() DoSearch(SearchInput.Text) end)
        SearchBtn.MouseButton1Click:Connect(function()
            if SearchBarBG.Visible then 
                TweenService:Create(SearchBarBG, TweenInfo.new(0.3), {Size=UDim2.new(0,0,0,26), Position=UDim2.new(1,-60,0,4)}):Play(); task.wait(0.3); SearchBarBG.Visible=false; SearchInput.Text=""; DoSearch("") 
            else 
                SearchBarBG.Visible=true; TweenService:Create(SearchBarBG, TweenInfo.new(0.3), {Size=UDim2.new(0,200,0,26), Position=UDim2.new(1,-270,0,4)}):Play(); SearchInput:CaptureFocus() 
            end
        end)

        -- Tabs System
        local TabHolder = CreateInstance("ScrollingFrame", {Parent=MainWin, BackgroundTransparency=1, Position=UDim2.new(0,10,0,48), Size=UDim2.new(0,105,1,-58), ScrollBarThickness=0}); CreateInstance("UIListLayout", {Parent=TabHolder, SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,5)})
        PageHolder = CreateInstance("Frame", {Parent=MainWin, BackgroundTransparency=1, Position=UDim2.new(0,120,0,48), Size=UDim2.new(1,-130,1,-58), ClipsDescendants=true})
        
        local Tabs = {}
        local First = true

        function Tabs:CreateTab(Name)
            local TabBtn = CreateInstance("TextButton", {Parent=TabHolder, BackgroundTransparency=1, Size=UDim2.new(1,0,0,30), Text="  "..Name, Font=UIConfig.Font, TextSize=13, TextColor3=Color3.fromRGB(150,150,150), TextXAlignment=0})
            AddThemeObject(TabBtn, "TextColor3", "Text")
            local Indicator = CreateInstance("Frame", {Parent=TabBtn, BackgroundColor3=UIConfig.AccentColor, Size=UDim2.new(0,2,0,16), Position=UDim2.new(0,0,0.5,-8), Transparency=1}); AddThemeObject(Indicator, "BackgroundColor3", "Accent")
            
            local Page = CreateInstance("ScrollingFrame", {Parent=PageHolder, Size=UDim2.new(1,0,1,0), Visible=false, BackgroundTransparency=1, ScrollBarThickness=2, ScrollBarImageColor3=UIConfig.AccentColor, AutomaticCanvasSize=Enum.AutomaticSize.Y, CanvasSize=UDim2.new(0,0,0,0)}); AddThemeObject(Page, "ScrollBarImageColor3", "Accent")
            CreateInstance("UIListLayout", {Parent=Page, SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,6)}); CreateInstance("UIPadding", {Parent=Page, PaddingTop=UDim.new(0,2), PaddingBottom=UDim.new(0,10), PaddingRight=UDim.new(0,5), PaddingLeft=UDim.new(0,5)})
            
            TabBtn.MouseButton1Click:Connect(function()
                for _,v in pairs(PageHolder:GetChildren()) do v.Visible = false end; for _,v in pairs(TabHolder:GetChildren()) do if v:IsA("TextButton") then TweenService:Create(v,TweenInfo.new(0.2),{TextColor3=Color3.fromRGB(150,150,150)}):Play(); TweenService:Create(v.Frame,TweenInfo.new(0.2),{Transparency=1}):Play() end end
                Page.Visible=true; TweenService:Create(TabBtn,TweenInfo.new(0.2),{TextColor3=UIConfig.TextColor}):Play(); TweenService:Create(Indicator,TweenInfo.new(0.2),{Transparency=0}):Play()
            end)
            if First then TabBtn.TextColor3=UIConfig.TextColor; Indicator.Transparency=0; Page.Visible=true; First=false end

            local ContainerFuncs = {}

            -- // ELEMENTS GENERATOR //
            local function GetElemTable(Container) 
                local Elems = {}
                
                function Elems:CreateSection(Txt)
                    local SectionFrame = CreateInstance("Frame", {Parent=Container, BackgroundColor3=UIConfig.SectionColor, Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y, BackgroundTransparency=0.5}); CreateInstance("UICorner", {Parent=SectionFrame, CornerRadius=UDim.new(0,6)}); AddThemeObject(SectionFrame, "BackgroundColor3", "Section")
                    local SecStroke = CreateInstance("UIStroke", {Parent=SectionFrame, Color=UIConfig.StrokeColor, Thickness=1, Transparency=0.8}); AddThemeObject(SecStroke, "Color", "Stroke")
                    
                    local SecTitle = CreateInstance("TextLabel", {Parent=SectionFrame, Text="  "..Txt, Size=UDim2.new(1,0,0,24), BackgroundTransparency=1, TextXAlignment=0, TextColor3=UIConfig.AccentColor, Font=Enum.Font.GothamBold, TextSize=12});
                    AddThemeObject(SecTitle, "TextColor3", "Accent") -- CORREÇÃO APLICADA AQUI
                    
                    local Content = CreateInstance("Frame", {Parent=SectionFrame, BackgroundTransparency=1, Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y, Position=UDim2.new(0,0,0,26)}); CreateInstance("UIListLayout", {Parent=Content, SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,6)}); CreateInstance("UIPadding", {Parent=Content, PaddingBottom=UDim.new(0,6), PaddingLeft=UDim.new(0,6), PaddingRight=UDim.new(0,6)})
                    return GetElemTable(Content)
                end

                function Elems:CreateLabel(Txt)
                    local Lbl = CreateInstance("Frame", {Parent=Container, BackgroundTransparency=1, Size=UDim2.new(1,0,0,20)}); Lbl:SetAttribute("IsElement", true)
                    local T = CreateInstance("TextLabel", {Parent=Lbl, Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text=Txt, TextXAlignment=0, Font=Enum.Font.GothamBold, TextColor3=UIConfig.AccentColor, TextSize=13}); AddThemeObject(T, "TextColor3", "Accent")
                    return {SetTooltip=function(self,v) AddTooltip(Lbl,v) end}
                end

                function Elems:CreateButton(Txt, Callback)
                    local Btn = CreateInstance("TextButton", {Parent=Container, BackgroundColor3=UIConfig.SecondaryColor, Size=UDim2.new(1,0,0,32), Text="", AutoButtonColor=false, BackgroundTransparency=0.1}); Btn:SetAttribute("IsElement", true)
                    CreateInstance("UICorner", {Parent=Btn, CornerRadius=UDim.new(0,6)}); CreateInstance("UIStroke", {Parent=Btn, Color=UIConfig.StrokeColor, Thickness=1})
                    AddThemeObject(Btn, "BackgroundColor3", "Secondary")
                    CreateInstance("TextLabel", {Parent=Btn, BackgroundTransparency=1, Text=Txt, Size=UDim2.new(1,-10,1,0), Position=UDim2.new(0,10,0,0), TextXAlignment=0, Font=UIConfig.Font, TextColor3=UIConfig.TextColor, TextSize=13})
                    CreateInstance("ImageLabel", {Parent=Btn, BackgroundTransparency=1, Position=UDim2.new(1,-25,0.5,-9), Size=UDim2.new(0,18,0,18), Image="rbxassetid://6031068390", ImageColor3=Color3.new(0.8,0.8,0.8)})
                    Btn.MouseEnter:Connect(function() TweenService:Create(Btn,TweenInfo.new(0.2),{BackgroundColor3=UIConfig.HoverColor}):Play() end)
                    Btn.MouseLeave:Connect(function() TweenService:Create(Btn,TweenInfo.new(0.2),{BackgroundColor3=UIConfig.SecondaryColor}):Play() end)
                    Btn.MouseButton1Click:Connect(function() pcall(Callback) end)
                    
                    local Funcs = {}
                    function Funcs:SetTooltip(t) AddTooltip(Btn, t) end
                    return Funcs
                end

                function Elems:CreateToggle(Txt, Callback, Default)
                    local Flag = Txt
                    local State = Default or false
                    Lib.Flags[Flag] = State
                    
                    local Hooks = {OnEnable=nil, OnDisable=nil}
                    
                    local Btn = CreateInstance("TextButton", {Parent=Container, BackgroundColor3=UIConfig.SecondaryColor, Size=UDim2.new(1,0,0,32), Text="", AutoButtonColor=false, BackgroundTransparency=0.1}); Btn:SetAttribute("IsElement", true)
                    CreateInstance("UICorner", {Parent=Btn, CornerRadius=UDim.new(0,6)}); CreateInstance("UIStroke", {Parent=Btn, Color=UIConfig.StrokeColor, Thickness=1})
                    AddThemeObject(Btn, "BackgroundColor3", "Secondary")
                    CreateInstance("TextLabel", {Parent=Btn, BackgroundTransparency=1, Text=Txt, Size=UDim2.new(1,-50,1,0), Position=UDim2.new(0,10,0,0), TextXAlignment=0, Font=UIConfig.Font, TextColor3=UIConfig.TextColor, TextSize=13})
                    
                    local CheckBG = CreateInstance("Frame", {Parent=Btn, BackgroundColor3=(State and UIConfig.AccentColor or Color3.fromRGB(50,50,50)), Size=UDim2.new(0,36,0,18), Position=UDim2.new(1,-46,0.5,-9)}); CreateInstance("UICorner", {Parent=CheckBG, CornerRadius=UDim.new(1,0)})
                    local Dot = CreateInstance("Frame", {Parent=CheckBG, BackgroundColor3=Color3.new(1,1,1), Size=UDim2.new(0,14,0,14), Position=(State and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7))}); CreateInstance("UICorner", {Parent=Dot, CornerRadius=UDim.new(1,0)})
                    
                    local function UpdateVisuals()
                        TweenService:Create(Dot, TweenInfo.new(0.2), {Position = (State and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7))}):Play()
                        TweenService:Create(CheckBG, TweenInfo.new(0.2), {BackgroundColor3 = (State and UIConfig.AccentColor or Color3.fromRGB(50,50,50))}):Play()
                    end

                    local function Trigger(NewState, SkipCallback)
                        State = NewState
                        Lib.Flags[Flag] = State
                        UpdateVisuals()
                        if not SkipCallback then
                            if State and Hooks.OnEnable then pcall(Hooks.OnEnable) 
                            elseif not State and Hooks.OnDisable then pcall(Hooks.OnDisable) end
                            pcall(Callback, State)
                        end
                    end
                    
                    Btn.MouseEnter:Connect(function() TweenService:Create(Btn,TweenInfo.new(0.2),{BackgroundColor3=UIConfig.HoverColor}):Play() end)
                    Btn.MouseLeave:Connect(function() TweenService:Create(Btn,TweenInfo.new(0.2),{BackgroundColor3=UIConfig.SecondaryColor}):Play() end)
                    Btn.MouseButton1Click:Connect(function() Trigger(not State) end)
                    
                    -- Object API
                    local Obj = {}
                    function Obj:Set(Val) Trigger(Val, true) end
                    function Obj:SetTooltip(t) AddTooltip(Btn, t) end
                    function Obj:OnEnable(func) Hooks.OnEnable = func end
                    function Obj:OnDisable(func) Hooks.OnDisable = func end
                    
                    Lib.Options[Flag] = Obj
                    return Obj
                end
                
                function Elems:CreateSlider(Txt, Min, Max, Default, Callback)
                    local Flag = Txt
                    local Value = Default or Min
                    Lib.Flags[Flag] = Value
                    
                    local Sld = CreateInstance("Frame", {Parent=Container, BackgroundColor3=UIConfig.SecondaryColor, Size=UDim2.new(1,0,0,45), BackgroundTransparency=0.1}); Sld:SetAttribute("IsElement", true)
                    AddThemeObject(Sld, "BackgroundColor3", "Secondary")
                    CreateInstance("UICorner", {Parent=Sld, CornerRadius=UDim.new(0,6)}); CreateInstance("UIStroke", {Parent=Sld, Color=UIConfig.StrokeColor, Thickness=1})
                    CreateInstance("TextLabel", {Parent=Sld, BackgroundTransparency=1, Text=Txt, Size=UDim2.new(0.7,0,0,20), Position=UDim2.new(0,10,0,4), TextXAlignment=0, Font=UIConfig.Font, TextColor3=UIConfig.TextColor, TextSize=13})
                    local ValLbl = CreateInstance("TextLabel", {Parent=Sld, BackgroundTransparency=1, Text=tostring(Value), Size=UDim2.new(0.3,-15,0,20), Position=UDim2.new(0.7,0,0,4), TextXAlignment=1, Font=UIConfig.Font, TextColor3=Color3.new(0.8,0.8,0.8), TextSize=12})
                    
                    local BarBG = CreateInstance("Frame", {Parent=Sld, BackgroundColor3=Color3.fromRGB(50,50,50), Size=UDim2.new(1,-20,0,4), Position=UDim2.new(0,10,0,30)}); CreateInstance("UICorner", {Parent=BarBG, CornerRadius=UDim.new(1,0)})
                    local Fill = CreateInstance("Frame", {Parent=BarBG, BackgroundColor3=UIConfig.AccentColor, Size=UDim2.new((Value-Min)/(Max-Min),0,1,0)}); CreateInstance("UICorner", {Parent=Fill, CornerRadius=UDim.new(1,0)}); AddThemeObject(Fill, "BackgroundColor3", "Accent")
                    local Trigger = CreateInstance("TextButton", {Parent=BarBG, BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), Text=""})
                    
                    local function Update(InputVal, SkipCallback)
                        local Clamp = math.clamp(InputVal, Min, Max)
                        Value = Clamp
                        Lib.Flags[Flag] = Value
                        ValLbl.Text = tostring(math.floor(Value*10)/10)
                        TweenService:Create(Fill, TweenInfo.new(0.1), {Size = UDim2.new((Value-Min)/(Max-Min),0,1,0)}):Play()
                        if not SkipCallback then pcall(Callback, Value) end
                    end
                    
                    local Dragging = false
                    Trigger.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then Dragging=true end end)
                    UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then Dragging=false end end)
                    UserInputService.InputChanged:Connect(function(i)
                        if Dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
                            local SizeX = BarBG.AbsoluteSize.X
                            local PosX = BarBG.AbsolutePosition.X
                            local Ratio = math.clamp((i.Position.X - PosX)/SizeX, 0, 1)
                            Update(Min + ((Max-Min)*Ratio))
                        end
                    end)
                    
                    local Obj = {}
                    function Obj:Set(Val) Update(Val, true) end
                    function Obj:SetTooltip(t) AddTooltip(Sld, t) end
                    Lib.Options[Flag] = Obj
                    return Obj
                end

                function Elems:CreateDropdown(Txt, Options, Callback)
                    local Flag = Txt
                    local Expanded, H_Collapsed, H_Option = false, 34, 26
                    
                    local Drop = CreateInstance("Frame", {Parent=Container, BackgroundColor3=UIConfig.SecondaryColor, Size=UDim2.new(1,0,0,34), ClipsDescendants=true, BackgroundTransparency=0.1}); Drop:SetAttribute("IsElement", true)
                    AddThemeObject(Drop, "BackgroundColor3", "Secondary")
                    CreateInstance("UICorner", {Parent=Drop, CornerRadius=UDim.new(0,6)}); CreateInstance("UIStroke", {Parent=Drop, Color=UIConfig.StrokeColor, Thickness=1})
                    
                    local HeadBtn = CreateInstance("TextButton", {Parent=Drop, BackgroundTransparency=1, Size=UDim2.new(1,0,0,34), Text=""})
                    local TitleLbl = CreateInstance("TextLabel", {Parent=HeadBtn, BackgroundTransparency=1, Text=Txt.."...", Size=UDim2.new(1,-40,1,0), Position=UDim2.new(0,10,0,0), TextXAlignment=0, Font=UIConfig.Font, TextColor3=UIConfig.TextColor, TextSize=13})
                    local Arrow = CreateInstance("ImageLabel", {Parent=HeadBtn, BackgroundTransparency=1, Image="rbxassetid://6031091004", Size=UDim2.new(0,20,0,20), Position=UDim2.new(1,-30,0.5,-10), ImageColor3=Color3.new(0.7,0.7,0.7)})
                    local List = CreateInstance("Frame", {Parent=Drop, BackgroundTransparency=1, Size=UDim2.new(1,0,0,0), Position=UDim2.new(0,0,0,34)}); CreateInstance("UIListLayout", {Parent=List, SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,2)})
                    
                    local function Refresh(Selection, SkipCallback)
                        TitleLbl.Text = Txt .. ": " .. Selection
                        Lib.Flags[Flag] = Selection
                        if not SkipCallback then pcall(Callback, Selection) end
                        Expanded = false
                        TweenService:Create(Drop, TweenInfo.new(0.2), {Size=UDim2.new(1,0,0,34)}):Play()
                        TweenService:Create(Arrow, TweenInfo.new(0.2), {Rotation=0}):Play()
                    end
                    
                    for _, Opt in pairs(Options) do
                        local OptBtn = CreateInstance("TextButton", {Parent=List, BackgroundColor3=Color3.fromRGB(40,40,40), Size=UDim2.new(1,-10,0,26), Text=Opt, Font=UIConfig.Font, TextSize=12, TextColor3=Color3.new(0.9,0.9,0.9), BackgroundTransparency=0.2}); CreateInstance("UICorner", {Parent=OptBtn, CornerRadius=UDim.new(0,4)})
                        OptBtn.MouseButton1Click:Connect(function() Refresh(Opt) end)
                    end
                    
                    HeadBtn.MouseButton1Click:Connect(function()
                        Expanded = not Expanded
                        local TotalH = (#Options * 28) + 40
                        TweenService:Create(Drop, TweenInfo.new(0.2), {Size=UDim2.new(1,0,0, Expanded and TotalH or 34)}):Play()
                        TweenService:Create(Arrow, TweenInfo.new(0.2), {Rotation=Expanded and 180 or 0}):Play()
                    end)
                    
                    local Obj = {}
                    function Obj:Set(Val) Refresh(Val, true) end
                    function Obj:SetTooltip(t) AddTooltip(Drop, t) end
                    Lib.Options[Flag] = Obj
                    return Obj
                end

                function Elems:CreateColorPicker(Txt, Default, Callback)
                    local Flag = Txt
                    local Col = Default or Color3.fromRGB(255,255,255)
                    Lib.Flags[Flag] = {R=Col.R, G=Col.G, B=Col.B}
                    
                    local Exp, H_Min, H_Max = false, 34, 140
                    local MainF = CreateInstance("Frame", {Parent=Container, BackgroundColor3=UIConfig.SecondaryColor, Size=UDim2.new(1,0,0,H_Min), ClipsDescendants=true, BackgroundTransparency=0.1}); MainF:SetAttribute("IsElement", true)
                    AddThemeObject(MainF, "BackgroundColor3", "Secondary")
                    CreateInstance("UICorner", {Parent=MainF, CornerRadius=UDim.new(0,6)}); CreateInstance("UIStroke", {Parent=MainF, Color=UIConfig.StrokeColor, Thickness=1})
                    
                    local Header = CreateInstance("TextButton", {Parent=MainF, BackgroundTransparency=1, Size=UDim2.new(1,0,0,H_Min), Text=""})
                    CreateInstance("TextLabel", {Parent=Header, BackgroundTransparency=1, Text=Txt, Size=UDim2.new(1,-70,1,0), Position=UDim2.new(0,10,0,0), TextXAlignment=0, Font=UIConfig.Font, TextColor3=UIConfig.TextColor, TextSize=13})
                    local Preview = CreateInstance("Frame", {Parent=Header, BackgroundColor3=Col, Size=UDim2.new(0,35,0,20), Position=UDim2.new(1,-45,0.5,-10)}); CreateInstance("UICorner", {Parent=Preview, CornerRadius=UDim.new(0,4)})
                    
                    local Sliders = CreateInstance("Frame", {Parent=MainF, BackgroundTransparency=1, Size=UDim2.new(1,0,0,H_Max-H_Min), Position=UDim2.new(0,0,0,H_Min)})
                    local R, G, B = math.floor(Col.R*255), math.floor(Col.G*255), math.floor(Col.B*255)
                    
                    local function Update(SkipCallback)
                        local C = Color3.fromRGB(R,G,B)
                        Preview.BackgroundColor3 = C
                        Lib.Flags[Flag] = {R=C.R, G=C.G, B=C.B}
                        if not SkipCallback then pcall(Callback, C) end
                    end
                    
                    local function MakeSlider(Axis, C, Max, Y)
                        local Lb = CreateInstance("TextLabel", {Parent=Sliders, BackgroundTransparency=1, Text=Axis, TextColor3=C, Position=UDim2.new(0,10,0,Y), Font=Enum.Font.GothamBold, TextSize=12, Size=UDim2.new(0,20,0,20)})
                        local Bg = CreateInstance("Frame", {Parent=Sliders, BackgroundColor3=Color3.fromRGB(45,45,45), Position=UDim2.new(0,35,0,Y+8), Size=UDim2.new(1,-70,0,4)}); CreateInstance("UICorner", {Parent=Bg, CornerRadius=UDim.new(1,0)})
                        local Fi = CreateInstance("Frame", {Parent=Bg, BackgroundColor3=C, Size=UDim2.new(Max/255,0,1,0)}); CreateInstance("UICorner", {Parent=Fi, CornerRadius=UDim.new(1,0)})
                        local BT = CreateInstance("TextButton", {Parent=Bg, BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), Text=""})
                        
                        BT.MouseButton1Down:Connect(function()
                            local MouseC = RunService.RenderStepped:Connect(function()
                                local X = math.clamp((UserInputService:GetMouseLocation().X - Bg.AbsolutePosition.X) / Bg.AbsoluteSize.X, 0, 1)
                                local V = math.floor(X * 255)
                                Fi.Size = UDim2.new(X,0,1,0)
                                if Axis=="R" then R=V elseif Axis=="G" then G=V else B=V end
                                Update()
                            end)
                            UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then MouseC:Disconnect() end end)
                        end)
                    end
                    
                    MakeSlider("R", Color3.fromRGB(255,80,80), R, 10)
                    MakeSlider("G", Color3.fromRGB(80,255,80), G, 40)
                    MakeSlider("B", Color3.fromRGB(80,80,255), B, 70)
                    
                    Header.MouseButton1Click:Connect(function() Exp = not Exp; TweenService:Create(MainF, TweenInfo.new(0.2), {Size=UDim2.new(1,0,0, Exp and H_Max or H_Min)}):Play() end)
                    
                    local Obj = {}
                    function Obj:Set(Tbl) if not Tbl then return end; R=math.floor((Tbl.R or 0)*255); G=math.floor((Tbl.G or 0)*255); B=math.floor((Tbl.B or 0)*255); Update(true) end
                    function Obj:SetTooltip(t) AddTooltip(MainF, t) end
                    Lib.Options[Flag] = Obj
                    return Obj
                end

                function Elems:CreateTextBox(Txt, Place, Callback)
                    local BoxFrame = CreateInstance("Frame", {Parent=Container, BackgroundColor3=UIConfig.SecondaryColor, Size=UDim2.new(1,0,0,50), BackgroundTransparency=0.1}); BoxFrame:SetAttribute("IsElement", true)
                    AddThemeObject(BoxFrame, "BackgroundColor3", "Secondary")
                    CreateInstance("UICorner", {Parent=BoxFrame, CornerRadius=UDim.new(0,6)}); CreateInstance("UIStroke", {Parent=BoxFrame, Color=UIConfig.StrokeColor, Thickness=1})
                    CreateInstance("TextLabel", {Parent=BoxFrame, BackgroundTransparency=1, Text=Txt, Size=UDim2.new(1,-10,0,20), Position=UDim2.new(0,10,0,4), TextXAlignment=0, Font=UIConfig.Font, TextColor3=UIConfig.TextColor, TextSize=13})
                    local IBG = CreateInstance("Frame", {Parent=BoxFrame, BackgroundColor3=Color3.fromRGB(25,25,25), Size=UDim2.new(1,-20,0,22), Position=UDim2.new(0,10,0,24)}); CreateInstance("UICorner", {Parent=IBG, CornerRadius=UDim.new(0,4)})
                    local Inp = CreateInstance("TextBox", {Parent=IBG, BackgroundTransparency=1, Size=UDim2.new(1,-8,1,0), Position=UDim2.new(0,4,0,0), Text="", PlaceholderText=Place, TextXAlignment=0, Font=Enum.Font.Gotham, TextSize=12, TextColor3=Color3.new(1,1,1)})
                    Inp.FocusLost:Connect(function() pcall(Callback, Inp.Text) end)
                    
                    local Obj = {}
                    function Obj:SetTooltip(t) AddTooltip(BoxFrame, t) end
                    return Obj
                end
                
                return Elems
            end

            return GetElemTable(Page)
        end
        return Tabs
    end

    return Lib
end)()
