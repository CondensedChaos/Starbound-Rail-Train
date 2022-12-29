function init()

message.setHandler("PutItemsAt",function(_,_,Item,Offset)
    world.containerPutItemsAt(entity.id(),Item,Offset)
end)
  
end

function update(dt)

end
