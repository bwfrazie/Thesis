function P = read_pat( f )
%read_pat - Reads a TEMPER antenna pattern file.
%
%
% USE: P = read_pat( [f] );
%
%   (optional) Input "f" is name of file containing pattern.  If omitted, or if
%   the input value is empty [], a graphical file selection box appears. 
%
%   Output "P" is structure with elements:
%        file  : .pat file name
%        above : normalized voltage amplitude above boresight (1st column)
%        below :  " "  below boresight (2nd column), or empty if no 2nd column
%        angle : vector of angles in degrees above & below boresight (i.e. 
%                the angular abscissa of first two output vectors)
%
%
% © 2003-2015 JHU/APL (jonathan.gehman@jhuapl.edu)
% Last update: 2006-11-01 (JZG)

% Update list:
% 2003-10-13 (JZG) Significant code improvements & header comments.
% 2006-11-01 (JZG) Added empty input file-prompt trigger & RESHAPE to column

    if ( nargin == 0 ), f = []; end % empty triggers graphical file selection
    
    if isempty(f)
    	[patFile, patPath] = uigetfile('*.pat');
        if isnumeric(patFile), P = []; return; end
    	f = fullfile(patPath,patFile);
    else
       [patPath,patFile] = fileparts(f); %trim any path names
    end			%"file" variable for display purposes only

	% open file
	fid = fopen( f , 'rt' );
	% pull first line out of file as a string
	line1 = fgetl(fid);
	% scan the angle increment out of string - kick error if no float value available
	[deltaAng,COUNT] = sscanf(line1,'%f',1);
	if COUNT~=1
		error(['Could not find an angle increment in line #1 of ',patFile]);
	end
	line2 = fgetl(fid);
	[temp,COUNT] = sscanf(line2,'%f',inf);
	switch COUNT
	case 1
		[theRest,COUNT2] = fscanf(fid,'%f',inf);
		pat = zeros( 1 , 1 + COUNT2 );
		pat(1) = temp;
		pat(2:end) = theRest;
		pabove = pat;
		pbelow = [];
		cols = 1;
	case 2
		[theRest,COUNT2] = fscanf(fid,'%f',[2,inf]);
		pat = zeros( 2 , 1 + COUNT2/2 );
		pat(1,1) = temp(1);
		pat(2,1) = temp(2);
		pat(:,2:end) = theRest;
		pabove = pat(1,:);
		pbelow = pat(2,:);
		cols = 2;
	otherwise
		error(['Second line in ' f ' must contain 1 or 2 values']);
	end

    fclose(fid);

	%create vector of angles corresponding to the pattern data based
	%on the first number ingested - the pat file's increment.
	ang = deltaAng .* [0:length(pabove)-1];

	P = struct(...
        'file',  f,...
	    'above', pabove,...
	    'below', pbelow,...
	    'angle', ang );
    
    P.above = reshape( P.above, [length(P.above),1] );
    P.below = reshape( P.below, [length(P.below),1] );
    P.angle = reshape( P.angle, [length(P.angle),1] );

return