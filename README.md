# GO-Strain-Mapping

File list and description.

1. CalculateCentroid.cpp 
The source code is built using OpenCV library. Please configure the OpenCV environment before using the code.

These two files read images and calculate the centroid coordinates of each gold nanoparticles. Before using the codes, please rename the images as "1.jpg", "2.jpg" etc. Running the code will show two windows. "LabelledImage" window shows the current image with contours of the particles. Click on a particle, then the window will update the image. Continue clicking on the same particle across iamges until a number is labelled near the particle. Then click on another particle and repeat until all particles of interest are clicked on all images. "Reference Image" window shows the raw image overlaid with the clicked position (red dot), functioning as a reminder so users know which particlee they are focusing on.

The results, including the particle ID, centroid coordinates (x,y) and the match score, are written to a file "data_.csv", which will be processed by the following two MATLAB scripts.

------------------------------
2. StrainMappingAll.m
3. FitBeadStrainFieldLocal.m

These two files calculate strain field using the coordinates of each particle. 

Run "StrainMappingAll.m" first, then the "FitBeadStrainFieldLocal.m" function will be called automatically.
