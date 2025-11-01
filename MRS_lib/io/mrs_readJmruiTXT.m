function [fids, spects, info] = mrs_readJmruiTXT( fileName )
% MRS_READJMRUITXT reads jMRUI output MRS data file in .txt format 
%
% [fids spects info] = mrs_readJmruiTxt( fileName )
%
% ARGS :
% fileName = name of data file 
%
% RETURNS:
% fids = FIDs 
% spects = spectra 
% info = header file information
%
% EXAMPLE: 
% >> [fids spects info] = mrs_readJmruiTXT('sub1.txt');
%
% REFERENCE: 
% jMRUI software : http://www.mrui.uab.es/mrui/mrui_Overview.shtml
%
% AUTHOR : Chen Chen
% PLACE  : Sir Peter Mansfield Magnetic Resonance Centre (SPMMRC)
%
% Copyright (c) 2013, University of Nottingham. All rights reserved.
%
% 2019-02-14, Fred Tam (Sunnybrook Research Institute): Added info output,
%   fixed blank dataset output.

	[~,~,ext]=fileparts(fileName);    
	if isempty(ext)==1
        fileName=[fileName,'.txt'];
	end
    
    fid=fopen(fileName,'r');
	content=textscan(fid,'%s','delimiter','\n');   
	fclose(fid);
    
    % .txt is ambiguous. Check for magic string.
    if strcmp('jMRUI Data Textfile', content{1}{1}) == 0
        error('%s does not appear to be a jMRUI Data Textfile\n', fileName);
    end

	no_lines=size(content{1});
    sig_c = 0;        
	for i=1:no_lines 
        
        line=content{1}{i};
        
        % Header fields (except the column headers) are all delimited by :
        if strfind(line, ':')
            str_temp = textscan(line, '%s', 'delimiter', ':');

            % Populate the info with known values and whatever else is there
            switch str_temp{1}{1}
            case {'PointsInDataset', 'DatasetsInFile', 'SamplingInterval', ...
                'ZeroOrderPhase', 'BeginTime', 'TransmitterFrequency', ...
                'MagneticField', 'TypeOfNucleus'}

                info.(str_temp{1}{1}) = str2double(str_temp{1}{2});
            otherwise
                if length(str_temp{1}) > 1
                    info.(str_temp{1}{1}) = str_temp{1}{2};
                else
                    info.(str_temp{1}{1}) = [];
                end
            end

            % Extract a few things we need for initialization too
            switch str_temp{1}{1}
            case 'PointsInDataset'
                sample = info.PointsInDataset;
            case 'DatasetsInFile'
                num = info.DatasetsInFile;

                % Assuming sample is always defined before num at the file start
                % A separate header scan would be safer, but whatever
                fids = zeros(sample,num);
                spects = zeros(sample,num);
            end
        
        % Delimiter for beginning of next signal (just 'Signal' matches header)
        elseif regexp(line, 'Signal \d+ out of \d+ in file')
            sig_c = sig_c+1;
            p=0;

        % Looks like data (close enough)
        elseif sig_c >= 1 && length(regexp(line, '([+-]?[\d\.]+([Ee][+-]?\d+)?|[Nn][Aa][Nn]|[+-]?[Ii][Nn][Ff])')) >= 4
            p = p+1;
            str_temp = textscan(line, '%f');
            fids(p,sig_c)= str_temp{1}(1) + 1i*str_temp{1}(2);
            spects(p,sig_c)= str_temp{1}(3) + 1i*str_temp{1}(4);
        end

	end
end

