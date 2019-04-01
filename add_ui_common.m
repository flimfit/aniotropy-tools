function add_ui_common
    % Update submodule if required
    if ~exist('matlab-ui-common','dir')
        system('git submodule update --init --recursive')
    else
        system('git submodule update')      
    end
    
    addpath('matlab-ui-common')
end