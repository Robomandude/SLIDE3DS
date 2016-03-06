red = Color.new(255,0,0)
blue = Color.new(0,0,255)
green = Color.new(0,200,0)
white = Color.new(230,230,230)
wwhite = Color.new(255,255,255)
black = Color.new(0,0,0)
dgray = Color.new(50,50,50)
gray = Color.new(150,150,150)
size = 0
TABSTOP=8
lines={{}}
SCREEN_WIDTH=30
pad=Controls.read()
pDir=""
tx,ty,ox,oy=0,0,0,0 --Touchscreen x and y and Previous frame tx and ty
oldpad=pad --previous frame pad state

cX=1 cY=1 sX=0 sY=0	--cursor xy and screen xy.  stores where the screen is in the file and where the cursor is on screen

function curX()		--I use screen position + cursor position so often I made functions for it
	return cX+sX		--perhaps these functions are a good idea(?)
end

function curY()
	return cY+sY
end

dispX=1 dispY=1

function typeTab() end
function tabulate() end

function getScrLoc(x,y)
	return x*13,y*20-15
end
function loadText(fileName)
	local fileStream=io.open(fileName,FREAD)
	local file=io.read(fileStream,0,io.size(fileStream))
	for i=1,#file do
		typeChar(string.sub(file,i,i))()
	--		Screen.clear(TOP_SCREEN)
	--Screen.debugPrint(5,20,#file,white,TOP_SCREEN)
	--Screen.debugPrint(5,5,i,white,TOP_SCREEN)
	end
io.close(fileStream)
end

function listMenu(list)
	local c=1
	local s=0
	while true do

	oldpad=pad
	pad=Controls.read()
	
	Screen.waitVblankStart()
	Screen.refresh()
	Screen.flip()
	Screen.fillRect(0,400,0,240,white,TOP_SCREEN)
		for i=1,12 do
			if list[i+s] then
			Screen.debugPrint(20,i*20,list[i+s],black,TOP_SCREEN)
			end
		end
	Screen.debugPrint(1,c*20,"*",black,TOP_SCREEN)
	
	if oldpad ~= pad then
	
		if Controls.check(pad,KEY_DDOWN) and c+s<#list then
			if c==12
				then
					s=s+1
				else
					c=c+1
				end
			
		end
		
		if Controls.check(pad,KEY_DUP) and c+s>1 then
			if c==1 then
				s=s-1
			else
				c=c-1
			end
		end
		
		if Controls.check(pad,KEY_A)

		then
			return list[c+s]
		end
	end

	end
end



function displayTop()
	Screen.fillRect(0,400,0,240,white,TOP_SCREEN)
	if math.random()>.5 then
	Screen.fillRect(cX*13,cX*13-2,cY*20-19,cY*20,dgray,TOP_SCREEN)
	else
	Screen.fillRect(cX*13,cX*13-2,cY*20-19,cY*20,gray,TOP_SCREEN)
 end
	for y=1, 12 do
	
		if lines[y+sY] then
			for x=1 ,SCREEN_WIDTH do
				if lines[y+sY][x+sX] then
					if lines[y+sY][x+sX]=="" and lines[y+sY][x+sX+1]~="" then
						Screen.fillRect(x*13+3,x*13+2,y*20-15,y*20,wwhite,TOP_SCREEN)
					else
						Screen.debugPrint(x*13,y*20-15,lines[y+sY][x+sX],black,TOP_SCREEN)
					end
				end
			end
		end
	end
end

function moveVertical()
	if (curX())>#lines[curY()] then
		cX=#lines[curY()]-sX		--if the line you move to is shorter, moves cursor to end of line
		if cX<1 then sX=#lines[curY()] cX=1 end	--moves screen to keep cursor on screen (if needed)
	end
end

function moveUp()
	if lines[curY()-1] then		--cant move cursor to before beggining of file
		if cY==1 then
			sY = sY-1
		else
			cY = cY-1
		end
	moveVertical()
	return true
	else
		cX=1 sX=0		--if its the first line, it moves the cursor to the beginning of it
	end
end

function moveDown()
	if lines[curY()+1] then		--cant move cursor past end of file		
		if cY==11 then		--cant move cursor past edge of screen
			sY = sY+1	--moves screen, keeps cursor still
		else
			cY = cY+1	--moves cursor, keeps screen still
		end
		moveVertical()

		return true
	end				--reports it successfully moved down/wasn't at end of the file

end

function moveLeft()
	if cX==1 then
		if sX==0 then		--if its at the beggining of the line it moves up and to the end of the line
			if moveUp() then
				if #lines[curY()]>sX+SCREEN_WIDTH then
					cX=SCREEN_WIDTH
					sX=#lines[curY()]-SCREEN_WIDTH
				elseif #lines[curY()]<sX then
					sX=#lines[curY()]
					cX=1
				else cX=#lines[curY()]-sX+1
				end
			end
		else
			sX=sX-1
		end
	else
		cX=cX-1
	end
	


while lines[curY()][curX()]=="" do
	cX=cX-1
end

while cX<1 do
	cX=cX+1
	sX=sX-1
end

end

function moveRight() --moves the cursor right
	if lines[curY()][curX()] then		--cant move cursor past end of line
		cX=cX+1
		while lines[curY()][curX()]=="" do
			cX=cX+1
		end
		while cX>= SCREEN_WIDTH do
			cX=cX-1
			sX=sX+1
		end
	elseif moveDown() then sX=0 cX=1	--if at the end of the line tries to move down.  if successful sets x to beginning of line
	else return
	end
	return true
end

function insertChar(y,x,t)				--I use this function because specifying the end of a table does not work 
						--	well, I have to not specify anything instead
	if #lines[y]==x then
		table.insert(lines[y],t)
	else
		table.insert(lines[y],x,t)
	end
end

function typeChar(char)

	if char=="\t" then
		return typeTab
	end
	if char=="\n" then
		return typeEnter
	end

	return function() 
		insertChar(curY(),curX(),char)
		tabulate(curY(),curX())
		moveRight()
	end
end

function backspace()
	if curX()>1 then
		moveLeft()
		
		repeat
			table.remove(lines[curY()],curX())
		until lines[curY()][curX()]~=""
	elseif curX()==1 and curY()~=1 then
		local _=curY()
		moveLeft()
		for i=1,#lines[_] do
			table.insert(lines[_-1],lines[_][i])
		end
		table.remove(lines,_)
	end
end

function typeDelete()
	if moveRight() then backspace() end 	--delete is just backspace after pressing right -that is, if pressing right did anything
end

function tabulate(y)
	local x=1
	while lines[y][x] do
		if lines[y][x]=="\t" then
			x=x+1
			while x%TABSTOP~=1 do
				if lines[y][x]~="" then
					insertChar(y,x,"")
				end
			x=x+1
			end

			while lines[y][x]=="" do
				table.remove(lines[y],x)
			end
		else
			x=x+1
		end
	end
end

			




function typeTab()
	insertChar(curY(),curX(),"\t")
	tabulate(curY(),curX())
	moveRight()
end


function typeEnter()
	table.insert(lines,curY()+1,{})
	while lines[curY()][curX()] do
		table.insert(lines[curY()+1],table.remove(lines[curY()],curX()))
	end
	moveDown()
	sX=0 cX=1
end


function Keyboard()
	


	local keyset --pointer to beggining of character set for lowercase and UPPERCASE for entire keyboard
	local ix,iy --integer x and y, lightly processed coordinate values for faster (cleaner?) code

	
	local keys = {"`1234567890-=",[[qwertyuiop[]\]],"asdfghjkl;'","zxcvbnm,./  \t","~!@#$%^&*()_+",
		"QWERTYUIOP{}|",[[ASDFGHJKL:"]],"ZXCVBNM<>?  \t","TAB SPC","BCK DEL"}

	if Controls.check(pad,KEY_L) then

		keyset=5
	else
		keyset=1
	end
	if Controls.check(pad,KEY_A) then
	typeEnter()
	end
	if Controls.check(pad,KEY_DUP) then
	moveUp()
	end
	if Controls.check(pad,KEY_DDOWN) then
	moveDown()
	end
	if Controls.check(pad,KEY_DRIGHT) then
	moveRight()
	end
	if Controls.check(pad,KEY_DLEFT) then
	moveLeft()
	end
	if Controls.check(pad,KEY_X) then
	backspace()
	end
	if Controls.check(pad,KEY_Y) then
	typeDelete()
	end

	local inputChar
	if Controls.check(pad,KEY_TOUCH) then
		ix = math.ceil((tx-4)/24)
		iy = math.ceil((ty-4)/30)
	else
		ix = math.ceil((ox-4)/24)
		iy = math.ceil((oy-4)/30)
	end

	if ix>0 and iy>0 then
		if ix<=#keys[iy] then
		inputChar=string.sub(keys[iy+keyset-1],ix,ix)
		end
	end
	
	for y=0,3 do

		for x=1,#keys[y+keyset] do
			local tempC
			if ix==x and y+1==iy then 

				if Controls.check(oldpad,KEY_TOUCH) and not Controls.check(pad,KEY_TOUCH) then 
					tempC = green
					

					typeChar(inputChar)()


					else tempC=blue
				 end 
				
				elseif (y+x%2)%2==0 then tempC=dgray else tempC=gray end
			
			Screen.fillRect(x*24-20,x*24+3,y*30+4,y*30+33,tempC,BOTTOM_SCREEN)

		Screen.debugPrint(x*24-14,y*30+10,string.sub(keys[y+keyset],x,x),white,BOTTOM_SCREEN)

		end
 	end
	ix = math.ceil(tx/24)
	iy = math.ceil(ty/30)
	if ix>0 and iy>0 then
		if ix<=#keys[iy] then
		inputChar=string.sub(keys[iy],ix,ix)
		end
	end
	--Screen.debugPrint(5,150,cX,white,BOTTOM_SCREEN)
	Screen.debugPrint(5,170,cY,white,BOTTOM_SCREEN)
	Screen.debugPrint(5,200,sX,white,BOTTOM_SCREEN)
	Screen.debugPrint(5,220,sY,white,BOTTOM_SCREEN)
	Screen.debugPrint(5,150,string.format("Line: %i",curY()),white,BOTTOM_SCREEN)
	--if inputChar then
	--	Screen.debugPrint(6,40,inputChar,blue,TOP_SCREEN)
	--else
	--	Screen.debugPrint(6,40,"nil",blue,TOP_SCREEN)
	--end
	--Screen.debugPrint(6,100,pad,blue,TOP_SCREEN)
	--Screen.debugPrint(6,80,POC,blue,TOP_SCREEN)
end


loadText("/document.txt")
	while true do
	

		if Controls.check(pad,KEY_START)
		then
			local menuDo =listMenu({"Save","Quit","Resume"})
			if menuDo==Quit then return "Quit" end
			mainMenu[menuDo]()
			
		end

		Screen.waitVblankStart()
		Screen.refresh()
		oldpad=pad
		pad = Controls.read()
		Screen.clear(BOTTOM_SCREEN)
		Screen.clear(TOP_SCREEN)
		ox,oy=tx,ty
		tx,ty=Controls.readTouch()
		--Screen.fillRect(5,395,5,235,green,TOP_SCREEN)
		displayTop()
		Keyboard()
			--Screen.debugPrint(6,6,tx,blue,TOP_SCREEN)
			--Screen.debugPrint(6,20,ty,blue,TOP_SCREEN)
			Screen.flip()
		if Controls.check(pad,KEY_B) then crash() end --faster restarting in citra
	end
