fixClickPosition = (imgData, width, height, pos) ->
  #imgData ist ein Array der Länge width*height*4, jeweils [r,g,b,a,r,g,b,a,...] zeilenweise
  #Struktur von `pos`: {x: 21, y: 42}
  #TODO Actually fix the clicked position here!
  fixedPos =
    x: pos.x
    y: pos.y
  return fixedPos