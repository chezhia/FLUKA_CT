close all
load('Final2.mat')
FL_P = reshape(Fluence,51,50);
ER_P = reshape(Error,51,50);

ER_P = ER_P .* FL_P/100;
center_val = mean(mean(FL_P(26,25:26)));   % 25:26
FL_P = FL_P/center_val;
ER_P = ER_P/center_val;

% z_ax = -4.18:(4.18*2)/9:4.18; 
% z_ax = z_ax';
% % % % % % % % % % % % % % % % % % % % % % 
load('Measured.mat')
z_ax = z_profile;
x_ax = x_profile;
% x_ax = -25:0.98039:25;
% for i = 1:length(x_ax)-1
%     x_new(i) = mean(x_ax(i:i+1));
% end
% H_bin = abs(z_profile(1)-z_profile(2));
% 16cm
% %z_ax =  -8.109:0.32436:8.109;
% % 8cm
% z_ax =  -4.1756:0.16702:4.1756;
% for i = 1:length(z_ax)-1
%     z_new(i) = mean(z_ax(i:i+1));
% end % 50 bin

% x_ax = x_new;
% z_ax = z_new;
% 
%z_ax = [z_profile(1)-H_bin; z_profile; z_profile(50)+H_bin]; % 52 bins
%z_ax_100 = -4.4304E+00:8.5200E-02:4.4304E+00;
% for i = 1:length(z_ax_100)-1
%   z_ax(i) = mean(z_ax_100(i:i+1));
% end
% z_ax = z_ax';

%Plot 2D heel
figure;
plot(z_ax,FL_P(26,:),'-');%ER_P(26,:)
%plot(z_ax,FL_P(26,:),'o');
hold on;
plot(z_profile,Measured_profile(26,:),'--');
%axis([-9 9 0 1.1]);

%Plot 2D Bowtie
figure;
plot(x_ax,FL_P(:,26),'-')% ,ER_P(:,26)
hold on;
plot(x_ax,Measured_profile(:,26),'--')


%Plot 3D Surface Plots
figure;
surf(x_ax',z_ax',FL_P')
%axis([-25 25 -8.0 8.0 0.0 1.2])
title('Normalized fluence profile at isocenter for 8cm tube collimation');
xlabel('X-axis');
ylabel('Z-axis');
zlabel('Photons per cm^{2}');

figure;
surf(x_profile',z_profile',Measured_profile')
%axis([-25 25 -8.0 8.0 0.0 1.2])

figure;
Diff = 100*(Measured_profile - FL_P)./Measured_profile;
surf(x_profile',z_profile',Diff');
SqDiff = (Measured_profile-FL_P).^2
MSE = sum(SqDiff(:))/numel(FL_P);
SD  = sqrt(MSE)