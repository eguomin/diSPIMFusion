diSPIM Data Processing (diSPIMFusion)
=====================================

## Overview

Dual-view inverted Selective Plane Illumination Microscopy (diSPIM) [[1]](#1)[[2]](#2) enables isotropic 3D resolution by fusing two volumetric views acquired by two orthogonally configured arms. This repository provides a brief description and a collection of code to process diSPIM data with GPU implementation [[3]](#3), mainly including two parts:

- **Image preprocessing**: background removal, ROI selection, image deskewing, etc.
- **Dual-view image fusion**: registration and joint deconvolution, this is the major computational part, also refered to as `diSPIMFusion`.

## Image Preprocessing

The preprocessing includes several operations on the raw data at low level to facilitate the further fusion of the images. Additionally, if the data are acquired in a stage-scan mode [[4]](#4), the raw images need to be deskewed to corrrect the distortion and converted to regular lightsheet-scan images.

As an example, we provide [a ImageJ macro code](diSPIM_Preprocessing.ijm) along with [a reference](diSPIM_Preprocessing_Referrence.pdf) for preprocesing diSPIM raw data acquired by LabVIEW control software. The macro provides ImageJ-based user interface, including:

- Background subtraction.
- Deskewing: optionally for stage-scan data.
- ROI cropping: to make the images initially aligned and/or more compact to save processing time and storage.
- Maximum intensity projection (MIP).
- 3D orientation: SPIMB image rotation and interpolation.

This works within Fiji that has ImageJ version 1.48c or later, on a PC with Windows 7 or 10 OS. Tested environment: Fiji(Life-Line version, 2013 July 15), Windows 7 and 10.

Depending on the microscope control software (Micro-Manager or LabVIEW) and the acquisition configuration, the preprocessing may vary and users may correspondingly need to customize their own code.

## Dual-view Image Fusion

The fusion of the dual-view images mainly includes the image registration and joint deconvolution, and is computational heavy. So GPU-based parallel computing has been developed using C/C++ and CUDA, and compiled to console applications at the user level. Along with a few other macros/scripts, the applications are deployed as a ready-to-use portable package [diSPIMFusion](https://github.com/eguomin/diSPIMFusion/releases), including:

- 3D orientation: image rotation and interpolation.
- Image registration.
- Joint deconvolution.
- Maximum intensity projection (MIP): choices for 2D and 3D MIP.

The `diSPIMFusion` package provides several options, either GUI interface or command line, for use across Windows and Linux platforms. It is suitalbe for processing images less than 4 GB (single volume after isotropizing the voxels, 16-bit) depending on the actual available GPU memory. For big images (single volume > 4 GB) such as cleared tissue data, users may refer to [the big data processing pipeline](https://github.com/eguomin/regDeconProject) in another GitHub repository.

For source code of the `diSPIMFusion` package, please go to the GitHub repository: [microImageLib](https://github.com/eguomin/microImageLib).

## Usage

Download the latest release verion v1.2.0: [diSPIMFusion.zip](https://github.com/eguomin/diSPIMFusion/releases/tag/v1.2.0) with test data included, and check the user manual [diSPIMFusion_UI_UserManual](diSPIMFusion_UI_UserManual.md).

### System Requirements

- Windows 10 or Linux OS.
- NVIDIA GPU
- Optional: Fiji or ImageJ.

### User Interface Options

#### (Option 1) ImageJ macro-based GUI interface

This is the default option when `diSPIMFusion` package was originally developed. It uses the ImageJ macro to create a GUI for setting parameters and then invokes the application `spimFusionBatch` within the package. To run it, [Fiji](https://fiji.sc/) (or [ImageJ](https://imagej.net)) and [GPU driver](https://www.nvidia.com/Download/index.aspx) compatible with CUDA 10.0 (typically the latest NVIDIA driver should be fine) need to be installed, then:

> a) Copy the package folder `/diSPIMFusion` to Fiji's main path `/Fiji.app`.

> b) Open macro file `diSPIMFusion_UI.ijm` within Fiji and run it following the user manual [diSPIMFusion_UI_UserManual](diSPIMFusion_UI_UserManual.md).

The default settings are configured for the test data, users can also customize parameters for their own data by modifying the first lines in the macro file `diSPIMFusion_UI.ijm`.

**Tested environments:** Windows 10 with NVIDIA Quadro M6000.

#### (Option 2) Command line based interface

The applications can be directly launched by commands via the Windows or Linux terminal. Users may find the applications in the folder `/diSPIMFusion/cudaLib/bin` for Windows and Linux platforms. The `spimFusionBatch` (also used in the ImageJ macro-based option) processes time-lapse images, users may refer to the user manual for ImageJ macro option. For all applications, users can use command with option `-h` or `-help` to find the introduction and manual for each application, e.g.

```posh
spimFusionBatch -h
```

We also provide a few example scripts consisting of a group of *cmd* or *shell* commands that invoke the binary applications with default configurations for the test dataset. To run the scripts, users need to open the command terminal and get to the directory of the scripts, i.e., the folder `./diSPIMFusion/cudaLib`.

1. For Windows PC, run any of the `cmd_xx.bat` scripts, e.g.

    ```posh
    cmd_spimFusionBatch.bat
    ```

2. For Linux PC, run any of the `sh_xx.sh` scripts, e.g.
    
    ```posh
    sh sh_spimFusionBatch.sh
    ```
    
    In case the Linux PC does not have the CUDA or FFTW installed, users will need to add the dependencies directory to the path variable *LD_LIBRARY_PATH* so as to use the libraries provided within the compiled package, e.g., use command:

    ```posh
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:./bin/linux
    sh sh_spimFusionBatch.sh
    ```

**Tested environment:** Windows 10 with NVIDIA Quadro M6000 GPU, Ubuntu 18.04 LTS with NVIDIA Quadro K600.

## Other Resources

More resources related to diSPIM instrument and data processing:

- Wiki page for general information of diSPIM: [dispim.org](http://dispim.org/).
- C/C++ and CUDA source code for `diSPIMFusion` package: [microImageLib](https://github.com/eguomin/microImageLib).
- MIPAV CPU-based image registration and joint deconvolution:  [MIPAV GenerateFusion](http://dispim.org/software/mipav_generatefusion).

Please cite our paper [[3]](#3) if you use the diSPIM data processing code and package provided in this repository.

## References

<a id="1">[1]</a>
Yicong Wu, *et al*. (2013).
"[Spatially isotropic four-dimensional imaging with dual-view plane illumination microscopy](https://doi.org/10.1038/nbt.2713)." Nature biotechnology 31.11 (2013): 1032-1038.

<a id="2">[2]</a>
Abhishek Kumar, *et al*.
"[Dual-view plane illumination microscopy for rapid and spatially isotropic imaging](https://doi.org/10.1038/nprot.2014.172)." Nature protocols 9.11 (2014): 2555-2573.

<a id="3">[3]</a>
Min Guo, *et al*.
"[Rapid image deconvolution and multiview fusion for optical microscopy](https://doi.org/10.1038/s41587-020-0560-x)." Nature Biotechnology 38.11 (2020): 1337-1346.

<a id="4">[4]</a>
Abhishek Kumar, *et al*.
"[Using stage-and slit-scanning to improve contrast and optical sectioning in dual-view inverted light sheet microscopy (diSPIM)](https://doi.org/10.1086/689589)." The Biological Bulletin 231.1 (2016): 26-39.
