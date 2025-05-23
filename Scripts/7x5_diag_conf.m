% Import COMSOL libraries
import com.comsol.model.*
import com.comsol.model.util.*

% Clear any previous models
ModelUtil.clear;

% Create a new COMSOL model
model = ModelUtil.create('Model3');

%% Define 2D Geometry: 7x5 Grid of Microfluidic Pipes
model.geom.create('geom1', 2);  % 2D geometry

% Loop to create both horizontal and vertical pipes
for i = 0:6
    for j = 0:4
        % Create horizontal pipe (width > height)
        if i~=6
            h_pipe = model.geom('geom1').feature.create(sprintf('hpipe_%d_%d', i, j), 'Rectangle');
            h_pipe.set('size', [80e-6, 10e-6]);  % Size: 80µm x 10µm (horizontal)
            h_pipe.set('pos', [i * 90e-6, j * 90e-6]);  % Position in grid
        end

        % Create vertical pipe (height > width)
        if j ~= 4
            v_pipe = model.geom('geom1').feature.create(sprintf('vpipe_%d_%d', i, j), 'Rectangle');
            v_pipe.set('size', [10e-6, 80e-6]);  % Size: 10µm x 80µm (vertical)
            v_pipe.set('pos', [i * 90e-6 - 10e-6, j * 90e-6 + 10e-6]);  % Shift x by half horizontal pipe length
        end
        
        % Junctions
        if i==0 && j==4
            % For (0,4): use original square junction
            junc = model.geom('geom1').feature.create(sprintf('junc_%d_%d', i, j), 'Rectangle');
            junc.set('size', [10e-6, 10e-6]);
            junc.set('pos', [i * 90e-6 - 10e-6, j * 90e-6]);
        elseif i==6 && j==4
            % For (6,4): use original square junction
            junc = model.geom('geom1').feature.create(sprintf('junc_%d_%d', i, j), 'Rectangle');
            junc.set('size', [10e-6, 10e-6]);
            junc.set('pos', [i * 90e-6 - 10e-6, j * 90e-6]);
        else
            % For all other cases, use octagons (or partial octagons)
            if j==0 && i~=0 && i~=6
                selIndices = [1, 2, 3, 4, 5, 8];
            elseif j==4 && i~=0 && i~=6
                selIndices = [1, 4, 5, 6, 7, 8];
            elseif i==0
                selIndices = [1, 2, 3, 6, 7, 8];
            elseif i==6
                selIndices = [2, 3, 4, 5, 6, 7];
            else
                selIndices = 1:8;
            end
        
            % Compute center of the junction (same as the original square's center)
            cx = i * 90e-6 - 10e-6 + 5e-6;
            cy = j * 90e-6 + 5e-6;
            
            % Compute circumradius R for a regular octagon with side length s = 10e-6:
            R = 10e-6 / (2 * sin(pi/8));
            
            % Compute the full set of vertex angles (rotated by 22.5° so that sides are horizontal/vertical)
            angles_full = (22.5 + (0:7)*45) * pi/180;
            
            % Use only the vertices specified by selIndices
            xvertices = cx + R * cos(angles_full(selIndices));
            yvertices = cy + R * sin(angles_full(selIndices));
            
            % Create a polygon junction using the computed vertices
            junc = model.geom('geom1').feature.create(sprintf('junc_%d_%d', i, j), 'Polygon');
            junc.set('x', xvertices);
            junc.set('y', yvertices);
        end
    end
end

% Define diagonal pipe length
diag_length = sqrt((80e-6)^2 + (80e-6)^2) + sqrt((10e-6)^2+(10e-6)^2);
trav_length = 5e-6;

for i = 0:6
    for j = 0:4
        % Bottom-right diagonal (i+1, j+1)
        if i ~= 6 && j ~= 4
            dr_pipe = model.geom('geom1').feature.create(sprintf('drpipe_%d_%d', i, j), 'Rectangle');
            dr_pipe.set('size', [10e-6, diag_length]);
            dr_pipe.set('pos', [i * 90e-6 + 90e-6 - 13.5e-6 + trav_length, j * 90e-6 + 6.5e-6 - trav_length]);
            dr_pipe.set('rot', 45);
        end
        
        % Top-right diagonal (i+1, j-1)
        if i ~= 6 && j ~= 0
            tr_pipe = model.geom('geom1').feature.create(sprintf('trpipe_%d_%d', i, j), 'Rectangle');
            tr_pipe.set('size', [10e-6, diag_length]);
            tr_pipe.set('pos', [i * 90e-6 - 3.5e-6 - trav_length, j * 90e-6 - 76.5e-6 - trav_length]);
            tr_pipe.set('rot', -45);
        end 

    end
end

in_pipe = model.geom('geom1').feature.create(sprintf('inpipe_%d', 1), 'Rectangle');
in_pipe.set('size', [10e-6, 70e-6]); 
in_pipe.set('pos', [1 * 90e-6 - 10e-6, 4 * 90e-6 + 10e-6]);  % Position in grid

%in_pipe = model.geom('geom1').feature.create(sprintf('inpipe_%d', 2), 'Rectangle');
%in_pipe.set('size', [10e-6, 70e-6]); 
%in_pipe.set('pos', [3 * 90e-6 - 10e-6, 4 * 90e-6 + 10e-6]);  % Position in grid

in_pipe = model.geom('geom1').feature.create(sprintf('inpipe_%d', 2), 'Rectangle');
in_pipe.set('size', [10e-6, 70e-6]); 
in_pipe.set('pos', [5 * 90e-6 - 10e-6, 4 * 90e-6 + 10e-6]);  % Position in grid

out_pipe = model.geom('geom1').feature.create(sprintf('outpipe_%d', 1), 'Rectangle');
out_pipe.set('size', [10e-6, 70e-6]); 
out_pipe.set('pos', [0 * 90e-6 - 10e-6, -1 * 90e-6 + 20e-6]);  % Position in grid

out_pipe = model.geom('geom1').feature.create(sprintf('outpipe_%d', 2), 'Rectangle');
out_pipe.set('size', [10e-6, 70e-6]); 
out_pipe.set('pos', [2 * 90e-6 - 10e-6, -1 * 90e-6 + 20e-6]);  % Position in grid

out_pipe = model.geom('geom1').feature.create(sprintf('outpipe_%d', 3), 'Rectangle');
out_pipe.set('size', [10e-6, 70e-6]); 
out_pipe.set('pos', [4 * 90e-6 - 10e-6, -1 * 90e-6 + 20e-6]);  % Position in grid

out_pipe = model.geom('geom1').feature.create(sprintf('outpipe_%d', 4), 'Rectangle');
out_pipe.set('size', [10e-6, 70e-6]); 
out_pipe.set('pos', [6 * 90e-6 - 10e-6, -1 * 90e-6 + 20e-6]);  % Position in grid

% Build the geometry
model.geom('geom1').run;

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


%% Pipe Boundaries
pipe_boundaries = cell(106, 1);

% Horizontal pipes
pipe_boundaries{1}  = [172, 175 246];
pipe_boundaries{2}  = [566, 569, 645];
pipe_boundaries{3}  = [965, 968, 1044];
pipe_boundaries{4}  = [1361, 1364 1440];
pipe_boundaries{5}  = [1760, 1763, 1839];
pipe_boundaries{6}  = [2159, 2162, 2238];

pipe_boundaries{7}  = [179, 250, 180, 182];
pipe_boundaries{8}  = [573, 649, 576, 572, 653, 651];
pipe_boundaries{9}  = [972, 1048, 971, 975, 1050, 1052];
pipe_boundaries{10} = [1368, 1444, 1367, 1371, 1446, 1448];
pipe_boundaries{11} = [1767, 1843, 1766, 1770, 1845, 1847];
pipe_boundaries{12} = [2166, 2243, 2165, 2169, 2245, 2247];

pipe_boundaries{13} = [186, 255, 187, 189];
pipe_boundaries{14} = [580, 654, 581, 583];
pipe_boundaries{15} = [979, 1053, 982, 980];
pipe_boundaries{16} = [1375, 1449, 1378, 1376];
pipe_boundaries{17} = [1774, 1848, 1775, 1777];
pipe_boundaries{18} = [2173, 2248, 2176, 2174];

pipe_boundaries{19} = [193, 260, 194, 196];
pipe_boundaries{20} = [587, 659, 590, 588];
pipe_boundaries{21} = [986, 1058, 989, 987];
pipe_boundaries{22} = [1382, 1454, 1385, 1383];
pipe_boundaries{23} = [1781, 1853, 1784, 1782];
pipe_boundaries{24} = [2180, 2253, 2183, 2181];

pipe_boundaries{25} = [149, 150, 265];
pipe_boundaries{26} = [594, 595 664];
pipe_boundaries{27} = [993, 994, 1063];
pipe_boundaries{28} = [1389, 1459, 1390];
pipe_boundaries{29} = [1788, 1858, 1789];
pipe_boundaries{30} = [2187, 2188 2360, 2287];

% Vertical pipes
pipe_boundaries{31} = [10, 12];
pipe_boundaries{32} = [18, 20];
pipe_boundaries{33} = [26, 28];
pipe_boundaries{34} = [34, 36, 68];

pipe_boundaries{35} = [377, 379, 316, 318];
pipe_boundaries{36} = [381, 383, 332, 334];
pipe_boundaries{37} = [385, 387, 348, 350];
pipe_boundaries{38} = [389, 391, 364, 366];

pipe_boundaries{39} = [776, 778, 717, 719];
pipe_boundaries{40} = [780, 782, 733, 735];
pipe_boundaries{41} = [784, 786, 749, 751];
pipe_boundaries{42} = [788, 790, 765, 767];

pipe_boundaries{43} = [1173, 1175, 1114, 1116];
pipe_boundaries{44} = [1177, 1179, 1130, 1132];
pipe_boundaries{45} = [1181, 1183, 1146, 1148];
pipe_boundaries{46} = [1185, 1187, 1162, 1164];

pipe_boundaries{47} = [1571, 1573, 1512, 1514];
pipe_boundaries{48} = [1575, 1577, 1528, 1530];
pipe_boundaries{49} = [1579, 1581, 1544, 1546];
pipe_boundaries{50} = [1583, 1585, 1560, 1562];

pipe_boundaries{51} = [1970, 1972, 1909, 1911];
pipe_boundaries{52} = [1974, 1976, 1925, 1927];
pipe_boundaries{53} = [1978, 1980, 1941, 1943];
pipe_boundaries{54} = [1982, 1984, 1957, 1959];

pipe_boundaries{55} = [2364, 2366, 2307, 2309];
pipe_boundaries{56} = [2368, 2370, 2323, 2325];
pipe_boundaries{57} = [2372, 2374, 2339, 2341];
pipe_boundaries{58} = [2376, 2357, 2406, 2355];

% / diagonal pipes
pipe_boundaries{59} = [152, 272, 176, 317, 214, 224]; 
pipe_boundaries{60} = [156, 276, 183, 333, 216, 228];
pipe_boundaries{61} = [160, 280, 190, 349, 218, 232];
pipe_boundaries{62} = [164, 284, 197, 365, 220, 236];

pipe_boundaries{63} = [544, 671, 570, 718, 613, 623];
pipe_boundaries{64} = [548, 675, 577, 734, 615, 627];
pipe_boundaries{65} = [552, 679, 584, 750, 617, 631];
pipe_boundaries{66} = [556, 683, 591, 766, 619, 635];

pipe_boundaries{67} = [943, 1070, 969, 1115, 1012, 1022];
pipe_boundaries{68} = [947, 1074, 976, 1131, 1014, 1026];
pipe_boundaries{69} = [951, 1078, 983, 1147, 1016, 1030];
pipe_boundaries{70} = [955, 1082, 990, 1163, 1018, 1034];

pipe_boundaries{71} = [1339, 1466, 1365, 1513, 1408, 1418];
pipe_boundaries{72} = [1343, 1470, 1372, 1529, 1410, 1422];
pipe_boundaries{73} = [1347, 1474, 1379, 1545, 1412, 1426];
pipe_boundaries{74} = [1351, 1478, 1386, 1561, 1414, 1430];

pipe_boundaries{75} = [1738, 1865, 1764, 1910, 1807, 1817];
pipe_boundaries{76} = [1742, 1869, 1771, 1926, 1809, 1821];
pipe_boundaries{77} = [1746, 1873, 1778, 1942, 1811, 1825];
pipe_boundaries{78} = [1750, 1877, 1785, 1958, 1813, 1829];

pipe_boundaries{79} = [2137, 2261, 2163, 2308, 2206, 2216];
pipe_boundaries{80} = [2141, 2265, 2170, 2324, 2208, 2220];
pipe_boundaries{81} = [2145, 2269, 2177, 2340, 2210, 2224];
pipe_boundaries{82} = [2149, 2286, 2356, 2184, 2212, 2228];

% \ diagonal pipes
pipe_boundaries{83} = [154, 270, 313, 178, 215, 222];
pipe_boundaries{84} = [158, 274, 329, 185, 217, 226];
pipe_boundaries{85} = [162, 278, 345, 192, 219, 230];
pipe_boundaries{86} = [145, 148, 282, 361, 221, 234];

pipe_boundaries{87} = [546, 669, 714, 572, 614, 621];
pipe_boundaries{88} = [550, 673, 730, 579, 616, 625];
pipe_boundaries{89} = [554, 677, 746, 586, 618, 629];
pipe_boundaries{90} = [558, 681, 593, 762, 620, 633];

pipe_boundaries{91} = [945, 1068, 1111, 971, 1013, 1020];
pipe_boundaries{92} = [949, 1072, 1127, 978, 1015, 1024];
pipe_boundaries{93} = [953, 1076, 1143, 985, 1017, 1028];
pipe_boundaries{94} = [957, 1080, 1159, 992, 1019, 1032];

pipe_boundaries{95} = [1341, 1464, 1509, 1367, 1409, 1416];
pipe_boundaries{96} = [1345, 1468, 1525, 1374, 1411, 1420];
pipe_boundaries{97} = [1349, 1472, 1541, 1381, 1413, 1424];
pipe_boundaries{98} = [1353, 1476, 1557, 1388, 1415, 1428];

pipe_boundaries{99} = [1740, 1863, 1906, 1766, 1808, 1815];
pipe_boundaries{100} = [1744, 1867, 1922, 1773, 1810, 1819];
pipe_boundaries{101} = [1748, 1871, 1938, 1780, 1812, 1823];
pipe_boundaries{102} = [1752, 1875, 1954, 1787, 1814, 1827];

pipe_boundaries{103} = [2139, 2259, 2304, 2165, 2207, 2214];
pipe_boundaries{104} = [2143, 2263, 2320, 2172, 2209, 2218];
pipe_boundaries{105} = [2147, 2267, 2336, 2179, 2211, 2222];
pipe_boundaries{106} = [2151, 2271, 2352, 2186, 2213, 2226];


%% Add Water as the Material
model.material.create('mat1');  % Create a new material
model.material('mat1').propertyGroup('def').set('density', '1000');  % Density of water
model.material('mat1').propertyGroup('def').set('dynamicviscosity', '0.001');  % Viscosity of water
model.material('mat1').name('Water');  % Set material name

%% Add Transport of Diluted Species (TDS) Physics
model.physics.create('tds', 'DilutedSpecies', 'geom1');  % Add TDS physics

% Define multiple inflow and outflow boundary conditions
inlet1 = model.physics('tds').feature.create('inl1', 'Inflow', 1);
inlet1.selection.set([375]);
inlet1.set('c0', '1');

inlet2 = model.physics('tds').feature.create('inl2', 'Inflow', 1);
inlet2.selection.set([1968]);
inlet2.set('c0', '2'); 

outlet1 = model.physics('tds').feature.create('out1', 'Outflow', 1);
outlet1.selection.set([2]);

outlet1 = model.physics('tds').feature.create('out2', 'Outflow', 1);
outlet1.selection.set([707]);

outlet1 = model.physics('tds').feature.create('out3', 'Outflow', 1);
outlet1.selection.set([1502]);

outlet1 = model.physics('tds').feature.create('out4', 'Outflow', 1);
outlet1.selection.set([2295]);

%% Read binary strings from the text file into the list array
filename = 'non_diagonal_TC_sb.txt'; % Replace with the correct file path if needed
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


%% test
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
            pipe_boundary = pipe_boundaries{x};
            num_elements = length(pipe_boundary);  % Get the number of elements

            % Append values to barrier_boundaries based on size
            if num_elements == 2
                barrier_boundaries = [barrier_boundaries; pipe_boundary(1); pipe_boundary(2)];
            elseif num_elements == 3
                barrier_boundaries = [barrier_boundaries; pipe_boundary(1); pipe_boundary(2); pipe_boundary(3)];
            elseif num_elements == 4
                barrier_boundaries = [barrier_boundaries; pipe_boundary(1); pipe_boundary(2); pipe_boundary(3); pipe_boundary(4)];
            elseif num_elements == 5
                barrier_boundaries = [barrier_boundaries; pipe_boundary(1); pipe_boundary(2); pipe_boundary(3); pipe_boundary(4); pipe_boundary(5)];
            elseif num_elements == 6
                barrier_boundaries = [barrier_boundaries; pipe_boundary(1); pipe_boundary(2); pipe_boundary(3); pipe_boundary(4); pipe_boundary(5); pipe_boundary(6)];
            else
                error('Unexpected number of elements in pipe_boundaries{%d}', x);
            end
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
    
    image_filename = sprintf('Plots_nonD/plot_%d.png', z+4834);  % Filename for plot
    saveas(figure_handle, image_filename);  % Save the plot as PNG
    close(figure_handle);  % Close the figure
    
    disp(['Plot with legend saved as ', image_filename]);

    %% Save the Model as .mph
    %mph_filename = sprintf('Models_chip/microfluidic_model_%d.mph', z);  % Unique model filename
    %mphsave(model, mph_filename);  % Save the model
    
    %disp(['Model saved as ', mph_filename]);
    
    %% Evaluate and Save Outlet Concentrations to CSV
    outlet_boundaries = [375, 1968, 2, 707, 1502, 2295];  % Outlet & Inlet boundary IDs
    num_outlets = length(outlet_boundaries);  % Number of outlets
    
    concentration_data = zeros(1, num_outlets);  % Preallocate row for concentrations
    
    % Evaluate concentration at each outlet boundary and store in row
    for i = 1:num_outlets
        %c_outlet = mpheval(model, 'c', 'selection', outlet_boundaries(i), 'edim', 1);  % Evaluate concentration
        c_outlet = mpheval(model, 'c', 'selection', outlet_boundaries(i), 'edim', 1, 'dataset', dset_name); 
        concentration_data(1, i) = mean(c_outlet.d1);  % Store the average concentration
    end
    
    csv_filename = 'outlet_concentration_nonD_sb.csv';  % CSV filename
    
    % Create headers only if the CSV file doesn't exist
    if ~isfile(csv_filename)
        % Create headers dynamically, with specific inlets labeled
        headers = cell(1, num_outlets);  % Preallocate header cell array
        for i = 1:num_outlets
            if ismember(i, [375, 1968])  % Check if it's an inlet
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
