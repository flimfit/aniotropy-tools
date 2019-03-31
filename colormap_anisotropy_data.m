function colormap_anisotropy_data

    add_ui_common();
    get_bioformats();

    lim = [0.0 0.4]; % Display limits
    kern_size = 3; % Smoothing kernel size

    para_channel = 3; % Parallel channel
    perp_channel = 4; % Perpedicular channel


    % Get files from user
    persistent path
    if isempty(path); path = userpath; end

    [files,path] = uigetfile('*.ome.tif','Select files to process',path,'Multiselect','on');
    if ~iscell(files)
        files = {files};
    end

    h = waitbar(0, 'Processing');
    for i=1:length(files)
        file = [path filesep files{i}];

        % Get file information
        reader = bfGetReader(file);
        num_t = reader.getSizeT();
        num_z = reader.getSizeZ();
        num_x = reader.getSizeX();
        num_y = reader.getSizeY();

        para = zeros(num_y,num_x,num_z);
        perp = zeros(num_y,num_x,num_z);

        % Load parallel and perpendicular channels
        for t=1:num_t
            for z=1:num_z
                idx = reader.getIndex(z - 1, para_channel - 1, t - 1) + 1;
                para(:,:,z) = para(:,:,z) + double(bfGetPlane(reader, idx));

                idx = reader.getIndex(z - 1, perp_channel - 1, t - 1) + 1;
                perp(:,:,z) = perp(:,:,z) + double(bfGetPlane(reader, idx));
            end
            waitbar((i-1+t/num_t)/length(files),h);
        end
        reader.close()

        % Get output filenames
        mapped_output_file = strrep(file,'.ome.tif','-anisotropy-mapped.tif');
        raw_output_file = strrep(file,'.ome.tif','-anisotropy.tif');

        % Smooth channels
        para_smoothed = imgaussfilt(para,kern_size);
        perp_smoothed = imgaussfilt(perp,kern_size);

        % Calculate anisotropy and intensity
        r = (para - perp) ./ (para + 2*perp);
        r_smoothed = (para_smoothed - perp_smoothed) ./ (para_smoothed + 2 * perp_smoothed);
        intensity = para + perp;

        if exist(mapped_output_file,'file')
            delete(mapped_output_file);
        end

        % Save colormapped data
        for z=1:num_z
            im = display_flim(r_smoothed(:,:,z),[],lim,intensity(:,:,z));
            imwrite(im,mapped_output_file,'WriteMode','append');
        end
        names = arrayfun(@(i) ['z = ' num2str(i)],1:num_z,'UniformOutput',false);

        % Save raw data
        SaveFPTiffStack(raw_output_file,r,names);
        waitbar(i/length(files),h);
    end
    close(h);

end