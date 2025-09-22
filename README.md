# dNEMO-1.1.0
Software detecting-NEMO (dNEMO). Publication in Bioinformatics (March 2021): https://doi.org/10.1093/bioinformatics/btaa874 and described in STAR Protocols (September 2022): https://doi.org/10.1016/j.xpro.2022.101630.

Download dNEMO and add the folder and all subfolders to the current MATLAB path. Type RUN_ME into the command window to open the tool.

Guided walkthrough for installation and use of dNEMO: dNEMO-0.9.0/DNEMO_READ_ME.docx

Sample images for dNEMO: [https://pitt.box.com/s/huzv0bq4ksbm4q5asfyj8v976jpwwo1g](https://data.mendeley.com/datasets/8j4x6dj2f7/1)

Simulated images with theoretical PSFs were used in testing detection methods used in dNEMO, and can be found in this repository: https://github.com/recleelab/simulate_psf_image

Simulated images created using the "simulate_psf_image" package and used to test dNEMO can be found here: https://pitt.box.com/s/pic5e5c7pxhlismfljhyregfrlkbwcjt

Standalone copies of the application for Windows & Mac/Linux and wrapped materials used as examples in STAR Protocols manuscript can be found here: Lee, Robin; Kowalczyk, Gabriel; Guo, Yue  (2022), “Guo_Kowalczyk_Lee_Data_Software_Package”, Mendeley Data, V1, doi: 10.17632/8j4x6dj2f7.1

dNEMO uses bioformats to handle image input into the application, and is cited here:

Linkert, M., C. T. Rueden, C. Allan, J.-M. Burel, W. Moore, A. Patterson, B. Loranger, J. Moore, C. Neves, D. MacDonald, A. Tarkowska, C. Sticco, E. Hill, M. Rossner, K. W. Eliceiri, and J. R. Swedlow. 2010. Metadata matters: access to image data in the real world. The Journal of Cell Biology 189(5):777.

In order for dNEMO's image class to properly read in images to the interface, the Bioformats Package Java package must also be downloaded, but is too large to include here. Download the 'bioformats_package.jar' file from the OME Downloads page: https://www.openmicroscopy.org/bio-formats/downloads/ and copy it to your local copy of dNEMO's 'bfmatlab' folder.

Results from Cellpose (Stringer, C., Wang, T., Michaelos, M., and Pachitariu, M. (2021). Cellpose: a generalist algorithm for cellular segmentation. Nat Methods 18, 100-106. 10.1038/s41592-020-01018-x.) can be input into the dNEMO interface, and is cited here.
