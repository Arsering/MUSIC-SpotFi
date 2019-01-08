function [CSI,path_info] = simulation_generateCSI(WLAN_paras,AP_index)
% target_location �Ƕ�λĿ���λ�� ��СΪ��1-2��һ������Ϊ����ԭ�㣩
% AP_location ��AP��λ�� ��СΪ��2-2 ÿ��AP��Ӧ�������� 
%              ÿ�б�ʾһ����ά����㣬��������㼴ȷ����һ��AP�������������ڵ�
%              ƽ�档Ĭ������������о���target����ļ�Ϊ�������е�һ�����ߵ�λ
%              �ã���һ�����������������е�������Ա���һ�����ߵ�λ�ù�ϵ
% frequency ��Ϣ����Ĺ���Ƶ�� ��λ��Hz
% antenna_space AP����������֮��ľ��� ��ʾΪ�����ı���
% num_antenna ÿ��AP�����ߵĸ���
% num_subcarrier ÿ�������ϵ����ز���
% 
% ����ֵ��CSI Nantenna-Nsubcarrier
%         path_info Npath-2


% ��þ���target����ĵ���к�
[~,min_index] = min(sum((WLAN_paras.target_location - WLAN_paras.APs_location(:,:,AP_index)).^2,2));

if min_index == 1
    max_index = 2;
else
    max_index = 1;
end


%����洢·����Ϣ�ľ��� ÿ�е�һ����ToF �ڶ�����AoA ��Χ����0��180��
path_info = zeros(WLAN_paras.num_path,2);

% ֱ��·����Ӧ��AoA ToF
signal_vector = WLAN_paras.APs_location(min_index,:,AP_index) - WLAN_paras.target_location; % ֱ��·����Ӧ������
antenna_vector = WLAN_paras.APs_location(max_index,:,AP_index) - WLAN_paras.APs_location(min_index,:,AP_index); % ����������ֱ�߶�Ӧ������
path_info(1,2) = sqrt(sum(signal_vector.^2,2)) / WLAN_paras.speed_light;
path_info(1,1) = acos(signal_vector * antenna_vector.'/(sqrt(sum(signal_vector.^2,2) * sum(antenna_vector.^2,2))))*180/pi;
    
% �������������ֱ��·����AoA ToF
for k = 2:WLAN_paras.num_path
    path_info(k,2) = (rand + WLAN_paras.add_len) * path_info(1,2);
    path_info(k,1) = rand * 180;
end

% ��������֮����� ��λ��m
antenna_space = (WLAN_paras.speed_light/WLAN_paras.frequency) * WLAN_paras.antenna_space_ofwaveLen;

% ����洢CSIֵ�ľ���
CSI = complex(zeros(WLAN_paras.num_antenna,WLAN_paras.num_subcarrier));

%����CSI
for k = 1:size(path_info,1)
    exp_AoA = exp((2 * pi * antenna_space * cos(path_info(k,1)*pi / 180) * WLAN_paras.frequency / WLAN_paras.speed_light) * -1i);
    exp_ToF = exp(2 * pi * WLAN_paras.frequency_space * path_info(k,2) * -1i);
    
    for t = 1:WLAN_paras.num_antenna
        tmp_AoA = exp_AoA.^(t-1);
        for m = 1:WLAN_paras.num_subcarrier
            CSI(t,m) = CSI(t,m) + exp_ToF.^(m - 1) * tmp_AoA * WLAN_paras.path_complex_gain(AP_index,k); 
        end
    end
end

if WLAN_paras.has_noise == 1
    CSI = awgn(CSI,WLAN_paras.SNR,'measured');
end



% 
% awgnChannel = comm.AWGNChannel;
% awgnChannel.NoiseMethod = 'Signal to noise ratio (SNR)';
% % Normalization
% awgnChannel.SignalPower =1/sum(WLAN_paras.path_complex_gain(AP_index));
% % Account for energy in nulls
% awgnChannel.SNR = WLAN_paras.SNR;
% CSI = awgnChannel(CSI);


% %������������
% noise = wgn(WLAN_paras.num_antenna,1,WLAN_paras.SNR,'complex');
% 
% %��CSIֵ�������
% for t = 1:WLAN_paras.num_antenna
%     for m = 1:WLAN_paras.num_subcarrier
%         CSI(t,m) = CSI(t,m) + noise(t); 
%     end
% end


end

