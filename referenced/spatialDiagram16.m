classdef spatialDiagram16  < handle
    
    properties        
        glowFeatures % the sizes of glow features [a, b, c]
        spatialPointPadding = 2 % extra-room factor in nSpatialPoints
        nSpatialPoints
        glowPattern
        shinePattern       
        trackedShine
        stackedShine
        texGlow
        arrayGlow
        formGlow
        darkFeatureBrightPoint = 'center' % 'center' or 'left'
        includeFreeSky = false        
        brightTag = 1
        darkTag = 0
        emptyTag = -1
    end

    
    methods
        
        % constructor
        function this = spatialDiagram16()
            % 
        % constructor end
        end 

        
        
        
        % 
        function calcPatternAtZ(this, thisZ)
            
            % validate inputs
            if ~isequal( size(this.glowFeatures), [1,3] )
                disp('glow must be a row of three numbers!'); % for a simple beam, set b and c = 1
                error('glow must be a row of three numbers!'); % for a simple beam, set b and c = 1
            end

            % calculate the glow pattern
            this.glowPattern = this.getPatternFromFeatures( this.glowFeatures, {'bright','dark','bright'} );
            iTrim = find(this.glowPattern,1,'first'):find(this.glowPattern,1,'last');
            this.glowPattern = this.glowPattern( iTrim );
            this.glowPattern = this.formatPattern( this.glowPattern );

            % classify by parameters
            this.texGlow = prod( this.glowFeatures(1) );
            this.arrayGlow = prod( this.glowFeatures(1:2) );
            this.formGlow = prod( this.glowFeatures(1:3) );

            shineFeatureSizes = [];
            shineFeatureTypes = {};

            % find the shine sizes and types
            if (thisZ==0)
                this.shinePattern = [];
            else  % starting from the innermost shine, find hatched features
                
                if (thisZ >= this.formGlow)
                    shineFeatureSizes(1,end+1) = thisZ / this.formGlow;
                    shineFeatureTypes{1,end+1} = 'bright';                
                end
                
                if (thisZ >= this.arrayGlow)
                    shineFeatureSizes(1,end+1) = thisZ / this.arrayGlow / prod(shineFeatureSizes);
                    shineFeatureTypes{1,end+1} = 'dark';
                end
                
                if (thisZ >= this.texGlow)
                    shineFeatureSizes(1,end+1) = thisZ / this.texGlow / prod(shineFeatureSizes);
                    shineFeatureTypes{1,end+1} = 'bright';
                end
    
                if this.includeFreeSky
                    shineFeatureSizes(1,end+1) = thisZ / this.texGlow;
                    shineFeatureTypes{1,end+1} = 'dark';                
                end
                
                % calculate the shine pattern
                shinePatternLoc = this.getPatternFromFeatures( shineFeatureSizes, shineFeatureTypes );
                this.shinePattern = this.formatPattern(shinePatternLoc);
                
            end
           
            % get the matrices for all outputs     
            iBrightGlowPoints = find( this.glowPattern==this.brightTag );
            nBrightGlowPoints = numel( iBrightGlowPoints );
            this.nSpatialPoints = this.spatialPointPadding *... 
                ( numel(this.glowPattern) + numel(this.shinePattern) );
            this.trackedShine = nan([this.nSpatialPoints,nBrightGlowPoints]);
            
            % for each bright glow patch, displace the entire shine pattern.  track all results 
            fullShinePattern = this.padPattern(this.shinePattern); % includes extra empty space
            for ii = 1:nBrightGlowPoints               
                iThisPoint = iBrightGlowPoints(ii);
                if ( (iThisPoint + numel(this.shinePattern)) > this.nSpatialPoints )
                    error('space is not large enough to hold the full stack! increase nSpatialPoints');
                end
                this.trackedShine(:,ii) = circshift(fullShinePattern,iThisPoint);     
            end
            
            % stack (collate) results
            allDepths = sum( this.trackedShine==this.brightTag,2 ); 
            this.stackedShine = this.darkTag * ones([this.nSpatialPoints,max(allDepths)]); % initialize all as dark shine
            for ii = 1:this.nSpatialPoints
                thisDepth = allDepths(ii);
                this.stackedShine(ii,1:thisDepth) = this.brightTag;
            end

            % trim away empty space
            allTrackedValid = find( sum( (this.trackedShine~=this.emptyTag),2 ) > 0 );
            allStackedValid = find( any( this.stackedShine==this.brightTag, 2 ) );
            iTrackedValid = min(allTrackedValid):max(allTrackedValid);  
            iStackedValid = min(allStackedValid):max(allStackedValid);  
            this.trackedShine = this.trackedShine( iTrackedValid, : );
            this.stackedShine = this.stackedShine( iStackedValid, : );
            
        % function end
        end




        % 
        function pattern = getPatternFromFeatures(this, featureSizes, featureTypes)

            % validate inputs
            if ~isequal( numel(featureSizes), numel(featureTypes) )
                error('feature size and feature type vectors must be the same size!');
            end
            if ( isempty(featureSizes) && isempty(featureTypes) )
                error('feature specification can not be empty!');
            end
            if ~allEntriesAreIntegers(featureSizes,1e-9)
                disp('feature size is not an integer!');
                error('feature size is not an integer!');
            end
            
            pattern = 1; % it starts off trivially
            nFeatures = numel(featureSizes);
            % for each feature...
            for ii = 1:nFeatures
                nPatches = featureSizes(ii);  
                % get the state vector for the feature
                if strcmp(featureTypes(ii),'dark')
                    thisStateVec = zeros([nPatches,1]);
                    if strcmp(this.darkFeatureBrightPoint,'center')                        
                        if ~isItEven(nPatches) % if it's symmetrical            
                            zeroPoint = ceil(nPatches/2);
                        else % if it's not symmetrical
                            zeroPoint = floor(nPatches/2) + 1;
                        end
                        thisIndex = mod((zeroPoint-1),nPatches)+1; 
                    elseif strcmp(this.darkFeatureBrightPoint,'left')
                        thisIndex = 1;
                    else
                        disp('invalid dark feature location!');
                        error('invalid dark feature location!');
                    end
                    thisStateVec(thisIndex) = 1;        
                elseif strcmp(featureTypes(ii),'bright')
                    thisStateVec = ones([nPatches,1]);     
                else
                    disp('invalid feature type!')
                    error('invalid feature type!')
                end
                % take the outer product of this feature with the cumulative outer product 
                nPointsTotal = numel(pattern)*numel(thisStateVec);
                pattern = reshape(pattern*thisStateVec.', nPointsTotal, 1);                                
            end
            
            % scale it
            pattern = pattern / sum(pattern);
                        
        % function end
        end




        % adds zeros to the pattern to make it the right length
        function patternOut = padPattern(this, patternIn)
        
            nZerosToAdd = this.nSpatialPoints - numel(patternIn);
            if ( nZerosToAdd < 0 )
                error('component is too large! cannot pad');
            else
                moreZeros = this.emptyTag * ones([nZerosToAdd,1]);
                patternOut = [ patternIn; moreZeros ];
            end              
        
        % function end
        end




        % this replaces all 0s and nonZeros with dark and bright tags, respectively.
        function patternOut = formatPattern(this, patternIn)
        
            zeroPoints = ( patternIn==0 );
            patternOut(zeroPoints) = this.darkTag;
            patternOut(~zeroPoints) = this.brightTag;
            patternOut = patternOut.';
            
        % function end
        end

        

               
    % end of methods           
    end

% end of class       
end

