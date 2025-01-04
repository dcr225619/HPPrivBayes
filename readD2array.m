function dataset = readD2array()
    filename = 'dataset_binary.txt';
    fileID = fopen(filename, 'r');
    dataset = [];
    line = fgetl(fileID);
    while ischar(line)
        line_list = strsplit(line, ',');
        line_list = str2double(line_list);
        dataset = [dataset; line_list];
        line = fgetl(fileID);
    end
    fclose(fileID);
end