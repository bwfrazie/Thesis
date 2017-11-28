function check_path
%check_path - remove any shadowed TEMPER mfiles from your path until this function runs without error
%
% This function was auto-generated on 2016-10-20

    W = which('getset_temper_input','-all');
    if length(W) > 1
        error('More than one "getset_temper_input" function found on your path!');
    end

    W = which('change_osg_input_parameter','-all');
    if length(W) > 1
        error('More than one "change_osg_input_parameter" function found on your path!');
    end

    W = which('plot_grz','-all');
    if length(W) > 1
        error('More than one "plot_grz" function found on your path!');
    end

    W = which('plot_pat','-all');
    if length(W) > 1
        error('More than one "plot_pat" function found on your path!');
    end

    W = which('plot_ref','-all');
    if length(W) > 1
        error('More than one "plot_ref" function found on your path!');
    end

    W = which('plot_srf','-all');
    if length(W) > 1
        error('More than one "plot_srf" function found on your path!');
    end

    W = which('read_grz','-all');
    if length(W) > 1
        error('More than one "read_grz" function found on your path!');
    end

    W = which('read_pat','-all');
    if length(W) > 1
        error('More than one "read_pat" function found on your path!');
    end

    W = which('read_ref','-all');
    if length(W) > 1
        error('More than one "read_ref" function found on your path!');
    end

    W = which('read_spf','-all');
    if length(W) > 1
        error('More than one "read_spf" function found on your path!');
    end

    W = which('read_srf','-all');
    if length(W) > 1
        error('More than one "read_srf" function found on your path!');
    end

    W = which('tdata31','-all');
    if length(W) > 1
        error('More than one "tdata31" function found on your path!');
    end

    W = which('tffrp','-all');
    if length(W) > 1
        error('More than one "tffrp" function found on your path!');
    end

    disp('Congratulations, you have no shadowed TEMPER mfiles on your path!');

return
