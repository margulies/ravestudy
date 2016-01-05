ISC toolbox 2.1
Homepage: https://code.google.com/p/isc-toolbox/

To get started with the toolbox move to the root folder of the toolbox and type the following in Matlab command prompt:

setISCToolboxPath; ISCanalysis;

"setISCToolboxPath" defines necessary paths to Matlab path and
"ISCanalysis" starts the analysis startup GUI.

By adding the ISCToolbox root folder and the subfolders to the default path of the Matlab there is no more need to run the the setISCToolboxPath function and the analysis tools can be started from any working folder:
This can be done in Matlab by: 
File -> Set Path -> Add Folder with Subfolders -> <select the main isctoolbox folder> -> Save 


We suggested that only one ISCtoolbox is defined in Matlab path at a time, so if multiple versions of ISCToolbox are needed the safest way to use them without possible conflicts is to remove all ISCToolbox paths from the Matlab default path and run the selected version from its own folder with the setISCToolboxPath function as described earlier.

To carry out the analysis, preprocessed 4-dimensional (X,Y,Z,Time) mat- or nifti files must be available from 2 or more subjects.

The MNI152 templates are necessary if one is willing to use a visualization software but they are not included in the toolbox due to licensing issues. The templates are freely distributed with the FSL analysis tools (http://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FSL). The templates are found in the FSL installation folders: 
$FSLDIR/data/standard/
$FSLDIR/data/atlases/HarvardOxford

The required files are (place them in templates/ folder of ISCtoolbox):

HarvardOxford-cort-maxprob-thr0-2mm.nii
HarvardOxford-cort-maxprob-thr25-2mm.nii
HarvardOxford-cort-maxprob-thr50-2mm.nii
HarvardOxford-cort-prob-2mm.nii
HarvardOxford-sub-maxprob-thr0-2mm.nii
HarvardOxford-sub-maxprob-thr25-2mm.nii
HarvardOxford-sub-maxprob-thr50-2mm.nii
HarvardOxford-sub-prob-2mm.nii
MNI152_T1_2mm_brain_mask.nii
MNI152_T1_2mm_brain.nii

Hence, to allow the use of visualization software, the fMRI data sets must be registered to a 2mm MNI template before the ISC analysis. The ISC visualization tool can be launched directly from the Start-up GUI or from the command line by typing: ISCtool;

In case of any questions regarding the use of the ISC toolbox, send email to the corresponding authors: jukka-pekka.kauppi@helsinki.fi or juha.pajula@tut.fi. 
