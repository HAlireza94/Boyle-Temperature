clc
clear
close all

format long

Tc=150.86;Pc=48.98;w=0.000;Zc=0.291; % Argon

% Tc=190.56;Pc=45.99200;w=0.011;Zc=0.2863; %Methane

% Tc=305.3;Pc=49;w=0.099;Zc=0.279; % Ethane

% Tc=369.9;Pc=42.5;w=0.153;Zc=0.276; % Propane

% Tc=425.12;Pc=37.96;w=0.2;Zc=0.274; % Butane

% Tc=469.7;Pc=33.7;w=0.252;Zc=0.270; % Pentane

% Tc=507.6;Pc=30.25;w=0.301;Zc=0.266; % Hexane

% Tc=540.2;Pc=27.4;w=0.350;Zc=0.261; % Heptane

% Tc=568.7;Pc=24.9;w=0.400;Zc=0.256; % Octane

% Tc=594.6;Pc=22.9;w=0.444;Zc=0.235; % Nonane

%   Tc=617.7;Pc=21.1;w=0.492;Zc=0.231; % Decane

% Tc=513;Pc=81;w=0.556;Zc=0.224; % Methanol

% Tc=647.13;Pc=220.55;w=0.34449;Zc=0.229; %Water

% Tc=304.2;Pc=73.8;w=0.239;Zc=0.274; % Carbon ioxid

% Tc=562;Pc=48.9;w=0.212;Zc=0.268; % Benzene

% Tc=405.65;Pc=112.8;w=0.2526;Zc=0.242; %Ammonia






P=1e-7;
% R=8.3144598;
R=83.14472;
a=(0.45724*(R^2)*(Tc^2))/Pc;b=(0.07780*R*Tc)/Pc;
k=0.37464+(1.54226*w)-(0.26992*w^2); % original 
c=(-0.252*((R*Tc)/Pc)*((1.5448*Zc)-0.4024));


x1=input('Enter lowe range of temperature, T1=');
x2=input('Enter uper range of temperature, T2=');


 T=linspace(x1,x2,5000)';
% T=[83.806 133.81 183.81 233.81 283.81 333.81 383.81 433.81 ...
% 483.81 533.81 583.81 633.81 683.81];
n=numel(T);

 
 x0=zeros(n,1);
for i=1:n
    
    
    x0(i)=(R*T(i))/P;
    
    
end


OF=zeros(n,1);
for i=1:n
    
     f=@(x) ((R*T(i))/(x+c-b))-((a*((1+(k*(1-((T(i)/Tc)^0.5))))^2))/((x+c)*(x+c+b)-(b*(x+c-b))))-P;
     
     OF(i)=fzero(f,x0(i)); % OF : Volume
%           OF(i)=fsolve(f,x0(i));
% OF(i)=fminsearch(f,x0(i))

end


Z=zeros(n,1);
F_B=zeros(n,1);
Helmholtz_Energy=zeros(n,1);
Internal_Energy=zeros(n,1);
Delta_Entropy=zeros(n,1);
Delta_Enthalpy=zeros(n,1);


for i=1:n
    
    Tr(i)=T(i)/Tc;
    
    
    Z(i)=(P*OF(i))/(R*T(i));
    alpha(i)=((1+(k*(1-((T(i)/Tc)^0.5))))^2); % Original

    A(i)=(a*alpha(i))/((R*T(i))^2);
    C(i)=((c*P)/(R*T(i)));
    B(i)=((b*P)/(R*T(i)));
    
    Delta_Enthalpy(i)=(R*T(i)*(Z(i)-1))+...
        (((a*(alpha(i)+(k*sqrt(Tr(i))*...
        sqrt(alpha(i)))))/(2*sqrt(2)*b))*...
    (log((OF(i)+c+((1-sqrt(2))*b))/(OF(i)+c+((1+sqrt(2))*b)))));

    Delta_Entropy(i)=(R*(log(Z(i)+C(i)-B(i))))-...
        (((((a*k*sqrt(Tr(i))*sqrt(alpha(i)))/T(i)))/(2*sqrt(2)*b))*...
        (log((OF(i)+c+((1+sqrt(2))*b))/(OF(i)+c+((1-sqrt(2))*b))))); % Original
    
    Internal_Energy(i)=(((a*(alpha(i)+(k*sqrt(Tr(i))*...
        sqrt(alpha(i)))))/(2*sqrt(2)*b))*...
    (log((OF(i)+c+((1-sqrt(2))*b))/(OF(i)+c+((1+sqrt(2))*b)))));

    Helmholtz_Energy(i)=(R*T(i)*(log(1/(Z(i)+C(i)-B(i)))))+(((((a*alpha(i)))/(2*sqrt(2)*b)))*...
        (log((OF(i)+c+((1-sqrt(2))*b))/(OF(i)+c+((1+sqrt(2))*b)))));

    
    
    
    F_B(i)=Delta_Enthalpy(i)/Delta_Entropy(i);
    
    
    
end






I=max(F_B);
disp('Objective Value, alpha=');disp(I);

Andis=find(F_B==I);
% [row,colm]=find(OBV==I)

T_Final=T(Andis);
disp('Temperature, T');disp(T_Final)

RH=Delta_Enthalpy(Andis);
RS=Delta_Entropy(Andis);

plot(T_Final,I,'ok',T,F_B)

legend({'Boyle Temperature','Ratio of Residual Enthalpy to Residual Entropy'})
