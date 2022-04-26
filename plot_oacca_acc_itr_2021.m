clear all
close all
addpath('..\mytoolbox');

mypv=fun_subplot_position(2,5,0.05,0.1,0,0.07,0.125); % fun_subplot_position.m (https://github.com/edwin465/matlab-mytoolbox-plot)
mypv2=fun_subplot_position(2,2,0.05,0.1,0,0.07,0.125); % fun_subplot_position.m (https://github.com/edwin465/matlab-mytoolbox-plot)
dataset_no=2;
if dataset_no==1
    load('OACCA_accuracy_tsinghua_2021.mat');num_of_subj=35;ntrial = 240;
elseif dataset_no==2
    load('OACCA_accuracy_beta_2021.mat');num_of_subj=70;ntrial = 160;
else
end

cv_num=size(save_data,2);
font_size=30;
for cv=1:cv_num
    for tw_no=1:length(tw_length)        
        mu_acc(tw_no,cv,1)=mean(save_data(cv).cca_iacc_online1(end,:,tw_no),2);
        mu_acc(tw_no,cv,2)=mean(save_data(cv).cca_iacc_online2(end,:,tw_no),2);
        mu_acc(tw_no,cv,3)=mean(save_data(cv).cca_iacc_online3(end,:,tw_no),2);
        mu_acc(tw_no,cv,4)=mean(save_data(cv).cca_iacc_online4(end,:,tw_no),2);
        mu_acc(tw_no,cv,5)=mean(save_data(cv).cca_iacc_online5(end,:,tw_no),2);
        mu_acc(tw_no,cv,6)=mean(save_data(cv).cca_iacc_online6(end,:,tw_no),2);

        
        mu_itr(tw_no,cv,1)=mean(save_data(cv).cca_iitr_online1(end,:,tw_no),2);
        mu_itr(tw_no,cv,2)=mean(save_data(cv).cca_iitr_online2(end,:,tw_no),2);
        mu_itr(tw_no,cv,3)=mean(save_data(cv).cca_iitr_online3(end,:,tw_no),2);
        mu_itr(tw_no,cv,4)=mean(save_data(cv).cca_iitr_online4(end,:,tw_no),2);
        mu_itr(tw_no,cv,5)=mean(save_data(cv).cca_iitr_online5(end,:,tw_no),2);
        mu_itr(tw_no,cv,6)=mean(save_data(cv).cca_iitr_online6(end,:,tw_no),2);        
    end
end
color_rgb=[0 0 0;
    1 0 0;
    0 0 1;
    0 204/255 0;
    153/255 153/255 0;
    1 0 1;
    1 128/255 0;
    0 128/255 1;
    0.9 0 0;
    1 102/255 1;
    0 1 0];
legend_str={'CCA','OMSCCA','PSF','CCA+OMSCCA','CCA+PSF','OACCA'};
method_id=[1 2 3 4 5 6]; % OMSCCA-1, OMSCCA-2, OMSCCA-3, OCCA, CCA
figure(1);
b=bar(squeeze(mean(mu_acc,2)));
legend(legend_str(method_id),'location','southeast');
for n=1:length(method_id)
    b(n).FaceColor=color_rgb(method_id(n),:);
    b(n).EdgeColor=color_rgb(method_id(n),:);
end
ylim([0 1.1]);xlim([0.5 10.5]);
set(gca,'xtick',[1:length(tw_length)]);
set(gca,'xticklabel',{'0.6';'0.7';'0.8';'0.9';'1.0';'1.1';'1.2';'1.3';'1.4';'1.5'});
set(gca,'ytick',[0.2:0.2:1]);
set(gca,'yticklabel',{'20';'40';'60';'80';'100'});
ylabel('Accuracy (%)');
if dataset_no==1
    title('Dataset I');
elseif dataset_no==2
    title('Dataset II');
else
end
set(gca,'fontsize',font_size);
ax = gca;
ax.XRuler.Axle.LineWidth = 2;
ax.YRuler.Axle.LineWidth = 2;

figure(2);
b=bar(squeeze(mean(mu_itr,2)));
legend(legend_str(method_id),'location','southeast');
for n=1:length(method_id)
    b(n).FaceColor=color_rgb(method_id(n),:);
    b(n).EdgeColor=color_rgb(method_id(n),:);
end
ylim([0 190]);xlim([0.5 10.5]);
set(gca,'xtick',[1:length(tw_length)]);
set(gca,'xticklabel',{'0.6';'0.7';'0.8';'0.9';'1.0';'1.1';'1.2';'1.3';'1.4';'1.5'});
set(gca,'ytick',[30:30:180]);
set(gca,'yticklabel',{'30';'60';'90';'120';'150';'180'});
ylabel('ITR (bits/min)');
if dataset_no==1
    title('Dataset I');
elseif dataset_no==2
    title('Dataset II');
else
end
set(gca,'fontsize',font_size);
ax = gca;
ax.XRuler.Axle.LineWidth = 2;
ax.YRuler.Axle.LineWidth = 2;
