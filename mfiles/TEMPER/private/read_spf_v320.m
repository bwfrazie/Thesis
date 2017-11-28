function S = read_spf_v320( fileOrFid )
%read_spf_v320 - Helper function for read_spf.m
%
%
%
%  S = read_spf_v320( fid );
%
%   See help comments in read_spf.m. Input an open file I/O "fid", file will
%   still be open when routine returns, unless an error occurs.
%
%   TEMPER     spf format
%   version:   style:          read by:
%   -------    ----------      -------
%   3.2.0.0000 v3.1.2          read_spf.m
%   3.2.0.0005 in flux         read_spf.m
%   3.2.0.0020 v3.2.0          read_spf_v320.m
%
%
% Created KAG (JHU/APL - A2A)
% Last update: 2015-09-24 (KAG)


% Updates:
% -------
% 2015-09-24 (KAG) Change OSG Seed from unit to int
% 2015-02-10 (KAG) Make sure fid is reset to beginning of file before doing any
% reading.
% 2015-02-08 (JZG) Updated header comments and changed from file input to fid,
% to avoid confusion with read_spf.m going forward. Also fixed a few minor
% issues in some of the lesser-used output struct fields.
% 2015-01-15 (KAG) Created.

closeFidBeforeReturn = 0;

if nargin ~= 1
    error('1 input required (open fid or filename)');
elseif ~isnumeric( fileOrFid )
    if ischar( fileOrFid )
        spfFile = fileOrFid;
        if exist( fileOrFid, 'file' )
            closeFidBeforeReturn = 1;
            fid = fopen( spfFile, 'rb' );
        else
            error(['Cannot find file: ',spfFile]);
        end
    else
        error('Invalid input, please provid an open fid or a filename');
    end
elseif (isnumeric(fileOrFid))
    if( fileOrFid == -1 )
        error('Input fid corresponds to a file that could not be opened');
    else
        fid = fileOrFid;
    end
end

%Reset fid to beginning of file
fseek(fid,0,0);
% check to see if this is a version 3.1.2 or later file
reclen = fread(fid,1,'int');
ver    = fread(fid,1,'int');
fseek(fid,0,-1);

% (KAG) 09/12/13 Add
% Convert function to use version + bug fix
verNum = ver/10;

% If version number is still > 10, it could be a 100*version file ...
if ( verNum > 10 ), verNum = ver/100; end

% ... or it could be the newest 1e6*version file
if ( verNum > 10 ), verNum = ver/1e6; end

% ... or maybe I made a mistake?
if ( verNum > 10 )
    error('Code bug detected, or developers got industrious');
    % ... I don't think we'll ever see v10.0!
end

ver = verNum;
% version number + bug fix number when the v3.2.0 inputs went into the
% temper header

% kag 01/01/15 v.320 header finailized in version 3.2.0.0020. Send to new
% function if header >= 3.200020.

if( ver < 3.200020*(1-eps) )
    fclose(fid);
    error('call read_spf.m for formats prior to 3.2.0.0020');
end

Header = read_head_v320(fid);
nHeaderRec = Header.numHead;

fseek(fid,nHeaderRec*Header.reclen,-1);
rng(1,:) = fread(fid,[1,Header.nr],'double',Header.reclen-8);

fseek(fid,nHeaderRec*Header.reclen+08,-1);
ter(1,:) = fread(fid,[1,Header.nr],'float',Header.reclen-4);

fseek(fid,nHeaderRec*Header.reclen+12,-1);
ang(1,:) = fread(fid,[1,Header.nr],'float',Header.reclen-4);

fseek(fid,nHeaderRec*Header.reclen+16,-1);
epr(1,:) = fread(fid,[1,Header.nr],'double',Header.reclen-8);

fseek(fid,nHeaderRec*Header.reclen+24,-1);
epi(1,:) = fread(fid,[1,Header.nr],'double',Header.reclen-8);

fseek(fid,nHeaderRec*Header.reclen+32,-1);
rgh(1,:) = fread(fid,[1,Header.nr],'double',Header.reclen-8);

fseek(fid,nHeaderRec*Header.reclen+40,-1);
itm(1,:) = fread(fid,[1,Header.nr],'int32',Header.reclen-4);

fseek(fid,nHeaderRec*Header.reclen+44,-1);
prec = [num2str(2*Header.nz),'*double'];

skip = Header.reclen - 16*Header.nz;
[pfx(:,:),count] = fread(fid,[2*Header.nz,Header.nr],prec,skip);

surface_eps = complex(epr,epi);
pfs = complex(pfx(1:2:2*Header.nz-1,:),pfx(2:2:2*Header.nz,:));

% Height vector is not saved in file; reconstructed based on header info
hgt = Header.zmin + [0:Header.nz-1]*Header.zinc;

S = struct(...
    'head',Header,...
    'freq',Header.freq,'dr',Header.rinc,'dz',Header.zinc,'units',Header.units,...
        'nr',Header.nr,'pol',Header.pol,'type',Header.iter,'ver',Header.version,...
    'range',rng,'height',hgt,'terrain',ter,'grazing',ang,'eps',surface_eps,'rgh',rgh,'itm',itm,'pf',pfs);

if ( closeFidBeforeReturn )
    fclose( fid );
end

return

function Header = read_head_v320(fid)

%Record 1
frewind(fid);
Header.reclen= fread(fid,1,'int');
Header.version = fread(fid,1,'int')/1e6;
Header.numHead = fread(fid,1,'int');
Header.freq = fread(fid,1,'float');
Header.anthgt = fread(fid,1,'float');
Header.ipat = fread(fid,1,'uint');
Header.beamwidth = fread(fid,1,'float');
Header.beampoint = fread(fid,1,'float');
Header.probangle = fread(fid,1,'float');
Header.transfsize = fread(fid,1,'uint');
Header.pol = fread(fid,1,'uint');
Header.zmin = fread(fid,1,'float');
Header.zmax = fread(fid,1,'float');
Header.zinc = fread(fid,1,'float');
Header.nz = fread(fid,1,'uint');
Header.rmin = fread(fid,1,'float');
Header.rmax = fread(fid,1,'float');
Header.rinc = fread(fid,1,'float');
Header.nr = fread(fid,1,'uint');

%Record 2
fseek(fid,Header.reclen,-1);
Header.units = fread(fid,1,'uint');
Header.iter = fread(fid,1,'uint');
Header.teroff = fread(fid,1,'float');
Header.usetag = fread(fid,1,'uint');
Header.terH_at_0 = fread(fid,1,'float');
Header.perm = fread(fid,1,'float');
Header.cond = fread(fid,1,'float');
Header.rough = fread(fid,1,'float');
Header.tlat = fread(fid,1,'float');
Header.tlon = fread(fid,1,'float');
Header.osgTimeOff = fread(fid,1,'float');
Header.spfRngThin = fread(fid,1,'uint');
Header.refExtBelow = fread(fid,1,'uint');
Header.osgSeed = fread(fid,1,'int');
Header.osgOutput = fread(fid,1,'uint');
Header.antRef = fread(fid,1,'uint');

%Record 3,4,5
Header.tit = [];
fseek(fid,2*Header.reclen,-1);
Header.tit = [Header.tit char(fread(fid,76,'char')')];
fseek(fid,3*Header.reclen,-1);
Header.tit = [Header.tit char(fread(fid,76,'char')')];
fseek(fid,4*Header.reclen,-1);
Header.tit = [Header.tit char(fread(fid,48,'char')')];

%Record 6,7,8
Header.restart =[];
fseek(fid,5*Header.reclen,-1);
Header.restart = [Header.restart  char(fread(fid,76,'char')')];
fseek(fid,6*Header.reclen,-1);
Header.restart = [Header.restart  char(fread(fid,76,'char')')];
fseek(fid,7*Header.reclen,-1);
Header.restart = [Header.restart  char(fread(fid,48,'char')')];

%Record 9,10,11
Header.srffile =[];
fseek(fid,8*Header.reclen,-1);
Header.srffile = [Header.srffile  char(fread(fid,76,'char')')];
fseek(fid,9*Header.reclen,-1);
Header.srffile = [Header.srffile  char(fread(fid,76,'char')')];
fseek(fid,10*Header.reclen,-1);
Header.srffile = [Header.srffile  char(fread(fid,48,'char')')];

%Record 12,13,14
Header.osgFile =[];
fseek(fid,11*Header.reclen,-1);
Header.osgFile = [Header.osgFile  char(fread(fid,76,'char')')];
fseek(fid,12*Header.reclen,-1);
Header.osgFile = [Header.osgFile  char(fread(fid,76,'char')')];
fseek(fid,13*Header.reclen,-1);
Header.osgFile = [Header.osgFile  char(fread(fid,48,'char')')];

return




