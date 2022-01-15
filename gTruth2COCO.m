% script to convert single ground truth object (.mat) into COCO format
% Load all ground truth label object
labels = load("gTruth_merged_remapped.mat");
% extract number of files
% command for Mac; uncomment this if you use Mac
numfile = length(labels.gTruth.DataSource.Source);
% command for windows; uncomment this if you use windows
%numfile = length(labels.gTruth.DataSource);
%------ get all image filenames and save them to an array
filenames = {};
for i = 1:numfile
    filenames{i} = get_imagename(labels.gTruth.DataSource.Source{i});
end
filenames = string(filenames);

%------ extract total number of annotations
totalAnno = 0;
for i =1:numfile
    totalAnno = totalAnno + length(labels.gTruth.LabelData.leaf{i});
	totalAnno = totalAnno + length(labels.gTruth.LabelData.collar{i});
end

%------ create unique ids for images, categories and annotations
imageID = 1:numfile;
annoID = 1:totalAnno; annoID = annoID * 3;
catID = [1 2];

% Create COCO object with all necessary collections
COCO = struct();
COCO.info = struct();
COCO.licenses = struct();
COCO.images = cell(numfile, 1);
COCO.annotations = cell(totalAnno, 1);
COCO.categories = cell(2,1);

% Fill in information collection
COCO.info.description = "Team #21: plant-phenotyping label";
COCO.info.year = 2020;
COCO.info.contributor = "Team #21: Anh Nguyen, Trupti Sarje, Rakshita Ranganath";
COCO.info.date_created = "2020/03/05";

idcounter = 1;
for i = 1:numfile
    % Fill in images collection
    COCO.images{i} = struct();
    COCO.images{i}.file_name = filenames(i);
    COCO.images{i}.id = imageID(i);
    % fill in annotation collection
    numLeaf = length(labels.gTruth.LabelData.leaf{i});
    numCol = length(labels.gTruth.LabelData.collar{i});
    for j = 1:numLeaf
        %disp(idcounter);
        %disp(i); disp(j);
        n = length(labels.gTruth.LabelData.leaf{i}{j});
        one = ones(n, 1);
        COCO.annotations{idcounter} = struct();
        COCO.annotations{idcounter}.id = annoID(idcounter);
        COCO.annotations{idcounter}.image_id = imageID(i);
        COCO.annotations{idcounter}.category_id = 1;
        kp = round([labels.gTruth.LabelData.leaf{i}{j} one]);
        COCO.annotations{idcounter}.keypoints = reshape(kp.', 1, []);
        COCO.annotations{idcounter}.num_keypoints = n;
        idcounter = idcounter + 1;
    end
    for j = 1:numCol
        %disp(idcounter);
        %disp(i); disp(j);
        n = length(labels.gTruth.LabelData.collar{i}{j});
        one = ones(n, 1);
        COCO.annotations{idcounter} = struct();
        COCO.annotations{idcounter}.id = annoID(idcounter);
        COCO.annotations{idcounter}.image_id = imageID(i);
        COCO.annotations{idcounter}.category_id = 2;
        kp = round([labels.gTruth.LabelData.collar{i}{j} one]);
        COCO.annotations{idcounter}.keypoints = reshape(kp.', 1, []);
        COCO.annotations{idcounter}.num_keypoints = n;
        idcounter = idcounter + 1;
    end
end

%------ fill in categories
COCO.categories{1} = struct();
COCO.categories{1}.supercategory = "leaf";
COCO.categories{1}.id = 1;
COCO.categories{1}.name = "leaf tip";
COCO.categories{2}.supercategory = "collar";
COCO.categories{2} = struct();
COCO.categories{2}.supercategory = "collar";
COCO.categories{2}.id = 2;
COCO.categories{2}.name = "collar joint";

%------ convert cells into array of structs
COCO.images = [COCO.images{:}];
COCO.annotations = [COCO.annotations{:}];
COCO.categories = [COCO.categories{:}];

%------ convert struct to json object
output = jsonencode(COCO);
%------ write json object to file??
fid = fopen("annotationCOCO.json", "w");
if fid == -1, error("cannot create json file"); end
fwrite(fid, output, "char");
fclose(fid);

%-- Helper functions --%
function fname = get_imagename(filename)
    tmp = split(filename, "/");
    folder = tmp{length(tmp) - 1};
    imagename = tmp{length(tmp)};
    fname = join(["/", folder, "/", imagename], "");
end
