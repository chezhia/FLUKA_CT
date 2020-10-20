Description:
The scripts in this folder take calibration data and generate the HU to material conversion calibration curve by  following Schneider's paper.

Scripts:
1. Dicom_preproc.m - Preprocess DICOM scan to get rid of table in the phantom/patient scan
2. Dicom_rescale.m - Rescale the phantom scan to match the high resolution Table scan
3  Dicom_fuse_AF.m - Fuses the table scan and phantom scan [Adult Female Phantom]
4  Dicom_fuse_CTDI.m - Fuses the table for CTDI phantom scan 
5  Dicom_fuse_5yr.m  - Fuses the table for 5yr old phantom scan 
   Dicom_fuse_AF for Adult Female is the latest version and should be used for
   further modifications to suit new patient/phantom scans. The folders contain
   images for the adult phantom alone.

Functions:
1. pad.m - used to pad strings