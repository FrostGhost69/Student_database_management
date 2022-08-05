clc;
clear;
close all;

%opening simulink model of bldc motor for speed control

open('bldcmotor.slx');

global kp ki kd
N=3; %No of variables
      
kmin=[0 0 0];
kmax=[10 500 1];

%GA parameters initialization 

popsize=10; %15 individuals having diff combinations of k
MaxIt=2; %No of iterations
nb=[20 23 20]; %Bits allocated for kp,ki,kd
Nt=sum(nb);

%Declaring all rates
parent_selection_rate=0.3;
totalparent=ceil(popsize*parent_selection_rate);
rejection_rate=0.1;
total_rejected=ceil(popsize*parent_selection_rate);
average=popsize-totalparent-total_rejected;
mutation_rate = 0.1;
%Rate declaration ends

total_mutations = floor(mutation_rate*Nt*popsize); %Will be changed later

initialpop = round(rand(popsize,Nt));% A random matrix of size 15*63 in this case ehich consists of 15 rows/individuals each consisiting of Ki,Kp,Kd 
a=0;
b=0;

for i=1:N
    a=b+1;
    b=b+nb(i);
    %DV=bide(initialpop(:,(a:b)));
    DV=bi2de(initialpop(:,(a:b)));
    
    k(:,i)= kmin(i) + ((kmax(i)-kmin(i))*DV)/(2^nb(i)-1);
    
    
    
end


for i=1:popsize
   fit(i) = control_bldc(k(i,:));
   fitness(i) = 1./(1+fit(i));
   fprintf("Iteration %d ",i);
end
 

for ii=1:MaxIt
    initialpop2=[];  %This matrix is for storing elements according to descending order
    
    for jj=1:popsize
     maxx=max(fitness);
     [x,y]=find(maxx==fitness);
     %fitness;
     initialpop2(jj,:)=initialpop(y,:);
     fitness(:,y)=[];
    end
    
    %Storing average population in rempop
    rempop=[];
    
    for i=1:average
       rempop(i,:)=initialpop2(i+totalparent,:);
    end
    
    %Storing parents in parent matrix
    parent=[]
    for i=1:totalparent
        parent(i,:)=initialpop2(i,:);
    end
    
    %Crossover
    
     offspring = []; %offspring matrix
    
    if size(parent,1)>1
        for i=(size(parent,1)-1)
            r=randi(Nt);
            offspring(i,:) = [parent(i,1:r) parent(i+1,r+1:Nt)];
        end
        
        %Crossover between last and first parent
        
        r=randi(Nt);
        offspring(i+1,:) = [parent(i+1,1:r) parent(i,r+1:Nt)];
        
        
      
    end
   
    %storing top parents in parent2
    parent2=[];
    for i=1:total_rejected
        parent2(i,:)=parent(i,:);
    end
    
    newpop=[parent2;offspring;rempop];
    
    %mutation
    
    totgen = popsize*Nt;
    for i = 1:total_mutations
        r=randi(totgen);
        
        row= ceil(r/Nt);
        
        if rem(r,Nt)==0
            col=Nt;
        else
            col=rem(r,Nt);
        end
        
        %mutating the binary values
        
        
        if newpop(row,col)==1
            newpop(row,col)=0;
        else
            newpop(row,col)=1;
        end
    end
    
    a=0;
b=0;

for i=1:N
    a=b+1;
    b=b+nb(i);
    
    DV=bi2de(newpop(:,(a:b)));
    
    k(:,i)=kmin(i) + (((kmax(i)-kmin(i))*DV)/(2^nb(i)-1));
    
    
end
    
    
for i=1:popsize
   fit(i) = control_bldc(k(i,:));
   fitness(i) = 1./(1+fit(i));
   fprintf("Iteration %d of set %d ",i,ii);
end

initialpop=newpop;

end

%Finding best chromosme

[maxx,ind]=max(fitness);

fprintf("\nThe value of K are");
kp=k(ind,1)
ki=k(ind,2)
kd=k(ind,3)


sim('bldcmotor.slx')
    



    
    
    
    
    
