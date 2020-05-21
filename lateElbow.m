clear all
close all
dbstop on error
clc
addpath([ fileparts(mfilename('fullpath')), '\referenced' ]);

% late elbow
a = 1;
b = 2;
c = 4;
planeZs = a*a*b*b*c*(0:c).';

% set up calc object
calc = spatialDiagram16;
calc.glowFeatures = [ a, b, c ];

% create a color palate
colors = colorList01();
colors.fromPalate('lines',a*c)

patternZScale = 2;
shineZScale = 1;

% set up pattern drawing object
drawPattern = spatialDiagram17;
drawPattern.stackFigPos = [1200 300 600 400];
drawPattern.trackFigPos = [600 300 600 400];
drawPattern.zStagger = patternZScale;
drawPattern.darkColor = colors.darkColors(3,:);

% set up shine drawing object
drawShine = spatialDiagram17;
drawShine.stackFigPos = [0 300 600 400];
drawShine.zStagger = shineZScale;
drawShine.darkColor = colors.darkColors(2,:);
drawShine.markerWidthFrac = 0.75;
drawShine.stackFigName = 'one shine instance';

% go thru all the planes
for thisZ = planeZs.'
    
    try
        
        disp(['plotting z = ',num2str(thisZ)]);
        
        % calculate / plot the shine
        calc.calcPatternAtZ(thisZ);    
        drawShine.plotStacked(calc.shinePattern, thisZ, false);        

        % plot tracked shine
        drawPattern.plotTracked(calc.trackedShine, thisZ, colors.colorList, false);
        
        % plot glow
        if ( thisZ==0 )
            drawShine.plotStacked( drawShine.brightTag, thisZ, true);        
            staggeredGlow = drawPattern.staggerGlow( calc.glowPattern );
            drawPattern.plotTracked( staggeredGlow, thisZ, [], true );
        end

    catch
        disp('error while calculating or drawing!');
    end
    
end

drawShine.clearBorder;
drawPattern.clearBorder;

