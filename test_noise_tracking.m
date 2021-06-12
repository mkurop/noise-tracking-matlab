
clear
load('./test-data/stencil.mat')
% initialize state structure
state = init_noise_tracking(256,8000);
result = zeros(size(noisy_psd));
for i = 1:10 % time loop
  % compute actual noise estimate
  [result(:,i), state] = fast_noise_tracking(noisy_psd(:,i),prev_clean_speech_estimates(:,i),state);
end
if norm(stencil-result,"fro") < 1.e-7
  fprintf('Test passed ...')
else
  fprintf('Test failed ...')
end