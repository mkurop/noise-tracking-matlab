function [state] = init_noise_tracking(frame2,sampleRate)
%INITNOISETRACKING This function initializes the state of the algorithm
%   Input
%     frame2 - length of the fft after zero adding, preferably a power of 2
%     sampleRate - sampling rate in Hz
%     
%   Output
%     state - the initial algorithm state

state.sampleRate = sampleRate;
state.frmNo = 1;
state.alpha_n = 0.8;
state.alpha_ns = 0.98;
state.alpha_p = 0.2;
state.deltak = 1;
state.deltal = 2;
state.frame2 = frame2;
state.gammaBuf = zeros(frame2/2+1,state.deltal+1);
state.gammaBufPos = 1;
state.Psi = zeros(frame2/2+1,1);
state.K = frame2/2+1;
state.p = zeros(state.K,1);
state.ksiFloor = 10^(-15/10);
for i = 1:state.K
    f = i/frame2*sampleRate;
    if f < 1000
        state.Psi(i) = 5;
        continue
    end
    if (f >= 1000) && (f < 3000)
        state.Psi(i) = 6.5;
        continue
    end
    if f > 3000
        state.Psi(i) = 8;
    end
end

end

