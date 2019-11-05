// Nicolas Levacher
// 2019-06
// Macro name:  IHC_Tool
// Goals: Counting DAB stained nucleus on testicular tissue + Measuring tissue areas if necessary 

//MIT License
//Copyright (c) [2019] [Nicolas Levacher]
//Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

//Information pop-up for the user:
showMessage("<html><b>Welcome:</b> Be sure to work on stitched images");

////////////////////////////
//Declaration of variables//
////////////////////////////

//Selection of the original parent folder path:
directoryOri = getDirectory("Select your image folder");

//Dialog box creation with 4 fields to fill:
Dialog.create("Configuration");

Dialog.addChoice("Images format:", newArray(".TIF", ".JPG")); //Image format to treat
Dialog.addChoice("Magnification x:", newArray("5","10","20","40","50"));
Dialog.addChoice("Immunostainning:", newArray("TRA98","CREM","STRA8"));
Dialog.addCheckbox("Necrotic elimination",false);

Dialog.show();

//Information extraction:
directoryExt = Dialog.getChoice(); //Image file format in input and in output
directoryGro = Dialog.getChoice(); //Objective magnification used
directoryStain = Dialog.getChoice(); //Immunostaining type used
directoryNecrotic = Dialog.getCheckbox(); //Is there a necrotic area

//Names of the directory files:
files = getFileList(directoryOri);

//Saving path selection:
directorySave = getDirectory("Select saving folder of your results"); //Dialog box to indicate the saving path

//Return the right file format in the saveAs function:
		if (directoryExt == ".JPG") {       
			sExt = "Jpeg";
		}else {
			sExt = "Tiff";
		}

i=0;

////////////////////
//Image treatments//
////////////////////

do{endsWith(files[i],directoryExt); //Do loop taking files in the right directory

ImageName = files[i]; //Image name variable
	
pathOri = directoryOri + files[i]; //Path for input images
pathDest = directorySave; //Path of output saving 


open(pathOri); //Opens images in the right folder

//Image calibation following the objective magnification (5x to 50x):
if(directoryGro== 5){
	run("Properties...", "channels=1 slices=1 frames=1 unit=um pixel_width=0.9130859375 pixel_height=0.91276041667 voxel_depth=1.0000000");

	}else{if(directoryGro== 10){
		run("Properties...", "channels=1 slices=1 frames=1 unit=um pixel_width=0.45654296875 pixel_height=0.45703125 voxel_depth=1.0000000");

	}else{if(directoryGro== 20){
		run("Properties...", "channels=1 slices=1 frames=1 unit=um pixel_width=0.2280273 pixel_height=0.2285156 voxel_depth=1.0000000");

	}else{if(directoryGro== 40){
		run("Properties...", "channels=1 slices=1 frames=1 unit=um pixel_width=0.1142578125 pixel_height=0.11393229167 voxel_depth=1.0000000");	

	}else{if(directoryGro== 50){ 
		run("Properties...", "channels=1 slices=1 frames=1 unit=um pixel_width=0.09130859375 pixel_height=0.09114583333333333333 voxel_depth=1.0000000");
}}}}};

//If Necrotic elimination is choisen in the parameters dialog box:
//The image is modify in consequence:
if(directoryNecrotic){
//Brightness enhancement:
setMinAndMax(90,250);
run("Apply LUT");
run("8-bit");
//Threshold to eliminate the background:
run("Threshold...");
setThreshold(1, 220);
setOption("BlackBackground", false);
run("Convert to Mask");

//Morphological modifications to fill the slice in black:
run("Gray Morphology", "radius=2 type=circle operator=dilate"); 
run("Fill Holes");
run("Remove Outliers...", "radius=2 threshold=50 which=Dark");
run("Gray Morphology", "radius=2 type=circle operator=dilate");
run("Fill Holes"); 
run("Remove Outliers...", "radius=2 threshold=50 which=Dark");
run("Gray Morphology", "radius=2 type=circle operator=dilate");
run("Fill Holes");
run("Remove Outliers...", "radius=2 threshold=50 which=Dark");
run("Gray Morphology", "radius=2 type=circle operator=dilate");
run("Fill Holes");

//Erosion to correct dilatations:
run("Gray Morphology", "radius=6 type=circle operator=erode");

//Analyze the slice size/area:
run("Analyze Particles...", "size=80000-Infinity display clear include");

//Information extractions:
selectWindow("Results");
TotalArea=getResult("Area",0); 
run("Close All"); //Close all the whole slice measurement windows

//Openning the same image:
open(pathOri);

//Image calibation following the objective magnification (5x to 50x):
if(directoryGro== 5){
	run("Properties...", "channels=1 slices=1 frames=1 unit=um pixel_width=0.9130859375 pixel_height=0.91276041667 voxel_depth=1.0000000");

}else{if(directoryGro== 10){
	run("Properties...", "channels=1 slices=1 frames=1 unit=um pixel_width=0.45654296875 pixel_height=0.45703125 voxel_depth=1.0000000");

}else{if(directoryGro== 20){
		run("Properties...", "channels=1 slices=1 frames=1 unit=um pixel_width=0.2280273 pixel_height=0.2285156 voxel_depth=1.0000000");

}else{if(directoryGro== 40){
	run("Properties...", "channels=1 slices=1 frames=1 unit=um pixel_width=0.1142578125 pixel_height=0.11393229167 voxel_depth=1.0000000");	

}else{if(directoryGro== 50){ 
	run("Properties...", "channels=1 slices=1 frames=1 unit=um pixel_width=0.09130859375 pixel_height=0.09114583333333333333 voxel_depth=1.0000000");
}}}}};

//Manual drawing of the necrotic area:
run("ROI Manager...");
setTool("polygon");
waitForUser("ROI Necrotic","Determine your necrotic area, then press Ok"); //Information pop-up to indicate user to draw the necrotic area
rename(ImageName +" with necrotic"); //Rename the image because its necrotic area has been indicated

//Morphological modifications:
roiManager("Add");
roiManager("Fill");
roiManager("Select",0);
run("Measure"); //Necrotic area measurement

//Information extraction:
selectWindow("Results");
NecroticArea=getResult("Area",1);
Necrotic_pourcentage = (NecroticArea/TotalArea)*100; //Calculation of the necrotic rate

//Set up the display + saving results:
selectWindow("Results");
setResult("NecroticArea",1,NecroticArea);
setResult("SlideArea",1,TotalArea); 
setResult("NecroticProportion",1,Necrotic_pourcentage);
saveAs("Text",pathDest+ "Arearesult"+ImageName+"");

//Hide the necrotic area by flattening the ROI:
selectWindow(ImageName +" with necrotic");
roiManager("Show All without labels");
run("Flatten");
selectWindow(ImageName +" with necrotic"+"-1"); //Rename this image to differentiate it from the previous one
}; 

//Modifications following the staining type done:
if(directoryStain=="TRA98"){
setMinAndMax(50,255);
run("Apply LUT");
};

	else { if(directoryStain=="CREM"){ 
	setMinAndMax(0,205);
	run("Apply LUT");}

	else { if(directoryStain=="STRA8"){ 
	setMinAndMax(0,205);
	run("Apply LUT");}
}}

//Color deconvolution:
run("Colour Deconvolution", "vectors=[Methyl Green DAB]");

//Selection of the right channel (the one corresponding to the staining):
if(directoryNecrotic){
selectWindow(ImageName + " with necrotic-1-(Colour_2)");
}else{
selectWindow(ImageName + "-(Colour_2)");
};
run("8-bit"); //Convert it in 8 bit to enable its treatment

//Modifactions following the objective magnification to isolate the stained structures:
//Calibrations; Thresholds; Background elimination; Morphological modifications; Segmentation:
if(directoryGro== 5){
run("Properties...", "channels=1 slices=1 frames=1 unit=um pixel_width=0.9130859375 pixel_height=0.91276041667 voxel_depth=1.0000000");
setAutoThreshold("Otsu");
setOption("BlackBackground", false);
run("Convert to Mask");
run("Convert to Mask");
run("Remove Outliers...", "radius=2.5 threshold=50 which=Dark");
run("Watershed");

}else{if(directoryGro== 10){
run("Properties...", "channels=1 slices=1 frames=1 unit=um pixel_width=0.45654296875 pixel_height=0.45703125 voxel_depth=1.0000000");
setAutoThreshold("Otsu");
setOption("BlackBackground", false);

run("Convert to Mask");
run("Convert to Mask");
run("Remove Outliers...", "radius=5 threshold=50 which=Dark");
run("Fill Holes");
run("Watershed");

}else{if(directoryGro== 20){
run("Properties...", "channels=1 slices=1 frames=1 unit=um pixel_width=0.2280273 pixel_height=0.2285156 voxel_depth=1.0000000");
	

			if(directoryStain=="TRA98"){
			setAutoThreshold("Otsu");
			setOption("BlackBackground", false);
			run("Convert to Mask");
			run("Convert to Mask");
			run("Remove Outliers...", "radius=7.5 threshold=50 which=Dark");
			
			}else{if(directoryStain=="CREM"){
			setAutoThreshold("Minimum");
			setOption("BlackBackground", false);
			run("Convert to Mask");
			run("Convert to Mask");
			run("Remove Outliers...", "radius=12 threshold=50 which=Dark");
			
			}else{if(directoryStain=="STRA8"){
			setAutoThreshold("Minimum");
			setOption("BlackBackground", false);
			run("Convert to Mask");
			run("Convert to Mask");
			run("Remove Outliers...", "radius=12 threshold=50 which=Dark");}}}
		

		run("Fill Holes");
		run("Dilate");
		//run Fill Holes;
		
		run("Dilate");
		run("Dilate");
		//run Dilate;
		
		
run("Erode");
		run("Erode");
		run("Erode");
		//run Erode;
		
		run("Watershed");

}else{if(directoryGro== 40){
run("Properties...", "channels=1 slices=1 frames=1 unit=um pixel_width=0.1142578125 pixel_height=0.11393229167 voxel_depth=1.0000000");
setAutoThreshold("Otsu");
setOption("BlackBackground", false);
run("Convert to Mask");
run("Remove Outliers...", "radius=12 threshold=50 which=Dark");
run("Dilate");
run("Fill Holes");
run("Dilate");
run("Dilate");
run("Dilate");
run("Dilate");
run("Fill Holes");
run("Watershed");

}else{if(directoryGro== 50){ 
run("Properties...", "channels=1 slices=1 frames=1 unit=um pixel_width=0.09130859375 pixel_height=0.09114583333333333333 voxel_depth=1.0000000");
setAutoThreshold("Otsu");
setOption("BlackBackground", false);
run("Convert to Mask");
run("Fill Holes");
run("Remove Outliers...", "radius=18 threshold=50 which=Dark");
setOption("BlackBackground", false);
run("Dilate");
run("Dilate");
run("Dilate");
run("Dilate");
run("Erode");
run("Erode");
run("Erode");
run("Erode");
run("Watershed");
}}}}};

//Stained structure counting / Measurements:
run("Analyze Particles...", "size=6.00-1042.16 circularity=0.50-1.00 exclude clear include summarize");

//Image + results saving:
saveAs(sExt,pathDest + ImageName); 
selectWindow("Summary");
Number_of_nucleus=getValue("results.count");

i++;

//Result message display:
if(directoryNecrotic){
showMessage("Parameters","<html><b>Global results:</b><br>- Necrotic Proportion: "+Necrotic_pourcentage+" %<br>- Total area: "+TotalArea+" <span>&#181;</span>m<sup>2</sup><br>- Necrotic area: "+NecroticArea+" <span>&#181;</span>m<sup>2</sup><br>- Number of stained nuclei: "+Number_of_nucleus+" nuclei");
}else{
showMessage("Parameters","<html><b>Global results:</b> Number of stained nuclei: "+Number_of_nucleus+" Nuclei");
};

selectWindow(ImageName);
ImageNamesansext=File.nameWithoutExtension;

//Saving counting results:
selectWindow("Summary");
saveAs("text", pathDest + "Count_result" + ImageNamesansext);
run("Close All");

//Close all the additional windows:
selectWindow("Count_result" + ImageNamesansext + ".txt");
run("Close");
selectWindow("Log");
run("Close");
selectWindow("ROI Manager");
run("Close");
selectWindow("Threshold");
run("Close");
selectWindow("Results");
run("Close");

} while(i < files.length);

showMessage("Treatment of the image is over"); //End message
