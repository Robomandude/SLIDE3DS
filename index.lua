red = Color.new(255,0,0)
blue = Color.new(0,0,255)
green = Color.new(0,200,0)
white = Color.new(255,255,255)
black = Color.new(0,0,0)
dgray = Color.new(50,50,50)
gray = Color.new(150,150,150)
size = 0
lines={{}}
pad=Controls.read()
tx,ty,ox,oy=0,0,0,0 --Touchscreen x and y and Previous frame tx and ty
oldpad=pad --previous frame pad state

curX=1 curY=1
dispX=1 dispY=1
function displayTop()

	for y=1, #lines do
	Screen.debugPrint(15,15,lines[y][x],blue,TOP_SCREEN)
		for x=1 ,#lines[y] do
			--Screen.debugPrint(x*15,y*20,lines[y][x],blue,TOP_SCEEN)
		end
	end
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
					
					table.insert(lines[curY],curX,inputChar) curX=curX+1 --the cursor moves when you type

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
	Screen.fillRect(5,300,5,20,green,TOP_SCREEN)
	displayTop()
	Keyboard()
		--Screen.debugPrint(6,6,tx,blue,TOP_SCREEN)
		--Screen.debugPrint(6,20,ty,blue,TOP_SCREEN)
		Screen.flip()
	if Controls.check(pad,KEY_B) then crash() end --faster restarting in citra
end
