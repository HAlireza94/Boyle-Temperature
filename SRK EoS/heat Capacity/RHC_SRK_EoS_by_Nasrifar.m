clc
clear 
close all



format long

N=input('Enter Group, name=','s');
name=lower(N);
switch name
    case 'alkanols'
        data1=load('Alkanols');
        data2=load('Coefficient_Cp_Alkanol');
    case 'thiophenes'
        data1=load('Thiophenes');
    case 'pyridines'
        data1=load('Pyridines');
    case 'alkanes'
        data1=load('Alkanes');
        data2=load('Coefficient_Cp');
        case 'polar gases'
        data1=load('Polar gases');
    case 'alkenes'
        data1=load('Alkenes');
        data2=load('Coefficient_Cp_Alkenes');

         case 'vd'
        data1=load('Validate_data');
        
        data2=load('Coefficient_Cp_Validate');
        
    case 'cycloalkanes'
        data1=load('Cycloalkanes');
    case 'amines'
        data1=load('Amines');
    case 'glycol ethers'
        data1=load('Glycol ethers');
    case 'water'
        data1=load('Water');
    case 'aromatics'
        data1=load('Aromatics');
    case 'gases'
        data1=load('Gases');
    case 'ethers'
        data1=load('Ethers');
    case 'ketones'
        data1=load('Ketones');
        case 'halogens'
        data1=load('Halogenes');
        case 'noble gases'
        data1=load('Noble gases');
        
    case 'fatty acid esters'
        
        data1=load('Fatty acid esters');
       
end


Tc=data1.Tc;
pc=data1.Pc;
w=data1.w;
Zc=data1.Zc;

M=data1.Mw;

Pc=pc.*10^5;

n1=numel(Tc);

P=1e-2;R=8.3144598;

A=data2.A;
B=data2.B;
C=data2.C;
D=data2.D;
E=data2.E;


for i=1:n1
    
  a(i)=(((0.42747*(R^2)*(Tc(i)^2)))/Pc(i));
  b(i)=(0.08664*R*Tc(i))/Pc(i);

  k(i)=0.480+(1.574*w(i))-(0.175*w(i)^2);
  b1(i)=0.25*(12-(11*k(i))+(k(i)^2));
  b2(i)=0.5*(-6+(9*k(i))-(k(i)^2));
  b3(i)=0.25*(4-(7*k(i))+(k(i)^2));

end

Pr=P/Pc;



T=[939.09
907.55
957.30
1017.13
1072.74
1111.43
1156.95
1184.59
1208.00
1225.89
1223.94];


 n=numel(T);

 
 x0=zeros(n,1);
for i=1:n
    
    
    x0(i)=(R*T(i))/P;
    
    
end


OF=zeros(n,1);
for i=1:n
    
     f=@(x) (((R*T(i))/(x-b(i)))-(((a(i)*(((b1(i)/(T(i)/Tc(i)))+...
         (b2(i)/((T(i)/Tc(i)))^2)+(b3(i)/((T(i)/Tc(i)))^3))))/(x*(x+b(i)))))-P);
     
     OF(i)=fzero(f,x0(i)); % OF : Volume
%           OF(i)=fsolve(f,x0(i));
% OF(i)=fminsearch(f,x0(i))

end

J_T=zeros(n,1);
Tr=zeros(n,1);
Cv=zeros(n,1);
Cp=zeros(n,1);
Gamma=zeros(n,1);
X=zeros(n,1);
RSS=zeros(n,1);
sound_speed=zeros(n,1);

for i=1:n
    
    Cp_star(i)=A(i)+(B(i)*T(i))+(C(i)*(T(i)^2))+(D(i)*(T(i)^3))+(E(i)*(T(i)^4));
    
    Cv_star(i)=Cp_star(i)-R;
    
    
    Tr(i)=T(i)/Tc(i);
    
    Z(i)=(P*OF(i))/(R*T(i));
    
    alpha(i)=(((b1(i)/(T(i)/Tc(i)))+(b2(i)/...
        ((T(i)/Tc(i)))^2)+(b3(i)/((T(i)/Tc(i)))^3)));
    
    first_order_alpha(i)=-((Tc(i)*b1(i))/(T(i)^2))-...
        ((2*(Tc(i)^2)*b2(i))/(T(i)^3))-...
        ((3*(Tc(i)^3)*b3(i))/(T(i)^4));
     

    second_order_alpha(i)=((2*Tc(i)*b1(i))/(T(i)^3))+...
        ((6*(Tc(i)^2)*b2(i))/(T(i)^4))+...
        ((12*(Tc(i)^3)*b3(i))/(T(i)^5));
     
     a_first_order_alpha(i)=a(i)*first_order_alpha(i);

     a_second_order_alpha(i)=a(i)*second_order_alpha(i);

     Cv(i)=Cv_star(i)+(T(i)*...
     ((a_second_order_alpha(i))/(b(i)))*...
     (log((b(i)/OF(i))+1)));
    
     first_order_P_T(i)=(R/(OF(i)-b(i)))-...
         ((a_first_order_alpha(i))/(OF(i)*(OF(i)+b(i))));
    
     first_order_P_V(i)=((-R*T(i))/((OF(i)-b(i))^2))+...
         (a(i)*alpha(i)*((2*OF(i))+b(i)))/((OF(i)^2)*((OF(i)+b(i))^2));
    
    Cp(i)=Cv(i)-((T(i)*(first_order_P_T(i)^2))/(first_order_P_V(i)));
    
    X(i)=Cp(i)*Cv(i);
    
    Gamma(i)=Cp(i)/Cv(i);
    
    SS(i)=sqrt((-OF(i)^2)*(Gamma(i)/M(i))*first_order_P_V(i)); 
    
    sound_speed(i)=SS(i)*sqrt(1000); %$#@
    
    Kappa(i)=((-(1/OF(i)))*(first_order_P_V(i)^(-1)));
    
    
    J_T(i)=((T(i)*((-first_order_P_T(i))/first_order_P_V(i)))-OF(i))/Cp(i);
    
    
end
    
    

figure (1)

plot(T,Cp)
xlabel('Temperature (K)');ylabel('heat capacity at constant pressure(Cp)')

figure (2)

plot(T,Cv)
xlabel('Temperature (K)');ylabel('heat capacity at constant volume (Cv)')


figure (3)
plot(T,Gamma)
xlabel('Temperature (K)');ylabel('Gamma (Cp/Cv)')




