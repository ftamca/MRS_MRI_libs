function fids_apod = mrs_apod( fids, BW, LB, filtType )
% MRS_APOD multiplies each FID by an apodizing filter (a line broadening filter)
% to eliminate sinc ringing caused by a truncated FID. 
% 
% fids_apod = mrs_apod( fids, BW, LB )
% fids_apod = mrs_apod( fids, BW, LB, filtType )
%
% ARGS :
% fids = FIDs before apodization       (dim=[samples,avgs,dyns])
% BW = spectral bandwidth   (Hz)
% LB = the FWHM of the exponential filter (Hz)
% filtType = the type of filter to use (default = 'Exponential')
%
% You can choose from these filters:
%   'Exponential' => E(t)=exp(-pi*LB*t)
%   'Lorentzian'  => L(i)=a*a/(pi*i*i + a*a)  (from jMRUI manual)
%   'Gaussian'    => G(i)=exp(-i*i / (2*a*a)) (from jMRUI manual)
%                    where a=1/(LB * 1/BW)
%                    and i=0:samples-1
% 
% RETURNS:
% fids_apod = FIDs after apodization   (dim=[samples,avgs,dyns])
%
% EXAMPLE: 
% >> FID_apod = mrs_apod(FID, 4000, 5); 
% >> figure; plot(real(FID));
% >> hold on; plot(real(FID_apod),'r');
%
% AUTHOR : Chen Chen
% PLACE  : Sir Peter Mansfield Magnetic Resonance Centre (SPMMRC)
%
% Copyright (c) 2013, University of Nottingham. All rights reserved.
%
% 2019-02-14, Fred Tam (Sunnybrook Research Institute): Added
%   Lorentzian and Gaussian filters from jMRUI.

    [samples, avg, dyn]= size(fids);  
   
    % apodization 
    if LB~=0 
        if nargin >= 4 && strcmp('Lorentzian', filtType)
            i = 0:samples-1;
            a = 1/(LB * 1/BW);
            filter = a*a./(pi.*i.*i + a*a);
        elseif nargin >= 4 && strcmp('Gaussian', filtType)
            i = 0:samples-1;
            a = 1/(LB * 1/BW);
            filter = exp(-i.*i / (2*a*a));
        else % the original Exponential
            t = 0:(1/BW):((samples-1)/BW);
            filter=exp(-pi*LB.*t);
        end
        
        filter=repmat(filter',1,avg);
        
        for d=1:dyn
            fids_apod(:,:,d)=fids(:,:,d).*filter; 
        end
    else
        fids_apod=fids;
    end     
end

