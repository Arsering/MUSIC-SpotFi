function [path_info_output]=my_music(CSI,WLAN_paras,signal_space)
%%  chanEst �ŵ�����ֵ Nsb-Ntx-Nrx
%    numSC    ��ʹ�õ����ز�������
%    numTX    ��ʹ�õ����ߵ�����
%    signal_space ����ʱ��ʾ��Ӧ���źſռ������ֵ�ĸ���
%                 ����ʱ��һ��Ԫ�ر�ʾ��Ӧ���źſռ������ֵ�����ֵ���ڶ���Ԫ�ر�ʾ��Ӧ���źſռ������ֵ���½�
%    per_frequency �������ز�֮���Ƶ�ʲ� ��Ϊ 312.5Hz
%     d ��������֮��ľ���=����*d

row = floor(WLAN_paras.num_subcarrier/2) * 2;% smoothed_CSI������
column=(WLAN_paras.num_subcarrier - row/2 + 1) * (WLAN_paras.num_antenna - 1);% smoothed_CSI������

%����smoothed_CSI�Ĵ洢����
smoothed_CSI = zeros(row,column,'like',CSI);


%����smoothed_CSI
for k = 1:(WLAN_paras.num_antenna-1)
    for t = 1:(WLAN_paras.num_subcarrier - row/2 + 1)
        smoothed_CSI(:,t + (k-1)*(WLAN_paras.num_subcarrier - row/2 + 1)) = [CSI(k,t:(t+row/2-1)),CSI(k+1,t:(t+row/2-1))].';
    end
end

% ����smoothed_CSI������ֵ�����Ӧ����������
correlation_matrix = smoothed_CSI * smoothed_CSI';
[E,D] = eig(correlation_matrix);

 % �ҵ�noise_space��Ӧ����������
[~,indx] = sort(diag(D),'descend');
eigenvects = E(:,indx);
noise_eigenvects = eigenvects(:,(signal_space+1):end);

antenna_space = (WLAN_paras.speed_light/WLAN_paras.frequency) * WLAN_paras.antenna_space_ofwaveLen; % ��������֮����� ��λ��m

%ȷ��������
X = 0:1:180;
Y = ((10^-7)/40):((10^-7)/40):10^-7;
% [sample_AoA,sample_ToF] = meshgrid(X,Y);
samples = complex(zeros(length(X),length(Y)));

%����
for t = 1:length(X)
    for k = 1:length(Y)
       
        angleE = exp(-1i * 2 * pi * antenna_space * cos(X(t)*pi/180) * WLAN_paras.frequency / WLAN_paras.speed_light);
        timeE = exp(-1i * 2 * pi * WLAN_paras.frequency_space * Y(k));
        steering_vector = complex(zeros(row,1));
        for n=0:1
            for m=1:row/2
                steering_vector((n*row/2)+m,1) = angleE.^n * timeE.^(m-1);
            end
        end
        samples(t,k) = 1/sum(abs(noise_eigenvects' * steering_vector).^2,1);
    end
end

%% ������άͼ��
mesh(Y,X,samples);
xlabel('X(TOF/s)');
ylabel('Y(AOA/��)');
% surf(sample_AoA,sample_ToF,samples.')
shading interp;

%% 
%����洢��õ�AOA TOF�ľ���
path_info_output = zeros(signal_space,2);
max_N_value = zeros(1,signal_space);

%Ѱ��ǰsignal_space������ֵ��
for m = 1:length(X)
    for n = 1:length(Y)
        step = [1 0;0 1;-1 0;0 -1];
        scope = [length(X),length(Y)];
        mark = 1;

        %�жϵ�ǰ���Ƿ�Ϊ����ֵ��
        for k = 1:size(step,1)
            temp_x = m + step(k,1);
            if temp_x < 1 || temp_x > scope(1)
                temp_x = m;
            end
            temp_y = n + step(k,2);
            if temp_y < 1 ||temp_y > scope(2)
                temp_y = n;
            end
            if samples(m,n) < samples(temp_x,temp_y)
                mark = 0;
                break;
            end
        end
       
        %���Ϊ����ֵ�㣬��洢����
        if mark == 1
            min_index = minI(max_N_value);
            if max_N_value(min_index) < samples(m,n)
                max_N_value(min_index) =  samples(m,n);
                path_info_output(min_index,:) = [X(m) Y(n)];
            end
        end
    end
end

end


%% ���������������СԪ�ص��±�

function index = minI(input)
    index  = 1;
    for k = 2:length(input)
        if input(k) < input(index)
            index = k;
        end
    end
end

