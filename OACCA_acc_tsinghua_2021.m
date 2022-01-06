clear all
close all
addpath('../mytoolbox');
%addpath('D:\chiman\Dropbox\Disk\Matlab\mytoolbox');
filename=mfilename('fullpath');
str_save='OACCA_accuracy_tsinghua_2021.mat';

frequencySet=[8:0.2:15.8];
phaseSet=[0 0.5 1 1.5 0 0.5 1 1.5 0 0.5 1 1.5 0 0.5 1 1.5 0 0.5 1 1.5 ...
    0 0.5 1 1.5 0 0.5 1 1.5 0 0.5 1 1.5 0 0.5 1 1.5 0 0.5 1 1.5]*pi;
temp=reshape([1:40],8,5);
temp=temp';
target_order=temp(:)';
% target_selection=[1:1:40];
% target_order=target_order(target_selection);
% frequencySet=frequencySet(target_selection);
% phaseSet=phaseSet(target_selection);
% online_learn_idx1=[1:length(frequencySet)];
% online_learn_idx2=[1:length(frequencySet)];
% online_learn_idx3=[1:length(frequencySet)];
% online_learn_idx4=[1:length(frequencySet)];

% [sort_v,sort_freq_idx]=sort(frequencySet);
nConditions = length(frequencySet);
condition = 1:nConditions;
srate = 250;
stimTime = 2;
dataLength = round(stimTime*srate);
delayTime = 0.12;% visual latency
latencyDelay = round(delayTime*srate);% time windows for CCA training
pressvepLength = round(0.12*srate);
% epochTime = stimTime + delayTime;
% eeg_channels = [1:62];
eeg_channels = [48 54 55 56 57 58 61 62 63]; % Pz, PO5, PO3, POz, PO4, PO6, O1, Oz, O2
numOfSubband = 5;
multiplicateTime = 5;

%dataset_str='..\Tsinghua dataset 2016\';
dataset_str='/data/2016_Tsinghua_SSVEP_database/';

nSubjects=35;
blocknum=[1:6];
tw_length=floor([0.6:0.1:1.5]*srate);

tic
subj_num_count=1;

data1=zeros(length(eeg_channels),dataLength+latencyDelay,length(target_order),length(blocknum),nSubjects);
ssvepdata=zeros(length(eeg_channels),dataLength,length(target_order),length(blocknum),nSubjects,numOfSubband);
ssvepdata_stream=zeros(length(eeg_channels),dataLength,length(target_order)*length(blocknum),nSubjects,numOfSubband);
ssvepdata_stream_label=zeros(1,length(target_order)*length(blocknum));
ssveptemplate=zeros(length(eeg_channels),dataLength,length(target_order),nSubjects);

tic
for sn=1:nSubjects
    load([dataset_str 'S' num2str(sn) '.mat']);
    data1(:,:,:,:,subj_num_count) = data(eeg_channels,floor(0.5*srate)+1:floor(0.5*srate+latencyDelay)+dataLength,target_order,:); % SSVEP
    subj_num_count=subj_num_count+1;
end
toc

disp('loading the data ... finished');
subj_num_count=subj_num_count-1;
fs = srate/2;

%notch
Fo = 50;
Q = 35;

BW = (Fo/(srate/2))/Q;

[notchB,notchA] = iircomb(srate/Fo,BW,'notch');

%bandpass filter
for k=1:numOfSubband
    Wp = [(8*k)/fs 90/fs];
    Ws = [(8*k-2)/fs 100/fs];
    [N,Wn] = cheb1ord(Wp,Ws,3,40);
    [subband(k).bpB,subband(k).bpA] = cheby1(N,0.5,Wn);
end

sub=[1:subj_num_count];

for i = length(frequencySet):-1:1
    testFres = frequencySet(i) * (1:multiplicateTime)';
    t = 0:1/srate:3-1/srate;
    targetTemplateSet{i} = [cos( 2 * pi * testFres * t +phaseSet(i)* (1:multiplicateTime)');...
        sin( 2 * pi * testFres * t+phaseSet(i)* (1:multiplicateTime)')];
    online_learn_Y(:,:,i)=targetTemplateSet{i};
end

tic
for nsub = 1:subj_num_count
    % SSVEP data
    ct=1;
    for nblock = 1:length(blocknum)
        
        for ncond = 1:length(condition)
            
            for nchan = 1:length(eeg_channels)
                tmp0 = data1(nchan,:,ncond,nblock,nsub);
                tmp1 = filtfilt(notchB, notchA, tmp0); %notch
                
                for k=1:numOfSubband
                    tmp2=filtfilt(subband(k).bpB,subband(k).bpA,tmp1);
                    ssvep0 = tmp2(latencyDelay+1:latencyDelay+dataLength);
                    
                    ssvepdata(nchan,:,ncond,nblock,nsub,k) = ssvep0;%bandpass
                    ssvepdata_stream(nchan,:,ct,nsub,k) = ssvep0;%bandpass
                    ssvepdata_stream_label(ct) = ncond;%bandpass
                end
            end
            ct=ct+1;
        end
    end
    
    for k=1:numOfSubband
        ssveptemplate(:,:,:,nsub,k)=mean(ssvepdata(:,:,:,:,nsub,k),4);
    end
    disp(['Subj.' num2str(nsub)]);
end
toc
disp('Preprocessing the data ... finished');

% 10-repetitions (10 random orders for the trials)
for cv=1:10
    % SSVEP data stream
    % the trial order is random
    num_of_labels=length(target_order)*length(blocknum);
    
    rand_data_idx=randperm(num_of_labels);
    ssvepdata_stream_label=ssvepdata_stream_label(rand_data_idx);
    ssvepdata_stream = ssvepdata_stream(:,:,rand_data_idx,:,:);
    
    
    %% Calculate the OACCA accuracy (simulated online scenario)    
    
    fb_coef=[1:numOfSubband].^(-1.25)+0.25;
    for tw_no=1:length(tw_length)
        tic
        tw=tw_length(tw_no);
        
        for nsub = 1:length(sub)
            n_correct1=0;
            n_correct2=0;
            n_correct3=0;
            n_correct4=0;n_correct5=0;n_correct6=0;           
            covar_mat=zeros(length(eeg_channels),length(eeg_channels),3,numOfSubband);
            isChange2=zeros(1,3);
            Cxx=zeros(length(eeg_channels),length(eeg_channels),3,numOfSubband);
            isChange=zeros(1,3);
            Cxy=zeros(length(eeg_channels),2*multiplicateTime,3,numOfSubband);
            
            for trial=1:num_of_labels
                sig_len=tw;
                for k=1:numOfSubband
                    test_signal{k}=ssvepdata_stream(:,1:sig_len,trial,nsub,k);
                    test_signal{k}=test_signal{k}-mean(test_signal{k},2)*ones(1,length(test_signal{k}));
                    test_signal{k}=test_signal{k}./(std(test_signal{k}')'*ones(1,length(test_signal{k})));
                    
                    for i = length(frequencySet):-1:1
                        ref=targetTemplateSet{i}(:,1:sig_len);
                        [A1,B1,r]=canoncorr(test_signal{k}',ref');
                        cca_sfx(:,i,k)=[A1(:,1)];
                        cca_sfy(:,i,k)=[B1(:,1)];
                        cca_r=r(1);
                        if (isChange(1)==1) && (isChange(2)==1) && (isChange(3)==1)
                            r0=corrcoef((OWx{k}(:,i)'*test_signal{k})',(OWy{k}(:,i)'*ref)');r2=r0(1,2);
                        else
                            r2=0;
                        end
                        if (isChange2(1)==1) && (isChange2(2)==1) && (isChange2(3)==1)
                            [~,~,r]=canoncorr((prototype_sfx{k}(:,i)'*test_signal{k})',ref');r3=r(1);
                        else
                            r3=0;
                        end
                        
                        rho6(k,i)=r2(1)+r3(1)+cca_r; % OACCA
                        rho5(k,i)=r3(1)+cca_r; % CCA+PSF
                        rho4(k,i)=r2(1)+cca_r; % CCA+OMSCCA
                        rho3(k,i)=r3(1); % PSF
                        rho2(k,i)=r2(1); % OMSCCA
                        rho1(k,i)=cca_r; % CCA
                    end
                end
                
                r1=sum((rho1).*(fb_coef'*ones(1,length(frequencySet))),1);
                [~,result1]=max(r1);
                
                r1=sum((rho6).*(fb_coef'*ones(1,length(frequencySet))),1);
                [~,result6]=max(r1);
                r1=sum((rho5).*(fb_coef'*ones(1,length(frequencySet))),1);
                [~,result5]=max(r1);
                
                result2=result5;
                result3=result1;
                
                %% Update the parameters
                eig_idx{1}=[1:40];
                
                for k=1:numOfSubband
                    if result1==result6
                        sf1x=[cca_sfx(:,result3,k)'];
                        sf1y=[cca_sfy(:,result3,k)'];
                        
                        sf1x=sf1x/norm(sf1x);
                        sf1y=sf1y/norm(sf1y);
                        
                        isChange2(1)=1;
                        covar_mat(:,:,1,k)=covar_mat(:,:,1,k)+[sf1x]'*[sf1x];
                        n_cov=1;
                        
                        isChange2(3)=1;
                        isChange2(2)=1;
                        
                        
                        [V, D] = eig(covar_mat(:,:,n_cov,k));
                        [~, loc] = max(diag(D));
                        u1=V(1:length(eeg_channels), loc);
                        prototype_sfx{k}(:,eig_idx{n_cov}) = repmat(u1,1,length(eig_idx{n_cov}));
                    end
                    
                    
                    filteredData = test_signal{k};
                    sinTemplate = targetTemplateSet{result2}(:,1:sig_len);
                    CCyy=eye(size(sinTemplate,1));
                    
                    isChange(1)=1;
                    Cxx(:,:,1,k)=Cxx(:,:,1,k)+filteredData*filteredData';
                    Cxy(:,:,1,k)=Cxy(:,:,1,k)+filteredData*sinTemplate(:,1:length(filteredData))';
                    n_cov=1;
                    
                    isChange(3)=1;
                    isChange(2)=1;
                    
                    
                    
                    
                    CCyx=(Cxy(:,:,n_cov,k)).';
                    CCxx=Cxx(:,:,n_cov,k);
                    CCxy=Cxy(:,:,n_cov,k);
                    A=[zeros(size(CCxx)) CCxy; CCyx zeros(size(CCyy))];
                    B=[(CCxx) zeros(size(CCxy)); zeros(size(CCyx)) CCyy];
                    [eig_v1,eig_d1]=eig(A,B);
                    [eig_val,sort_idx]=sort(diag(eig_d1),'descend');
                    u1=eig_v1(1:size(CCxx,1),sort_idx(1));
                    v1=eig_v1(1+size(CCxx,1):end,sort_idx(1));
                    if u1(1)==1
                        u1=zeros(length(eeg_channels),1);
                        u1(end-2:end)=1;
                    end
                    OWx{k}(:,eig_idx{n_cov}) = repmat(u1,1,length(eig_idx{n_cov}));
                    OWy{k}(:,eig_idx{n_cov}) = repmat(v1,1,length(eig_idx{n_cov}));
                    
                end
                
                
                
                if result1==ssvepdata_stream_label(trial)
                    n_correct1=n_correct1+1;
                end
                r1=sum((rho2).*(fb_coef'*ones(1,length(frequencySet))),1);
                [~,result1]=max(r1);
                if result1==ssvepdata_stream_label(trial)
                    n_correct2=n_correct2+1;
                end
                r1=sum((rho3).*(fb_coef'*ones(1,length(frequencySet))),1);
                [~,result1]=max(r1);
                if result1==ssvepdata_stream_label(trial)
                    n_correct3=n_correct3+1;
                end
                r1=sum((rho4).*(fb_coef'*ones(1,length(frequencySet))),1);
                [~,result1]=max(r1);
                if result1==ssvepdata_stream_label(trial)
                    n_correct4=n_correct4+1;
                end
                r1=sum((rho5).*(fb_coef'*ones(1,length(frequencySet))),1);
                [~,result1]=max(r1);
                if result1==ssvepdata_stream_label(trial)
                    n_correct5=n_correct5+1;
                end
                r1=sum((rho6).*(fb_coef'*ones(1,length(frequencySet))),1);
                [~,result1]=max(r1);
                if result1==ssvepdata_stream_label(trial)
                    n_correct6=n_correct6+1;
                end
                
                if trial>=1
                    save_data(cv).cca_iacc_online1(trial,nsub,tw_no)=n_correct1/trial;
                    save_data(cv).cca_iacc_online2(trial,nsub,tw_no)=n_correct2/trial;
                    save_data(cv).cca_iacc_online3(trial,nsub,tw_no)=n_correct3/trial;
                    save_data(cv).cca_iacc_online4(trial,nsub,tw_no)=n_correct4/trial;
                    save_data(cv).cca_iacc_online5(trial,nsub,tw_no)=n_correct5/trial;
                    save_data(cv).cca_iacc_online6(trial,nsub,tw_no)=n_correct6/trial;
                    
                    save_data(cv).cca_iitr_online1(trial,nsub,tw_no)=itr_bci(n_correct1/trial,length(frequencySet),(tw_length(tw_no)/srate+0.5));
                    save_data(cv).cca_iitr_online2(trial,nsub,tw_no)=itr_bci(n_correct2/trial,length(frequencySet),(tw_length(tw_no)/srate+0.5));
                    save_data(cv).cca_iitr_online3(trial,nsub,tw_no)=itr_bci(n_correct3/trial,length(frequencySet),(tw_length(tw_no)/srate+0.5));
                    save_data(cv).cca_iitr_online4(trial,nsub,tw_no)=itr_bci(n_correct4/trial,length(frequencySet),(tw_length(tw_no)/srate+0.5));
                    save_data(cv).cca_iitr_online5(trial,nsub,tw_no)=itr_bci(n_correct5/trial,length(frequencySet),(tw_length(tw_no)/srate+0.5));
                    save_data(cv).cca_iitr_online6(trial,nsub,tw_no)=itr_bci(n_correct6/trial,length(frequencySet),(tw_length(tw_no)/srate+0.5));
                    
                end
            end
            cca_acc_online1(nsub,tw_no)=n_correct1/num_of_labels;
            cca_acc_online2(nsub,tw_no)=n_correct2/num_of_labels;
            cca_acc_online3(nsub,tw_no)=n_correct3/num_of_labels;
            cca_acc_online4(nsub,tw_no)=n_correct4/num_of_labels;
            cca_acc_online5(nsub,tw_no)=n_correct5/num_of_labels;
            cca_acc_online6(nsub,tw_no)=n_correct6/num_of_labels;            
            clear ssvepdata_stream_mylabel_level ssvepdata_stream_mylabel
        end
        cca_itr_online1(:,tw_no)=itr_bci(cca_acc_online1(:,tw_no)',length(frequencySet),(tw_length(tw_no)/srate+0.5)*ones(1,length(sub)));
        cca_itr_online2(:,tw_no)=itr_bci(cca_acc_online2(:,tw_no)',length(frequencySet),(tw_length(tw_no)/srate+0.5)*ones(1,length(sub)));
        cca_itr_online3(:,tw_no)=itr_bci(cca_acc_online3(:,tw_no)',length(frequencySet),(tw_length(tw_no)/srate+0.5)*ones(1,length(sub)));
        cca_itr_online4(:,tw_no)=itr_bci(cca_acc_online4(:,tw_no)',length(frequencySet),(tw_length(tw_no)/srate+0.5)*ones(1,length(sub)));
        cca_itr_online5(:,tw_no)=itr_bci(cca_acc_online5(:,tw_no)',length(frequencySet),(tw_length(tw_no)/srate+0.5)*ones(1,length(sub)));
        cca_itr_online6(:,tw_no)=itr_bci(cca_acc_online6(:,tw_no)',length(frequencySet),(tw_length(tw_no)/srate+0.5)*ones(1,length(sub)));
        
        toc
        disp(tw_length(tw_no))        
        mean([cca_itr_online1(:,tw_no) cca_itr_online2(:,tw_no) ...
            cca_itr_online3(:,tw_no) cca_itr_online4(:,tw_no) ...
            cca_itr_online5(:,tw_no) cca_itr_online6(:,tw_no)],1)        
    end
    disp(cv)
    save(str_save,'save_data','filename','tw_length');
end


