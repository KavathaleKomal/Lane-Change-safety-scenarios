%% Clean workspace and close all
clear all;
clc;
close all;

%% Constraint for parameter
AVlongdecEB=-7;
SFDTrkFW=6.325;
G=-7;
VVhwy_kmph_EV=[];
FFTTI=[];
GG=[];
FFHTI=[];
AA=[];
d=130*0.2778*SFDTrkFW;

%% TTC calculation
for Vhwy_kmph_EV=110:5:130
    
    Vhwy_mps_EV=0.2778*Vhwy_kmph_EV;
    dummy=Vhwy_mps_EV;
    dT=0.01;
    AVlongdecEB=-7;
    alpha=abs(atan(G/100));
    gx=9.81*sin(alpha);
    amax=gx;
    K=0;
    Flag=false;
    Pos_EV=0;
    SignF=-1;
    Vhwy_kmph_TV=130;
    Vhwy_mps_TV=0.2778*Vhwy_kmph_TV;
while(Flag==false)
    %Target vehicle
    Vhwy_mps_TV=Vhwy_mps_TV+AVlongdecEB*dT;
    Vhwy_mps_TV=max(Vhwy_mps_TV,0);
    Pos_TV=Vhwy_mps_TV*dT;
    if (Vhwy_mps_TV>=0)
       Pos_TV_SD=d+Pos_TV;
    else 
        Pos_TV=0;
    end 
    
  %Ego vehicle
  Vhwy_mps_EV=Vhwy_mps_EV+amax*dT;
  Vhwy_mps_EV=max(Vhwy_mps_EV,0);
  Pos_EV=Pos_EV+Vhwy_mps_EV*dT;
  Diff_TV_EV=Pos_TV_SD-Pos_EV; 
  Diff_TV_EV=max(Diff_TV_EV,0);    
   if(Diff_TV_EV<=0 || Pos_TV==0 || Vhwy_mps_EV==0)
        Flag=true;
    end
    K=K+1;
end 
FTTI=K*dT;
FFTTI=[FFTTI FTTI];

%% FHTI calculation
 Vhwy_mps_EV=dummy;
    for j = 0.01 : 0.01 : FTTI
    Dist_A=Vhwy_mps_EV*j+(0.5*amax*j^2);
    VV = sqrt(Vhwy_mps_EV^2+(2*amax*Dist_A));
    Dist_B = VV*j+(0.5*AVlongdecEB*j^2);
    if sign(((Dist_A + Dist_B) - Pos_TV_SD)) ~= sign(SignF)
        break;
    else
        SignF = sign(((Dist_A + Dist_B) - Pos_TV_SD));
    end
  end
    
 FHTI=j;
 FFHTI=[FFHTI FHTI];
 AA=[AA amax];
 VVhwy_kmph_EV=[VVhwy_kmph_EV Vhwy_kmph_EV];
end

%% plots
figure(1);
plot(VVhwy_kmph_EV,FFHTI);
grid on
xlabel('EV velocity in KMPH')
ylabel('Fault Handling Time Interval in sec');
hold on

f=gcf;
saveas(f,'freeway_unable_to_decelerate_FHTI.jpg');

figure(2);
plot(VVhwy_kmph_EV,FFTTI);
grid on
xlabel('EV velocity in KMPH')
ylabel('Time-to-collision in sec');
hold on


f=gcf;
saveas(f,'freeway_unable_to_decelerate_TTC.jpg');

%% EXcel writing
x_speed=VVhwy_kmph_EV';
y_TTC=FFTTI';
z_FHTI=FFHTI';
data={'Vehicle_Speed','TTC','FHTI'};
xlswrite('Functional_Safety_Scenarios',data,'freeway_unable_to_decelerate','A1');
xlswrite('Functional_Safety_Scenarios',x_speed,'freeway_unable_to_decelerate','A2');
xlswrite('Functional_Safety_Scenarios',y_TTC,'freeway_unable_to_decelerate','B2');
xlswrite('Functional_Safety_Scenarios',z_FHTI,'freeway_unable_to_decelerate','C2');

folder = pwd;
excelFileName = 'Functional_Safety_Scenarios.xls';
fullFileName = fullfile(folder, excelFileName);
objExcel = actxserver('Excel.Application');
objExcel.Visible = true;
ExcelWorkbook = objExcel.Workbooks.Open(fullFileName);
oSheet = objExcel.ActiveSheet;
imageFolder = fileparts(which('freeway_unable_to_decelerate_TTC.jpg'));
imageFullFileName = fullfile(imageFolder, 'freeway_unable_to_decelerate_TTC.jpg');
Shapes = oSheet.Shapes;
Shapes.AddPicture(imageFullFileName, 0, 1, 400, 20, 400, 300);

imageFolder1 = fileparts(which('freeway_unable_to_decelerate_FHTI.jpg'));
imageFullFileName1 = fullfile(imageFolder, 'freeway_unable_to_decelerate_FHTI.jpg');
Shapes.AddPicture(imageFullFileName1, 0, 1, 850, 20, 400, 300);

objExcel.DisplayAlerts = false;
ExcelWorkbook.SaveAs(fullFileName);
ExcelWorkbook.Close(false);
objExcel.Quit; 

