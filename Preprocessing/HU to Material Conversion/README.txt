Description:
The scripts in this folder take calibration data and generate the HU to material conversion calibration curve by  following Schneider's paper.

Scripts:
1. HA_Calibrate.m - Calculates the calibration constants in Schneider's paper from measurement data 
2. HA_Create_tissue_constants.m - Calculates the tissue constants 
3. HA_Fluka_input_maker.m - Creates the final input files for FLUKA/FLAIR to convert DICOM to Voxels

Functions:
1. HA_interpolate_rhos.m - Interpolate density values using linear interpolation
2. HA_interpolate_elwt.m - Interpolate elemental weights for the materials using Schneider's equations
3. HA_interpolate_rhos_stline.m - Interpolate elementatl weights using linear interpolation for certain HU range.
4. HA_find_rel_attn.m - Used to find the relative attenuation with respect to H20 
5. write_all_material.m - Writes the output in format readable by FLUKA/FLAIR