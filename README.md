# Nature Communications (Albizu et al. 2023)
Artificial Intelligence-Optimized Non-Invasive Brain Stimulation and Treatment Response Prediction for Major Depression 
--
Author List: Alejandro Albizu, Paulo Suen, Ziqian Huang, Jori L. Waner, Skylar E. Stolte, Aprinda Indahlastari, Ruogu Fang, Andre R. Brunoni, & Adam J. Woods 

## Data Availability
The raw data of this study are available upon reasonable request from the corresponding author. The raw data are not publicly available due to potential identifying information that could compromise participant privacy. Source data are provided with the respository (SourceData.mat) and ([https://doi.org/10.6084/m9.figshare.23946768.v3](https://doi.org/10.6084/m9.figshare.23946768.v3)).

All analyses were proerfomed using the available toolboxes: MATLAB R2022a ([https://www.mathworks.com](https://www.mathworks.com)), FreeSurfer Version 7.1.1 for Resampling ([http://freesurfer.net](http://freesurfer.net)), headreco from SimNIBS v3.2.1 for Segmentation ([https://simnibs.github.io/simnibs/build/html/index.html](https://simnibs.github.io/simnibs/build/html/index.html)), ROAST v3.0 for FEM ([https://www.parralab.org/roast/](https://www.parralab.org/roast/)), and SPM12 for Image Registration ([https://www.fil.ion.ucl.ac.uk/spm/software/spm12/](https://www.fil.ion.ucl.ac.uk/spm/software/spm12/)).

Statistical Analyses and Source Data

For transparency and in order to reconstruct/replicate our results, we upload the MATLAB script (Analysis.m) to analyze the data we used within our manuscript (SourceData.mat). The data file contains the source data (data), class labels (label), model performance (perf), pretrained weights (weights), and precision doses (doses). 

To run the MATLAB script:
- Install MATLAB ([https://www.mathworks.com](https://www.mathworks.com))
- Clone the current repository to your working directory
- Change Directories to the cloned directory
- Run the Script

Alejandro Albizu, University of Florida
aa14av@gmail.com
August 2023
