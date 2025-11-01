function shifts_point = mrs_Hz2points( shifts_Hz, samples, BW )
% MRS_HZ2POINTS converts unit of chemical shift from Hz to points
%
% shifts_point = mrs_Hz2points( shifts_Hz, samples, BW )
%
% ARGS :
% shifts_Hz  = an array of chemical shifts in Hz
% samples = number of points sampled for each spectrum
% BW = spectral bandwidth, Hz
%
%
% RETURNS:
% shifts_points = an array of chemical shifts in points
%       --may not be whole numbers: round or interpolate as necessary
%
% EXAMPLE:
% >> shifts_point = mrs_Hz2points(shifts_Hz, info.samples, info.BW)
%
% AUTHOR : Chen Chen
% PLACE  : Sir Peter Mansfield Magnetic Resonance Centre (SPMMRC)
%
% Copyright (c) 2013, University of Nottingham. All rights reserved.
%
% 2019-02-14 Fred Tam (Sunnybrook Research Institute): New function based
%       on mrs_points2Hz in MRS_MRI_libs.

    shifts_point = (shifts_Hz + BW/2) ./ BW .* (samples - 1) + 1;
end

