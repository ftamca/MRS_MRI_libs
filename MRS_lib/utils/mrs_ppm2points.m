function shifts_point = mrs_ppm2points( shifts_ppm, samples, BW, transmit_freq)
% MRS_PPM2POINTS converts unit of chemical shift from ppm to points
%
% shifts_point = mrs_ppm2points(shifts_ppm, samples, BW, transmit_freq)
%
% ARGS :
% shifts_ppm  = an array of chemical shifts in ppm
% samples = number of points sampled for each spectrum
% BW = spectral bandwidth, Hz
% transmit_freq = synthesizer frequency, Hz
%
% RETURNS:
% shifts_points = an array of chemical shifts in points
%
% EXAMPLE:
% >> shifts_point = mrs_ppm2points(shifts_ppm, info.samples, info.BW, info.transmit_frequency)
%
% AUTHOR : Chen Chen
% PLACE  : Sir Peter Mansfield Magnetic Resonance Centre (SPMMRC)
%
% Copyright (c) 2013, University of Nottingham. All rights reserved.
%
% 2019-02-14 Fred Tam (Sunnybrook Research Institute): New function based
%       on mrs_points2ppm in MRS_MRI_libs.

    shifts_point = mrs_Hz2points(shifts_ppm .* (transmit_freq / 10^6), samples, BW);
end

