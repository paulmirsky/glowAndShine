function colorArray = colorsForValues01( valueArray, colormapName, range, options )

if ndims(valueArray) > 2
    screenMsg = 'WHOOPS! colorsForValues01, max number of dims is 2!'
    return
end
[nRows, nCols] = size(valueArray);
range = range(:);
if ( max(max(valueArray)) > range(2,1) ) || ( min(min(valueArray)) < range(1,1) )
    screenMsg = 'WHOOPS! colorsForValues01, values exceed range!'
end

defaultNColors = 64;
if isfield(options, 'nColors')
    nColors = options.nColors;
else
    nColors = defaultNColors;
end
colormapArrayString = [colormapName, '(', num2str(nColors), ')' ];
colormapRGBVals = eval(colormapArrayString);

colormapSize = size(colormapRGBVals,1);
colormapStep = ( range(2)-range(1) ) / (colormapSize-1); 
colormapVariableVals = ( range(1):colormapStep:range(2) ).';

% if there is only one value
if nRows==1 % treat separately or else it crashes when you do the interpolation
    colorArray = colormapRGBVals(1,:);
    colorArray = permute(colorArray, [1 3 2]);
else
    % map the variable array to a color array
    colorArray = interp1(colormapVariableVals, colormapRGBVals, valueArray);
    if size(valueArray,2)==1
        colorArray = permute(colorArray, [1 3 2]);
    elseif size(valueArray,1)==1
        colorArray = permute(colorArray, [3 1 2]);
    end
end



end

