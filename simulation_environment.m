function [path_info_input,path_info_output] = simulation_environment(num_path,SNR,AP_index,has_noise)
%% ��ʵ�黷������Ϊһ����ά����ϵ ÿ����λ���ȴ���1m
% target_location �Ƕ�λĿ���λ�� ��СΪ��1-2��һ������Ϊ����ԭ�㣩
% APs_location ��AP��λ�� ��СΪ��2-2-Nap 
%              Nap��ʵ�����õ���AP�ܸ�����ÿ��AP��Ӧ�������� 
%              ÿ�б�ʾһ����ά����㣬��������㼴ȷ����һ��AP�������������ڵ�
%              ƽ�档Ĭ������������о���target����ļ�Ϊ�������е�һ�����ߵ�λ
%              �ã���һ�����������������е�������Ա���һ�����ߵ�λ�ù�ϵ
% frequency ��Ϣ����Ĺ���Ƶ�� ��λ��Hz
% antenna_space AP����������֮��ľ��� ��ʾΪ�����ı���
% num_antenna ÿ��AP�����ߵĸ���
% num_subcarrier ÿ�������ϵ����ز���
% num_path ÿ��AP�ϵ�·������
% add_len ���ڷ�ֱ��·�� ·�����ȷ�Χ��(direct_len * add_len,direct_len * (add_len + 1))
% speed_light �źŴ����ٶ� m/s

%% �������
WLAN.target_location = [0 0];
WLAN.num_AP = 3;
WLAN.APs_location = zeros(2,2,WLAN.num_AP);
WLAN.APs_location(:,:,1) = [10*sqrt(3) 10;10*sqrt(3) 20]; % AoAΪ60�� ����Ϊ20m
WLAN.APs_location(:,:,2) = [3*sqrt(2) 3*sqrt(2);6 3*sqrt(2)]; % AoAΪ45�� ����Ϊ6m
WLAN.APs_location(:,:,3) = [-5 5*sqrt(3);-5 10]; % AoAΪ30�� ����Ϊ10m
WLAN.frequency = 5 * 10^9;
WLAN.antenna_space_ofwaveLen = 0.5;
WLAN.num_antenna = 3;
WLAN.num_subcarrier = 30;
WLAN.frequency_space = 312.5 * 10^3; % ��λ��Hz
WLAN.num_path = num_path;
WLAN.add_len = 1.1;
WLAN.speed_light = 3 * 10^8;
WLAN.path_complex_gain = complex(zeros(WLAN.num_AP,WLAN.num_path));
WLAN.has_noise = has_noise; % Ϊ1��������� �����������
WLAN.SNR = SNR;

for k = 1:WLAN.num_AP
    for t = 1:WLAN.num_path
        WLAN.path_complex_gain(k,t) = complex(rand * 10 + 1,rand * 10 + 1);
    end
end

%% �Ը���AP�Ȳ�����Ӧ��CSI���� ֮������MUSIC�㷨�����Ӧ��AOA��Tof


% parfor k=1:WLAN.num_AP
    % ����ÿ��AP��Ӧ��CSI������������յ���·����Ϣ
    [CSI,path_info_input] = simulation_generateCSI(WLAN,AP_index);
    
    % ����MUSIC�㷨��CSI�����з����ÿ��·����AoA ToF
    path_info_output = music_SpotFi(CSI,WLAN,WLAN.num_path);
% end
end
    