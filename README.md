# herald-of-darkness
game made in godot 3 to test the networking api and some personal ideas

i was trying to make something by mixing as much ideas as i could, 
i added an inheritance tree to handle all the networking 
and the basics of all spawnable objects in the world and tried 
making a auto-arranged dungeon like the one in gungeon. 

I tried keeping everything as modular as possible but ended up 
messing some of that so if you are interested in checking the 
project have that in mind, the way i did the networking i believe 
was that every object would actually handle all of its networked 
calls instead of having the base character script or the object script 
handle everything for themselves, this allowed me to have a more modular
approach yet i believe it could be improved, hope this is useful to someone.
