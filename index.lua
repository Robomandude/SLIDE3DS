red = Color.new(255,0,0)
blue = Color.new(0,0,255)
green = Color.new(0,200,0)
white = Color.new(200,200,200)
black = Color.new(0,0,0)
dgray = Color.new(50,50,50)
gray = Color.new(150,150,150)
size = 0
lines={{}}
pad=Controls.read()
tx,ty,ox,oy=0,0,0,0 --Touchscreen x and y and Previous frame tx and ty
oldpad=pad --previous frame pad state

cX=1 cY=1 sX=0 sY=0	--cursor xy and screen xy.  stores where the screen is in the file and where the cursor is on screen
curX=1 curY=1		--where the cursor is in the file.  simply screen+cursor location
dispX=1 dispY=1

function displayChar(x,y,char)
	Screen.debugPrint(x*13+10,y*20-15,char,black,TOP_SCREEN)
	end



function displayTop()
	Screen.fillRect(0,400,0,240,white,TOP_SCREEN)
	for y=1, 12 do
	Screen.debugPrint(3,y*20-15,y,black,TOP_SCREEN)
			if lines[y] then
		for x=1 ,28 do
			if lines[y][x] then
				displayChar(x,y,lines[y+sY][x+sX])
			end end
		end
	end
end

function moveVertical()
	if (cX+sX)>#lines[curY] then
		cX=#lines[curY]-sX		--if the line you move to is shorter, moves cursor to end of line
		if cX<0 then sX=#lines[cY+sY] cX=0 end	--moves screen to keep cursor on screen (if needed)
	end
end

function moveUp()
	if lines[curY-1] then		--cant move cursor to before beggining of file
		if cY==1 then
			sY = sY-1
		else
			cY = cY-1
		end
	else
		cX=0 sX=0		--if its the first line, it moves the cursor to the beginning of it
	end
end

function moveDown()
	if lines[curY+1] then		--cant move cursor past end of file		
		if cY==11 then		--cant move cursor past edge of screen
			sY = sY+1	--moves screen, keeps cursor still
		else
			cY = cY+1	--moves cursor, keeps screen still
		end
	curY=curY+1
	moveVertical()

	return true end			--reports it successfully moved down/wasn't at end of the file

end


function moveRight() --moves the cursor right
	if lines[curY][cX+sX+1] then 		--cant move cursor past end of line
		if cX==28 then 			--cant move cursor past edge of screen
			sX = sX+1 		--if end of screen move screen right and keep cursor still
		else
			cX = cX+1 		--otherwise move cursor right
		end
	else if moveDown() then sX=1 cX=0 end	--if at the end of the line tries to move down.  if successful sets x to beginning of line
	end
end
			

function typeChar(char)
	return function() 
		if #lines[curY]==cX+sX then
		table.insert(lines[curY],char)
		else
		table.insert(lines[curY],cX+sX,char)
		end
		moveRight()
	end
end

function typeEnter()
	table.insert(lines,sY+cY+1,{})
	while lines[sY+cY][sX+cX] do
		table.insert(lines[sY+cY+1],1,table.remove(lines[sY+cY]))
	end
	moveDown()
	sX=1 cX=1
end




function Keyboard()
	


	local keyset --pointer to beggining of character set for lowercase and UPPERCASE for entire keyboard
	local ix,iy --integer x and y, lightly processed coordinate values for faster (cleaner?) code


	if Controls.check(pad,KEY_DDOWN) then
		curY=curY+1 end
	if Controls.check(pad,KEY_DUP) then
		curY=curY-1 end



	
	local keys = {"`1234567890-=",[[qwertyuiop[]\]],"asdfghjkl;'","zxcvbnm,./","~!@#$%^&*()_+",
		"QWERTYUIOP{}|",[[ASDFGHJKL:"]],"ZXCVBNM<>?","TAB SPC","BCK DEL"}

	if Controls.check(pad,KEY_A) then

		keyset=5
	else
		keyset=1
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
	--if inputChar then
	--	Screen.debugPrint(6,40,inputChar,blue,TOP_SCREEN)
	--else
	--	Screen.debugPrint(6,40,"nil",blue,TOP_SCREEN)
	--end
	--Screen.debugPrint(6,100,pad,blue,TOP_SCREEN)
	--Screen.debugPrint(6,80,POC,blue,TOP_SCREEN)
end










while true do
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
