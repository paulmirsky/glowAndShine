classdef colorList01  < handle
    
    properties        
        colorNames = {...
            'red';
            'blue';
            'green';
            'yellow';
            'grey';
            'purple';
            'brown';
            'black'; }
        colorList = [ ...
            [255 0 0]/255;
            [91 155 213]/255;
            [112 173 71]/255;
            [255 192 0]/255;
            [140 140 140]/255;
            [165 75 205]/255;
            [182 111 40]/255;
            [0 0 0]/255 ]
        darkColors = [
            [160 195 230]/255; % dark
            [195 217 239]/255; % medium
            [215 230 245]/255; % light
            [255 255 255]/255 ] % white
        colorNamesAreValid = true        
    end

    
    methods

        % usage examples:
        % getColors = colorList01();
        % getColors.fromPalate('cool',10)
        % getColors.get('red');
        % getColors.expandList(3);
        % getColors.darkColors(2,:)        

        
        
        % constructor
        function this = colorList01()
            % 
        % constructor end
        end 
        
        
        
        % 
        function fromPalate( this, colormapName, nColors )
                        
            this.colorNamesAreValid = false;

            options.nColors = nColors;
            if options.nColors < 2 % do this or else it can't interpolate
                options.nColors = 2;
            end
            colorLimits = [1,nColors].';
            if colorLimits(2) < 2 % do this or else it can't interpolate
                colorLimits(2) = 2;
            end
            this.colorList = colorsForValues01((1:nColors).',colormapName,...
                colorLimits,options);
            this.colorList = squeeze(this.colorList);                 
                
        % function end
        end                        


                    
        % it takes the color list, and replicates each color multiple
        % times, keeping the color order the same
        function expandList(this, nReplicates)
        
            nNewColors = size(this.colorList,1)*nReplicates;
            expandedColors = nan([nNewColors,3]);
            
            for ii = 1:size(this.colorList,1)
                iStart = ( (ii - 1) * nReplicates ) + 1;
                iEnd = iStart + nReplicates - 1;
                expandedColors((iStart:iEnd),:) = repmat(this.colorList(ii,:),[nReplicates,1]);
            end
            
            this.colorList = expandedColors;
            this.colorNamesAreValid = false;
        
        % function end
        end

        
                    
        % it takes the color list, and replicates the entire list multiple times
        function repeatList(this, nReplicates)
        
            nNewColors = size(this.colorList,1)*nReplicates;
            nCurrentColors = size(this.colorList,1);
            expandedColors = nan([nNewColors,3]);
            
            for ii = 1:nReplicates
                iStart = ( (ii - 1) * nCurrentColors ) + 1;
                iEnd = iStart + nCurrentColors - 1;
                expandedColors((iStart:iEnd),:) = this.colorList;
            end
            
            this.colorList = expandedColors;
            this.colorNamesAreValid = false;
        
        % function end
        end


                    
        % give it a name, and it tells you the correponding rgb values
        function rgbVal = get(this, colorName)
        
            if ~this.colorNamesAreValid
                error('color list is not the original list! name is not valid.');
            end
            
            iColor = find(strcmp(colorName,this.colorNames));
            if isempty(iColor)
                error('invalid color name!');
            end
            rgbVal = this.colorList(iColor,:);                        
        
        % function end
        end


               
    % end of methods           
    end

% end of class       
end

