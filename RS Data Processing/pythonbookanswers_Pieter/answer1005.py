text = "Hello, world!"
newtext = ""

while len( text ) > 0:
    i = 0
    ch = text[i]
    j = 1
    while j < len( text ):
        if text[j] < ch:
            ch = text[j]
            i = j
        j += 1
    text = text[:i] + text[i+1:]
    newtext += ch
    
print( newtext )