% code
global g;
global ratio;
global numTable;
global bitWidedisplay;
global simulationResolution;

simulationTime = 0.25;
simulationResolution = 100;

g = 9.80665;
bitWidedisplay = 8;
ratio = simulationTime/simulationResolution;
            
% w*h=7*15 each number
numTable = ["0", "0", "0", "0", "3c", "26", "46", "4a", "52", "62", "64", "3c", "0", "0", "0"; %number 0
            "0", "0", "0", "0", "30", "50", "10", "10", "10", "10", "10", "7c", "0", "0", "0"; %number 1
            "0", "0", "0", "0", "38", "44", "04", "04", "08", "10", "20", "7c", "0", "0", "0"; %number 2
            "0", "0", "0", "0", "78", "04", "04", "38", "04", "04", "04", "78", "0", "0", "0"; %number 3
            "0", "0", "0", "0", "18", "38", "28", "48", "88", "fe", "08", "08", "0", "0", "0"; %number 4
            "0", "0", "0", "0", "7c", "40", "40", "78", "04", "04", "0c", "78", "0", "0", "0"; %number 5
            "0", "0", "0", "0", "1c", "20", "40", "5c", "62", "42", "42", "3c", "0", "0", "0"; %number 6
            "0", "0", "0", "0", "7e", "02", "04", "0c", "08", "18", "10", "30", "0", "0", "0"; %number 7
            "0", "0", "0", "0", "38", "44", "64", "38", "6c", "44", "44", "38", "0", "0", "0"; %number 8
            "0", "0", "0", "0", "3c", "42", "42", "46", "3a", "02", "04", "38", "0", "0", "0"] %number 9

% main show
for count = 0:99
    simulate(count);
end
        
        
function simulate(num)
    global simulationResolution;
    global bitWidedisplay;
    global ratio;
    global g;
    
    time=0;
    axis([0 10 -(0.5*g*(simulationResolution*ratio)^2) 0])
    hold on;
    
    MSH = fix(num/10);
    numberCode_MSH = decode(MSH);
    
    LSH = mod(num,10);
    numberCode_LSH = decode(LSH);
    
    windowHeight=15;
    Xcoor2D = {};
    Y_accumulate = [];
    Ycoor1D = [];
    for n=1:simulationResolution
        time = n*ratio;
        y = -0.5*g*time^2;
        Y_accumulate(n) = y;
        
        if (n <= windowHeight)
            %MSH
            dispK = 0
            numberCodeRaw_MSH = numberCode_MSH(n,:)
            rawCoordinate_MSH = find(numberCodeRaw_MSH);
            leftPartCoor = rawCoordinate_MSH + (dispK*bitWidedisplay);
            %LSH
            dispK = 1
            numberCodeRaw_LSH = numberCode_LSH(n,:)
            rawCoordinate_LSH = find(numberCodeRaw_LSH);
            rightPartCoor = rawCoordinate_LSH + (dispK*bitWidedisplay);
            
            Xcoor2D{n} = [leftPartCoor, rightPartCoor];
            Ycoor1D = Y_accumulate;
        else
            Ycoor1D = Y_accumulate((n-windowHeight):(n-1));
        end
        
        displayW7H15(Xcoor2D, flip(Ycoor1D));
        cla;
    end
    hold off;
end


function retVct = decode(num)
    if num < 0 || num > 9
        return;
    end
    
    global numTable;
    v_hexStr = numTable((num+1),:);
    
    for m = 0:(length(v_hexStr) - 1)
        hexStr = v_hexStr(length(v_hexStr) - m)
        
        D = int8(hex2dec(hexStr));
        bitsize = 7;
        %retVct = zeros(1,7);
        for n = 0:(bitsize - 1)
            bsr = bitsra(D,(n+1))
            b = bitand(bsr,1)
            retVct((m+1),(bitsize - n)) = b
        end
    end
end

function displayW7H15(Xs_2d, Ys_1d)
    %Xs_2d = {[1 2]; [1 2 3]};
    %Ys_1d = [2 3];
    x_stretch_ratio = 0.1;
    for k1 = 1:numel(Ys_1d)
        if isempty(Xs_2d{k1}) == 0
            plot(Xs_2d{k1}*x_stretch_ratio, Ys_1d(k1), 'r*')
        end
    end
    drawnow();
end