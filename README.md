# Overview

Dual-view inverted Selective Plane Illumination Microscopy (diSPIM) [[1]](#1)[[2]](#2) enables isotropic 3D resolution by fusing two view images acquired by two orthogonally configured arms. This repository provides a brief description and a collection of code on processing diSPIM data with GPU implementation [[3]](#3), mainly including two parts:
- **Image preprocessing**: basically ROI selection, background removal, image deskewing, etc.
- **Dual-view image fusion**: registration and joint deconvolution, this is the major computation part, also refered to as `diSPIMFusion`.

## Image Prepocessing

The preprocessing includes several operations on the raw dada at low level to facilitate the further fusion of the images. Additionally, if the data are acquired in a stage-scan mode [[4]](#4), the raw images need to be deskewed to corrrect the distortion and converted to regular lightsheet-scan images.

As an example, we provide [a ImageJ macro code](https://github.com/eguomin/diSPIMFusion/blob/master/diSPIM_Preprocessing.ijm) along with [a reference](https://github.com/eguomin/diSPIMFusion/blob/master/diSPIM_Preprocessing_Referrence.pdf) for preprocesing diSPIM raw data acquired by LabVIEW control software. The macro provide ImageJ based user interface, involving:
- Background subtraction.
- Deskewing: optionally for stage-scan data.
- ROI cropping: to make the images initially aligned and/or more compact to save processing time and storage.
- Maximum intensity projection (MIP).
- 3D orentiation: SPIMB image rotation and interpolation.

It is supposed to work within Fiji that has ImageJ version 1.48c or later, on a PC with Windows 7 or 10 OS. Tested enveronment: Fiji(Life-Line version, 2013 July 15), Windows 7 and 10.

Depending on the microscope control software (Micro-Manager or LabVIEW) and the acquisition configuration, the preprocessing may vary and users may correspondingly need to customize their own code.

## Dual-view Image Fusion

The fusion of the dual-view images mainly includes the image registartion and joint deconvolution, and is computational heavy. So GPU-based parallel computing has been developed using C/C++ and CUDA, and compiled to console applications at the user level. Along with a few other macros/scripts, the applications are deployed as a ready-to-use portable package [`diSPIMFusion`](https://www.dropbox.com/sh/czn4kwzwcgy0s3x/AADipfEsUSwuCsEBg8P7wc4_a?dl=0), involving:
- 3D orentiation: image rotation and interpolation.
- Image registration.
- Joint deconvolution.
- Maximum intensity projection (MIP): choices for 2D and 3D MIP.

The `diSPIMFusion` package provides several options, either GUI interface or command line, to use the applications cross Windows and Linux platforms. It is suitalbe for processing images less than 4 GB (single volume after isotropizing the voxels, 16-bit) depending on the actual available GPU memory. For big images (single volume > 4 GB) such as cleared tissue data, users may refer to [the big data processing pipeline](https://github.com/eguomin/regDeconProject) in another GitHub repository.

For source code of the `diSPIMFusion` package, please go to the GitHub repository: [microImageLib](https://github.com/eguomin/microImageLib).

## Usage

Download the [diSPIMFusion](https://www.dropbox.com/sh/czn4kwzwcgy0s3x/AADipfEsUSwuCsEBg8P7wc4_a?dl=0) package along with the test data, and check the user manual [diSPIMFusion_UI_UserManual.pdf](https://github.com/eguomin/diSPIMFusion/blob/master/diSPIMFusion_UI_UserManual.pdf).

### System Requirements

- Windows 10 or Linux OS. 
- NVIDIA GPU
- Optional: Fiji or ImageJ.

### User Interface Options

#### 1. Fiji macro based GUI interface

This is the default option when `diSPIMFusion` package was originally developed. It uses the ImageJ macros to create a GUI for setting parameters and then invokes the `spimFusionBatch` application within the package. To run it, [Fiji](https://fiji.sc/) (or [ImageJ](https://imagej.net)) and [GPU driver](https://www.nvidia.com/Download/index.aspx) compatible with CUDA 10.0 (typically the latest NVIDIA driver should be fine) need to be installed, then:

> a) Copy the package folder `/diSPIMFusion` to `/Fiji.app` folder.

> b) Open `diSPIMFusion_UI.ijm` file within Fiji and run it following the associated user manual [diSPIMFusion_UI_UserManual.pdf](https://github.com/eguomin/diSPIMFusion/blob/master/diSPIMFusion_UI_UserManual.pdf).

The default settings are configured for the test data, users can also customize parameters for their own data by modifying the first lines in the macro file `diSPIMFusion_UI.ijm`. 

**Tested environments:** Windows 10 with NVIDIA Quadro M6000.

#### 2. Command line based interface

The console applications can be directly luanched by commands via the Windows or Linux terminal. Users may find the applications in the folder `/diSPIMFusion/cudaLib/bin` for Windows or Linux OS. The `spimFusionBatch` (also used in the Fiji macro option) processes time-lapse images, users may refer to the user manual for Fiji macro option. For other applications, users can use command with option `-h` or `-help` to find the introduction and manual, e.g.
```posh
spimFusionBatch -h
```
We also provide a few example scripts consisting of a group of *cmd* or *shell* commands that invoke the binary applications with default configurations for the test dataset. To run the scripts, users need to open the command terminal and get to the directory of the scripts, i.e., the folder `./diSPIMFusion/cudaLib`.

1) For Windows PC, run any of the `cmd_xx.bat` scripts, e.g.
```posh
cmd_spimFusionBatch.bat
```
2) For Linux PC, run any of the `sh_xx.sh` scripts, e.g.
```posh
sh sh_spimFusionBatch.sh
```
In case the Linux PC does not have the CUDA or FFTW installed, users will need to add the dependencies directory to the path variable *LD_LIBRARY_PATH* so as to use the libraries provided within the compiled package, e.g., use command:
```posh
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:./bin/linux
sh sh_spimFusionBatch.sh
```
**Tested environment:** Windows 10 with NVIDIA Quadro M6000 GPU, Ubuntu 18.04 LTS with NVIDIA Quadro K600.

Please cite our paper [[3]](#3) if you use the code/document provided in this repository.

## Other Resources

More resources related to diSPIM instrument and data processing: 
- Wiki page for general information of diSPIM: [dispim.org](http://dispim.org/).
- C/C++ and CUDA source code for `diSPIMFusion` package: [microImageLib](https://github.com/eguomin/microImageLib).
- MIPAV CPU-based image registration and joint deconvolution:  [MIPAV GenerateFusion](http://dispim.org/software/mipav_generatefusion).

## Reference

<a id="1">[1]</a>
Yicong Wu *et al.* (2013).
"Spatially isotropic four-dimensional imaging with dual-view plane illumination microscopy." Nature biotechnology 31.11 (2013): 1032-1038. https://doi.org/10.1038/nbt.2713

<a id="2">[2]</a>
Abhishek Kumar *et al.* (2014).
"Dual-view plane illumination microscopy for rapid and spatially isotropic imaging." Nature protocols 9.11 (2014): 2555-2573. https://doi.org/10.1038/nprot.2014.172

<a id="3">[3]</a>
Min Guo *et al.* (2020).
"Rapid image deconvolution and multiview fusion for optical microscopy." Nature Biotechnology (2020): 1-10. https://doi.org/10.1038/s41587-020-0560-x

<a id="4">[4]</a>
Abhishek Kumar *et al.* (2016).
"Using stage-and slit-scanning to improve contrast and optical sectioning in dual-view inverted light sheet microscopy (diSPIM)." The Biological Bulletin 231.1 (2016): 26-39. https://doi.org/10.1086/689589

