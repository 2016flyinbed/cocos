-----------------------------------------------------------------------------------------------  
-- @description 节点系统 
-- @author  liuyao
-- @release  2015/09/24
--------------------------------------------------------------------------------------------
local M = class(..., import("..System"))
local NodeCom = import(".coms.NodeCom")

M._firstType = NodeCom.__cname

function M:ctor(param)

end


return M