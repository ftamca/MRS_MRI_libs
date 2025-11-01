function [data, info] = mrs_readMRUI( fileName )
% MRS_READMRUI reads data and header information from a jMRUI MR spectroscopy data file (.mrui)
%
% [data info] = mrs_readMRUI( fileName )
%
% ARGS :
% fileName = name of data file
%
% RETURNS:
% data = averaged FIDs
% info = header information
%        (Tip: bandwidth in Hz = 1/info.SamplingInterval*1000
%         because info.SamplingInterval is in ms)
%
% EXAMPLE:
% >> [data info] = mrs_readMRUI('sub1.mrui');
% >> size(data)
%
% AUTHOR : Fred Tam
% PLACE  : Sunnybrook Research Institute
%
% Copyright (c) 2019, Sunnybrook Research Institute. All rights reserved.
%
% Compatible with MRS_MRI_libs (but watch out for different info conventions).

    [~,~,ext]=fileparts(fileName);
    if isempty(ext)==1
        fileName=[fileName,'.mrui'];
    end

    fid = fopen(fileName, 'r', 'ieee-be.l64');

    % Read header
    info.TypeOfSignal   = fread(fid, 1, 'double');
    info.NumberOfPoints = fread(fid, 1, 'double');
    info.SamplingInterval   = fread(fid, 1, 'double');
    info.BeginTime      = fread(fid, 1, 'double');
    info.ZeroOrderPhase = fread(fid, 1, 'double');
    info.TransmitterFrequency   = fread(fid, 1, 'double');
    info.MagneticField  = fread(fid, 1, 'double');
    info.TypeOfNucleus  = fread(fid, 1, 'double');
    info.ReferenceFrequencyHz   = fread(fid, 1, 'double');
    info.ReferenceFrequencyPpm  = fread(fid, 1, 'double');
    info.IsEcho         = fread(fid, 1, 'double');
    fseek(fid, 104, -1);
    info.NumberOfFrames = fread(fid, 1, 'double');

    data = complex(zeros(info.NumberOfPoints, info.NumberOfFrames));

    % Read data, one frame at a time
    fseek(fid, 512, -1);
    for frame = 1 : info.NumberOfFrames
        tempframe = fread(fid, info.NumberOfPoints * 2, 'double');
        data(:, frame) = complex(tempframe(1:2:end), tempframe(2:2:end));
    end

    % Don't bother with the metadata strings at the end for now

    fclose(fid);
end
