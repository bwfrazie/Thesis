function S = read_spf( spfFile )
%read_spf - Reads a TEMPER surface prop. factor file (binary, custom format)
%
%
%
% USE: S = read_spf( spfFile );
%
%   Reads the data in the specified Surface Propagation factor (.spf) file,
%   returning data in structure S.
%
%   This code should work for v3.1.0, v3.1.1, v3.1.2 and v3.2.0 .spf files, noting
%   that all of these versions output different formats for the .spf file so the
%   output structures for these versions will differ.
%
%   For v3.2.0 .spf files starting at beta release (.0020) this function calls 
%   another routine (read_spf_v320.m). See comments in that routine for more
%   info, but do not call that routine directly - instead, call read_spf.m and
%   it should read all v3.2.0 files properly by either using code in this routine
%   or by calling read_spf_v320.m, as appropriate.
%
%
% ©1999-2015, Johns Hopkins University / Applied Physics Lab
% Last update: 2015-02-05 (JZG)


% Update list:
% -----------
% 2002-09-10 (JZG) Changed structure names, working off original MHN function.
% 2004-02-25 (JZG) Added file exist check.
% 2006-06-16 (JZG) Added ".file" to output structure.
% 2007-10-30 (JZG) Added WHICH( -all ) check, removed a few extraneous code
% branches.
% 2013-01-02 (JZG) Minor aesthetic changes to the code. No functional or header-
% comment changes.
% 2013-04-22 (JZG) Updated for 3.1.4+ change in version number.
% 2013-12-09 (KAG) Update for v3.2.0 inputs
% 2015-01-08 (KAG) Update nHeaderRec for v3.2.0
% 2015-02-05 (JZG) Fixed multiple glitches to make it work again for pre-v3.1.2
% files, by creating get_spf_version() subroutine.


% Verification log:
% ----------------
% 2015-02-05 (JZG) Ran dbstop_everywhere and tested on all TEMPER versions,
% confirming full Matlab code coverage, after fixing glitches in pre-v3.1.2
% format reading.


if nargin==0
    spfFile = '';
end

if isempty( spfFile )
    [f,p] = uigetfile('*.spf','Load SPF file');
    if isnumeric(f)
        S = struct('');
        return
    else
        spfFile = fullfile(p,f);
    end
elseif ~exist( spfFile, 'file' )
    error(['Input file "',spfFile,'" does not exist']);
end

fid = fopen(spfFile,'r');

ver = get_spf_version( fid );

verNumTol = 1e-10;

% kag 01/01/15 v.320 header finailized in version 3.2.0.0020. Send to new
% function if header >= 3.200020.
if(ver >= 3.200020*(1-verNumTol)) 
    S = read_spf_v320( fid );
    fclose( fid );
    S.file = spfFile;
    return
end

v320HeaderUpdate = 3.200005;

if ver >= 3.20*(1-verNumTol)
    
    Header = read_head_v320prebeta(fid,ver>=v320HeaderUpdate);
    
elseif ver >= 3.12*(1-verNumTol)
    
    Header = read_head(fid);
    
else
    
    freq = fread(fid,1,'double');
    dr   = fread(fid,1,'double');
    dz   = fread(fid,1,'double');
    unit = fread(fid,1,'int');
    nr   = fread(fid,1,'int');
    pol  = fread(fid,1,'int');
    type = fread(fid,1,'int');
    verCheck  = fread(fid,1,'int')/100;
    if abs( verCheck - ver ) > 1e-8
        fclose( fid );
        error('Version check failed, code bug likely');
    end
    
end

if ( abs( ver - 3.12 ) < verNumTol ) && ( Header.uni == 1 )
    warning('Catching bug in TEMPER v3.1.2 for km/m units');
    % Bug in TEMPER's "fld_write.f" causes "delta_z" to be written
    % to header in feet, rather than meters.  Account for the
    % missing conversion factor here (JZG,2003-12-23):
    Header.ina = Header.ina * 0.3048;
end

if ver >= 3.12*(1-verNumTol)
    
    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    % Explanation of "selective read" FSEEK/FREAD method used to speed up
    % I/O for v3.1.1 & v3.1.2+ formats:
    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    %
    %
    % IF FILE IS ARRANGED LIKE THIS,      READ (e.g.) 3rd VAR. (ang) AS:
    % _________________________________   __________________________________
    % REC1: header.....................   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    % REC2: rng ter ang eps rgh pfs itm   XX(START) READ1-----------SKIP---
    % REC3: rng ter ang eps rgh pfs itm   --------->READ2-----------SKIP---
    % REC4: rng ter ang eps rgh pfs itm   --------->READ3----------- . . .
    % .     <-------- 57 bytes ------->                     .
    % .               ( RECL )                              .
    % REC"nr"                             --------->READ"nr" (STOP)XXXXXXXXX
    % _________________________________   __________________________________
    %
    % This can be 100+ time faster than looping / FREAD'ing each record
    % separately.
    %
    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    if ver >= v320HeaderUpdate*(1-verNumTol)
        nHeaderRec = 20;
    elseif ver >= 3.20*(1-verNumTol)
        error(['Code should not reach this point anymore, should have gone',...
            ' into read_spf_v320.m. Please report this code bug.']);
    else
        nHeaderRec = 1;
    end
    fseek(fid,nHeaderRec*Header.recl,-1);
    rng(1,:) = fread(fid,[1,Header.npr],'double',Header.recl-8);
    
    fseek(fid,nHeaderRec*Header.recl+08,-1);
    ter(1,:) = fread(fid,[1,Header.npr],'float',Header.recl-4);
    
    fseek(fid,nHeaderRec*Header.recl+12,-1);
    ang(1,:) = fread(fid,[1,Header.npr],'float',Header.recl-4);
    
    fseek(fid,nHeaderRec*Header.recl+16,-1);
    epr(1,:) = fread(fid,[1,Header.npr],'double',Header.recl-8);
    
    fseek(fid,nHeaderRec*Header.recl+24,-1);
    epi(1,:) = fread(fid,[1,Header.npr],'double',Header.recl-8);
    
    fseek(fid,nHeaderRec*Header.recl+32,-1);
    rgh(1,:) = fread(fid,[1,Header.npr],'double',Header.recl-8);
    
    fseek(fid,nHeaderRec*Header.recl+40,-1);
    itm(1,:) = fread(fid,[1,Header.npr],'int32',Header.recl-4);
    
    fseek(fid,nHeaderRec*Header.recl+44,-1);
    prec = [num2str(2*Header.npa),'*double'];
    
    skip = Header.recl - 16*Header.npa;
    [pfx(:,:),count] = fread(fid,[2*Header.npa,Header.npr],prec,skip);
    
    surface_eps = complex(epr,epi);
    pfs = complex(pfx(1:2:2*Header.npa-1,:),pfx(2:2:2*Header.npa,:));
    
    % Height vector is not saved in file; reconstructed based on header info
    hgt = (Header.fho-1)*Header.ina +[0:Header.npa-1] * Header.ina;
        
elseif abs( ver - 3.11 ) < verNumTol
    
    % v3.1.1 files contains an additional INTEGER*1 per record over v3.1.0
    %    (NOTE: comments at bottom of file provide more info on the FSEEK / FREAD
    %    method used here to get dramatically faster I/O over looped FREAD calls
    data = zeros(8,nr);
    RECL = 57;
    SKIP = RECL - 8;
    for i = 1:7 % selectively read out seven vectors of REAL*8's
        seekto = RECL + (i-1)*8;
        fseek(fid, seekto ,-1); % rewind to the first value for the "ith" variable (e.g. rng, ter, etc...)
        data(i,:) = fread(fid , [1,nr] , 'double' , SKIP); % ... then read out ALL those values
    end
    % b/c "itm" is not a REAL*8, must deal with it separately:
    SKIP = RECL - 1;
    seekto = RECL + 7*8;
    fseek(fid, seekto ,-1);
    data(8,:) = fread(fid, [1,nr] , 'int8' , SKIP); % read out all itm values (INTEGER*1)
    
else
    
    % version 3.1.0 (first version to make .spf's) same as v3.1.1, except no "itm" terrain flag
    RECL = 56;
    fseek(fid,RECL,-1); % skip past first record (record length is 56 bytes)
    data = fread(fid,[7,nr],'double'); % all data is REAL*8
    
end

fclose(fid);

if ver < 3.12*(1-verNumTol)
    rng = data(1,:);
    ter = data(2,:);
    ang = data(3,:);
    surface_eps = complex( data(4,:) , data(5,:) );
    rgh = data(6,:);
    pfs = data(7,:);
    
    if ver < 3.11*(1-verNumTol)
        itm = [];
    else
        itm = data(8,:);
    end
    S = struct(...
        'freq',freq,'dr',dr,'dz',dz,'units',unit,...
        'nr',nr,'pol',pol,'type',type,'ver',ver,...
        'range',rng,'height',0,  'terrain',ter,'grazing',ang,'eps',surface_eps,'rgh',rgh,'itm',itm,'pf',pfs);
        %           ^^^^^^^^^^^ Added a height struct field 2015-02-05
else
    S = struct(...
        'head',Header,...
        'freq',Header.frq,'dr',Header.inr,'dz',Header.ina,'units',Header.uni,...
        'nr',Header.npr,'pol',Header.pol,'type',Header.typ,'ver',Header.ver,...
        'range',rng,'height',hgt,'terrain',ter,'grazing',ang,'eps',surface_eps,'rgh',rgh,'itm',itm,'pf',pfs);
end

S.file = spfFile; % new, 2006-06-16

return


function ver = get_spf_version( fid )
% Note that this function will reposition the I/O pointer to beginning of file
% before returning.

    recl = fread(fid,1,'int');
    ver  = fread(fid,1,'int');
    
    if (( recl < 50 ) | ( recl > 1e9 )) & ...
       (( ver  <  3 ) | ( ver  > 1e7 ))
        % Probably a v3.1.0 or v3.1.1 file
        fseek(fid,3*8+4*4,'bof');
        ver = fread(fid,1,'int');        
    end

    % (KAG) 09/12/13 Add
    % Convert function to use version + bug fix
    verNum = ver/10;

    % If version number is still > 10, it could be a 100*version file ...
    if ( verNum > 10 ), verNum = ver/100; end

    % ... or it could be the newest 1e6*version file
    if ( verNum > 10 ), verNum = ver/1e6; end

    % Also check for coding mistakes (assumes version is never > 10)
    if ( verNum > 10 )
        fclose( fid );
        error('Code bug detected, or TEMPER version > 10');
    end

    ver = verNum;
    % version number + bug fix number when the v3.2.0 inputs went into the
    % temper header

    fseek(fid,0,'bof');
    
return




function Header = read_head(fid)

    Header.recl= fread(fid,1,'int');
    Header.ver = fread(fid,1,'int');
    Header.cmp = fread(fid,1,'int');
    Header.frq = fread(fid,1,'float');
    Header.hgt = fread(fid,1,'float');
    Header.pat = fread(fid,1,'uint');
    Header.bmw = fread(fid,1,'float');
    Header.bmd = fread(fid,1,'float');
    Header.thm = fread(fid,1,'float');
    Header.mft = fread(fid,1,'uint');
    Header.pol = fread(fid,1,'uint');
    Header.typ = fread(fid,1,'uint');
    Header.mna = fread(fid,1,'float');
    Header.mxa = fread(fid,1,'float');
    Header.ina = fread(fid,1,'float'); %<- changed from 'double' 9/19/01 to match .fld-file header

    Header.npa = fread(fid,1,'uint');
    Header.mnr = fread(fid,1,'float');
    Header.mxr = fread(fid,1,'float');
    Header.inr = fread(fid,1,'float');
    Header.npr = fread(fid,1,'uint');
    Header.uni = fread(fid,1,'uint');
    Header.ter = fread(fid,1,'uint');
    Header.tof = fread(fid,1,'float');
    Header.tag = fread(fid,1,'uint');
    Header.dat = char(fread(fid,8,'char')');
    Header.tim = char(fread(fid,10,'char')');
    Header.tit = char(fread(fid,200,'char')');
    Header.prv = char(fread(fid,200,'char')');
    Header.thz = fread(fid,1,'float');
    Header.prm = fread(fid,1,'float');
    Header.cnd = fread(fid,1,'float');
    Header.rgh = fread(fid,1,'float');
    Header.sfn = char(fread(fid,200,'char')');
    Header.lat = fread(fid,1,'float');
    Header.lon = fread(fid,1,'float');
    Header.fho = 1;

return


function Header = read_head_v320prebeta( fid, with_v320_inputs )

    Header.recl= fread(fid,1,'int');
    Header.ver = fread(fid,1,'int');
    Header.cmp = fread(fid,1,'int');
    Header.frq = fread(fid,1,'float');
    Header.hgt = fread(fid,1,'float');
    Header.pat = fread(fid,1,'uint');
    Header.bmw = fread(fid,1,'float');
    Header.bmd = fread(fid,1,'float');
    Header.thm = fread(fid,1,'float');
    Header.mft = fread(fid,1,'uint');
    Header.pol = fread(fid,1,'uint');
    Header.typ = fread(fid,1,'uint');
    Header.mna = fread(fid,1,'float');
    Header.mxa = fread(fid,1,'float');
    Header.ina = fread(fid,1,'float'); 
    
    fseek(fid,Header.recl,-1);
    Header.npa = fread(fid,1,'uint');
    Header.mnr = fread(fid,1,'float');
    Header.mxr = fread(fid,1,'float');
    Header.inr = fread(fid,1,'float');
    Header.npr = fread(fid,1,'uint');
    Header.uni = fread(fid,1,'uint');
    Header.ter = fread(fid,1,'uint');
    Header.tof = fread(fid,1,'float');
    Header.tag = fread(fid,1,'uint');
    Header.thz = fread(fid,1,'float');
    Header.prm = fread(fid,1,'float');
    Header.cnd = fread(fid,1,'float');
    Header.rgh = fread(fid,1,'float');
    Header.lat = fread(fid,1,'float');
    Header.lon = fread(fid,1,'float');
    
    fseek(fid,2*Header.recl,-1);
    Header.fho = fread(fid,1,'int');
    Header.dat = char(fread(fid,8,'char')');
    Header.tim = char(fread(fid,10,'char')');
    
    Header.tit = [];
    fseek(fid,3*Header.recl,-1);
    Header.tit = [Header.tit char(fread(fid,60,'char')')];
    fseek(fid,4*Header.recl,-1);
    Header.tit = [Header.tit char(fread(fid,60,'char')')];
    fseek(fid,5*Header.recl,-1);
    Header.tit = [Header.tit char(fread(fid,60,'char')')];
    fseek(fid,6*Header.recl,-1);
    Header.tit = [Header.tit char(fread(fid,20,'char')')];

    Header.prv =[];
    fseek(fid,7*Header.recl,-1);
    Header.prv = [Header.prv  char(fread(fid,60,'char')')];
    fseek(fid,8*Header.recl,-1);
    Header.prv = [Header.prv  char(fread(fid,60,'char')')];
    fseek(fid,9*Header.recl,-1);
    Header.prv = [Header.prv  char(fread(fid,60,'char')')];
    fseek(fid,10*Header.recl,-1);
    Header.prv = [Header.prv  char(fread(fid,20,'char')')];

    Header.sfn =[];
    fseek(fid,11*Header.recl,-1);
    Header.sfn = [Header.sfn  char(fread(fid,60,'char')')];
    fseek(fid,12*Header.recl,-1);
    Header.sfn = [Header.sfn  char(fread(fid,60,'char')')];
    fseek(fid,13*Header.recl,-1);
    Header.sfn = [Header.sfn  char(fread(fid,60,'char')')];
    fseek(fid,14*Header.recl,-1);
    Header.sfn = [Header.sfn  char(fread(fid,20,'char')')];

    if not( with_v320_inputs ), return; end
        
    fseek(fid,15*Header.recl,-1);
    Header.spfMinHgt = fread(fid,1,'float');
    Header.spfMaxHgt = fread(fid,1,'float');
    Header.fldMaxRng = fread(fid,1,'float');
    Header.osgTimeOff = fread(fid,1,'float');

    Header.spfRngThin = fread(fid,1,'uint');
    Header.fldRngThin = fread(fid,1,'uint');
    Header.refExt = fread(fid,1,'uint');
    Header.osgSeed = fread(fid,1,'uint');
    Header.osgOutput = fread(fid,1,'uint');
    Header.antRef = fread(fid,1,'uint');

    Header.osgFile =[];
    fseek(fid,16*Header.recl,-1);
    Header.osgFile = [Header.osgFile  char(fread(fid,60,'char')')];
    fseek(fid,17*Header.recl,-1);
    Header.osgFile = [Header.osgFile  char(fread(fid,60,'char')')];
    fseek(fid,18*Header.recl,-1);
    Header.osgFile = [Header.osgFile  char(fread(fid,60,'char')')];
    fseek(fid,19*Header.recl,-1);
    Header.osgFile = [Header.osgFile  char(fread(fid,20,'char')')];

return




