# dNEMO-1.1.1

**detecting-NEMO (dNEMO)** - A MATLAB-based tool for quantification of mRNA and punctate structures in time-lapse images of single cells

- **Bioinformatics** (March 2021): [https://doi.org/10.1093/bioinformatics/btaa874](https://doi.org/10.1093/bioinformatics/btaa874)
- **STAR Protocols** (September 2022): [https://doi.org/10.1016/j.xpro.2022.101630](https://doi.org/10.1016/j.xpro.2022.101630)

## Installation

- **MATLAB R2018b or later**
   - Image Processing Toolbox
   - Statistics and Machine Learning Toolbox
   - Signal Processing Toolbox

1. Download dNEMO and add the folder and all subfolders to your MATLAB path
2. **Important**: Download the Bio-Formats package to read images into dNEMO interface:
   - Download `bioformats_package.jar` from [OME Downloads](https://www.openmicroscopy.org/bio-formats/downloads/)
   - Copy it to the `bfmatlab` folder in your local dNEMO directory
3. Type `RUN_ME` in the MATLAB command window to launch the tool

**Installation & Usage Guide**: [DNEMO_READ_ME.docx](DNEMO_READ_ME.docx)

## Sample Data

- **Sample images** from the Bioinformatics paper and PSF-simulated images: [Zenodo Repository](https://zenodo.org/records/17186070?token=eyJhbGciOiJIUzUxMiJ9.eyJpZCI6IjUyM2ExNDRiLTc4NmQtNGQ1OS1iNDQ4LTU1MjM0ZDU0MWQwNSIsImRhdGEiOnt9LCJyYW5kb20iOiI2MzcxMGQ0NWRiMmJkMTFmN2E2ZDk5MDI4NGU1ZDc3NCJ9.R8JOEoxJRNWEtjGmie5nTVP8KKNacSZjns5Po3wRaDSEhCUEOLyWRFJAu65KYOu5oFe_UQLWWPtx7dUb01hdIA)
- **Standalone copies** (Windows & Mac/Linux) and wrapped materials used as examples in STAR Protocols manuscript can be found here: [Mendeley Data](https://doi.org/10.17632/8j4x6dj2f7.1)
- Testing was performed on **simulated images with theoretical PSFs**, methods which can be found here: [simulate_psf_image](https://github.com/recleelab/simulate_psf_image)
- Cellpose segmentation results can be imported into dNEMO

## Citations

**Bio-Formats:**
> Linkert, M., C. T. Rueden, C. Allan, J.-M. Burel, W. Moore, A. Patterson, B. Loranger, J. Moore, C. Neves, D. MacDonald, A. Tarkowska, C. Sticco, E. Hill, M. Rossner, K. W. Eliceiri, and J. R. Swedlow. 2010. Metadata matters: access to image data in the real world. *The Journal of Cell Biology* 189(5):777. [https://doi.org/10.1083/jcb.201004104](https://doi.org/10.1083/jcb.201004104)

**Cellpose:**
> Stringer, C., Wang, T., Michaelos, M., and Pachitariu, M. (2021). Cellpose: a generalist algorithm for cellular segmentation. *Nat Methods* 18, 100-106. [https://doi.org/10.1038/s41592-020-01018-x](https://doi.org/10.1038/s41592-020-01018-x)
