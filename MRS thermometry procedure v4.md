## MRS Thermometry Procedure, Version 4.1

Fred Tam, 2020-09-29 (4.1 edited 2025-11-01)

### About the MRS data files

You may receive the MR spectroscopy data in up to 4 different formats from our Siemens scanner, roughly in order of preference:

- **.rda**: Raw data exported from the Siemens MRS software. _In this processing pipeline, we prefer to read RDA files directly into Matlab._ They can also be read into jMRUI and converted into MRUI format for reading into Matlab. (However, importing RDA files directly into Matlab gives you the complex conjugate, compared to reading MRUI files. I can’t say which one is right—it’s really a matter of convention—but this is not important to us.)

- **.dcm**: Raw data wrapped in an MRS-specific DICOM format. If this is all you have, read them into jMRUI and convert to MRUI format for reading into Matlab. The data are virtually identical to the RDA files except for the numeric representation and slight differences in the headers.

- **.IMA**: Raw data or images of default-processed spectra. Useful as backups, and the raw data can be reimported on the scanner for conversion to RDA or DCM formats. Some MRS analysis software might work with it directly, but I haven’t found software that does so reliably.

- **.dat**: Really raw data straight off the receiver. Huge file size and limited compatibility. It might be possible to reimport it on the scanner and convert to another format. Some third-party software might be able to read it, but the format changed several years ago.

_Stick with one file type, and therefore one processing stream, for all of a subject’s scans._ There are some slight differences in numeric representation and in the conversion routines for each format. In particular, the differing bandwidth header representation can result in a slight, possibly constant offset in temperature between RDA and DCM files (I’ve seen ~0.5°C). It should be okay if the file type differs between subjects for relative, within-subjects comparison, although it’s not ideal.

The raw data for each series (“scan”) may be separated into one or more measurements in individual files, rather than pre-averaged into a single file. The file names should help you to group them. These are usually intended to be processed separately, to enable first-order dynamic correction and low-level quality inspection, and then averaged together to generate one result for the series.

For thermometry, we currently use water unsuppressed data only, because water suppression tends to distort the residual water signal. In protocols that include both water-unsupressed and water-suppressed MRS series, we typically acquire them in pairs starting with the unsuppressed series. The series name likely includes a note when water suppression is off, which you should use to separate the series.

### Using jMRUI to inspect and convert data formats (Optional)

Optionally, freeware [jMRUI](http://www.jmrui.eu/) (stable version 5.2) may be used to read RDA and DCM files, quickly inspect the data, and export to MRUI format, if needed. One side benefit with jMRUI is that you can easily select and load all measurements in a series together for inspection, if the raw data files were split by measurement (you could load all measurements from all series together too, but that could get confusing with multiple measurements).

1. Start jMRUI. File → Open (or toolbar Open) and navigate to the directory containing the MRS data files. Select the data for all measurements in one series (tip: resize the Load window to make it easier to see and select files). Load.

2. Quickly inspect the data plot to see if the data look okay. Check the dataset list to the left of the plot and ensure the data are sorted as expected, because _the data will be saved in that order—which may not match the sort order in the file selection dialogue!_ (*shakes fist*) You will probably need to renumber the filenames to correct the order (you can do this right inside the Load dialogue).

3. If working with DCM files, convert to MRUI format. File → Save as → MRUI. Type in a file name, e.g. Subject1_Series09. Save. By default, this will save the data to the source directory. This may take several seconds, during which jMRUI will appear to freeze.

4. Repeat 1-3 for all MRS series. Move the resulting data files in jMRUI’s format to a convenient location for further processing with Matlab.

### Using Matlab to calculate temperature

This could be done in jMRUI, but Matlab is easier and more reliable for processing large amounts of data. Add [this version of MRS_MRI_libs containing Fred's modifications](https://github.com/ftamca/MRS_MRI_libs) (just the MRS_lib part is enough) to the end of your Matlab path.

Within this collection of functions, the mrs_calTempFred function implements the pipeline. Briefly: Import the data as appropriate, zero-fill, apodize, Fourier transform, find the water and NAA peaks, and calculate temperature based on calibration values. Peak finding searches for local maxima, as that seemed most reliable in my testing (less susceptible to skewed peaks and uneven baselines), but peak fitting with a Lorentzian (or Gaussian) is possible if you really want to try it—read the mrs_calTempFred help for how. It also plots the spectrum and peaks for quality checking, which is especially important to see if fitting with a function worked (I’ve seen some bad failures).

1. Start Matlab, with the above functions installed, and navigate to your data directory. Substitute the filename of your RDA or MRUI file:

    `[temperature, waterppm, naappm] = mrs_calTempFred('rda0.rda')`

2. Record these data. Of course, the temperature is the primary metric, but the peak frequencies may be useful for troubleshooting. If measurements were separated into multiple files, average the temperature estimates together to get your final temperature. You can copy the values to a central spreadsheet to keep all the data for the project together, and to organize for analysis and reporting. Saving variables directly to files from Matlab is also an option, particularly if you want to do further work in Matlab.