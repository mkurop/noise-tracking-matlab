function [noisePsd,N2,state] = fastNoiseTracking(prevSpeechPsd,noisyPsd,state)
%FASTNOISETRACKING Function computing noise estimate using algorithm
%proposed in 
% Q.Zang et al., "Fast Nonstationary Noise Tracking"
%   Input
%     prevSpeechPsd - previous frame speech PSD estimate
%     noisyPsd - noisy frame PSD
%     state - state of the algorithm
%   Output
%     noisePsd - estimated noise PSD
%     state - updated state of the algorithm

% Marcin Kuropatwiński (c)
%
% Created on 07.02.2020

if state.frmNo == 1
    state.noisePsd = noisyPsd;
    state.frmNo = state.frmNo + 1;
    noisePsd = noisyPsd;
    gamma_ = noisyPsd./noisePsd;
    state.gammaBuf(:,state.gammaBufPos) = gamma_;
    state.gammaBufPos = state.gammaBufPos + 1;
    N2= noisePsd;
    return
end
gamma_ = noisyPsd./state.noisePsd; % underscore to differentiate from the build-in gamma function
ksi = max(state.alpha_ns * prevSpeechPsd./state.noisePsd + (1-state.alpha_ns)*max((gamma_-1),0),state.ksiFloor);
v =gamma_./(ksi.*(ksi+1));
N = 1./(ksi+1).^2.*exp(min(gamma(1e-5)*gammainc(v,1e-5,'upper'),10)).*sqrt(noisyPsd);
N2 = N.*conj(N);
if any(isnan(N2)) || any(isinf(N2))
    disp('N2')
    disp(gamma(1e-5)*gammainc(v,1e-5,'upper'))
    disp(state.frmNo)
    pause
end
state.gammaBuf(:,state.gammaBufPos) = gamma_;
state.gammaBufPos = state.gammaBufPos + 1;
if state.gammaBufPos > 3
    state.gammaBufPos = 1;
end
% time averaging of gammaBuf
gammaAvg = mean(state.gammaBuf(:,1:min(state.frmNo,3)),2);
gammaAvgF = gammaAvg; % frequency averaged time averaged gamma
% frequency averaging of gammaBuf
for i = 1:state.K
    gammaAvgF(i) = mean(gammaAvg(max(i-state.deltak,1):min(i+state.deltak,state.K)));
end
if any(isnan(gammaAvgF)) 
    disp('gammaAvgF')
    disp(state.frmNo)
    pause
end
% detecting speech
I = gammaAvgF > state.Psi;
% speech probability estimation
state.p = state.alpha_p * state.p + (1-state.alpha_p)*I;
% compute noise estimate
alpha_N = state.alpha_n+(1-state.alpha_n)*state.p;
if any(isnan(alpha_N))
    disp('alpha_N');
    disp(state.frmNo);
    pause
end
if any(isnan(state.noisePsd))
    disp('noisePsd inside0');
    disp(state.frmNo);
    pause
end
state.noisePsd = alpha_N.*state.noisePsd + (1-alpha_N).*N2;
if any(isnan(state.noisePsd))
    disp('noisePsd inside1');
    disp(state.frmNo);
    pause
end
state.frmNo = state.frmNo + 1;
noisePsd = state.noisePsd;
if any(isnan(noisePsd))
    disp('noisePsd inside2');
    disp(state.frmNo);
    pause
end
