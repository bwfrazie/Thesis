function [file_names] = change_osg_input_parameter( ...
                            in_file, out_dir, osg_parameter, value_vector)
%change_osg_input_parameter.m - Change .in file Ocean Surface Gen. parameters
%
%     This function changes the time step or random seed parameter to be changed
%     in an existing TEMPER input file and keeps all other parameters the same.
%     A new file is created for each value of the time step or random seed
%     vector that is input.
%
%
% USE: [file_names] = change_osg_input_parameter( ...
%                           in_file, out_dir, osg_parameter, value_vector)
%      Inputs:
%
%       in_file -- full path & name of TEMPER .in used as the base file
%       out_dir -- directory where new TEMPER .in files are written
%       osg_parameter -- the parameter to change in the new input files.
%                        Valid values are: 'seed' or 'time'
%       value_vector -- vector of values for the random seed (integers) or
%                       OSG-wave-evolution time (seconds after "time zero")
%
%      Output:
%
%       file_names -- cell array with names of new files. If input_file is 
%                     (e.g.) /path/to/base.in, the output files are named:
%                 .../out_dir/base_seed_%d.in    -> for osg_parameter == 'seed'
%                 .../out_dir/base_time_%4.3f.in -> for osg_parameter == 'time'
%
%
% SEE ALSO: getset_temper_input.m
%
%
% ©2014-2015 Johns Hopkins University / Applied Physics Laboratory
% Created by:  griffka1 2014-12-19
% Last update: 2014-12-19


% TODO: either replace use of inefficient getset_temper_input.m, or update that
% dependency so it works better / faster.


% Update list:
% -----------
% 2014-12-19 (griffka1) Created initial version.
% 2015-01-29 (JZG) Changed 'osgTimeStep' to 'osgTime'.

% Validation log:
% --------------
% 2014-12-19 (griffka1) initial testing

if(~exist(in_file,'file'))
    error(sprintf('%s Does not exist\n',in_file));
end

failsafe_mkdir(out_dir);

param_name = [];
if(strcmpi(osg_parameter,'seed'))
    param_name ='osgSeed';
    val_specifier = '%d';
    value_vector = ceil(abs(value_vector));
elseif(strcmpi(osg_parameter,'time'))
    param_name ='osgTime';
    val_specifier = '%4.3f';
else
    error(sprintf('Invalid osg parameter: %s\n Valid choices are "seed" or "time"\n',osg_parameter));
end

N = length(value_vector);
[in_path,in_name,in_ext] = fileparts(in_file);
file_names = [];
for value_cnt = 1:N
    new_val = value_vector(value_cnt);
    new_file_name = sprintf(['%s_%s_' val_specifier '%s']...
        ,in_name,osg_parameter,new_val,in_ext);
    file_names{value_cnt} = fullfile(out_dir,new_file_name);
    failsafe_copyfile(in_file,file_names{value_cnt});
    getset_temper_input(file_names{value_cnt},'set',param_name,new_val);
end

return

