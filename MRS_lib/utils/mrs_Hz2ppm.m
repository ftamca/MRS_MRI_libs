function shift_ppm = mrs_Hz2ppm( shift_Hz , transmit_freq )
% MRS_HZ2PPM converts unit of a chemical shift from Hz to ppm
%
% shift_ppm = mrs_Hz2ppm(shift_Hz , transmit_freq)
%
% ARGS :
% shift_Hz  = the chemical shift between two peaks in Hz
% transmit_freq = synthesizer frequency, Hz
%
% RETURNS:
% shift_ppm = the chemical shift between two peaks in ppm
%
% EXAMPLE:
% >> shift_Hz = 200; % delta Hz
% >> shift_ppm = mrs_Hz2ppm(shift_Hz,info.transmit_frequency)
%
% AUTHOR : Chen Chen
% PLACE  : Sir Peter Mansfield Magnetic Resonance Centre (SPMMRC)
%
% Copyright (c) 2013, University of Nottingham. All rights reserved.
%
% 2019-02-14 Fred Tam (Sunnybrook Research Institute): New function based on
%       mrs_ppm2Hz.m in MRS_MRI_libs (except rather than absolute
%       frequency, it makes more sense to convert relative frequency to ppm).

    shift_ppm = shift_Hz / transmit_freq / 10^(-6);
end

