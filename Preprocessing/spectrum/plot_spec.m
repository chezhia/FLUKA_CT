% load('Spectra_kvp77_hvl_2_9.mat')
% figure
% plot(spec.*4,'r')
% hold on
% load('Spectra_kvp79_hvl_2_97.mat')
% plot(spec.*4,'g')
% load('Spectra_kvp87_hvl_3_3.mat')
% plot(spec.*10,'b')
% load('Spectra_kvp77_hvl_4_68.mat')
% plot(spec.*6.3,'-.r')
% load('Spectra_kvp79_hvl_4_83.mat')
% plot(spec.*6.3,'-.g')
% load('Spectra_kvp87_hvl_5_29.mat')
% plot(spec.*16,'-.b')
% legend('77 kvp, 2.9 hvl, 4 mAs','79 kvp, 2.97 hvl, 4 mAs','87 kvp, 3.3 hvl, 10 mAs','77 kvp, 4.68 hvl, 6.3 mAs', '79 kvp, 4.83 hvl, 6.3 mAs','87 kvp, 5.29 hvl, 16 mAs')
% xlabel('Energy (kvp)')
% title('X-ray spectra')
% ylabel('Photons / mm^2')

load('Spectra_kvp77_hvl_2_9.mat')
figure
plot(spec,'r')
hold on
load('Spectra_kvp79_hvl_2_97.mat')
plot(spec,'g')
load('Spectra_kvp87_hvl_3_3.mat')
plot(spec,'b')
load('Spectra_kvp77_hvl_4_68.mat')
plot(spec,'-.r')
load('Spectra_kvp79_hvl_4_83.mat')
plot(spec,'-.g')
load('Spectra_kvp87_hvl_5_29.mat')
plot(spec,'-.b')
legend('77 kvp, 2.9 hvl','79 kvp, 2.97 hvl','87 kvp, 3.3 hvl','77 kvp, 4.68 hvl', '79 kvp, 4.83 hvl','87 kvp, 5.29 hvl')
xlabel('Energy (kvp)')
ylabel('Photons / mm^2 / mAs')