#!/usr/bin/julia
# Julia program
#=

This program attempts to organize the X-Plane 11 (more likely do most 
of the grunt work) scenery_packs.ini.

X-Plane 11 is a Flight simulation program (some call it a game)

I think "attempt" to organize the config file is the best I can hope for.
X-Plane 11 requires you to manually organize it's scenery_packs.ini when
you want to add/improve features to/in it.
The folders listed within need to be ordered in a specific order, if not
the program will not function properly.
Unfortunately X-Plane 11 has NO folder name standards.
So for example if airports (and airports are just 1 of many catagories) 
are required to be ordered first, it would be nice if the word airport or 
some other constant like 001 was required to be somewhere in the 
folder name...it is NOT! A folder name can be anything 
'Fort Lauderdale Executive Airport' or 'ft laundry dale plain takeoff area' or 
'KFXE_AP' (KFXE is a valid airport ICAO code) or 'Field of Dreams'
...whatever that developer wanted to name it.

    On: 01/29/2019
    By: Bill Blasingim

01/29/2019 - Currently just laying the ground work!
02/07/2019 - Significant work on identifing  and sorting catagories
02/13/2019 - Added code to allow for testing if a filename contains 
a airport ICAO code. I found a airport ICAO file and created a 
SQLite airport ICAO code database to check if necessary!
   
=#
using Dates
using SQLite, DataFrames

fi="/home/bill/Mystuff/SQLite/AirportCodes.db3"
db=SQLite.DB(fi)
#=
sel="select count(*) from AirportCodes where ident='KFXx'"
ex=DataFrame(SQLite.Query(db, sel))
cnt=ex[1][1]
#println(">>>",cnt)
if cnt==0
    println("Not found")
end
exit()
=#

bslash=string('\\')
bslash=Char(92)
#sceneryDir="/media/bill/1450FC356E30C66C/SteamLibrary/steamapps/common/X-Plane 11/Custom Scenery/"
sceneryDir="/home/bill/Documents/Aviation/X-Plane/scenery_packs.ini/"
sceneryFln="scenery_packs11.ini"
suffix=string(now())
inFile=sceneryDir*sceneryFln    #"scenery_packs.ini"
filePieces=splitdir(inFile)

backup=sceneryDir*sceneryFln[1:end-4]*"_"*suffix*".ini"
#cp(inFile,backup)
#println("Backup created..."*backup)

println("Reading: "*inFile)
fi=open(inFile,"r")

outFl=sceneryDir*sceneryFln[1:end-4]*".new"
println("Writing: "*outFl)
fo=open(outFl, "w")

write(fo,"I\n")
write(fo,"1000 Version\n")
write(fo,"SCENERY\n\n")

cnt=recin = 0

###################################################
# Define and initialize arrays                    #
###################################################

noElements=200
apt1Array = Array{String}(undef, noElements)
apt2Array = Array{String}(undef, noElements) #Aerosoft
libArray = Array{String}(undef, noElements)
mshArray = Array{String}(undef, noElements)
ortArray = Array{String}(undef, noElements)
orbArray = Array{String}(undef, noElements)
objArray = Array{String}(undef, noElements)
othArray = Array{String}(undef, noElements)

i=0
for i=1:noElements
    apt1Array[i]="" 
    apt2Array[i]="" #Aerosoft
    libArray[i]=""
    mshArray[i]=""
    ortArray[i]=""
    orbArray[i]=""
    objArray[i]=""
    othArray[i]=""
end

libIdx=0
apt1Idx=0
apt2Idx=0
mshIdx=0
ortIdx=0
orbIdx=0
objIdx=0
othIdx=0

###################################################
# Main read loop                                  #
###################################################

while !eof(fi)
    
    global cnt,recin,apt1Idx,apt2Idx,libIdx,mshIdx,ortIdx,orbIdx,objIdx,othIdx,aptArray   
    ln=readline(fi) 
    #println(">> "*ln)
    
    recin += 1

    if length(ln)<13
        #println("Continuing...")
        continue
    end
    
    if ln[1:13] != "SCENERY_PACK "
        continue
    end

    scnDir=ln[29:end-1] #scenery file 
    #println("> "*scnDir[5])

    if length(scnDir)>21 && scnDir[1:21]=="zzz_hd_global_scenery"
        mshIdx+=1
        mshArray[mshIdx]=string(ln)
        continue
    end

###################################################
# Check for library                               #
###################################################
f=findfirst("librar",lowercase(ln))
if f!=nothing
    libIdx+=1
    libArray[libIdx]=string(ln)
    continue
end

###################################################
# Check for objects                               #
###################################################   
f=findfirst("cars",lowercase(ln))
#show(f)
if f!=nothing
    objIdx+=1
    objArray[objIdx]=string(ln)
    continue
end

f=findfirst("roads",lowercase(ln))
#show(f)
if f!=nothing
    objIdx+=1
    objArray[objIdx]=string(ln)
    continue
end

f=findfirst("aircraft",lowercase(ln))
#show(f)
if f!=nothing
    objIdx+=1
    objArray[objIdx]=string(ln)
    continue
end

f=findfirst("texture",lowercase(ln))
#show(f)
if f!=nothing
    objIdx+=1
    objArray[objIdx]=string(ln)
    continue
end

f=findfirst("scenery",lowercase(scnDir))
#show(f)
if f!=nothing
    objIdx+=1
    objArray[objIdx]=string(ln)
    continue
end

f=findfirst("landmarks",lowercase(ln))
#show(f)
if f!=nothing
    objIdx+=1
    objArray[objIdx]=string(ln)
    continue
end

f=findfirst("flags",lowercase(ln))
#show(f)
if f!=nothing
    objIdx+=1
    objArray[objIdx]=string(ln)
    continue
end

###################################################
# Check for airport                               #
###################################################

#if length(scnDir)>10 && scnDir[1:11]=="Aerosoft - "
if length(scnDir)>8 && scnDir[1:9]=="Aerosoft "
    apt2Idx+=1
    apt2Array[apt2Idx]=string(ln)
    continue
end

    if scnDir[1]=='K' && scnDir[5]=='_'
        #println("Airport File: "*ln)
        apt1Idx+=1
        apt1Array[apt1Idx]=string(ln)
        continue
    end

    f=findfirst("airport",lowercase(ln))
    if f!=nothing
        apt1Idx+=1
        apt1Array[apt1Idx]=string(ln)
        continue
    end
#=
    f=findfirst("demo",lowercase(ln))
    if f!=nothing
        apt1Idx+=1
        apt1Array[apt1Idx]=string(ln)
        continue
    end
=#
###################################################
# Check for mesh                                  #
###################################################
    f=findfirst("mesh",lowercase(ln))
    if f!=nothing
        mshIdx+=1
        mshArray[mshIdx]=string(ln)
        continue
    end

###################################################
# Check for orbx                                  #
###################################################
    f=findfirst("orbx",lowercase(ln))
    if f!=nothing
        orbIdx+=1
        orbArray[orbIdx]=string(ln)
        continue
    end

###################################################
# Check for ortho                                 #
###################################################    
    if findfirst("northo",lowercase(ln))==nothing
        f=findfirst("ortho",lowercase(ln))
        if f!=nothing
            ortIdx+=1
            ortArray[ortIdx]=string(ln)
            continue
        end
    end


    #=
    The following code takes the file name and looks for 4 characters words
    because they might be an airport ICAO code. It takes into account
    that the filename may use "_" instead of a spaces.
    The ICAO code SQLite database, containing 54,000+ records, is then searched.
    =#
    apt=false
    newStr=replace(scnDir, "-" => " ")   
    scnDir=newStr 
    newStr=replace(scnDir, "_" => " ")
    words=split(newStr) #split string into array
    #println("\nFilename :"*scnDir)
    for word in words
        if length(word)==4
            if all(isletter,word)
                #println("looking for..."*word)
                # I could program exceptions like below but where does it end?
                #if lowercase(word)!="orbx" && lowercase(word)!="mesh"
                sel="select count(*) from AirportCodes where ident='"*word*"'"
                ex=DataFrame(SQLite.Query(db, sel))
                cnt=ex[1][1]
                if cnt>0
                    #println(word*" is an airport!!!!!!!")
                    apt1Idx+=1
                    apt1Array[apt1Idx]=string(ln)
                    apt=true
                    continue
                end
            end
        end
    end    

    if apt
        continue
    end

    ############################################ 
    # Other...everything else                  #
    ############################################
    othIdx+=1
    othArray[othIdx]=string(ln)

end
############################################ 
# Finished reading file...on to sorting!   #
############################################

###################################################
# Libraries                                       #
###################################################

write(fo,"Libraries [sorted]...",'\n')
noElements=libIdx
arraySrt = Array{String}(undef, noElements)
libIdx=0

while libIdx<noElements
    global libIdx
    libIdx+=1
    arraySrt[libIdx]=libArray[libIdx]
end
sort!(arraySrt)
noElements=libIdx
libIdx=0
while libIdx<noElements
    global libIdx
    libIdx+=1
    write(fo,arraySrt[libIdx],'\n')
end
###################################################
# Airports                                        #
###################################################
#println("Airports [sorted]...")
write(fo,"\nAirports [sorted]...\n")
noElements=apt1Idx
arraySrt = Array{String}(undef, noElements)
apt1Idx=0

#I'm sure this is a bad way to copy an array

while apt1Idx<noElements
    global apt1Idx
    apt1Idx+=1
    arraySrt[apt1Idx]=apt1Array[apt1Idx]
end

sort!(arraySrt)
noElements=apt1Idx
apt1Idx=0
apt=""
glblSw=false
glbl="SCENERY_PACK Custom Scenery/Global Airports/" 
while apt1Idx<noElements
    global glblSw,apt1Idx
    apt1Idx+=1
    apt=arraySrt[apt1Idx]
    if apt==glbl
        glblSw=true
    else
        write(fo,apt,'\n')
    end
end

################
# Aerosoft     #
################
noElements=apt2Idx
arraySrt = Array{String}(undef, noElements)
apt2Idx=0

#I'm sure this is a bad way to copy an array

while apt2Idx<noElements
    global apt2Idx
    apt2Idx+=1
    arraySrt[apt2Idx]=apt2Array[apt2Idx]
end

sort!(arraySrt)
noElements=apt2Idx
apt2Idx=0
apt=""
while apt2Idx<noElements
    global glblSw,apt2Idx
    apt2Idx+=1
    apt=arraySrt[apt2Idx]
    write(fo,apt,'\n')
end

if glblSw
    write(fo,glbl,'\n')
end

###################################################
# Objects                                         #
###################################################

write(fo,"\nObjects [sorted]...\n")
noElements=objIdx
arraySrt = Array{String}(undef, noElements)
objIdx=0

#I'm sure this is a bad way to copy an array

while objIdx<noElements
    global objIdx
    objIdx+=1
    arraySrt[objIdx]=objArray[objIdx]
end

sort!(arraySrt)
noElements=objIdx
objIdx=0
while objIdx<noElements
    global objIdx
    objIdx+=1
    write(fo,arraySrt[objIdx],'\n')
end

write(fo,"\nORBX [sorted]...",'\n')
noElements=orbIdx
arraySrt = Array{String}(undef, noElements)
orbIdx=0

###################################################
# ORBX                                            #
###################################################

while orbIdx<noElements
    global orbIdx
    orbIdx+=1
    arraySrt[orbIdx]=orbArray[orbIdx]
end
sort!(arraySrt)
noElements=orbIdx
orbIdx=0
while orbIdx<noElements
    global orbIdx
    orbIdx+=1
    write(fo,arraySrt[orbIdx],'\n')
end

###################################################
# Ortho                                           #
###################################################

write(fo,"\nOrtho [sorted]...",'\n')
noElements=ortIdx
arraySrt = Array{String}(undef, noElements)
ortIdx=0

while ortIdx<noElements
    global ortIdx
    ortIdx+=1
    arraySrt[ortIdx]=ortArray[ortIdx]
end
sort!(arraySrt)
noElements=ortIdx
ortIdx=0
while ortIdx<noElements
    global ortIdx
    ortIdx+=1
    write(fo,arraySrt[ortIdx],'\n')
end

###################################################
# Mesh                                            #
###################################################

write(fo,"\nMesh [sorted]...",'\n')
noElements=mshIdx
arraySrt = Array{String}(undef, noElements)
mshIdx=0

while mshIdx<noElements
    global mshIdx
    mshIdx+=1
    arraySrt[mshIdx]=mshArray[mshIdx]
end
sort!(arraySrt)
noElements=mshIdx
mshIdx=0
while mshIdx<noElements
    global mshIdx
    mshIdx+=1
    write(fo,arraySrt[mshIdx],'\n')
end

###################################################
# Other...unknown!                                #
###################################################

write(fo,"\n\n\n########## Other [sorted]...##########",'\n')
noElements=othIdx
arraySrt = Array{String}(undef, noElements)
othIdx=0

while othIdx<noElements
    global othIdx
    othIdx+=1
    arraySrt[othIdx]=othArray[othIdx]
end
sort!(arraySrt)
noElements=othIdx
othIdx=0
while othIdx<noElements
    global othIdx
    othIdx+=1
    write(fo,arraySrt[othIdx],'\n')
end

close(fi)
close(fo)
#println(recin)
#println(cnt)
#sleep(5)
println("End!")
#exit()