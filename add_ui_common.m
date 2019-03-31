function add_ui_common
    % Update submodule if required
    if ~exist('matlab-ui-common','dir')
        system('git submodule update --init --recursive')
    end
    
    addpath('matlab-ui-common')
end