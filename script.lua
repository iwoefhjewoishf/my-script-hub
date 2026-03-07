-- GUI
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local Button = Instance.new("TextButton")

ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

Frame.Parent = ScreenGui
Frame.Size = UDim2.new(0,300,0,200)
Frame.Position = UDim2.new(0.4,0,0.3,0)
Frame.BackgroundColor3 = Color3.fromRGB(40,40,40)
Frame.Active = true
Frame.Draggable = true

Button.Parent = Frame
Button.Size = UDim2.new(0,200,0,50)
Button.Position = UDim2.new(0.15,0,0.35,0)
Button.Text = "Speed"

Button.MouseButton1Click:Connect(function()
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 50
end)
