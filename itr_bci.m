function itr=itr_bci(p,Nf,T)

len=length(p);
itr=zeros(1,len);

for k=1:len
    acc=p(k);
    Tw=T(k);
    if (acc==1)
        itr(k)=(log2(Nf)+acc*log2(acc))*60/(Tw);
    elseif (acc<1/Nf)
        itr(k)=0;
    else
        itr(k)=(log2(Nf)+acc*log2(acc)+(1-acc)*log2((1-acc)/(Nf-1)))*60/(Tw);
    end
end