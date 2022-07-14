%% Clean workspace and close all
clear all;
clc;
close all;

%% Constraint for parameter
Vss_kmph_EV=130;                           %Velocity of Ego vehicle in kmph
Vss_mps_EV=Vss_kmph_EV/3.6;
AVlongdecEB=-7;
G=0;
SFDCarFW=3;
Vhwy_kmph_EV=130;
tpr=2.5;
SignF = -1;
amax=-7;

d1= abs((Vss_kmph_EV^2)/(254*((AVlongdecEB/9.81)+(G/100)))); 
TTTC = [];
FFHTI = [];
VVhwy_kmph_TV=[];
%% TTC calculation
for Vhwy_kmph_TV=60:5:130
Vss_mps_TV=Vhwy_kmph_TV*0.2778;
SD=SFDCarFW*0.2778*Vhwy_kmph_TV;
d2=0.278*Vhwy_kmph_TV*tpr;
s=SD+d1-d2;
a=-(9.81*(Vhwy_kmph_TV*Vhwy_kmph_TV/(254*s)-(G/100)));

TTC =(-Vss_mps_TV+sqrt(Vss_mps_TV^2+2*s*-a))/-a;
  
%% FHTI calculation
for j = 0.01 : 0.01 : TTC
    Dist_A =Vss_mps_TV*j+ 0.5 * -a * j^2;
    VV = Vss_mps_TV+(-a)*j;
    Dist_B = VV*j+0.5 * amax * j^2;
    if sign(((Dist_A + Dist_B) - s)) ~= sign(SignF)
        break;
    else
        signF = sign(((Dist_A + Dist_B) - s));
    end
end
FHTI = j;

TTTC=[TTTC TTC];
FFHTI=[FFHTI FHTI];
VVhwy_kmph_TV=[VVhwy_kmph_TV Vhwy_kmph_TV];
end

%% plots
figure(1);
plot(VVhwy_kmph_TV,TTTC);
grid on
xlabel('TV velocity in KMPH')
ylabel('Time-to-collision in sec');
hold on

f=gcf;
saveas(f,'freewayImproper_Decel_2_TTC.jpg');

figure(2);
plot(VVhwy_kmph_TV,FFHTI);
grid on
xlabel('TV velocity in KMPH')
ylabel('Fault Handling Time Interval in sec');
hold on

f=gcf;
saveas(f,'freewayImproper_Decel_2_FHTI.jpg');

%% excel write
x_speed=VVhwy_kmph_TV';
y_TTC=TTTC';
z_FHTI=FFHTI';
data={'Vehicle_Speed','TTC','FHTI'};
xlswrite('Functional_Safety_Scenarios',data,'freewayImproper_Decel_2','A1');
xlswrite('Functional_Safety_Scenarios',x_speed,'freewayImproper_Decel_2','A2');
xlswrite('Functional_Safety_Scenarios',y_TTC,'freewayImproper_Decel_2','B2');
xlswrite('Functional_Safety_Scenarios',z_FHTI,'freewayImproper_Decel_2','C2');

folder = pwd;
excelFileName = 'Functional_Safety_Scenarios.xls';
fullFileName = fullfile(folder, excelFileName);
objExcel = actxserver('Excel.Application');
objExcel.Visible = true;
ExcelWorkbook = objExcel.Workbooks.Open(fullFileName);
oSheet = objExcel.ActiveSheet;
imageFolder = fileparts(which('freewayImproper_Decel_2_TTC.jpg'));
imageFullFileName = fullfile(imageFolder, 'freewayImproper_Decel_2_TTC.jpg');
Shapes = oSheet.Shapes;
Shapes.AddPicture(imageFullFileName, 0, 1, 400, 20, 400, 300);

imageFolder1 = fileparts(which('freewayImproper_Decel_2_FHTI.jpg'));
imageFullFileName1 = fullfile(imageFolder, 'freewayImproper_Decel_2_FHTI.jpg');
Shapes.AddPicture(imageFullFileName1, 0, 1, 850, 20, 400, 300);

objExcel.DisplayAlerts = false;
ExcelWorkbook.SaveAs(fullFileName);
ExcelWorkbook.Close(false);
objExcel.Quit; 