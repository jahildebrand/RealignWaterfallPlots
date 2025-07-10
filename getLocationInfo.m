function [lat_dd, lon_dd, depth_m] = getLocationInfo(Project, Data_ID, date_check,filename)
    % Define full path to the Excel file
    % filename is harp data summary
    % filename = 'HARPDataSummary_20250205.xlsx';
    % Read the table
    T = readtable(filename);

    % Combine Project and Data_ID to form the prefix (e.g., "RC01")
    Search_ID = strcat(string(Project), "_", string(Data_ID));

    % Convert first column to string array
    first_col = string(T{:,1});

    % Find all rows that start with Search_ID
    row_matches = startsWith(first_col, Search_ID);

    if ~any(row_matches)
        error('No entries found starting with "%s".', Search_ID);
    end

    % Extract matching subset
    T_sub = T(row_matches, :);

    % Convert Deploy_Date and Recovery_Date to datetime
    deploy_dates = datetime(T_sub{:,8}, 'InputFormat', 'yyyy-MM-dd');
    recovery_dates = datetime(T_sub{:,9}, 'InputFormat', 'yyyy-MM-dd');

    % Check which row contains the date_check
    date_in_range = (date_check >= deploy_dates) & (date_check <= recovery_dates);

    if ~any(date_in_range)
        error('Date %s is outside all deployment windows for "%s".', ...
              datestr(date_check), Search_ID);
    end

    % Use the first valid match
    idx = find(date_in_range, 1);
    row = T_sub(idx, :);

    % Extract and convert coordinates and depth
    lat_dd = convertToDecimalDegrees(row{1,5}{1}, 'N');
    lon_dd = convertToDecimalDegrees(row{1,6}{1}, 'E');
    depth_m = row{1,7};
end

function dd = convertToDecimalDegrees(coord_str, positive_hemisphere)
    coord_str = strtrim(coord_str);
    tokens = regexp(coord_str, '(\d+)-([\d\.]+)\s*([NSEW])', 'tokens');
    if isempty(tokens)
        error('Invalid coordinate format: "%s"', coord_str);
    end
    parts = tokens{1};
    deg = str2double(parts{1});
    min = str2double(parts{2});
    hemi = upper(parts{3});

    dd = deg + min / 60;

    % Flip sign if S or W
    if (hemi == 'S' && positive_hemisphere == 'N') || ...
       (hemi == 'W' && positive_hemisphere == 'E')
        dd = -dd;
    end
end
