local _, gp = ...

function gp.BuildPanel()
  local panel = CreateFrame("Frame", "GyroPathFrame", UIParent, "BackdropTemplate")
  gp.panel = panel
  panel:SetSize(160, 110)
  panel:SetPoint(GyroPath.ui.point, UIParent, GyroPath.ui.point, GyroPath.ui.x, GyroPath.ui.y)
  panel:SetMovable(true)
  panel:EnableMouse(true)
  panel:RegisterForDrag("LeftButton")
  panel:SetScript("OnDragStart", panel.StartMoving)
  panel:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, _, _, x, y = self:GetPoint()
    GyroPath.ui.point, GyroPath.ui.x, GyroPath.ui.y = point, x, y
  end)

  if panel.SetBackdrop then
    panel:SetBackdrop({
      bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
      edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
      tile = true, tileSize = 16, edgeSize = 16,
      insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
  end

  local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  title:SetPoint("TOP", 0, -8)
  title:SetText("|cff33ff99GyroPath|r")

  local body = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  body:SetPoint("TOPLEFT", 14, -28)
  body:SetJustifyH("LEFT")
  body:SetSpacing(3)
  panel.body = body
end

function gp.RefreshPanel()
  local panel = gp.panel
  if not panel or not panel:IsShown() then return end
  local L = GyroPath.lifetime
  local S = GyroPath.session
  local stats = gp.showSessionStats and S or L

  if gp.isBCC then
    panel.body:SetText(
      string.format("Steps: |cffffffff%s|r\n", gp.steps(stats.onFoot)) ..
      string.format("Mount steps: |cffffffff%s|r\n", gp.steps(stats.mount)) ..
      string.format("Flight paths: |cffffffff%s mi|r\n", gp.miles(stats.taxi)) ..
      string.format("Swam: |cffffffff%s mi|r\n", gp.miles(stats.swim)) ..
      string.format("Flying: |cffffffff%s mi|r\n", gp.miles(stats.flying)) ..
      string.format("Other: |cffffffff%s mi|r", gp.miles(stats.other))
    )
  else
    panel.body:SetText(
        string.format("Steps: |cffffffff%s|r\n", gp.steps(stats.onFoot)) ..
        string.format("Mount steps: |cffffffff%s|r\n", gp.steps(stats.mount)) ..
        string.format("Flight paths: |cffffffff%s mi|r\n", gp.miles(stats.taxi)) ..
        string.format("Swam: |cffffffff%s mi|r\n", gp.miles(stats.swim)) ..
        string.format("Other: |cffffffff%s mi|r", gp.miles(stats.other))
    )
  end
end