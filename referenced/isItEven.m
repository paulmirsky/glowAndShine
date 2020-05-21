function answer = isItEven(numberToTest)

    if isequal(2 * ceil(numberToTest/2), numberToTest)
        answer = true;
    else
        answer = false;
    end

end

