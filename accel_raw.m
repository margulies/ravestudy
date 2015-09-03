function accel_raw

clear; load accel_data.mat;

frequency = 90;
time = [1:length(handL1.x)]' ./ frequency;
limits = [0 250 -3 3];

figure;

% subplot(6,2,1); plot(time,handL1.x); title('handL1.x'); axis(limits); ylabel('acceleration');
% subplot(6,2,3); plot(time,handL1.y); title('handL1.y'); axis(limits);
% subplot(6,2,5); plot(time,handL1.z); title('handL1.z'); axis(limits);
% 
% subplot(6,2,2); plot(time,handL2.x); title('handL2.x'); axis(limits); ylabel('acceleration');
% subplot(6,2,4); plot(time,handL2.y); title('handL2.y'); axis(limits);
% subplot(6,2,6); plot(time,handL2.z); title('handL2.z'); axis(limits);
% 
% subplot(6,2,7); plot(time,handR1.x); title('handR1.x'); axis(limits);
% subplot(6,2,9); plot(time,handR1.y); title('handR1.y'); axis(limits);
% subplot(6,2,11); plot(time,handR1.z); title('handR1.z'); axis(limits); xlabel('time (s)');
% 
% subplot(6,2,8); plot(time,handR2.x); title('handR2.x'); axis(limits);
% subplot(6,2,10); plot(time,handR2.y); title('handR2.y'); axis(limits);
% subplot(6,2,12); plot(time,handR2.z); title('handR2.z'); axis(limits); xlabel('time (s)');

subplot(6,2,1); plot(time,hipL1.x); title('hipL1.x'); axis(limits); ylabel('acceleration');
subplot(6,2,3); plot(time,hipL1.y); title('hipL1.y'); axis(limits);
subplot(6,2,5); plot(time,hipL1.z); title('hipL1.z'); axis(limits);

subplot(6,2,2); plot(time,hipL2.x); title('hipL2.x'); axis(limits); ylabel('acceleration');
subplot(6,2,4); plot(time,hipL2.y); title('hipL2.y'); axis(limits);
subplot(6,2,6); plot(time,hipL2.z); title('hipL2.z'); axis(limits);

subplot(6,2,7); plot(time,hipR1.x); title('hipR1.x'); axis(limits);
subplot(6,2,9); plot(time,hipR1.y); title('hipR1.y'); axis(limits);
subplot(6,2,11); plot(time,hipR1.z); title('hipR1.z'); axis(limits); xlabel('time (s)');

subplot(6,2,8); plot(time,hipR2.x); title('hipR2.x'); axis(limits);
subplot(6,2,10); plot(time,hipR2.y); title('hipR2.y'); axis(limits);
subplot(6,2,12); plot(time,hipR2.z); title('hipR2.z'); axis(limits); xlabel('time (s)');