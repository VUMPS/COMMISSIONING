function str_coord_split, instring

; return integer coordinates [x1, y1, x2, y2] from a string of the form '[x1:y1,x2:y2]'

coords = strsplit(strsplit(strsplit(instring,'[',/extract),']',/extract),',',/extract)
return, [fix(strsplit(coords[0],':',/extract)), fix(strsplit(coords[1],':',/extract))]

end