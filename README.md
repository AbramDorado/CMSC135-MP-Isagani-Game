# CMSC23-MP-Isagani-Game
This is our Machine Problem in CMSC 135 where we used Assembly language. We made a custom game instructed by our professor, this game is called isagani game. This was done in the second semester of my second year. This project was done in pairs, I did this with my classmates. 

masm32 & DOSBox Setup:
1. DL masm32 (we have an installer, you can check in the files also) & install.
2. DL DOSBox and install (installer also provided)
3. Go to System Properties > Environment Variables > System variables > Path
4. Then paste the url of masm32 (e.g. C:\masm32\bin)
5. restart terminal id open
6. Locate your masm32 folder in the C drive and make a new folder for your projects (e.g. _projects)

----o automatically mount a directory to the C drive when you open DOSBox----
7. Go to: C:\Users\<YourUsername>\AppData\Local\DOSBox\dosbox-0.74-3.conf
8. Open the dosbox.conf 
9. Find the [autoexec] section in the configuration file. If it doesn't exist, you can add it to the end of the file.
10. Add Mounting Command: 
[autoexec]
# Lines in this section will be run at startup.
mount c: C:\masm32\+projects\
c:
11. Save and Close the File

Program Setup:
1. 
2. Open the folder _projects 
3. In the terminal type: "ml /c mp.asm"
4. Linking object file to executable type: "link16 mp"
5. Press "enter" repeatedly
6. Open dos box, type the file name "mp"
7. Done!