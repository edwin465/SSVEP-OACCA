# SSVEP-OACCA
The source code of the OACCA introduced in our IEEE TBME paper (10.1109/TBME.2021.3133594)

# Two SSVEP datasets  
In this study, we used two public SSVEP datasets (Dataset I and II) as provided by Tsinghua BCI group (http://bci.med.tsinghua.edu.cn/).

Dataset I:  
The details can be found in the following article:
Wang, Y., et al. (2016). A benchmark dataset for SSVEP-based brain–computer interfaces. IEEE Transactions on Neural Systems and Rehabilitation Engineering, 25(10), 1746-1752.

Dataset II:
The details can be found in the following article:
Liu, B., et al. (2020). BETA: A large benchmark database toward SSVEP-BCI application. Frontiers in neuroscience, 14, 627.

The following table lists the important information of these two datasets
![Table1](https://github.com/edwin465/SSVEP-OACCA/blob/main/plot_oacca_acc_ds1.png)

# Preliminary results
1) Dataset I  
At first, we run the code 'OACCA_acc_tsinghua_2021.m' to calculate the recognition accuracy using different methods (i.e., CCA, OMSCCA, PSF, CCA+OMSCCA, CCA+PSF, OACCA (or CCA+OMSCCA+PSF)), different trial orders (10 random orders) and different data lengths (10 different lengths: 0.6, 0.7, 0.8, ..., 1.5 s). All of the methods are under the same preprocessing procedure (e.g., the same bandpass filtering, the same filter-bank analysis, etc). Finally, all the calculated results will be stored in the OACCA_accuracy_tsinghua_2021.mat.  
Second, we run the code 'plot_oacca_acc_itr_2021.m' to plot the comparison results based on 'OACCA_accuracy_tsinghua_2021.mat'.    
The following figure shows the accuracy comparsion between CCA, OMSCCA, PSF, CCA+OMSCCA, CCA+PSF, OACCA (or CCA+OMSCCA+PSF). Note that x-axis indicates the data length (or time-window length) and y-axis indicates the average accuracy across different subjects and trial orders. The OACCA performs much better than the CCA.
![result1](https://github.com/edwin465/SSVEP-OACCA/blob/main/plot_oacca_acc_ds1.png)


The following figure shows the ITR comparsion between CCA, OMSCCA, PSF, CCA+OMSCCA, CCA+PSF, OACCA (or CCA+OMSCCA+PSF). Note that x-axis indicates the data length (or time-window length) and y-axis indicates the average ITR across different subjects and trial orders. The OACCA performs much better than the CCA.
![result2](https://github.com/edwin465/SSVEP-OACCA/blob/main/plot_oacca_itr_ds1.png)

It should be noticed that only the CCA performance can be kept constant every time (i.e., we can repeat the same results as shown in the IEEE TBME paper). For the others (OMSCCA, PSF, CCA+OMSCCA, CCA+PSF and OACCA), their performance may have a bit difference because of different trial orders. 

2) Dataset II  
Similarly, we follow the procedure as introduced in Dataset II in this study. At first, we run the code 'OACCA_acc_beta_2021.m' and all the calculated results will be stored in the OACCA_accuracy_beta_2021.mat. Second, we run the code 'plot_oacca_acc_itr_2021.m' to plot the comparison results based on 'OACCA_accuracy_beta_2021.mat'.  
The following figure shows the accuracy comparsion between CCA, OMSCCA, PSF, CCA+OMSCCA, CCA+PSF, OACCA (or CCA+OMSCCA+PSF). Note that x-axis indicates the data length (or time-window length) and y-axis indicates the average accuracy across different subjects and trial orders. The OACCA performs much better than the CCA. 

![result3](https://github.com/edwin465/SSVEP-OACCA/blob/main/plot_oacca_acc_ds2.png)

![result4](https://github.com/edwin465/SSVEP-OACCA/blob/main/plot_oacca_itr_ds2.png)

It should be noticed that only the CCA performance can be kept constant every time (i.e., we can repeat the same results as shown in the IEEE TBME paper). For the others (OMSCCA, PSF, CCA+OMSCCA, CCA+PSF and OACCA), their performance may have a bit difference because of different trial orders. 

# Citation  
If you use this code for a publication, please cite the following papers

@article{wong2020learning,  
title={Learning across multi-stimulus enhances target recognition methods in SSVEP-based BCIs},  
author={Wong, Chi Man and Wan, Feng and Wang, Boyu and Wang, Ze and Nan, Wenya and Lao, Ka Fai and Mak, Peng Un and Vai, Mang I and Rosa, Agostinho},  
journal={Journal of Neural Engineering},  
volume={17},  
number={1},  
pages={016026},  
year={2020},  
publisher={IOP Publishing}  
}  

@article{wong2020spatial,  
title={Spatial filtering in SSVEP-based BCIs: unified framework and new improvements},  
author={Wong, Chi Man and Wang, Boyu and Wang, Ze and Lao, Ka Fai and Rosa, Agostinho and Wan, Feng},  
journal={IEEE Transactions on Biomedical Engineering},  
volume={67},  
number={11},  
pages={3057--3072},  
year={2020},  
publisher={IEEE}  
}  

@article{wong2021online,  
  title={Online Adaptation Boosts SSVEP-Based BCI Performance},  
  author={Wong, Chi Man and Wang, Ze and Nakanishi, Masaki and Wang, Boyu and Rosa, Agostinho and Chen, Philip and Jung, Tzyy-Ping and Wan, Feng},  
  journal={IEEE Transactions on Biomedical Engineering},  
  year={2021 (Early Access)},   
  publisher={IEEE}  
}
