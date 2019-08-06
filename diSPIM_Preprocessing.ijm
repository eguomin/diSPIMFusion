macro "diSPIM_Preprocessing [p]"{
// This macro is to pre-process images acquired by diSPIM of correct distortion induced by stage-scanning in (d)iSPIM. With a simple User Interface within ImageJ for 
// 1) dual-view single-color diSPIM  
// 2) dual-view dual-color diSPIM
//
// Comparable with both conventional- (45deg tilt angle) and asymmetrical (any tilt angle) diSPIM. Also incorporating functions such as:
// 1)ROI croping
// 2)background subtraction
// 3)interpolation(isotropizing pixel size)
// 4)generating maximun intensity projection
// 5)image rotation 

// Min Guo, July 2017
// Modified by Feb. 2018
// Modified by Jun. 2019


//=================================================================
//=========You can customize your default parameters here!!!=======
//=================================================================
// The default setup is for the MBL diSPIM by Feb. 2018

imagingMode = "light sheet scanning"; // "light sheet scanning"; "stage scanning"

colorChoice = "Single color";

nameA1 = "SPIMA-";
nameB1 = "SPIMB-";

nameA2 = "SPIMA-";
nameB2 = "SPIMB-";

pixelSizeA = 0.1625;
sliceThicknessA = 1;
pixelSizeB = 0.1625;
sliceThicknessB = sliceThicknessA;

//background
bgChoice="Uniform Background"
bgValueA = 100;//background gound values
bgValueB = 100;//background gound values

//for stage scanning mode
theta = 45; //SPIMA tilt angle
//56.7 degree = 0.9896 rab, sin(56.6) = 0.836; cos(56.7) = 0.549
//stageStepA = 1.414;
//stageStepB = stageStepA;
d1 = -1; // shift direction: 1 or -1
d2 = 1; // shift direction: 1 or -1

//*******Axial Interpolation *********
//****rotation and Interpolation is only enabled for ROI cropping: 
interpRotTriger = false; //true: 1, false: 0 

// log file name
fileLog = "preprocessing log.txt";
//=================================================================
//===================Customization End!!!!=========================
//=================================================================

// close all windows
while (nImages>0) {
          selectImage(nImages); 
          close(); 
      }
// Imaging mode options
Dialog.create("Imaging Mode selection");
items = newArray("light sheet scanning", "stage scanning");
Dialog.addRadioButtonGroup("Imaging Mode", items, 2, 1, imagingMode);
Dialog.show();
imagingMode = Dialog.getRadioButton();

// Color options
Dialog.create("diSPIM Preprocessing Color Selection");
items = newArray("Single color", "Dual color");
Dialog.addRadioButtonGroup("Color Options", items, 2, 1, colorChoice);
Dialog.show();
colorChoice = Dialog.getRadioButton();

      
print("Set input parameters...\n...\n");

if(colorChoice=="Single color"){
	pathSPIMA1 = getDirectory("Select SPIMA folder");
	pathSPIMB1 = getDirectory("Select SPIMB folder");
	pathOutput = getDirectory("Select output folder");
	dualColor = false;
}
else{
	pathSPIMA1 = getDirectory("Select SPIMA Color 1 folder");
	pathSPIMB1 = getDirectory("Select SPIMB Color 1 folder");
	pathSPIMA2 = getDirectory("Select SPIMA Color 2 folder");
	pathSPIMB2 = getDirectory("Select SPIMB Color 2 folder");
	pathOutput = getDirectory("Select output folder");
	dualColor = true;
}
	
SPIMAList = getFileList(pathSPIMA1);
totalImageNum = lengthOf(SPIMAList);
imageNumStart = 0;
imageNumEnd = totalImageNum - 1;
imageNumInterval = 1;

//Create dialog panel
Dialog.create("diSPIM Preprocessing");	
Dialog.addMessage("\nDirectories and Files");
Dialog.addString("SPIMA Directory",pathSPIMA1,50);
Dialog.addString("SPIMB Directory",pathSPIMB1,50);
Dialog.addString("ImageA Name",nameA1,20);
Dialog.addString("ImageB Name",nameB1,20);
Dialog.addString("Output Directory",pathOutput,50);
if(colorChoice=="Dual color") {
	Dialog.addCheckbox("Dual Color", dualColor);
	Dialog.addString("Color 2 SPIMA Directory",pathSPIMA2,50);
	Dialog.addString("Color 2 SPIMB Directory",pathSPIMB2,50);
	Dialog.addString("Color 2 ImageA Name",nameA2,20);
	Dialog.addString("Color 2 ImageB Name",nameB2,20);
}
Dialog.addMessage("Image Number/Range");
Dialog.addNumber("Start #", imageNumStart);
Dialog.addNumber("End #", imageNumEnd);
Dialog.addNumber("Interval", imageNumInterval);
Dialog.addNumber("Test #", imageNumStart);

Dialog.addNumber("PixelsizeA", pixelSizeA,4,6,"um");
Dialog.addNumber("sliceThicknessA", sliceThicknessB,4,6,"um");
Dialog.addNumber("PixelsizeB", pixelSizeB,4,6,"um");
Dialog.addNumber("sliceThicknessB", sliceThicknessB,4,6,"um");

if(imagingMode == "stage scanning"){
		Dialog.addMessage("\nStage Scanning configurations");
		Dialog.addNumber("SPIMA Tilt Angle", theta,2,6,"degree");
		Dialog.addMessage("Set Stage Shifting Step and Direction");
		Dialog.addNumber("SPIMA direction:", d1,0,4,"1 or -1");
		Dialog.addNumber("SPIMB direction:", d2,0,4,"1 or -1");
}
Dialog.addMessage("\n");
items = newArray("No Subtraction", "Uniform Background", "Background Images");
Dialog.addRadioButtonGroup("Background Subtraction", items, 1, 3, bgChoice);
Dialog.addNumber("Uniform Value A:", bgValueA,2,6," ");
Dialog.addNumber("Uniform Value B:", bgValueB,2,6," ");

Dialog.addMessage("\n");
Dialog.addCheckbox("Isotropize Pixelsize and Ratate ImageB", interpRotTriger); //disabled for MBL diSPIM
Dialog.addMessage("Note: this function works only during the ROI selecting.");
Dialog.show();

//Get parameters from dialog
pathSPIMA1 = Dialog.getString();
pathSPIMB1 = Dialog.getString();
nameA1 = Dialog.getString();
nameB1 = Dialog.getString();
pathOutput = Dialog.getString();

if(colorChoice=="Dual color") {
	dualColor = Dialog.getCheckbox();
	pathSPIMA2 = Dialog.getString();
	pathSPIMB2 = Dialog.getString();
	nameA2 = Dialog.getString();
	nameB2 = Dialog.getString();
}

imageNumStart = Dialog.getNumber();
imageNumEnd = Dialog.getNumber();
imageNumInterval = Dialog.getNumber();
imageNumTest = Dialog.getNumber();
	
if((imageNumTest<imageNumStart)||(imageNumTest>imageNumEnd))
	imageNumTest = imageNumStart;

pixelSizeA = Dialog.getNumber();
sliceThicknessA = Dialog.getNumber();
pixelSizeB = Dialog.getNumber();
sliceThicknessB = Dialog.getNumber();
thicknessApixel = sliceThicknessA/pixelSizeA;
thicknessBpixel = sliceThicknessB/pixelSizeA;
B2AxyRatio = pixelSizeB/pixelSizeA;
if(imagingMode == "stage scanning"){
	theta = Dialog.getNumber();
	theta = 3.1416*theta/180;
	d1 = Dialog.getNumber();
	d2 = Dialog.getNumber();
	stageStepA = sliceThicknessA/cos(theta);
	stageStepB = sliceThicknessB/cos(theta);
	stageStepA = stageStepA*d1;
	stageStepB = stageStepB*d2;
	shiftStepApixel = stageStepA*sin(theta)/pixelSizeA;
	shiftStepBpixel = stageStepB*cos(theta)/pixelSizeB;
}
	
// background subtaction
bgChoice = Dialog.getRadioButton();// 1, 2, 3, 4;
bgValueA = Dialog.getNumber();
bgValueB = Dialog.getNumber();
bgMode = 0; 
file_bgA = "balabala";
file_bgB = "balabala";
if(bgChoice== "No Subtraction"){
	bgMode = 0; // no subtaction
	}
else if(bgChoice=="Uniform Background"){
	bgMode = 1; // subtracted by constant background
	}
else if(bgChoice=="Background Images"){
	bgMode = 2; // subtracted by background images
	file_bgA =  File.openDialog("Select background images for SPIMA");
	file_bgB =  File.openDialog("Select background images for SPIMB");
	}

interpRotTriger = Dialog.getCheckbox(); //true: 1, false: 0

if(interpRotTriger == false)
	rotDir = 0; // 1: 90 degree by Y-axis; -1: -90 degree by Y-axis; 0: no rotation;
else if(imagingMode=="stage scanning")
	rotDir = 1;
else if(imagingMode=="light sheet scanning")
	rotDir = -1;
	
// tif stacks or image squences
SPIMAList = getFileList(pathSPIMA1);
if (endsWith(SPIMAList[0], "/"))
	sequence = 1; //image squences
else
	sequence = 0; // tif stack	
sequence = 0; // disable image squences reading

// Processing
pathSPIMAPrep = pathOutput + "Prep_SPIMA\\";
pathSPIMBPrep = pathOutput + "Prep_SPIMB\\";
File.makeDirectory(pathSPIMBPrep);
File.makeDirectory(pathSPIMAPrep);
if(dualColor==false){
	pathSPIMAPrep1 = pathSPIMAPrep;
	pathSPIMBPrep1 = pathSPIMBPrep;
	pathSPIMAPrepMP1 = pathSPIMAPrep1 + "MP_ZProj\\";
	pathSPIMBPrepMP1 = pathSPIMBPrep1 + "MP_ZProj\\";
	File.makeDirectory(pathSPIMAPrepMP1);
	File.makeDirectory(pathSPIMBPrepMP1);
}
else{
	pathSPIMAPrep1 = pathSPIMAPrep+"Color1\\";
	pathSPIMBPrep1 = pathSPIMBPrep+"Color1\\";
	pathSPIMAPrepMP1 = pathSPIMAPrep1 + "MP_ZProj\\";
	pathSPIMBPrepMP1 = pathSPIMBPrep1 + "MP_ZProj\\";
	File.makeDirectory(pathSPIMAPrep1);
	File.makeDirectory(pathSPIMBPrep1);
	File.makeDirectory(pathSPIMAPrepMP1);
	File.makeDirectory(pathSPIMBPrepMP1);

	pathSPIMAPrep2 = pathSPIMAPrep+"Color2\\";
	pathSPIMBPrep2 = pathSPIMBPrep+"Color2\\";
	pathSPIMAPrepMP2 = pathSPIMAPrep2 + "MP_ZProj\\";
	pathSPIMBPrepMP2 = pathSPIMBPrep2 + "MP_ZProj\\";
	File.makeDirectory(pathSPIMAPrep2);
	File.makeDirectory(pathSPIMBPrep2);
	File.makeDirectory(pathSPIMAPrepMP2);
	File.makeDirectory(pathSPIMBPrepMP2);
}

// Select Region of Interest //
// Preprocessing
print("ROI selecting...");
Tole = 0;
dirA = pathSPIMA1 + nameA1 + imageNumTest;
dirB = pathSPIMB1 + nameB1 + imageNumTest;
	
ID1 = opImage(dirA, sequence); // open SPIMA image
ID1 = backgroundSubtraction(ID1, bgMode, bgValueA, file_bgA); // subtract background
if(imagingMode=="stage scanning"){
	ID1 = fshifting_singlecolor(ID1, shiftStepApixel); // shift image
}
ID1 = interpImage(ID1, interpRotTriger, 1, 1 , thicknessApixel);
selectImage(ID1);
run("Z Project...", "projection=[Max Intensity]");
ID2 = getImageID();
RA = roiDetection(ID2,Tole); // automated ROI detection
	
ID3 = opImage(dirB, sequence); // open SPIMB image
ID3 = backgroundSubtraction(ID3, bgMode, bgValueB, file_bgB); // subtract background
if(imagingMode=="stage scanning"){
	ID3 = fshifting_singlecolor(ID3, shiftStepBpixel); // shift image
}
selectImage(ID3);
sxBorg = getWidth();
syBorg = getHeight();
sliceBorg = nSlices();
ID3 = interpImage(ID3, interpRotTriger, B2AxyRatio, B2AxyRatio, thicknessBpixel);
ID3 = rotImage(ID3, rotDir);
selectImage(ID3);
run("Z Project...", "projection=[Max Intensity]");
ID4 = getImageID();
RB = roiDetection(ID4,Tole); // automated ROI detection

// manually modify ROIs
selectImage(ID2);	
makeRectangle(RA[0], RA[1], RA[2], RA[3]);
selectImage(ID4);
makeRectangle(RB[0], RB[1], RB[2], RB[3]);	
waitForUser("Selection","Select Region of Interest for Z projection, then press OK");
selectImage(ID2);
getSelectionBounds(xA, yA, wA, hA);
close();
wA = floor(wA/2)*2; // round width size to even
hA = floor(hA/2)*2; // round hight size to even
selectImage(ID4);//selectWindow(Title4);
getSelectionBounds(xB, yB, wB, hB);
wB = floor(wB/2)*2; // round width size to even
hB = floor(hB/2)*2; // round hight size to even
close();

// z stack cropping
Tolez = 0;
selectImage(ID1);
makeRectangle(xA, yA, wA, hA);
run("Crop");
ID1 = getImageID();
run("Reslice [/]...", "output=1.000 start=Top avoid");
ID5 = getImageID();
run("Z Project...", "projection=[Max Intensity]");
ID6 = getImageID();
selectImage(ID1);
close();
selectImage(ID5);
close();
RAz = roiDetection(ID6,Tolez);

selectImage(ID3);
makeRectangle(xB, yB, wB, hB);
run("Crop");
ID3 = getImageID();
run("Reslice [/]...", "output=1.000 start=Top avoid");
ID7 = getImageID();
run("Z Project...", "projection=[Max Intensity]");
ID8 = getImageID();

selectImage(ID3);
close();
selectImage(ID7);
close();
RBz = roiDetection(ID8,Tolez);

// manually modify z-ROIs
selectImage(ID6);	
makeRectangle(xA, RAz[1], wA, RAz[3]);
selectImage(ID8);
makeRectangle(xB, RBz[1], wB, RBz[3]);
waitForUser("Selection","Select Region of Interest for Y projection, then press OK");
selectImage(ID6);
getSelectionBounds(aa, zA1, bb, sA);
zA2 = zA1 + sA; // zA1, zA2: slices range 
close();
selectImage(ID8);
getSelectionBounds(aa, zB1, bb, sB);
zB2 = zB1 + sB; // zB1, zB2: slices range
close();

print("ROI selecting is completed.");

//define rotations and corresponding relations between cropping coordinates
if(interpRotTriger){ // may vary for differents diSPIM or different system configurations
	zA1 = maxOf(round(zA1/thicknessApixel),1);
	zA2 = minOf(round(zA2/thicknessApixel),sliceBorg);
	yB = maxOf(round(yB/B2AxyRatio),1);
	hB = minOf(round(hB/B2AxyRatio),syBorg-yB);
	if(rotDir==0){
		xB = maxOf(round(xB/B2AxyRatio),1);
		wB = minOf(round(wB/B2AxyRatio),sxBorg-xB);
		zB1 = maxOf(round(zB1/thicknessBpixel),1);
		zB2 = minOf(round(zB2/thicknessBpixel),sliceBorg);
	}
	if(rotDir==1){
		temp1 = round(xB/thicknessBpixel);
		temp2 = round(wB/thicknessBpixel);
		xB = maxOf(sxBorg-round(zB2/B2AxyRatio),1);
		wB = minOf(round((zB2-zB1)/B2AxyRatio),sxBorg-xB);
		zB1 = maxOf(temp1,1);
		zB2 = minOf(zB1+temp2-1, sliceBorg);
	}
	if(rotDir==-1){
		temp1 = round(xB/thicknessBpixel);
		temp2 = round(wB/thicknessBpixel);
		xB = maxOf(round(zB1/B2AxyRatio),1);
		wB = minOf(round((zB2-zB1)/B2AxyRatio),sxBorg-xB);
		zB1 = maxOf(sliceBorg-temp1-temp2,1);
		zB2 = minOf(zB1+temp2-1, sliceBorg);
	}
		
}

//record configurations to log file
flog = File.open(pathOutput+fileLog);
print(flog, "Image Preprocessing: " + imagingMode + ", "+ colorChoice +"\n");
print(flog, "...SPIMA pixel size:  " + pixelSizeA + "um, slice thickness:"+ sliceThicknessA +"um\n");
print(flog, "...SPIMB pixel size:  " + pixelSizeB + "um, slice thickness:"+ sliceThicknessB +"um\n");
print(flog, "...image time points range:  " + imageNumStart + "-"+ imageNumInterval +"-"+ imageNumEnd +"\n");
print(flog, "...image time point for ROI selecting:  " + imageNumTest +"\n");
if(interpRotTriger)
	print(flog, "... ... ... rotation and interpolation during ROI selecting:  yes\n");
else
	print(flog, "... ... ... rotation and interpolation during ROI selecting:  no\n");
print(flog, "... ... ... SPIMA ROI coordinates for cropping (x, y, width, height):  " + xA +", " + yA +", " + wA+", " + hA +"\n");
print(flog, "... ... ... SPIMA slice range for cropping:  " + zA1 +"-" + zA2 +"\n");
print(flog, "... ... ... SPIMB ROI coordinates for cropping (x, y, width, height):  " + xB +", " + yB +", " + wB+", " + hB +"\n");
print(flog, "... ... ... SPIMB slice range for cropping:  " + zB1 +"-" + zB2 +"\n");
if(bgChoice=="Uniform Background")
	print(flog,"... " + bgChoice + ":" + bgValueA +", " + bgValueB + "\n");
else
	print(flog, "... " + bgChoice + "\n");
	
if(imagingMode=="stage scanning")
print(flog, "... stage scanning... SPIMA: " + d1 +", SPIMB: " + d2 + "\n");
File.close(flog);

// Image Preprocessing begins ////////
setBatchMode(true);
print("Preprocessing begins...");
for(i=imageNumStart; i<=imageNumEnd; i++){
	print("Processing time point "+i+" ...");
	dirA = pathSPIMA1 + nameA1 + i;
	ID1 = opImage(dirA, sequence); // open SPIMA image
	ID1 = backgroundSubtraction(ID1, bgMode, bgValueA, file_bgA); // subtract background
	if(imagingMode=="stage scanning"){
		ID1 = fshifting_singlecolor(ID1, shiftStepApixel); // shift image
	}
	selectImage(ID1);
	makeRectangle(xA, yA, wA, hA);
  	run("Crop");
	ID9 = getImageID();
	run("Duplicate...", "duplicate range="+zA1+"-"+zA2);
	ID10 = getImageID();
  	selectImage(ID9);
	close();
	//ID11 = interpImage(ID10, interpRotTriger, 1, 1 , thicknessApixel);
	ID11 = ID10;
  	saveAs("Tiff", pathSPIMAPrep1 + nameA1 + i + ".tif");
  	run("Z Project...", "projection=[Max Intensity]");
  	ID12 = getImageID();
  	saveAs("Tiff", pathSPIMAPrepMP1+"Max_"+ nameA1 + i + ".tif");
  	selectImage(ID11);
  	close();
  	selectImage(ID12);
  	close();

	dirB = pathSPIMB1 + nameB1 + i;
  	ID3 = opImage(dirB, sequence); // open SPIMB image
	ID3 = backgroundSubtraction(ID3, bgMode, bgValueB, file_bgB); // subtract background
	if(imagingMode=="stage scanning"){
		ID3 = fshifting_singlecolor(ID3, shiftStepBpixel); // shift image
	}
	//ID3 = rotImage(ID3, rotDir);
	selectImage(ID3);
	makeRectangle(xB, yB, wB, hB);
  	run("Crop");
  	ID13 = getImageID();
  	run("Duplicate...", "duplicate range="+zB1+"-"+zB2);
  	ID14 = getImageID();
  	selectImage(ID13);
	close();
	//if(imagingMode=="stage scanning"){ //flip image to make the orientation of final output consistent with light sheet scanning mode
		selectImage(ID14);
		run("Flip Horizontally", "stack");
		run("Flip Z");
	//}
  	//ID15 = interpImage(ID14, interpRotTriger, thicknessBpixel, B2AxyRatio, B2AxyRatio);
  	ID15 = ID14;
  	saveAs("Tiff", pathSPIMBPrep1 + nameB1 + i + ".tif");
  	run("Z Project...", "projection=[Max Intensity]");
  	ID16 = getImageID();
  	saveAs("Tiff", pathSPIMBPrepMP1+"Max_"+ nameB1 + i + ".tif");
  	selectImage(ID15);
  	close();
  	selectImage(ID16);
  	close();

  	if(dualColor==true){
  		print("Processing time point "+i+" (second color)...");
		dirA = pathSPIMA2 + nameA2 + i;
		ID1 = opImage(dirA, sequence); // open SPIMA image
		ID1 = backgroundSubtraction(ID1, bgMode, bgValueA, file_bgA); // subtract background
		if(imagingMode=="stage scanning"){
			ID1 = fshifting_singlecolor(ID1, shiftStepApixel); // shift image
		}
		selectImage(ID1);
		makeRectangle(xA, yA, wA, hA);
  		run("Crop");
		ID9 = getImageID();
		run("Duplicate...", "duplicate range="+zA1+"-"+zA2);
		ID10 = getImageID();
  		selectImage(ID9);
		close();
		//ID11 = interpImage(ID10, interpRotTriger, 1, 1 , thicknessApixel);
		ID11 = ID10;
  		saveAs("Tiff", pathSPIMAPrep2 + nameA2 + i + ".tif");
  		run("Z Project...", "projection=[Max Intensity]");
  		ID12 = getImageID();
  		saveAs("Tiff", pathSPIMAPrepMP2+"Max_"+ nameA2 + i + ".tif");
  		selectImage(ID11);
  		close();
  		selectImage(ID12);
  		close();

		dirB = pathSPIMB2 + nameB2 + i;
  		ID3 = opImage(dirB, sequence); // open SPIMB image
		ID3 = backgroundSubtraction(ID3, bgMode, bgValueB, file_bgB); // subtract background
		if(imagingMode=="stage scanning"){
			ID3 = fshifting_singlecolor(ID3, shiftStepBpixel); // shift image
		}
		//ID3 = rotImage(ID3, rotDir);
		selectImage(ID3);
		makeRectangle(xB, yB, wB, hB);
  		run("Crop");
  		ID13 = getImageID();
  		run("Duplicate...", "duplicate range="+zB1+"-"+zB2);
  		ID14 = getImageID();
  		selectImage(ID13);
		close();
		//if(imagingMode=="stage scanning"){ //flip image to make the orientation of final output consistent with light sheet scanning mode
			selectImage(ID14);
			run("Flip Horizontally", "stack");
			run("Flip Z");
		//}
		
  		//ID15 = interpImage(ID14, interpRotTriger, thicknessBpixel, B2AxyRatio, B2AxyRatio);
  		ID15 = ID14;
  		saveAs("Tiff", pathSPIMBPrep2 + nameB2 + i + ".tif");
  		run("Z Project...", "projection=[Max Intensity]");
  		ID16 = getImageID();
  		saveAs("Tiff", pathSPIMBPrepMP2+"Max_"+ nameB2 + i + ".tif");
  		selectImage(ID15);
  		close();
  		selectImage(ID16);
  		close();
  		}
		
}
print("Preprocessing is completed !\n");

//function for opening image
function opImage(dir, sequence){
	if(sequence==1){
		list = getFileList(dir);
		run("Image Sequence...", "open="+dir+"/"+list[0]+" sort");
	}
	else
		open(dir+".tif");
	ID = getImageID();
	run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");
	// switch X, Y axises for micro-Manager out put***
	//run("Rotate 90 Degrees Right"); 
	return ID;
}
// function for background subtration
function backgroundSubtraction(ID, bgMode, bgValue, file_bg){
	if(bgMode==0) return ID;
	if(bgMode==1){
		selectImage(ID);
		run("Subtract...", "value="+ bgValue +" stack");
		return ID;
	}
	if(bgMode==2){
		selectImage(ID);
		open(file_bg);
		IDbg = getImageID();
		imageCalculator("Subtract stack", ID,  IDbg);
		selectImage(IDbg);
		close();
		return ID;
	}
}

// fucntion for image rotation
function rotImage(ID, rotDir){ // TransformJ can also be used here
	if(rotDir == 1){ //**** 90 round Y axis
		//***for B view of asymmetrical diSPIM at Hari's Lab ****
		//selectImage(ID);
		//run("Reslice [/]...", "output=1.000 start=Top avoid");
		//run("Rotate 90 Degrees Right");
		//ID_temp1 = getImageID();
		//run("Reslice [/]...", "output=1.000 start=Top avoid");
		//run("Flip Horizontally", "stack");
		//ID_temp2 = getImageID();
		//selectImage(ID);
		//close();
		//selectImage(ID_temp1);
		//close();
		//return ID_temp2;
		
		//***for B view of diSPIM at MBL 
		selectImage(ID);
		run("Reslice [/]...", "output=1.000 start=Top avoid");
		run("Rotate 90 Degrees Left");
		ID_temp1 = getImageID();
		run("Reslice [/]...", "output=1.000 start=Top avoid");
		ID_temp2 = getImageID();
		selectImage(ID);
		close();
		selectImage(ID_temp1);
		close();
		return ID_temp2;
	}
	else if(rotDir == -1){ //**** -90 round Y axis
		//***for B view of asymmetrical diSPIM at Hari's Lab ****
		//selectImage(ID);
		//run("Reslice [/]...", "output=1.000 start=Top avoid");
		//run("Rotate 90 Degrees Right");
		//ID_temp1 = getImageID();
		//run("Reslice [/]...", "output=1.000 start=Top avoid");
		//run("Flip Horizontally", "stack");
		//ID_temp2 = getImageID();
		//selectImage(ID);
		//close();
		//selectImage(ID_temp1);
		//close();
		//return ID_temp2;
		
		//***for B view of diSPIM at MBL 
		selectImage(ID);
		run("Reslice [/]...", "output=1.000 start=Top avoid");
		run("Rotate 90 Degrees Right");
		ID_temp1 = getImageID();
		run("Reslice [/]...", "output=1.000 start=Top avoid");
		ID_temp2 = getImageID();
		selectImage(ID);
		close();
		selectImage(ID_temp1);
		close();
		return ID_temp2;
	}
	else 
		return ID;
}

// function for 3D image interpolation
function interpImage(ID, interpTriger, ratiox, ratioy, ratioz){
	if(interpTriger){
		selectImage(ID);
		sx = getWidth();
		sy = getHeight();
		sliceNum = nSlices();
		sxNew = round(sx * ratiox);
		syNew = round(sy * ratioy);
		sliceNumNew = round(sliceNum * ratioz);
		run("Size...", "width=sxNew height=syNew depth=sliceNumNew average interpolation=Bilinear");
		ID_temp = getImageID();
		return ID_temp;
	}
	else 
		return ID;
}
// function for 2D image interpolation
function interpImage2D(ID, interpTriger, ratiox, ratioy){
	if(interpTriger){
		selectImage(ID);
		sx = getWidth();
		sy = getHeight();
		sxNew = round(sx * ratiox);
		syNew = round(sy * ratioy);
		run("Size...", "width=sxNew height=syNew average interpolation=Bilinear");
		ID_temp = getImageID();
		return ID_temp;
	}
	else 
		return ID;
}
// function for shifting image
function fshifting(ID,shiftStep){
	selectImage(ID);
	sx = getWidth();
	sy = getHeight();
	slice = nSlices();
	sx = round(slice*abs(shiftStep)) + sx;
	if(shiftStep>0)
		run("Canvas Size...", "width=sx height=sy position=Center-Left zero");
	else
		run("Canvas Size...", "width=sx height=sy position=Center-Right zero");		
	for (j=1;j<=slice;j++)
	{
		setSlice(j);
		shift = (j-1)*shiftStep;
		run("Translate...", "x=shift y=0 interpolation=Bilinear slice");
	}
	
}

//function for shifting single color image
function fshifting_singlecolor(ID, shiftStep){
	fshifting(ID,shiftStep);
	return ID;
}

//function for shifting dual color image
function fshifting_dualcolor(ID, shiftStep){
	selectImage(ID);
	slice = nSlices();
	run("Make Substack...", "  slices=1-"+slice+"-2");
	IDa = getImageID();
	selectImage(ID);
	run("Make Substack...", "  slices=2-"+slice+"-2");
	IDb = getImageID();
	selectImage(ID);
	close();
	selectImage(IDa);
	fshifting(IDa,shiftStep);
	selectImage(IDb);
	fshifting(IDb,shiftStep);
	IDs = newArray(2);
	IDs[0] = IDa;
	IDs[1] = IDb;
	return IDs;
}

//function for separate two colors (without shifting)
function sep_dualcolor(ID){
	IDs = newArray(2);
	selectImage(ID);
	slice = nSlices();
	run("Make Substack...", "  slices=1-"+slice+"-2");
	IDs[0] = getImageID();
	selectImage(ID);
	run("Make Substack...", "  slices=2-"+slice+"-2");
	IDs[1] = getImageID();
	selectImage(ID);
	close();	
	return IDs;
}

//function for ROI detection
function roiDetection(ID,Tole){
	selectImage(ID);
	sxA = getWidth();
	syA = getHeight();
	run("Duplicate...", " ");
	run("8-bit");
	run("Gray Morphology", "radius=3 type=[ver line] operator=erode"); // eliminate horizontal artifact lines
	run("Gray Morphology", "radius=3 type=[hor line] operator=erode"); // eliminate horizontal artifact lines
	run("Auto Threshold", "method=Triangle white");
	run("Dilate");
	run("Dilate");
	run("Dilate"); // eliminate small particles
	run("Select Bounding Box (guess background color)");
	getSelectionBounds(xA, yA, wA, hA);
	xA = xA - Tole;
	yA = yA - Tole;
	wA = floor(wA/10)*10+Tole*2;
	hA = floor(hA/10)*10+Tole*2;
	close();
	if(wA>sxA)
		wA=sxA;
	if(hA>syA)
		hA=syA;
	if(xA<0) 
		xA = 0;
	if(yA<0)
		yA = 0;
	R = newArray(4);
	R[0] = xA;
	R[1] = yA;
	R[2] = wA;
	R[3] = hA;
	return R;
}

}