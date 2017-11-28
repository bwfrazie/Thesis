function [grz,rng,rngUnits,iTyp,typLegend,file] = read_grz(file)
%read_grz - Reads data from a TEMPER grazing angle (.grz) file.
%
%   Input name of .grz file (string, full path & filename), or run with no
%   inputs to graphically select the .grz file.
%
%   Works for TEMPER v3.x, as well as older versions back to version "beta 7".
%
%
% USE: [grz,rng,rngUnits,iTyp,typLegend,file] = read_grz( [file] );
%
%   grz  - Grazing angles vs. range, in degrees.
%   rng  - Range vector, in "rngUnits".
%   rngUnits - String giving the units of range vector ('km' or 'nmi').
%   iTyp - Vector giving the TEMPER estimation method used to generate a
%       grazing angle at each range step.  This is a vector of integers.
%   typLegend - Cellstr of descriptive lables for the integer values found in
%       "iTyp"; e.g. typLenged{iTyp(n)} is a string that describes the TEMPER
%       estimation method used at the "nth" range step.
%
%
% USE: [...,iTyp,typLegend] = read_grz( ... );
%
%   Same as above, except takes a little extra time to read TEMPER estimation
%   method info out of v3.x .grz files:
%
%   iTyp - Vector giving the TEMPER estimation method used to generate a
%       grazing angle at each range step.  This is a vector of integers.
%   typLegend - Cellstr of descriptive lables for the integer values found in
%       "iTyp"; e.g. typLenged{iTyp(n)} is a string that describes the TEMPER
%       estimation method used at the "nth" range step.
%
%
% ©1998-2015, Johns Hopkins University / Applied Physics Lab
% Last update: 2015-02-22 (JZG)


% Update list:
% -----------
% 2006-01-04 - Updates to original MHN function.
% 2015-02-22 - Added file output.

	
    % Initialize outputs to empty:
    [grz,rng,rngUnits,iTyp,typLegend,file] = deal([]);

    % Empty "file" input triggers graphical selection
	if ( nargin < 1 ), file = []; end
    
    if isempty( file )
       [f,p] = uigetfile('*.grz');
       if isnumeric(f), return; end
       file = fullfile(p,f);
       cd(p);
	end
		
	fid = fopen( file, 'rt' );
	lineStr = fgetl(fid);
    
	% check for pre-beta 7 format (no header info)
    lineStr = strrep(lineStr,' ','');
    firstNonBlankChar = upper(lineStr(1));

    % Versions of TEMPER that are newer than "beta 7" will begin with the
    % following line:
    %   Range    Angle   Estimation  ...
    isPreBeta7Format = ( firstNonBlankChar ~= 'R');
        
    % Read header (only present in newer versions)
    if ( isPreBeta7Format )
        % No header - rewind to beginning of file:
        frewind( fid );
        rngUnits = '?';
        if ( nargout >= 3 )
            warning('range units unknown for .grz''s prior to ver. beta-7');
        end
    else
    	% This is beta 7 or later - includes header info:
        lineStr  = fgetl(fid);
        i1 = findstr( lineStr, '[' ); i1 = i1(1)+1;
        i2 = findstr( lineStr, ']' ); i2 = i2(1)-1;
        rngUnits = lineStr(i1:i2);
        % Skip one more line to position file i/o pointer at beginning of data:
        lineStr = fgetl(fid);
    end
    
    % Read data:
    
    ioDataPos = ftell( fid );

    % Get range & angle data:
    if ( isPreBeta7Format )
        fmt = '%f%f';
    else
        fmt = '%f%f%*s';
    end
    data = fscanf( fid, fmt, [2,inf] );
    rng = data(1,:);
    grz = data(2,:);
    
    getAngleType = ( nargout >= 4 );
    
    % Get angle type data:
    if ( isPreBeta7Format )
        iTyp = repmat({'?'},size(rng));
        if ( nargout >= 4 )
            warning('angle type unknown for .grz''s prior to ver. beta-7');
        end
    else
        fseek( fid, ioDataPos, 'bof' );
        % This format will read in first character of every third-column string
        % in the file:
        fmt = '%*f%*f%*[\t ]%c%*s';
        typChars = fscanf( fid, fmt, [1,inf] );
        % Note that FSCANF pulls in ASCII integers, not the actual characters,
        % for format '%c'.
        iTyp = repmat(NaN,size(rng));
        % 4/3 Earth Geometry -> '4/3E'
        iTyp(find(typChars==char('4'))) = 1;
        % Geometry Optics -> 'GO'
        iTyp(find(typChars==char('G'))) = 2;
        % Spectral Estimation -> 'SE'
        iTyp(find(typChars==char('S'))) = 3;
        % Create output legend:
        typLegend = {'4/3E','GO','SE'};
    end
	
	fclose(fid);
    
return
