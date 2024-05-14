local obj = {}
obj._VERSION = "0.01"

local mt = {__index = obj}

local menuBarItem
if not menuBarItem then menuBarItem = hs.menubar.new() end

local unreadMailCount
local allMailCount
local mailDigest
local getMailContent
local getRecentMailList

local threadId

local mailQueryStr = "tag:work "

local repeatTimer

getRecentMailList = function()
  local cmd = [[ notmuch search --format='json' --sort='newest-first' ]] .. "'" .. mailQueryStr ..
                " and thread:{date:360mins..}" .. "'"
  -- logger:d("cmd: ", cmd)
  local output, status, type, rc = hs.execute(cmd, true)
  if output then output = string.gsub(output, "[%s\n\r]+", "") end
  if status and output then
    -- logger:d("get recent unread mail info status:", status, ", output: ", output, ", type: ", type, ", rc: ", rc)
    local mails = hs.json.decode(output)
    if mails and #mails > 0 then return mails end
  end
end

getMailContent = function(searchMail)
  local query
  if not searchMail or #searchMail.query == 0 then return end

  for _, q in ipairs(searchMail.query) do
    if not query then
      query = q
    else
      query = query .. ' and ' .. q
    end
  end

  local cmd = [[notmuch show --format='json' ']] .. (query or '') .. "'"
  -- logger:d("cmd: " .. cmd)
  local output, status, type, rc = hs.execute(cmd, true)
  if not status or not output then return end

  output = string.gsub(output, "[%s\n\r]+", "")
  -- logger:d("get mail content output:" .. (output or ''))
  local mails = hs.json.decode(output)
  if mails and #mails > 0 then
    local subMails = mails[1]
    if subMails and #subMails > 0 then
      local subSubMails = subMails[1]
      if subSubMails and #subSubMails > 0 then
        local content = subSubMails[1]
        if content and #content.id > 0 then
          -- logger:d("content:" .. hs.json.encode(content))
          return content
        end
        -- if content and content.id == id then
        -- end
      end
    end
  end
end

function textToImage(input, color)
  if type(input) == "number" then input = utf8.char(input) end
  local styledInput = hs.styledtext
                        .new(input, {font = {name = "SF Pro", size = 100}, color = color})
  local canvas = hs.canvas.new({x = 0, y = 0, h = 0, w = 0})
  canvas:size(canvas:minimumTextSize(styledInput)):appendElements({
    type = "text",
    text = styledInput
  })
  return canvas:imageFromCanvas()
end

local function notmuchNotify(newMailCount)
  newMailCount = newMailCount or 0
  -- if newUnreadMailCount and oldUnreadMailCount then
  --     local newMailCount = newUnreadMailCount - oldUnreadMailCount
  if newMailCount > 0 then
    -- get recent mail or notify
    local mails = getRecentMailList()

    local maxThreadId = 0
    local info = "\n"
    if mails then
      for i = 1, newMailCount do
        local mail = mails[i]
        if mail and mail.thread then
          local mailThreadId = tonumber(mail.thread, 16)
          if not threadId or threadId < mailThreadId then
            maxThreadId = mailThreadId
          else
            logger:d("break forloop, threadId", threadId, ", maxThreadId: ", maxThreadId,
                     ", mailThreadId: ", mailThreadId)
            break
          end
        end

        if i > 5 then break end

        if mail then
          local digest = mailDigest(mail)
          local mailInfo = tostring(i) .. ". " .. (mail.subject or "") .. (digest or '') .. " - " ..
                             (mail.date_relative or "")
          info = info .. "\n" .. mailInfo
        end
      end
    end

    if maxThreadId and maxThreadId > 0 then threadId = maxThreadId end

    local notifyAttr = {
      alwaysPresent = true,
      setIdImage = textToImage(0x10020E),
      title = "Notmuch new mail notifications",
      subTitle = string.format("Received %d new mails since last refresh.", newMailCount),
      informativeText = info,
      withdrawAfter = 0
    }

    local notify = hs.notify.new(nil, notifyAttr)
    notify:alwaysPresent(true):autoWithdraw(false):send()
  end
end

mailDigest = function(mail)
  if not mail then return end

  local fullMail = getMailContent(mail)
  -- logger:d("fullMail is: " .. (fullMail or 'nil'))
  if not fullMail then return end

  local body = fullMail.body
  if not body then return end

  for _, item in ipairs(body) do
    local content = item.content
    if content then
      if type(content) == 'string' then
        -- logger:d("content is: " .. hs.json.encode(content or {}))
        -- else
        local regexpText = [[[成功率为|平均耗时|触发阈值：] ?([?0-9\.%%]+)]]
        local slashed_text = string.match(content, regexpText)
        if slashed_text then return string.format(" %s ", slashed_text) end
      end
    end
  end
end

local function checkUnreadMail(eventName, params)
  -- local search = 'tag:inbox'
  -- local search = 'folder:Work/ and tag:inbox and tag:unread'
  local search = mailQueryStr
  local output, status, _, _ = hs.execute("notmuch count " .. search .. ' ' .. " and tag:unread",
                                          true)
  local focusedStyle = {
    font = hs.styledtext.defaultFonts.menuBar
    -- color = hs.drawing.color.hammerspoon.osx_green,
  }

  if output then output = string.gsub(output, "[%s\n\r]+", "") end
  -- local newUnreadMailCount
  if status and unreadMailCount ~= output then
    unreadMailCount = output
    local displayText = "📮 " .. output
    local title = hs.styledtext.new(displayText, focusedStyle)
    menuBarItem:setTitle(title)
  end

  -- new mail received
  output, status, _, _ = hs.execute("notmuch count " .. search, true)
  if output then
    -- logger:d('output is: ' .. output .. ', diff: ' .. (output - output))
    output = string.gsub(output, "[%s\n\r]+", "")
    if output then
      output = tonumber(output)
    else
      output = 0
    end

    if status and allMailCount ~= output then
      local oldAllMailCount = allMailCount
      if oldAllMailCount ~= output then
        if oldAllMailCount then
          local newMailCount = output - oldAllMailCount
          if newMailCount > 0 then
            allMailCount = output
            notmuchNotify(newMailCount)
          end
        else
          allMailCount = output
        end
      end
    end
  end

  -- logger:d('get mail count status:', status, ', output: ', output)
end

function obj:start()
  checkUnreadMail()
  -- repeatTimer = hs.timer.doEvery(5, checkUnreadMail)
  hs.urlevent.bind("checkUnreadMail", checkUnreadMail)
end

return obj
