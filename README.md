# SSVEP-OACCA
The source code of the OACCA introduced in our IEEE TBME paper (10.1109/TBME.2021.3133594)

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
