local obj = {}
obj._VERSION = '0.01'

local mt = {__index = obj}

-- local server_url = 'http://localhost:8082/'

local function string_split(str, delimiter)
    local result = {}
    local from = 1
    local delim_from, delim_to = string.find(str, delimiter, from)
    while delim_from do
        table.insert(result, string.sub(str, from, delim_from - 1))
        from = delim_to + 1
        delim_from, delim_to = string.find(str, delimiter, from)
    end
    table.insert(result, string.sub(str, from))
    return result
end

local function urlEvent(eventName, params)
    logger:d('url event: ', eventName, hs.json.encode(params))
    local action_type = params.type
    local action_data = params.data
    if not action_type or not action_data then
        logger:e('action_type or action_data is nil')
        hs.pasteboard.clearContents()
        return
    end

    if action_type == 'trans_full_refund_wx' then
        local arr = string_split(action_data, ',')
        if not arr or #arr < 11 then
            hs.alert.show('交易格式错误')
            hs.pasteboard.clearContents()
            return
        end

        local trans_status = arr[8]
        local trans_type = arr[5]
        if (trans_status ~= '已全额退款' and trans_status ~=
            '已转入退款' and not string.find(trans_status, '已退款')) or
            trans_type ~= '支出' then
            hs.alert.show('非全额退款类别' .. (trans_status or ''))
            hs.pasteboard.clearContents()
            return
        end

        if string.find(arr[2], '商户消费') then
            arr[2] = arr[3] .. '-' .. '退款'
        else
            arr[2] = arr[2] .. '-' .. '退款'
        end

        arr[5] = '收入'

        if trans_status == '已转入退款' and string.find(arr[10], '/') then
            arr[10] = arr[9]
        else
            arr[9] = arr[10]
        end

        -- 已退款(￥23.24)
        if string.find(trans_status, '已退款') and
            string.find(trans_status, '￥') then
            -- "*(\\(￥[\\d\\.]+\\))*"
            -- local res = string.gsub(trans_status, "(￥[\\d\\.]+)", "%1")
            local res = string.match(trans_status, "￥([%d\\.]+)")
            -- 已退款(￥23.24)
            if res then
                logger:e('res: ', res)
                arr[6] = '¥' .. res
            end
        end

        local res_str = table.concat(arr, ',')
        logger:e('res_str: ', res_str)
        hs.pasteboard.setContents(res_str .. '\n' .. action_data .. '\n')
        hs.alert.show('转换成功，已复制至剪切板！')
    else
        hs.pasteboard.clearContents()
        hs.alert.show('非法操作类别：' .. (action_type or ''))
    end

    -- local data = 'type=' .. params.type .. '&' .. 'data=' ..
    --                  hs.http.encodeForQuery(params.data)
    -- local status, res, h = hs.http.post(server_url .. 'assist', data, nil)
    -- if status == 200 and h then
    --     local code = h['Code']
    --     logger:d('res is: ', res)
    --     if code == '100' then
    --         -- local res_tbl = hs.json.decode(res)
    --         -- if res_tbl then
    --         --     local clip_text
    --         --     if res_tbl.code == 100 then
    --         -- clip_text = res_tbl.data and res_tbl.data.result
    --         if res then
    --             res = (string.gsub(res, "^%s*(.-)%s*$", "%1"))
    --         end

    --         hs.pasteboard.setContents(res)
    --         hs.alert.show('解密成功，已复制至剪切板！')
    --         -- end
    --         -- end
    --     else
    --         hs.alert.show('解密失败：' .. res)
    --     end
    -- else
    --     hs.alert.show('解密失败，status: ' .. tostring(status))
    -- end
end

function obj:start() hs.urlevent.bind('ConvertTransRefundRecord', urlEvent) end

return obj
