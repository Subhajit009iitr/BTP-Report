% Import COMSOL libraries
import com.comsol.model.*
import com.comsol.model.util.*

% Clear any previous models
ModelUtil.clear;

% Create a new COMSOL model
model = ModelUtil.create('Model3');

%% Define 2D Geometry: 5x5 Grid of Microfluidic Pipes
model.geom.create('geom1', 2);  % 2D geometry

% Loop to create both horizontal and vertical pipes
for i = 0:4
    for j = 0:4
        % Create horizontal pipe (width > height)
        h_pipe = model.geom('geom1').feature.create(sprintf('hpipe_%d_%d', i, j), 'Rectangle');
        h_pipe.set('size', [80e-6, 10e-6]);  % Size: 80µm x 10µm (horizontal)
        h_pipe.set('pos', [i * 80e-6, j * 80e-6]);  % Position in grid

        % Create vertical pipe (height > width)
        v_pipe = model.geom('geom1').feature.create(sprintf('vpipe_%d_%d', i, j), 'Rectangle');
        v_pipe.set('size', [10e-6, 80e-6]);  % Size: 10µm x 80µm (vertical)
        v_pipe.set('pos', [((i * 80e-6) - 35e-6) + 35e-6, j * 80e-6]);  % Shift x by half horizontal pipe length
    end
end

for i = 0:4
    ve_pipe = model.geom('geom1').feature.create(sprintf('vepipe_%d', i), 'Rectangle');
    ve_pipe.set('size', [10e-6, 70e-6]);  % Size: 80µm x 10µm (horizontal)
    ve_pipe.set('pos', [i * 80e-6, -70e-6]);  % Position in grid
end

for j = 0:4
    he_pipe = model.geom('geom1').feature.create(sprintf('hepipe_%d', j), 'Rectangle');
    he_pipe.set('size', [70e-6, 10e-6]);  % Size: 80µm x 10µm (horizontal)
    he_pipe.set('pos', [-70e-6, j * 80e-6]);  % Position in grid
end

%ex_pipe = model.geom('geom1').feature.create(sprintf('expipe_%d', 1), 'Rectangle');
%ex_pipe.set('size', [70e-6, 10e-6]);  % Size: 80µm x 10µm (horizontal)
%ex_pipe.set('pos', [-70e-6, j * 80e-6]);  % Position in grid

% Build the geometry
model.geom('geom1').run;

%% Set Pipe Boundaries
pipe_boundaries = cell(40, 1);

% Horizontal pipes
pipe_boundaries{1}  = [40, 62];
pipe_boundaries{2}  = [84, 106];
pipe_boundaries{3}  = [128, 150];
pipe_boundaries{4}  = [172, 194];

pipe_boundaries{5}  = [44, 66];
pipe_boundaries{6}  = [88, 110];
pipe_boundaries{7}  = [132, 154];
pipe_boundaries{8}  = [176, 198];

pipe_boundaries{9}  = [48, 70];
pipe_boundaries{10} = [92, 114];
pipe_boundaries{11} = [136, 158];
pipe_boundaries{12} = [180, 202];

pipe_boundaries{13} = [52, 74];
pipe_boundaries{14} = [96, 118];
pipe_boundaries{15} = [140, 162];
pipe_boundaries{16} = [184, 206];

pipe_boundaries{17} = [56, 78];
pipe_boundaries{18} = [100, 122];
pipe_boundaries{19} = [144, 166];
pipe_boundaries{20} = [188, 210];

% Vertical pipes
pipe_boundaries{21} = [21, 23];
pipe_boundaries{22} = [25, 27];
pipe_boundaries{23} = [29, 31];
pipe_boundaries{24} = [33, 35];

pipe_boundaries{25} = [65, 67];
pipe_boundaries{26} = [69, 71];
pipe_boundaries{27} = [73, 75];
pipe_boundaries{28} = [77, 79];

pipe_boundaries{29} = [109, 111];
pipe_boundaries{30} = [113, 115];
pipe_boundaries{31} = [117, 119];
pipe_boundaries{32} = [121, 123];

pipe_boundaries{33} = [153, 155];
pipe_boundaries{34} = [157, 159];
pipe_boundaries{35} = [161, 163];
pipe_boundaries{36} = [165, 167];

pipe_boundaries{37} = [197, 199];
pipe_boundaries{38} = [201, 203];
pipe_boundaries{39} = [205, 207];
pipe_boundaries{40} = [209, 211];


%% Create a Mesh for the Geometry
model.mesh.create('mesh1', 'geom1');  % Link mesh to the geometry
model.mesh('mesh1').feature.create('fmesh', 'Free');  % Create a free mesh
model.mesh('mesh1').feature('fmesh').feature.create('size', 'Size');  % Control element size
model.mesh('mesh1').feature('fmesh').feature('size').set('hmax', 1e-6);  % Max element size
model.mesh('mesh1').feature('fmesh').feature('size').set('hmin', 1e-7);  % Min element size
model.mesh('mesh1').feature('fmesh').feature('size').set('custom', 'on');  % Enable custom mesh
model.mesh('mesh1').feature('fmesh').feature('size').set('hauto', 1);  % Extremely fine mesh preset

% Generate the mesh
model.mesh('mesh1').run;

%% Add Water as the Material
model.material.create('mat1');  % Create a new material
model.material('mat1').propertyGroup('def').set('density', '1000');  % Density of water
model.material('mat1').propertyGroup('def').set('dynamicviscosity', '0.001');  % Viscosity of water
model.material('mat1').name('Water');  % Set material name

%% Add Transport of Diluted Species (TDS) Physics
model.physics.create('tds', 'DilutedSpecies', 'geom1');  % Add TDS physics

% Define multiple inflow boundary conditions
inlet1 = model.physics('tds').feature.create('inl1', 'Inflow', 1);
inlet1.selection.set([1]);  % Boundary ID 1 for the first inlet
inlet1.set('c0', '1');  % Concentration: 1 mol/m^3

inlet2 = model.physics('tds').feature.create('inl2', 'Inflow', 1);
inlet2.selection.set([82]);  % Boundary ID 82 for the second inlet
inlet2.set('c0', '2');  % Concentration: 2 mol/m^3

inlet3 = model.physics('tds').feature.create('inl3', 'Inflow', 1);
inlet3.selection.set([10]);  % Boundary ID 10 for the third inlet
inlet3.set('c0', '3');  % Concentration: 3 mol/m^3

% Define multiple outflow boundary conditions
%outlet1 = model.physics('tds').feature.create('out1', 'Outflow', 1);
%outlet1.selection.set([238]);  % Boundary ID 238 for the first outlet

% Read binary strings from the text file into the list array
filename = 'Test_Cases_Folder/tc_subhajit.txt'; % Replace with the correct file path if needed
fid = fopen(filename, 'r'); % Open the file for reading
if fid == -1
    error('Could not open the file.');
end
list = {}; % Initialize an empty cell array to store binary strings
line = fgetl(fid); % Read the first line
while ischar(line)
    list{end + 1} = strtrim(line); % Add the line to the list array
    line = fgetl(fid); % Read the next line
end
fclose(fid); % Close the file

% Display the loaded binary strings
% disp('Loaded binary strings:');
% disp(list);

for z = 1:length(list)
    % Define the binary string
    binary_string = list{z};
    disp(binary_string);
    
    % Initialize the barrier_boundaries array as empty
    barrier_boundaries = [];  % Start with an empty array
    
    % Loop through the binary string
    for x = 1:length(binary_string)
        % Check if the character at position x is '0'
        if binary_string(x) == '0'
            % Retrieve the corresponding pipe_boundary for x
            pipe_boundary = pipe_boundaries{x};  % Assuming pipe_boundaries contains pairs
            
            % Append both values from pipe_boundary to barrier_boundaries
            barrier_boundaries = [barrier_boundaries; pipe_boundary(1); pipe_boundary(2)];  % Append both values
        end
    end
    % Display the barrier boundaries
    %disp('Barrier boundaries:');
    %disp(barrier_boundaries);

    % Loop through each boundary ID and apply an 'InteriorWall' feature
    for k = 1:length(barrier_boundaries)
        % Create an Interior Wall feature for each boundary
        thin_barrier = model.physics('tds').feature.create(sprintf('int_wall_%d', k), 'ThinImpermeableBarrier', 1);
        
        % Set the boundary ID for the thin barrier
        thin_barrier.selection.set([barrier_boundaries(k)]);
    end

    %% Create a Stationary Study
    study_name = sprintf('std_%d', z);
    model.study.create(study_name);  % Create a new study
    model.study(study_name).feature.create('stat', 'Stationary');  % Create a stationary study step
    model.study(study_name).feature('stat').set('activate', {'tds', 'on'});  % Activate TDS physics
    
    % --- Compute the study ---
    model.study(study_name).run;  % Run the study

    %% Create a Dataset and Surface Plot for Concentration
    sol_name = sprintf('sol%d', z);  % Unique solution name for each iteration
    %model.sol.create(sol_name);  % Create a unique solution1

    %% Create a Dataset and Surface Plot for Concentration
    dset_name = sprintf('dest_%d', z); 
    model.result.dataset.create(dset_name, 'Solution');  % Create a dataset from solution
    model.result.dataset(dset_name).set('solution',sol_name);  % Link dataset to the solution
    
    plot_name = sprintf('pg_%d',z);
    surface_plot = model.result.create(plot_name, 'PlotGroup2D');  % Create a 2D plot group
    surface_plot.set('data', dset_name);  % Set data source
    
    concentration_plot = surface_plot.feature.create('surf1', 'Surface');  % Create a surface plot
    concentration_plot.set('expr', 'c');  % Plot concentration 'c'
    
    % Generate the plot
    model.result(plot_name).run;  % Run the plot
    
    %% Save the Plot as PNG with Legend
    figure_handle = figure;
    mphplot(model, plot_name);  % Plot in a MATLAB figure
    
    colorbar;  % Add a colorbar for the concentration legend
    colormap('jet');  % Optional: Set colormap for better visualization
    title('Concentration Distribution');  % Add title
    
    image_filename = sprintf('Plots2/plot_%d.png', z);  % Filename for plot
    saveas(figure_handle, image_filename);  % Save the plot as PNG
    close(figure_handle);  % Close the figure
    
    disp(['Plot with legend saved as ', image_filename]);

    %% Save the Model as .mph
    %mph_filename = sprintf('Models/microfluidic_model_%d.mph', z);  % Unique model filename
    %mphsave(model, mph_filename);  % Save the model
    
    %disp(['Model saved as ', mph_filename]);
    
    %% Evaluate and Save Outlet Concentrations to CSV
    outlet_boundaries = [1, 4, 7, 10, 13, 38, 82, 126, 170, 214, 240, 239, ...
                         238, 237, 236, 193, 149, 105, 61, 17];  % Outlet boundary IDs
    num_outlets = length(outlet_boundaries);  % Number of outlets
    
    concentration_data = zeros(1, num_outlets);  % Preallocate row for concentrations
    
    % Evaluate concentration at each outlet boundary and store in row
    for i = 1:num_outlets
        %c_outlet = mpheval(model, 'c', 'selection', outlet_boundaries(i), 'edim', 1);  % Evaluate concentration
        c_outlet = mpheval(model, 'c', 'selection', outlet_boundaries(i), 'edim', 1, 'dataset', dset_name); 
        concentration_data(1, i) = mean(c_outlet.d1);  % Store the average concentration
    end
    
    csv_filename = 'outlet_concentration_sb.csv';  % CSV filename
    
    % Create headers only if the CSV file doesn't exist
    if ~isfile(csv_filename)
        % Create headers dynamically, with specific inlets labeled
        headers = cell(1, num_outlets);  % Preallocate header cell array
        for i = 1:num_outlets
            if ismember(i, [1, 4, 7])  % Check if it's an inlet
                headers{i} = sprintf('Inlet_%d', i);
            else
                headers{i} = sprintf('Outlet_%d', i);
            end
        end

        % Write the headers to the CSV file
        fid = fopen(csv_filename, 'w');  % Open file for writing
        fprintf(fid, '%s,', 'binary');
        fprintf(fid, '%s,', headers{1:end-1});  % Write headers (all except the last one)
        fprintf(fid, '%s\n', headers{end});  % Write the last header with a newline
        fclose(fid);  % Close the file
    end
    
    % Append the current concentration data as a new row in the CSV
    %writematrix(concentration_data, csv_filename, 'WriteMode', 'append');
    new_row = [{binary_string}, num2cell(concentration_data)];
    writecell(new_row, csv_filename, 'WriteMode', 'append');
    disp('Concentration data saved to outlet_concentration_new.csv.');
    
    %% Remove existing boundaries
    for k = 1:length(barrier_boundaries)
        % Create an Interior Wall feature for each boundary
        model.physics('tds').feature.remove(sprintf('int_wall_%d', k));
    end
    disp('All ThinImpermeableBarrier features removed.');
end
