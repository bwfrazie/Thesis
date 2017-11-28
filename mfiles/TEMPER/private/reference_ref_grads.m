function [stdGrad,ductThresh,adiabatic,dispersionThresh] = ...
    reference_ref_grads( refUnits, hgtUnits, freqHz )
%reference_ref_grads - Standard, ducting & adiabatic refractivity gradients
%
%
% USE: [stdGrad,ductThresh,adiabatic] = reference_ref_grads( refUnits, hgtUnits );
%
%   Returns a "standard atmosphere" and ducting-threshold gradient in units of 
%   [refUnits/hgtUnits].  Valid refUnits inputs are 'M' or 'N'.  Valid
%   hgtUnits are any string recognized by CONVERT.M (e.g. 'ft','m',...), or
%   TEMPER units flag of 0 or 1 (0='ft', 1='m').
%
% EXAMPLE TEST VALUES:
%
%     'M/ft':
%         stdGrad    = 0.036
%         ductThresh = 0.0
%     'M/m':
%         stdGrad    = 0.118
%         ductThresh = 0.0
%     'N/ft':
%         stdGrad    = -0.0119
%         ductThresh = -0.0479
%     'N/m':
%         stdGrad    = -0.0391
%         ductThresh = -0.157
%
% Last update: 2012-05-24 (JZG)


% Update list:
% -----------
% 2006-07-07 - ?
% 2012-05-24 - Added adiabatic output, removed mention of the yet-to-be-
% implemented "dispersionThresh" functionality from header comments.


    if isnumeric( hgtUnits )
        [rngUnits,hgtUnits] = unitflag2str( hgtUnits );
    end

    refUnits  = upper(refUnits);
    hgtUnits  = lower(hgtUnits);
    gradUnits = [refUnits,'/',hgtUnits];

    % This function uses TEMPER's hardcoded (in set_refr.f) value of 3.6d-2
    % M/ft for standard-atmosphere gradient:
    stdGrad_Mft    = 0.036;
    ductThresh_Mft = 0.0;
    adiabatic_Mft  = 0.0408; % <- this is consistent w/ the p=6.82 -> k = p/(p-1) = 1.1718 value from Julius course notes
    
    stdGrad = convert_ref_gradient( stdGrad_Mft, 'M/ft', gradUnits );
    
    if ( nargout >= 2 )
        ductThresh = convert_ref_gradient( ductThresh_Mft, 'M/ft', gradUnits );
    end
    
    if ( nargout >= 3 )
        adiabatic = convert_ref_gradient( adiabatic_Mft, 'M/ft', gradUnits );
    end
    
    if ( nargout >= 4 )
        % See p. 52 of Bean & Dutton "Radio Meteorology" (1968)
        error('NOT YET IMPLEMENTED!');
    end

return