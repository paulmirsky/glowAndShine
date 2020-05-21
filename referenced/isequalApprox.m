function [out, maxDifferenceEachLevel] = isequalApprox(matrix1, matrix2, smallestAllowableAmount)

    if ~isequal(size(matrix1), size(matrix2))
        out = false;
        return
    end
    
    % matrix1 and matrix2 can also be *stacks
    dims = size(matrix1, 1)*size(matrix1, 2);
    nLevels = size(matrix1, 3);
    eachLevelIsEqual = nan(nLevels, 1);
    maxDifferenceEachLevel = nan(nLevels, 1);
    for ii = 1:nLevels
        difference = matrix1(:,:,ii) - matrix2(:,:,ii);
        diffAsVector = reshape(abs(difference), 1, dims);
        maxEntryInDifference = max(diffAsVector);
        if maxEntryInDifference < smallestAllowableAmount
            eachLevelIsEqual(ii) = true;
        else
            eachLevelIsEqual(ii) = false;
        end
        maxDifferenceEachLevel(ii) = maxEntryInDifference;
    end
    
    out = all(eachLevelIsEqual);
    
end

