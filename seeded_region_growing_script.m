%Read in the image and convert to double values
HW1 = im2double(imread('HW1.png'));
HW4 = im2double(imread('HW4.png'));
PR4 = im2double(imread('PR4.png'));
PR7 = im2double(imread('PR7.png'));

%If you want to select the seed manually on the image, then set the x and y coordinates to 0
HW1_SRG = seeded_region_growing(0.2,HW1,100,100);
HW4_SRG = seeded_region_growing(0.2,HW4,100,100);
PR4_SRG = seeded_region_growing(0.5,PR4,100,100);
PR7_SRG = seeded_region_growing(0.2,PR7,100,100);

%Show the original image compared with the binarised one
figure, imshow(HW1_SRG);
figure, imshow(HW4_SRG);
figure, imshow(PR4_SRG);
figure, imshow(PR7_SRG);

colormap gray(255);