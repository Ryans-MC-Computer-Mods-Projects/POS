local function limit(str,len)
  return str:sub(1,len)
end

local function split(self, delimiter)
	local result = { }
	local from  = 1
	local delim_from, delim_to = string.find( self, delimiter, from  )
	while delim_from do
	  table.insert( result, string.sub( self, from , delim_from-1 ) )
	  from  = delim_to + 1
	  delim_from, delim_to = string.find( self, delimiter, from  )
	end
	table.insert( result, string.sub( self, from  ) )
	return result
end
  

local function drawBox(Sx, Sy, Ex, Ey, col)
	for i = Sy, Ey do
		term.setCursorPos(Sx, i)
		term.blit((" "):rep(Ex - Sx + 1), ("f"):rep(Ex - Sx + 1), colours.toBlit(col):rep(Ex - Sx + 1))
	end
end

local function draw(type, item, Bx, By, Sx, Sy, AIF, name)
	if type == "box" then
		local Box = Bx + (item.pos.x * Sx) + item.pos.Ox
		local Boy = By + (item.pos.y * Sy) + item.pos.Oy
		local BSx = Bx + math.ceil(item.size.x * Sx) + item.size.Ox - 1
		local BSy = By + math.ceil(item.size.y * Sy) + item.size.Oy - 1
		drawBox(Box, Boy, Box + BSx - 1, Boy + BSy - 1, item.col)
		return Box, Boy, BSx, BSy
	elseif type == "blitBox" or type == "blitButton" then
		local Box, Boy, BSx, BSy = draw("box", item, Bx, By, Sx, Sy)
		local textTable = split(item.text, "\10")
		if item.replaceChar then
			for i, v in pairs(textTable) do
				textTable[i] = (item.replaceChar):rep(#v)
			end
		end
		local bgTable = split(item.bgCol, "\10")
		local fgTable = split(item.fgCol, "\10")
		for i, v in pairs(textTable) do
			if #v > BSx then
				table.insert(textTable,  i + 1, v:sub(BSx + 1))
				textTable[i] = v:sub(1, BSx)
			end
		end
		for i, v in pairs(bgTable) do
			if #v > BSx then
				table.insert(bgTable,  i + 1, v:sub(BSx + 1))
				bgTable[i] = v:sub(1, BSx)
			end
		end
		for i, v in pairs(fgTable) do
			if #v > BSx then
				table.insert(fgTable,  i + 1, v:sub(BSx + 1))
				fgTable[i] = v:sub(1, BSx)
			end
		end
		local numLines = math.min(BSy, #textTable)
		local start = 1 + math.floor((BSy - numLines) / 2)
		if item.Ay == "T" then
			start = 1
		elseif item.Ay == "B" then
			start = BSy - numLines
		end 
		local acp = item.cp or 0
		if acp > BSx * BSy then acp = BSx * BSy end
		acp = acp - 1
		local Cx = Box + (acp % BSx)
		local Cy = Boy + math.floor(acp / BSx)
		for i = start, start + numLines - 1  do
			local v = textTable[i - (start - 1)]
			if item.Ax == "L" then
				term.setCursorPos(Box, Boy + i - 1)
			elseif item.Ax == "R" then
				term.setCursorPos((Box + BSx) - #v, Boy + i - 1)
			else
				term.setCursorPos(Box + math.floor((BSx - #v) / 2), Boy + i - 1)
			end
			term.blit(v, fgTable[i - (start - 1)], bgTable[i - (start - 1)])
		end
		return Box, Boy, BSx, BSy, Cx, Cy
	elseif type == "textBox" or type == "textButton" or type == "textField" then
		local textTable = split(item.text, "\10")
		item.bgCol = ""
		item.fgCol = ""
		for i, v in pairs(textTable) do
			item.bgCol = item.bgCol..colours.toBlit(item.col):rep(#v).."\10"
			item.fgCol = item.fgCol..colours.toBlit(item.textCol):rep(#v).."\10"
		end
		local Box, Boy, BSx, BSy, Cx, Cy = draw("blitBox", item, Bx, By, Sx, Sy)
		if AIF == name then
			if Cx > Box + BSx - 1 then
				--error(Cy.." "..Boy + BSy - 1)
				if Cy == math.floor(Boy + BSy - 1) then
					Cx = Cx - 1
				else
					Cx = Box
					Cy = Cy + 1
				end
			end
			return true, Cx, Cy
		end
	end
end

local function makeUI(UI)
	local UITab = {}
	UITab.UI = UI
	UITab.ActiveInputFeild = nil
	UITab.draw = function(Bx, By, Sx, Sy)
		drawBox(Bx, By, Bx + Sx - 1, By + Sy - 1, UITab.UI.BGC)
		local Cx, Cy = 0, 0
		for i, v in pairs(UITab.UI) do
			if i ~= "BGC" then 
				local isCursor, CxQ, CyQ = draw(v.t, v, Bx, By, Sx, Sy, UITab.ActiveInputFeild, i) 
				if isCursor == true then
					Cx = CxQ
					Cy = CyQ
				end
			end
		end
		return Cx, Cy
	end
	UITab.update = function(Bx, By, Sx, Sy, e)
		for i, v in pairs(UITab.UI) do
			if i ~= "BGC" then
				if e[1] == "mouse_click" then
					if v.t == "textButton" or v.t == "blitButton" then
						local BSx = Bx + (v.pos.x * Sx) + v.pos.Ox - 1
						local BSy = By + (v.pos.y * Sy) + v.pos.Oy - 1
						local BEx = BSx + (Bx + math.ceil(v.size.x * Sx) + v.size.Ox - 1)
						local BEy = BSy + (By + math.ceil(v.size.y * Sy) + v.size.Oy - 1)
						if e[3] > BSx and e[3] <= BEx and e[4] > BSy and e[4] <= BEy then
							v.fun()
						end
					elseif v.t == "textField" then
						local BSx = Bx + (v.pos.x * Sx) + v.pos.Ox - 1
						local BSy = By + (v.pos.y * Sy) + v.pos.Oy - 1
						local BEx = BSx + (Bx + math.ceil(v.size.x * Sx) + v.size.Ox - 1)
						local BEy = BSy + (By + math.ceil(v.size.y * Sy) + v.size.Oy - 1)
						if e[3] > BSx and e[3] <= BEx and e[4] > BSy and e[4] <= BEy then
							UITab.ActiveInputFeild = i
							v.cp = #v.text + 1
						end
					end
				end
			end
		end
		if UITab.ActiveInputFeild then
			local ActiveInputFeild = UITab.ActiveInputFeild
			local cp = UITab.UI[ActiveInputFeild].cp
			local text = UITab.UI[ActiveInputFeild].text 
			if e[1] == "key" then
				if e[2] == keys.backspace and cp > 1 then 
					UITab.UI[ActiveInputFeild].text = text:sub(1, cp - 2)..text:sub(cp)
					UITab.UI[ActiveInputFeild].cp = UITab.UI[ActiveInputFeild].cp - 1
				elseif e[2] == keys.left and cp > 1 then UITab.UI[ActiveInputFeild].cp = cp - 1
				elseif e[2] == keys.right and cp < #text + 1 then UITab.UI[ActiveInputFeild].cp = cp + 1
				elseif e[2] == keys.enter then UITab.UI[ActiveInputFeild].fun(text) UITab.ActiveInputFeild = nil
				end
			elseif e[1] == "char" then
			UITab.UI[ActiveInputFeild].text = text:sub(1, cp - 1)..e[2]..text:sub(cp)
			UITab.UI[ActiveInputFeild].cp = cp + 1
			end
		end
	end
	return UITab
end

return {
  makeUI = makeUI
}