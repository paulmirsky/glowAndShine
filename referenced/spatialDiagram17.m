classdef spatialDiagram17  < handle
    
    properties
        trackFig
        trackAx
        trackFigPos = [0 100 800 400]
        trackFigName = 'tracked shine'
        stackFig
        stackAx
        stackFigPos = [0 100 800 400]
        stackFigName = 'stacked shine'
        markerWidthFrac = 0.8 % how wide it is, compared to patch
        markerHeightFrac = 0.8 % how tall it is, compared to zStagger
        zStagger = 1
        stackedBrightColor = [255 0 0]/255
        darkColor = [160 195 230]/255
        glowColor = [1 1 1] * 0.35
        brightTag = 1
        darkTag = 0
        emptyTag = -1
    end


    
    methods
        
        % constructor
        function this = spatialDiagram17()
            % 
        % constructor end
        end 
        
        
        
        
        % pattern is stacked shine array from spatialDiagram16
        function plotStacked(this, pattern, zPlane, plotAsGlow) 
            
            % create window
            if isempty(this.stackFig)
                this.stackFig = figure('position',this.stackFigPos);
                this.stackFig.NumberTitle = 'off';
                this.stackFig.Name = this.stackFigName;
                this.stackAx = axes('parent',this.stackFig);
                hold(this.stackAx,'on');  
            end
            
            if plotAsGlow
                brightColorNow = this.glowColor;
            else
                brightColorNow = this.stackedBrightColor;
            end

            xOffset = this.getCenterOffset(pattern);
            for ii = 1:size(pattern,1)                    
                for jj = 1:size(pattern,2)
                    if pattern(ii,jj)==this.emptyTag
                        % do nothing
                    elseif pattern(ii,jj)==this.brightTag
                        % draw bright
                        this.markPoint( this.stackAx, ii+xOffset, zPlane + jj*this.zStagger, brightColorNow );
                    elseif pattern(ii,jj)==this.darkTag
                        % draw dark
                        this.markPoint( this.stackAx, ii+xOffset, zPlane + jj*this.zStagger, this.darkColor );
                    else
                        error('invalid number!');
                    end
                end
            end
           
        % function end
        end
        
        
        
              
        % pattern is a tracked-shine array from spatialDiagram16
        % colors is a list of colors, one for each column (emanator) of pattern
        function plotTracked(this, pattern, zPlane, colors, plotAsGlow) 
            
            if ( ~plotAsGlow && ~isequal( size(colors,1), size(pattern,2) ) )
                disp('size of color list does not match number of sources!')
                error('size of color list does not match number of sources!');
            end
            
            % create window
            if isempty(this.trackFig)
                this.trackFig = figure('position',this.trackFigPos);
                this.trackFig.NumberTitle = 'off';
                this.trackFig.Name = this.trackFigName;
                this.trackAx = axes('parent',this.trackFig);
                hold(this.trackAx,'on');                
            end
                  
            xOffset = this.getCenterOffset(pattern);
            for ii = 1:size(pattern,1)                    
                for jj = 1:size(pattern,2)
                    if pattern(ii,jj)==this.emptyTag
                        % do nothing
                    elseif pattern(ii,jj)==this.brightTag
                        % draw bright                        
                        if plotAsGlow
                            brightColorNow = this.glowColor;
                        else
                            brightColorNow = colors(jj,:);
                        end                                    
                        this.markPoint( this.trackAx, ii+xOffset, zPlane + jj*this.zStagger, brightColorNow );
                    elseif pattern(ii,jj)==this.darkTag
                        % draw dark
                        this.markPoint( this.trackAx, ii+xOffset, zPlane + jj*this.zStagger, this.darkColor );
                    else
                        error('invalid number!');
                    end
                end
            end
           
        % function end
        end
        
        
        
        
        % draws a point
        function markPoint(this, whichAxis, xVal, zVal, thisColor)
        
            markerDims = [ this.markerWidthFrac, this.markerHeightFrac*this.zStagger ];
            posVec = [ [xVal zVal] - 0.5*markerDims, abs(markerDims) ];
            rectangle('position',posVec,'curvature',[0],'FaceColor',thisColor,...
                'EdgeColor', 'none', 'parent',whichAxis);
            
        % function end
        end

        
        
                   
        % 
        function clearBorder(this)
        
            if ishandle(this.stackFig)
                this.stackFig.Color = [1 1 1];
                this.stackAx.XColor = 'none';
                this.stackAx.YColor = 'none';
            end         
            if ishandle(this.trackFig)
                this.trackFig.Color = [1 1 1];
                this.trackAx.XColor = 'none';
                this.trackAx.YColor = 'none';
            end         
        
        % function end
        end

        

                    
        % 
        function staggeredGlow = staggerGlow(this, glowIn)
                    
%             iGlow = (glowIn==this.brightTag);                       
%             staggeredGlow = diag(glowIn);
%             staggeredGlow = staggeredGlow(:,iGlow);
            
            
            iGlow = find( (glowIn==this.brightTag) );                       
            staggeredGlow = this.emptyTag * ones( [ numel(glowIn), numel(iGlow) ]  );
            for ii = 1:numel(iGlow)
                staggeredGlow( iGlow(ii), ii ) = this.brightTag;
            end
            
        
        % function end
        end        
        
        
        
                    
        % get the alignment offset
        function offset = getCenterOffset(this, pattern)
        
            iBright = find( any(pattern==this.brightTag,2) );
            if isempty(iBright)
                offset = 0;
            else
                offset = -( iBright(1) + iBright(end) )/2;
            end
            
        % function end
        end
        
        
                    
               
    % end of methods           
    end

% end of class       
end

