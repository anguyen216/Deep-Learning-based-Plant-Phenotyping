function remap_gTruthObj(path)
    % Script to merge ground truth object
    % changeFilePaths method may be useful later
    clc;
    % create cell arrays to store datasource and labels
    Source = cell(0,1);
    Leaf = cell(0,1);
    Collar = cell(0,1);

    truthObj = load('gTruth_merged.mat');

    % getting labels definitions
    Def = truthObj.gTruth.LabelDefinitions;

    %------ getting data source
    % because the fourth object is done on mac, mat object is saved
    % differently and the path is also different
    Source = getsource(truthObj, path);
    %Source = [Source; dsource];

    %------ getting leaf labels
    L = truthObj.gTruth.LabelData.leaf;
    C = truthObj.gTruth.LabelData.collar;
    Leaf = [Leaf; L];
    Collar = [Collar; C];

    Labels = table(Leaf, Collar);
    Labels.Properties.VariableNames = ["leaf", "collar"];
    Source = groundTruthDataSource(Source);

    %------ create ground truth object 
    gTruth = groundTruth(Source, Def, Labels);
    save('gTruth_merged_remapped.mat','gTruth');
    %------ HELPER FUNCTIONS ------
    % extract source files
    function sfiles = getsource(tobj, path)
        datasource = tobj.gTruth.DataSource.Source;
        sfiles = cell(length(datasource), 1);
        % get individual source
        for i = 1:length(datasource)
            sfiles{i} = regexp(datasource{i},'/','split'); %getpath(datasource{i});
            if size(sfiles{i},2) == 1
                warning('Using \ instead of /, but its ok buddy, I gotcha ;)');
                sfiles{i} = regexp(datasource{i},'\','split'); %getpath(datasource{i});
            end
            if length(sfiles{i}{end-1}) > 18
                sfiles{i}{end-1} = sfiles{i}{end-1}(1:18);
            end
            sfiles{i} = fullfile(path,sfiles{i}{end-1:end});
        end 
    end
end