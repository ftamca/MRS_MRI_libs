function [temperature, waterppm, naappm] = mrs_calTempFred(filename, dofit)
% MRS_CALTEMPFRED calculates temperature given an MRS raw data file
%
% [temperature, waterppm, naappm] = mrs_calTempFred(filename)
%
% INPUTS:
%
% filename is the name of the raw MRS data file (RDA or MRUI format)
%
% dofit (optional and not recommended) requests fitting with a function
% to find the peak instead of the default (local maximum, which I found
% more reliable): specify 'l' for a Lorentzian, or 'g' for a Gaussian line
% shape. Check your results even more carefully if you use this. Additional
% baseline correction is probably required to use this profitably, but that
% may alter the peak frequency which is what we really want.
%
% OUTPUTS:
%
% temperature is the calculated temperature
% waterppm is the water peak frequency in PPM
% naappm is the NAA peak frequency in PPM
%
% Also plots the spectrum and peaks for quality checking.
%
% This is a hack for our use at Sunnybrook with the Prisma.
% Our current calibration factors are hardcoded!
% Assumes sample points < 16384 (our zero-filled resolution).
% Assumes ranges for water [-0.1 0] and NAA [-2.7 -2.6] peaks (local maxima).
%
% Fred Tam, Sunnybrook Research Institute, 2020
% Calibration factors 2019-02-14, this pipeline, water unsupressed DCM/MRUI
cal_a = -103.2095; cal_b = 310.9396;

% Import the data according to the file format
if regexp(filename, '\.rda$')
    [data, info] = mrs_readRDA(filename);
    data = conj(data); % Siemens trying to be user friendly
    bw = info.BW;
    cfreq = info.transmit_frequency;

elseif regexp(filename, '\.mrui$')
    [data, info] = mrs_readMRUI(filename);
    bw = 1/info.SamplingInterval*1000;
    cfreq = info.TransmitterFrequency;

else
    error('I am only programmed to handle rda and mrui files.');
end

% Zero-fill, apodize, and Fourier transform
data_z = mrs_zerofill(data, 16384-length(data));
data_za = mrs_apod(data_z, bw, 2, 'Lorentzian');
data_zaf = mrs_fft(data_za);

% Find the peaks within the expected ppm ranges for water [-0.1 0.1] and
% NAA [-2.7 -2.6] (@3T @ body temperature). Just search for local maxima
% rather than fit a shape, because a) NAA is not totally distinct, so it
% appears skewed if you try to fit it alone; and b) NAA is strong enough
% that the peak is easy to find well above noise after filtering, even in
% water-unsupressed data. This gave me the most reliable results.
water_range = round([mrs_ppm2points(-0.1, length(data_zaf), bw, cfreq) mrs_ppm2points(0.1, length(data_zaf), bw, cfreq)]);
naa_range = round([mrs_ppm2points(-2.7, length(data_zaf), bw, cfreq) mrs_ppm2points(-2.6, length(data_zaf), bw, cfreq)]);
% Use fitting if the user really wants it instead
if nargin > 1
    [A_peaks_water, I_peaks_water] = mrs_fitPeak(data_zaf, water_range, 1, dofit);
    [A_peaks_naa, I_peaks_naa] = mrs_fitPeak(data_zaf, naa_range, 1, dofit);
else
    [A_peaks_water, I_peaks_water] = mrs_findPeak(data_zaf, water_range);
    [A_peaks_naa, I_peaks_naa] = mrs_findPeak(data_zaf, naa_range);
end

% Convert peaks to PPM and calculate temperature based on the calibration
naappm = mrs_points2ppm(I_peaks_naa, length(data_zaf), bw, cfreq);
waterppm = mrs_points2ppm(I_peaks_water, length(data_zaf), bw, cfreq);
diff_peaks_ppm = waterppm - naappm;
temperature = cal_a .* diff_peaks_ppm + cal_b;

% Plot spectrum and peaks
subplot(2,2,[1,2]);
plot(mrs_points2ppm(1:length(data_zaf), length(data_zaf), bw, cfreq), real(data_zaf), waterppm, A_peaks_water, 'o', naappm, A_peaks_naa, 'x')
title(sprintf('MRS Spectrum, Temperature = %.1f C', temperature));
xlabel('PPM');
set(gca, 'XDir', 'reverse');
subplot(2,2,3);
plot(mrs_points2ppm(water_range(1):water_range(2), length(data_zaf), bw, cfreq), real(data_zaf(water_range(1):water_range(2),:)), waterppm, A_peaks_water, 'o');
title('Water Peak');
xlabel('PPM');
set(gca, 'XDir', 'reverse');
subplot(2,2,4);
plot(mrs_points2ppm(naa_range(1):naa_range(2), length(data_zaf), bw, cfreq), real(data_zaf(naa_range(1):naa_range(2),:)), naappm, A_peaks_naa, 'x');
title('NAA Peak');
xlabel('PPM');
set(gca, 'XDir', 'reverse');
