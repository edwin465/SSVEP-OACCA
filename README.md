# SSVEP-OACCA
The source code of the OACCA introduced in our IEEE TBME paper (10.1109/TBME.2021.3133594) is shared here. After comparing the CCA and OACCA performance, it can be found that the OACCA performs better than the CCA.

## Version 
v1.0: (6 Jan 2022)  
Test OACCA in two SSVEP datasets  
Compare CCA and OACCA under different time-window lengths  

v1.1: (31 May 2022)  
Add the file `itr_bci.m` 

v1.2: (19 Jun 2025)  
Add the introduction part

## Feedback
If you find any mistakes, please let me know via chiman465@gmail.com.

# Two SSVEP datasets  
In this study, we used two public SSVEP datasets (Dataset I and II) as provided by Tsinghua BCI group (http://bci.med.tsinghua.edu.cn/).

Dataset I:    
The details can be found in the following article:
Wang, Y., et al. (2016). A benchmark dataset for SSVEP-based brain–computer interfaces. IEEE Transactions on Neural Systems and Rehabilitation Engineering, 25(10), 1746-1752.

Dataset II:  
The details can be found in the following article:
Liu, B., et al. (2020). BETA: A large benchmark database toward SSVEP-BCI application. Frontiers in neuroscience, 14, 627.

The following table lists the important information of these two datasets, including the subject number (N_{sub}), the target number (N_f), the block number (N_{block}), and the layout.
![Table1](https://github.com/edwin465/SSVEP-OACCA/blob/main/DatasetI_II.png)

# Introduction
## OACCA  
First, the OACCA aims to learn a subject-specified spatial filters from the subject’s multi-trial unlabeled data during online stage, which is substantially different from the traditional CCA method using a single-trial unlabeled data (or the current trial's data). The OACCA can compute the spatial filters that can adapt to a specified subject because it updates the parameters of the spatial filtering algorithm trial by trial. 

Here the following block diagrams are used to illustrate the difference between the traditional CCA method and the OACCA method for frequency detection in SSVEP-based BCIs. 

In the traditional CCA, each trial's frequency detection is only relied on **the current trial's data (or the single-trial data)**. It does not take the knowledge from previous trials into consideration.  

![cca](https://github.com/edwin465/SSVEP-OACCA/blob/main/cca_fig.png)
  
But, in the OACCA, each trial's frequency detection is relied on not only the current trial's data, but also the knowledge from previous trials. The OACCA could compute the adaptive spatial filters by considering the historical information, such as **the multi-trial data ($X^{[1]}$, $X^{[2]}$, ..., $X^{[t]}$), the labels of the multi-trial data (${k}^{[1]}$, ${k}^{[2]}$, ..., ${k}^{[t]}$), and the spatial filters of the multi-trial data ($u^{[1]}$, $u^{[2]}$, ..., $u^{[t]}$)**. In the OACCA, the outputs of the traditional CCA are used to compute the adaptive filters. For example, the CCA detection results are considered as the pseudo-labels of the data, which might determine which stimulus frequencies the data/spatial filters correspond to. i.e., the pseudo-labels of the data/spatial filters. Moreover, the unlabeled data could be transformed into the labeled data for supervised learning, e.g., the multi-stimulus CCA, during online stage. In summary, the OACCA is an enhanced version of the traditional CCA.

![oacca](https://github.com/edwin465/SSVEP-OACCA/blob/main/oacca_fig.png) 

### The baseline method (CCA)

```math
{r_{j}}^{[t]}=\max_{u_j^{[t]},v_j^{[t]}}{\frac{{u_j^{[t]}}^\top{X^{[t]}}^\top{Y_j}{v_j^{[t]}}}{\sqrt{{u_j^{[t]}}^\top {X^{[t]}}^\top{X^{[t]}}{u_j^{[t]}}\cdot{v_j^{[t]}}^\top{Y_j}^\top{Y_j}{v_j^{[t]}}}}}=\mathrm{CCA}({X^{[t]}},{Y_j}),
```
  
where $Y_j$ is the pre-defined sine-cosine reference signal of the $j$-th stimulus frequency, $j=1,2,\cdots,N_f$, $N_f$ is the total number of stimulus frequencies, $X^{[t]}$ is the $t$-th trial's multi-channel EEG data, $u_j^{[t]}$ and $v_j^{[t]}$ are a pair of CCA spatial filters (CCA-SFs).  

### Learning adaptive spatial filters

In the OACCA, there are two types of adaptive spatial filters: **prototype spatial filter** and **multi-stimulus CCA spatial filter**.  

- Prototype Spatial Filter  
The OACCA computes a **prototype spatial filter (PSF)** from a series of CCA-SFs corresponding to the previous trials (($u_{{k_1}^{[t]}}^{[1]}$, $u_{{k_1}^{[t]}}^{[2]}$, ..., $u_{{k_1}^{[t]}}^{[t]}$)), such that the PSF has maximal similarity to them:

```math
w^{[t+1]}=\max_{w^{[t+1]}}{\frac{{w^{[t+1]}}^\top {(\sum_{i=1}^{t}{u_{{k_1}^{[t]}}^{[i]}\cdot {u_{{k_1}^{[t]}}^{[i]}}^\top}) w^{[t+1]}}}{{w^{[t+1]}}^\top w^{[t+1]}}}=\max_{w^{[t+1]}}{\frac{{w^{[t+1]}}^\top \cdot {S^{[t]} \cdot w^{[t+1]}}}{{w^{[t+1]}}^\top w^{[t+1]}}}
```

where ${k_1}^{[t]}$ is the label of the $t$-th trial's data and $w^{[t+1]}$ is the PSF for the ($t+1$)-th trial. Let $S^{[t]} = \sum_{i=1}^{t}{u_{{k_1}^{[t]}}^{[i]}\cdot {u_{{k_1}^{[t]}}^{[i]}}^\top}$. Apparently, $S^{[t]}$ can be accumulated trial by trial. However, in empricially, **$S^{[t]}$ might be only updated when $k_1^{[t]} = k_3^{[t]}$ ($k_1$ is the CCA detection result and $k_3$ is the final detection result, see "template matching")**.

- Multi-Stimulus CCA Spatial Filter  
The OACCA computes a pair of **multi-stimulus CCA spatial filter** based on the multi-trial data ($X^{[1]}$, $X^{[2]}$, ..., $X^{[t]}$) and the corresponding sine-cosine reference signals (${Y_{{k_2}^{[1]}}}$, ${Y_{{k_2}^{[2]}}}$, ..., ${Y_{{k_2}^{[t]}}}$), such that they have the maximal canonical correlation coefficient: 

```math
\begin{align}
w_x^{[t+1]},w_y^{[t+1]}&=\max_{w_x^{[t+1]},w_y^{[t+1]}}{\frac{{w_x^{[t]}}^\top(\sum_{i=1}^{t}{{X^{[i]}}^\top {Y_{{k_2}^{[i]}}}}){w_y^{[t]}}}{\sqrt{{w_x^{[t]}}^\top (\sum_{i=1}^{t}{{X^{[i]}}^\top{X^{[i]}}}) {w_x^{[t]}}\cdot {w_y^{[t]}}^\top (\sum_{i=1}^{t}{{{Y_{{k_2}^{[i]}}}}^\top{{Y_{{k_2}^{[i]}}}}}) {w_y^{[t]}}}}} \\
&=\mathrm{CCA}([{X^{[1]}}^\top,{X^{[2]}}^\top,\cdots,{X^{[t]}}^\top]^\top,[{{Y_{{k_2}^{[1]}}}}^\top,{{Y_{{k_2}^{[2]}}}}^\top,\cdots,{{Y_{{k_2}^{[t]}}}}^\top]^\top),
\end{align}
```

where  ${k_2}^{[t]}$ is the label of the $t$-th trial's data, $w_x^{[t+1]}$ and $w_y^{[t+1]}$ are the multi-stimulus CCA spatial filters. Apparently, $\sum_{i=1}^{t}{{X^{[i]}}^\top {Y_{{k_2}^{[i]}}}}$, $\sum_{i=1}^{t}{{X^{[i]}}^\top{X^{[i]}}}$, and $\sum_{i=1}^{t}{{{Y_{{k_2}^{[i]}}}}^\top{{Y_{{k_2}^{[i]}}}}}$, are accumulated iteratively during online stage, thereby $w_x^{[t+1]}$ and $w_y^{[t+1]}$ can be kept updated trial by trial. Note that ${k_2}^{[t]}$ is the CCA + PSF detection result. 

### Template-matching
Based on three types of spatial filters, we can compute three groups of template-matching results ($r_{j,1}$, $r_{j,2}$, and $r_{j,3}$):

```math
\begin{align}
&{r_{j,1}}^{[t]}=\mathrm{corr}({u_j^{[t]}}^\top {X^{[t]}}^\top,{v_j^{[t]}}^\top {Y_j^{[t]}}^\top),\\
&{r_{j,2}}^{[t]}=\mathrm{CCA}({w^{[t]}}^\top {X^{[t]}}^\top,{Y_j^{[t]}}^\top),\\
&{r_{j,3}}^{[t]}=\mathrm{corr}({w_x^{[t]}}^\top {X^{[t]}}^\top,{w_y^{[t]}}^\top {Y_j^{[t]}}^\top).
\end{align}
```

Therefore, there are three types of detection results ($k_{1}$, $k_2$, and $k_{3}$):
```math
\begin{align}
&{{k}_1}^{[t]}=\max_{j}{\{{r_{j,1}}^{[t]}\}}, \qquad \mathrm{(CCA \quad detection \quad result)}\\
&{{k}_2}^{[t]}=\max_{j}{\{{r_{j,1}}^{[t]}+{r_{j,2}}^{[t]}\}}, \qquad \mathrm{(CCA + PSF \quad detection \quad result)}\\
&{{k}_3}^{[t]}=\max_{j}{\{{r_{j,1}}^{[t]}+{r_{j,2}}^{[t]}+{r_{j,3}}^{[t]}\}}, \qquad \mathrm{(CCA + PSF + MSCCA \quad detection \quad result)}\\ 
\end{align}
```

where CCA + PSF + MSCCA detection result is the final detection result.


# Preliminary results
1) Dataset I  
At first, we run the code `OACCA_acc_tsinghua_2021.m` to calculate the recognition accuracy using different methods (i.e., CCA, OMSCCA, PSF, CCA+OMSCCA, CCA+PSF, OACCA (or CCA+OMSCCA+PSF)), different trial orders (10 random orders) and different data lengths (10 different lengths: 0.6, 0.7, 0.8, ..., 1.5 s). All of the methods are under the same preprocessing procedure (e.g., the same bandpass filtering, the same filter-bank analysis, etc). Finally, all the calculated results will be stored in the OACCA_accuracy_tsinghua_2021.mat.  
Second, we run the code `plot_oacca_acc_itr_2021.m` to plot the comparison results based on 'OACCA_accuracy_tsinghua_2021.mat'.    
The following figure shows the accuracy comparsion between CCA, OMSCCA, PSF, CCA+OMSCCA, CCA+PSF, OACCA (or CCA+OMSCCA+PSF). Note that x-axis indicates the data length (or time-window length) and y-axis indicates the average accuracy across different subjects and trial orders. The OACCA performs much better than the CCA.
![result1](https://github.com/edwin465/SSVEP-OACCA/blob/main/plot_oacca_acc_ds1.png)


The following figure shows the ITR comparsion between CCA, OMSCCA, PSF, CCA+OMSCCA, CCA+PSF, OACCA (or CCA+OMSCCA+PSF). Note that x-axis indicates the data length (or time-window length) and y-axis indicates the average ITR across different subjects and trial orders. The OACCA performs much better than the CCA.
![result2](https://github.com/edwin465/SSVEP-OACCA/blob/main/plot_oacca_itr_ds1.png)

It should be noticed that only the CCA performance can be kept constant every time (i.e., we can repeat the same results as shown in the IEEE TBME paper). For the others (OMSCCA, PSF, CCA+OMSCCA, CCA+PSF and OACCA), their performance may have very little difference because of different trial orders. 

2) Dataset II  
Similarly, we follow the procedure as introduced in Dataset II in this study. At first, we run the code `OACCA_acc_beta_2021.m` and all the calculated results will be stored in the OACCA_accuracy_beta_2021.mat. Second, we run the code `plot_oacca_acc_itr_2021.m` to plot the comparison results based on 'OACCA_accuracy_beta_2021.mat'.  
The following figure shows the accuracy comparsion between CCA, OMSCCA, PSF, CCA+OMSCCA, CCA+PSF, OACCA (or CCA+OMSCCA+PSF). Note that x-axis indicates the data length (or time-window length) and y-axis indicates the average accuracy across different subjects and trial orders. The OACCA performs much better than the CCA. 

![result3](https://github.com/edwin465/SSVEP-OACCA/blob/main/plot_oacca_acc_ds2.png)

![result4](https://github.com/edwin465/SSVEP-OACCA/blob/main/plot_oacca_itr_ds2.png)

It should be noticed that only the CCA performance can be kept constant every time (i.e., we can repeat the same results as shown in the IEEE TBME paper). For the others (OMSCCA, PSF, CCA+OMSCCA, CCA+PSF and OACCA), their performance may have very little difference because of different trial orders. 

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
