function update()
  localAnimator.clearDrawables()
  local previewPosition = animationConfig.animationParameter("previewPosition")
  local numberOfCars = animationConfig.animationParameter("numberOfCars")
  local previewImgsArray = animationConfig.animationParameter("previewImages")
  local offsets = animationConfig.animationParameter("offsets")
  local flipTable = animationConfig.animationParameter("flipTable")
  local reversedTable = animationConfig.animationParameter("reversedTable")
  
  --self.trainsetData = animationConfig.animationParameter("trainsetData")
  
  --self.previewImgsArray{ body,cockpit,pantograph,decal1, .. decalN}, {body,cockpit,pantograph,decal1, .. decalN} } ={ {car1data}, {car2data} }

  for car=1,numberOfCars do  
	if previewPosition then
	  
	  local previewValid = animationConfig.animationParameter("previewValid")
      local facing = animationConfig.animationParameter("facing")
	
	  for i=1,#previewImgsArray[car] do
        local previewImage = previewImgsArray[car]
	    local flipped
        
	    if previewValid then
	      previewImage[i] = previewImage[i] .. "?fade=55FF5500;0.25?border=2;66FF6677;00000000"
	    else
	   	  previewImage[i] = previewImage[i] .. "?fade=FF555500;0.25?border=2;FF666677;00000000"
	    end
		
		if flipTable[car][i] then
		  if reversedTable[car] then
	        flipped = facing > 0
	      else
	        flipped = facing < 0
	      end
		else
		  flipped = false
		end
		
	    localAnimator.direction = -1
        localAnimator.addDrawable({
        image = previewImage[i],
        position = previewPosition,
        fullbright = true,
        mirrored = flipped
        })
		
	  end
	  
	  if facing < 0 then
        previewPosition[1] = previewPosition[1] + offsets[car]
      else
        previewPosition[1] = previewPosition[1] - offsets[car]
	  end
	  
	end
  end
  
end
